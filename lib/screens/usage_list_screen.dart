import 'package:flutter/material.dart';
import '../models/usage.dart';
import '../models/stock_item.dart';
import '../services/local_repo.dart';

class UsageListScreen extends StatefulWidget {
  @override
  _UsageListScreenState createState() => _UsageListScreenState();
}

class _UsageListScreenState extends State<UsageListScreen> {
  List<Usage> usages = [];
  List<StockItem> items = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      usages = LocalRepo.instance.getUsages();
      items = LocalRepo.instance.getStockItems();
    });
  }

  void _addUsage() async {
    final selected = await showDialog<Usage>(
      context: context,
      builder: (c) {
        StockItem? chosen;
        final qtyCtrl = TextEditingController(text: '0');
        final personsCtrl = TextEditingController(text: '1');
        return StatefulBuilder(builder: (c2, setState2) {
          return AlertDialog(
            title: Text('Yeni Günlük Çıkış'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<StockItem>(
                    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                    onChanged: (v) => setState2(() => chosen = v),
                    hint: Text('Malzeme seçin'),
                  ),
                  SizedBox(height: 8),
                  TextField(controller: qtyCtrl, decoration: InputDecoration(labelText: 'Miktar'), keyboardType: TextInputType.number),
                  SizedBox(height: 8),
                  TextField(controller: personsCtrl, decoration: InputDecoration(labelText: 'Satış - kaç kişiye'), keyboardType: TextInputType.number),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(c).pop(), child: Text('İptal')),
              TextButton(
                onPressed: () {
                  if (chosen == null) return;
                  final qty = double.tryParse(qtyCtrl.text) ?? 0.0;
                  final persons = int.tryParse(personsCtrl.text) ?? 1;
                  final cost = qty * chosen!.unitPrice;
                  final usage = Usage(
                    date: DateTime.now(),
                    userEmail: 'admin@catering.com',
                    stockItemId: chosen!.id,
                    quantity: qty,
                    persons: persons,
                    cost: cost,
                  );
                  Navigator.of(c).pop(usage);
                },
                child: Text('Kaydet'),
              ),
            ],
          );
        });
      },
    );

    if (selected != null) {
      LocalRepo.instance.addUsage(selected);
      _refresh();
    }
  }

  void _editUsage(Usage usage) async {
    final item = items.firstWhere((e) => e.id == usage.stockItemId, orElse: () => StockItem.empty());

    final result = await showDialog<Usage>(
      context: context,
      builder: (c) {
        StockItem? chosen = item.isEmpty ? null : item;
        final qtyCtrl = TextEditingController(text: usage.quantity.toString());
        final personsCtrl = TextEditingController(text: usage.persons.toString());

        return StatefulBuilder(builder: (c2, setState2) {
          return AlertDialog(
            title: Text('Günlük Çıkışı Düzenle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<StockItem>(
                    value: chosen,
                    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                    onChanged: (v) => setState2(() => chosen = v),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: qtyCtrl,
                    decoration: InputDecoration(labelText: 'Miktar'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: personsCtrl,
                    decoration: InputDecoration(labelText: 'Satış - kaç kişiye'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(c).pop(), child: Text('İptal')),
              TextButton(
                onPressed: () {
                  if (chosen == null) return;
                  final qty = double.tryParse(qtyCtrl.text) ?? 0.0;
                  final persons = int.tryParse(personsCtrl.text) ?? 1;
                  final cost = qty * chosen!.unitPrice;

                  final updated = Usage(
                    id: usage.id,
                    date: usage.date,
                    userEmail: usage.userEmail,
                    stockItemId: chosen!.id,
                    quantity: qty,
                    persons: persons,
                    cost: cost,
                  );
                  Navigator.of(c).pop(updated);
                },
                child: Text('Kaydet'),
              ),
            ],
          );
        });
      },
    );

    if (result != null) {
      // Eski kaydı sileyip yeniyi ekle (stok indirmeden)
      _deleteUsageById(usage.id);
      // Direkt listeye ekle, stok indirmeden
      LocalRepo.instance.usages.add(result);
      LocalRepo.instance.saveToLocalStorage();
      _refresh();
    }
  }

  void _deleteUsage(Usage usage) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Sil'),
        content: Text('Bu kaydı silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(), child: Text('İptal')),
          TextButton(
            onPressed: () {
              _deleteUsageById(usage.id);
              Navigator.of(c).pop();
              _refresh();
            },
            child: Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteUsageById(String id) {
    final usage = LocalRepo.instance.usages.firstWhere((e) => e.id == id, orElse: () => Usage(date: DateTime.now(), userEmail: '', stockItemId: '', quantity: 0, persons: 0, cost: 0));
    
    // Silmeden önce stok geri ekle
    if (usage.stockItemId.isNotEmpty) {
      final item = LocalRepo.instance.getStockItems().firstWhere((e) => e.id == usage.stockItemId, orElse: () => StockItem.empty());
      if (!item.isEmpty) {
        item.quantity += usage.quantity;
      }
    }
    
    LocalRepo.instance.usages.removeWhere((e) => e.id == id);
    LocalRepo.instance.saveToLocalStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Günlük Çıkışlar')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: usages.isEmpty
            ? Center(child: Text('Henüz günlük çıkış kaydı yok.'))
            : ListView.builder(
                itemCount: usages.length,
                itemBuilder: (c, i) {
                  final u = usages[i];
                  final item = items.firstWhere((e) => e.id == u.stockItemId, orElse: () => StockItem.empty());
                  return Card(
                    child: ListTile(
                      title: Text(item.isEmpty ? 'Bilinmeyen' : item.name),
                      subtitle: Text('${u.quantity} ${item.unit} • ₺${u.cost.toStringAsFixed(2)} • ${u.persons} kişi'),
                      trailing: SizedBox(
                        width: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, size: 20),
                              onPressed: () => _editUsage(u),
                              constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _deleteUsage(u),
                              constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                            ),
                            Text('${u.date.day}/${u.date.month}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addUsage, child: Icon(Icons.add)),
    );
  }
}

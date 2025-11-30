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
                children: [
                  DropdownButtonFormField<StockItem>(
                    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                    onChanged: (v) => setState2(() => chosen = v),
                    hint: Text('Malzeme seçin'),
                  ),
                  TextField(controller: qtyCtrl, decoration: InputDecoration(labelText: 'Miktar'), keyboardType: TextInputType.number),
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
                      trailing: Text('${u.date.day}/${u.date.month}/${u.date.year}'),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addUsage, child: Icon(Icons.add)),
    );
  }
}

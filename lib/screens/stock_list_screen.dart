import 'package:flutter/material.dart';
import '../models/stock_item.dart';
import '../services/local_repo.dart';
import 'usage_list_screen.dart';
import 'reports_screen.dart';

class StockListScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const StockListScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  _StockListScreenState createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  List<StockItem> items = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      items = LocalRepo.instance.getStockItems();
    });
  }

  void _addItem() async {
    final result = await showDialog<StockItem>(
      context: context,
      builder: (c) {
        final nameCtrl = TextEditingController();
        final unitCtrl = TextEditingController(text: 'adet');
        final priceCtrl = TextEditingController(text: '0');
        final qtyCtrl = TextEditingController(text: '0');
        final suppCtrl = TextEditingController();
        return AlertDialog(
          title: Text('Yeni Stok Öğesi'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'İsim')),
                TextField(controller: unitCtrl, decoration: InputDecoration(labelText: 'Birim')),
                TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Birim Fiyat'), keyboardType: TextInputType.number),
                TextField(controller: qtyCtrl, decoration: InputDecoration(labelText: 'Miktar'), keyboardType: TextInputType.number),
                TextField(controller: suppCtrl, decoration: InputDecoration(labelText: 'Tedarikçi')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(c).pop(), child: Text('İptal')),
            TextButton(
              onPressed: () {
                final item = StockItem(
                  name: nameCtrl.text.trim(),
                  unit: unitCtrl.text.trim(),
                  unitPrice: double.tryParse(priceCtrl.text) ?? 0.0,
                  quantity: double.tryParse(qtyCtrl.text) ?? 0.0,
                  supplier: suppCtrl.text.trim(),
                );
                Navigator.of(c).pop(item);
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      LocalRepo.instance.addStockItem(result);
      _refresh();
    }
  }

  void _editItem(StockItem item) async {
    final result = await showDialog<StockItem>(
      context: context,
      builder: (c) {
        final nameCtrl = TextEditingController(text: item.name);
        final unitCtrl = TextEditingController(text: item.unit);
        final priceCtrl = TextEditingController(text: item.unitPrice.toString());
        final qtyCtrl = TextEditingController(text: item.quantity.toString());
        final suppCtrl = TextEditingController(text: item.supplier);
        return AlertDialog(
          title: Text('Stok Öğesini Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'İsim')),
                TextField(controller: unitCtrl, decoration: InputDecoration(labelText: 'Birim')),
                TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Birim Fiyat'), keyboardType: TextInputType.number),
                TextField(controller: qtyCtrl, decoration: InputDecoration(labelText: 'Miktar'), keyboardType: TextInputType.number),
                TextField(controller: suppCtrl, decoration: InputDecoration(labelText: 'Tedarikçi')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(c).pop(), child: Text('İptal')),
            TextButton(
              onPressed: () {
                final updated = StockItem(
                  id: item.id,
                  name: nameCtrl.text.trim(),
                  unit: unitCtrl.text.trim(),
                  unitPrice: double.tryParse(priceCtrl.text) ?? 0.0,
                  quantity: double.tryParse(qtyCtrl.text) ?? 0.0,
                  supplier: suppCtrl.text.trim(),
                );
                Navigator.of(c).pop(updated);
              },
              child: Text('Güncelle'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      LocalRepo.instance.updateStockItem(result);
      _refresh();
    }
  }

  void _deleteItem(StockItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Silme Onayı'),
        content: Text('${item.name} silinsin mi? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text('İptal')),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: Text('Sil', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      LocalRepo.instance.removeStockItem(item.id);
      _refresh();
    }
  }

  void _openUsages() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => UsageListScreen()));
  }

  void _openReports() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stok Kartları'),
        actions: [
          IconButton(onPressed: _openUsages, icon: Icon(Icons.list_alt)),
          IconButton(onPressed: _openReports, icon: Icon(Icons.pie_chart_outline)),
          IconButton(onPressed: widget.onLogout, icon: Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: items.isEmpty
            ? Center(child: Text('Henüz stok öğesi yok. + ile ekleyin.'))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (c, i) {
                  final it = items[i];
                  return Card(
                    child: ListTile(
                      title: Text(it.name),
                      subtitle: Text('${it.quantity} ${it.unit} • ₺${it.unitPrice.toStringAsFixed(2)} / ${it.unit}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') _editItem(it);
                          if (v == 'delete') _deleteItem(it);
                        },
                        itemBuilder: (c) => [
                          PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                          PopupMenuItem(value: 'delete', child: Text('Sil', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/local_repo.dart';
import '../models/stock_item.dart';
import '../models/usage.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Usage> usages = [];
  List<StockItem> items = [];

  @override
  void initState() {
    super.initState();
    usages = LocalRepo.instance.getUsages();
    items = LocalRepo.instance.getStockItems();
  }

  Map<String, double> _aggregateCostPerItem() {
    final Map<String, double> map = {};
    for (final u in usages) {
      map[u.stockItemId] = (map[u.stockItemId] ?? 0) + u.cost;
    }
    return map;
  }

  double _totalCost() => usages.fold(0.0, (p, u) => p + u.cost);
  int _totalPersons() => usages.fold(0, (p, u) => p + u.persons);

  @override
  Widget build(BuildContext context) {
    final agg = _aggregateCostPerItem();
    return Scaffold(
      appBar: AppBar(title: Text('Raporlar')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: Text('Toplam Maliyet'),
                trailing: Text('₺${_totalCost().toStringAsFixed(2)}'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Toplam Satışta Kişi Sayısı'),
                trailing: Text('${_totalPersons()}'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Kişi Başına Maliyet (ortalama)'),
                trailing: Text(_totalPersons() > 0 ? '₺${(_totalCost() / _totalPersons()).toStringAsFixed(2)}' : '—'),
              ),
            ),
            SizedBox(height: 12),
            Text('Malzeme Bazlı Dağılım', style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: agg.entries.map((e) {
                  final item = items.firstWhere((it) => it.id == e.key, orElse: () => StockItem.empty());
                  return Card(
                    child: ListTile(
                      title: Text(item.isEmpty ? 'Bilinmeyen' : item.name),
                      subtitle: Text(item.isEmpty ? '' : '${item.unit} • Stoğu: ${item.quantity}'),
                      trailing: Text('₺${e.value.toStringAsFixed(2)}'),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

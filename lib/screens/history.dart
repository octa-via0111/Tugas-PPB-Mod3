import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/app_state.dart';
import 'detail.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    return '$day/$month/$year $hour:$minute:$second';
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hard Delete Riwayat'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus seluruh riwayat penelusuran secara permanen? Data yang dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _appState.clearHistory();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua riwayat telah dihapus secara permanen (Hard Delete)'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = _appState.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penelusuran'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Hard Delete Semua Riwayat',
              onPressed: _confirmClearAll,
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Riwayat penelusuran kosong',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Negara yang Anda buka akan tercatat di sini',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.blue.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Riwayat: ${history.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: _confirmClearAll,
                        icon: const Icon(Icons.delete_forever, size: 18, color: Colors.red),
                        label: const Text(
                          'Hard Delete Semua',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final Country country = item.country;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: ListTile(
                          leading: country.flagsPng != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    country.flagsPng!,
                                    width: 48,
                                    height: 30,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.flag, size: 30),
                                  ),
                                )
                              : const Icon(Icons.flag, size: 30),
                          title: Text(
                            country.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Benua: ${country.region}'),
                              Text(
                                'Dilihat pada: ${_formatTimestamp(item.timestamp)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            tooltip: 'Hard Delete Item Ini',
                            onPressed: () {
                              _appState.deleteHistoryItem(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Riwayat ${country.name} dihapus'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPage(country: country),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

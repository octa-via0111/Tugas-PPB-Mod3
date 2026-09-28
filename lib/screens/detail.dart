import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/app_state.dart';

class DetailPage extends StatefulWidget {
  final Country country;

  const DetailPage({super.key, required this.country});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    // Record visit to history automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appState.addToHistory(widget.country);
    });
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

  @override
  Widget build(BuildContext context) {
    final country = widget.country;
    final isFav = _appState.isFavorite(country);

    return Scaffold(
      appBar: AppBar(
        title: Text(country.name),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : null,
            ),
            tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
            onPressed: () {
              _appState.toggleFavorite(country);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFav
                        ? '${country.name} dihapus dari favorit'
                        : '${country.name} ditambahkan ke favorit',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (country.flagsPng != null)
              Center(
                child: Image.network(country.flagsPng!, width: 200),
              ),
            const SizedBox(height: 16),
            Text(
              'Name: ${country.name}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Capital: ${country.capital ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Region: ${country.region}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Population: ${country.population}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Languages: ${country.languages?.join(', ') ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Currencies: ${country.currencies?.join(', ') ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
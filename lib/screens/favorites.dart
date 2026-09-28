import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/app_state.dart';
import 'detail.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
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

  @override
  Widget build(BuildContext context) {
    final favorites = _appState.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Negara Favorit'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada negara favorit',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tekan ikon hati pada negara untuk menambahkan',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final Country country = favorites[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: ListTile(
                    leading: country.flagsPng != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              country.flagsPng!,
                              width: 50,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.flag, size: 32),
                            ),
                          )
                        : const Icon(Icons.flag, size: 32),
                    title: Text(
                      country.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${country.region} • Populasi: ${country.population}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      tooltip: 'Hapus dari Favorit',
                      onPressed: () {
                        _appState.toggleFavorite(country);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${country.name} dihapus dari favorit'),
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
    );
  }
}

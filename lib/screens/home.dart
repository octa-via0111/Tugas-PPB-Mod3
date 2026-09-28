import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../models/country.dart';
import '../services/app_state.dart';
import 'detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Country>> countriesFuture;
  final TextEditingController _searchController = TextEditingController();
  final AppState _appState = AppState();

  String _searchQuery = '';
  String _selectedRegion = 'Semua';
  String _sortOption = 'continent_asc'; // continent_asc, continent_desc, name_asc, name_desc

  final List<String> _regions = [
    'Semua',
    'Africa',
    'Americas',
    'Asia',
    'Europe',
    'Oceania',
    'Antarctic'
  ];

  @override
  void initState() {
    super.initState();
    countriesFuture = fetchCountries();
    _appState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _appState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<Country>> fetchCountries() async {
    final uri = Uri.parse('https://www.apicountries.com/countries');
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();

    if (response.statusCode == 200) {
      final respBody = await response.transform(utf8.decoder).join();
      final List jsonData = jsonDecode(respBody);
      return jsonData.map((j) => Country.fromJson(j)).toList();
    } else {
      throw Exception('Gagal memuat data negara: ${response.statusCode}');
    }
  }

  List<Country> _filterAndSortCountries(List<Country> list) {
    // 1. Filter by Search Query
    List<Country> filtered = list.where((c) {
      final matchesName = c.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRegion = c.region.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCapital = (c.capital ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesName || matchesRegion || matchesCapital;
    }).toList();

    // 2. Filter by Selected Region / Benua
    if (_selectedRegion != 'Semua') {
      filtered = filtered
          .where((c) => c.region.toLowerCase() == _selectedRegion.toLowerCase())
          .toList();
    }

    // 3. Sorting based on option (including Benua / Continent)
    filtered.sort((a, b) {
      switch (_sortOption) {
        case 'continent_asc':
          final comp = a.region.compareTo(b.region);
          if (comp != 0) return comp;
          return a.name.compareTo(b.name);
        case 'continent_desc':
          final comp = b.region.compareTo(a.region);
          if (comp != 0) return comp;
          return a.name.compareTo(b.name);
        case 'name_asc':
          return a.name.compareTo(b.name);
        case 'name_desc':
          return b.name.compareTo(a.name);
        case 'population_desc':
          return b.population.compareTo(a.population);
        default:
          return a.name.compareTo(b.name);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Negara'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          // Sorting Popup Button (Tugas 4: Sorting Benua & Nama)
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Urutkan Negara',
            onSelected: (String value) {
              setState(() {
                _sortOption = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'continent_asc',
                child: Row(
                  children: [
                    Icon(Icons.public, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Benua (A - Z)'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'continent_desc',
                child: Row(
                  children: [
                    Icon(Icons.public_off, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Benua (Z - A)'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'name_asc',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Nama Negara (A - Z)'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'name_desc',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Nama Negara (Z - A)'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'population_desc',
                child: Row(
                  children: [
                    Icon(Icons.groups, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Populasi Terbanyak'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Country>>(
        future: countriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 12),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        countriesFuture = fetchCountries();
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data negara'));
          }

          final rawList = snapshot.data!;
          final list = _filterAndSortCountries(rawList);

          return Column(
            children: [
              // Search Bar (Tugas 3)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari negara atau benua...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Filter Chips for Region / Benua
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _regions.length,
                  itemBuilder: (context, index) {
                    final region = _regions[index];
                    final isSelected = _selectedRegion == region;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FilterChip(
                        label: Text(region),
                        selected: isSelected,
                        selectedColor: Colors.blue.shade100,
                        checkmarkColor: Colors.blueAccent,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedRegion = region;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Active Sorting & Count Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Menampilkan ${list.length} negara',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.sort, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _getSortLabel(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // List of Countries
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 60, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ditemukan negara yang sesuai',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final country = list[i];
                          final isFav = _appState.isFavorite(country);

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                              subtitle: Text('Benua: ${country.region}'),
                              trailing: IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  _appState.toggleFavorite(country);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isFav
                                            ? '${country.name} dihapus dari favorit'
                                            : '${country.name} ditambahkan ke favorit',
                                      ),
                                      duration: const Duration(seconds: 1),
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
          );
        },
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortOption) {
      case 'continent_asc':
        return 'Benua (A-Z)';
      case 'continent_desc':
        return 'Benua (Z-A)';
      case 'name_asc':
        return 'Nama (A-Z)';
      case 'name_desc':
        return 'Nama (Z-A)';
      case 'population_desc':
        return 'Populasi';
      default:
        return 'Benua (A-Z)';
    }
  }
}
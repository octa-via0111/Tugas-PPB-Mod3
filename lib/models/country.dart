class Country {
  final String name;
  final String region;
  final String? capital;
  final int population;
  final String? flagsPng;
  final List<String>? languages;
  final List<String>? currencies;

  Country({
    required this.name,
    required this.region,
    required this.population,
    this.capital,
    this.flagsPng,
    this.languages,
    this.currencies,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    List<String>? langs;
    if (json['languages'] != null && json['languages'] is List) {
      langs = (json['languages'] as List)
          .map((l) => l is Map ? (l['name']?.toString() ?? '') : l.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    List<String>? cur;
    if (json['currencies'] != null && json['currencies'] is List) {
      cur = (json['currencies'] as List)
          .map((c) => c is Map ? (c['name']?.toString() ?? '') : c.toString())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    String? flag;
    if (json['flags'] != null && json['flags'] is Map) {
      flag = json['flags']['png']?.toString();
    } else if (json['flagsPng'] != null) {
      flag = json['flagsPng'].toString();
    }

    return Country(
      name: json['name']?.toString() ?? 'N/A',
      region: json['region']?.toString() ?? 'N/A',
      population: json['population'] is int
          ? json['population'] as int
          : int.tryParse(json['population']?.toString() ?? '0') ?? 0,
      capital: json['capital']?.toString(),
      flagsPng: flag,
      languages: langs,
      currencies: cur,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'region': region,
      'capital': capital,
      'population': population,
      'flagsPng': flagsPng,
      'languages': languages,
      'currencies': currencies,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          region == other.region;

  @override
  int get hashCode => name.hashCode ^ region.hashCode;
}

class HistoryItem {
  final Country country;
  final DateTime timestamp;

  HistoryItem({
    required this.country,
    required this.timestamp,
  });
}

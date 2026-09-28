import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onHomeTap;

  const ProfilePage({super.key, this.onHomeTap});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<Map<String, String>> teamMembers = [
    {'Nama': 'Aisha Alida Putri', 'NIM': '21120124130082'},
    {'Nama': 'Oktavia Damayanti', 'NIM': '21120124120025'},
    {'Nama': 'Rizkia Rahman', 'NIM': '21120124130086'},
    {'Nama': 'Shata\' Hibrizi Al Fa\'iq', 'NIM': '21120123130066'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 13, 105, 225),
        foregroundColor: Colors.white,
        actions: [
          if (widget.onHomeTap != null)
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: widget.onHomeTap,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Background cover: Gedung Teknik Komputer
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      image: AssetImage('assets/images/gedung_tekkom.png'),
                    ),
                  ),
                ),
                // Circular Avatar Photo
                Positioned(
                  bottom: -50,
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/foto_kelompok.jpg'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 65.0),
            // Group Members List (Nama & NIM)
            for (var member in teamMembers)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  children: [
                    Text(
                      member['Nama'] ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      member['NIM'] ?? 'No NIM',
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

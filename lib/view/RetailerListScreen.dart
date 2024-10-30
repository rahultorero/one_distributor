// lib/presentation/screens/retailer_list_screen.dart
import 'package:flutter/material.dart';

class Retailer {
  final String id;
  final String partyStoreName;
  final String retailerName;
  final String address;
  final String area;
  final String city;
  final String mobile;
  final String telephone;
  final String email;
  final String licenseNumber;
  final String gstNumber;

  Retailer({
    required this.id,
    required this.partyStoreName,
    required this.retailerName,
    required this.address,
    required this.area,
    required this.city,
    required this.mobile,
    required this.telephone,
    required this.email,
    required this.licenseNumber,
    required this.gstNumber,
  });
}



class RetailerListScreen extends StatelessWidget {
  const RetailerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SearchHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 10, // Replace with actual data length
                itemBuilder: (context, index) {
                  return const RetailerCard();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'MAPPED RETAILER',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('SANGLI MEDICAL HUB LLP'),
                      ),
                      items: [], onChanged: (String? value) {  },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class RetailerCard extends StatelessWidget {
  const RetailerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'A.J.MEDICAL;V.B SANGLI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('ADDRESS:', 'C.NO.8849,SHOP NO.1,GROUND FLOOR'),
                      _buildInfoRow('AREA:', 'SANJAYNAGAR'),
                      _buildInfoRow('MOBILE:', '9764584665'),
                      _buildInfoRow('EMAIL:', '-'),
                      _buildInfoRow('GST NUMBER:', '-'),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red[100],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
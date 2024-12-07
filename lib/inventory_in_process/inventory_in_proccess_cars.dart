import 'dart:convert'; // For jsonDecode
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_website/inventory_in_process/inventory_in_process_screen.dart';

class InventoryInProcessCars extends StatelessWidget {
  const InventoryInProcessCars({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cars').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No cars available.'),
            );
          }

          final cars = snapshot.data!.docs
              .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['collectionId'] = doc.id;

            // Check if repair or govCosts lists are empty
            bool hasRepairs = (data['repair'] ?? []).isNotEmpty;
            bool hasGovCosts = (data['govCosts'] ?? []).isNotEmpty;

            // Only include the car if it has repairs or governmental costs and is not sold
            bool isSold = data['isSold'] ?? false;
            if ((hasRepairs || hasGovCosts) && !isSold) {
              return {
                'type': data['carType'] ?? 'Unknown',
                'id': data['carId'] ?? 'No ID',
                'image': data['images'] != null
                    ? Uint8List.fromList(
                    List<int>.from(jsonDecode(data['images'].first)))
                    : null,
                'createdAt': data['createdAt'] ?? 'Unknown',
                'data': data,
              };
            } else {
              return null;
            }
          })
              .where((car) => car != null)
              .toList();


          // Group cars by date
          final groupedCars = <String, List<Map<String, dynamic>>>{};
          for (var car in cars) {
            String date = DateFormat('yyyy/MM/dd').format(
              DateTime.parse(car!['createdAt']),
            );
            if (!groupedCars.containsKey(date)) {
              groupedCars[date] = [];
            }
            groupedCars[date]!.add(car);
          }

          bool width = MediaQuery.of(context).size.width < 600;

          return groupedCars.isNotEmpty
              ? SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: groupedCars.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Wrap(
                      runSpacing: 8.0,
                      children: entry.value
                          .map((car) => _buildCarCard(car, context))
                          .toList(),
                    ),
                  ],
                );
              }).toList(),
            ),
          )
              : const Center(
            child: Text('No cars available'),
          );
        },
      ),
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => InventoryInProcess(
                  data: car['data'],
                )));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0,
        child: SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12.0)),
                  image: car['image'] != null
                      ? DecorationImage(
                    image: MemoryImage(car['image']),
                    fit: BoxFit.cover,
                  )
                      : null,
                  color: car['image'] == null ? Colors.grey : null,
                ),
                child: car['image'] == null
                    ? const Center(
                  child: Text(
                    'No Image',
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : null,
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  car['type'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  car['id'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

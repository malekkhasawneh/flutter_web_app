import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryInProcess extends StatelessWidget {
  const InventoryInProcess({Key? key, required this.data}) : super(key: key);
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory in Process'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarDetails() {
    // Get repairs and government costs from data
    final List<dynamic> repairs = data['repair'] ?? [];
    final List<dynamic> governmentalCosts = data['govCosts'] ?? [];

    // Calculate total costs for repairs and government costs
    final num totalRepairCost = repairs.fold<num>(
      0,
      (sum, repair) => sum + (int.tryParse(repair['cost'] ?? '0') ?? 0),
    );

    final num totalGovCost = governmentalCosts.fold<num>(
      0,
      (sum, cost) => sum + (int.tryParse(cost['cost'] ?? '0') ?? 0),
    );

    // Format the date using the intl package
    final DateFormat dateFormat = DateFormat('yyyy/MM/dd hh:mm a');
    final String formattedDate =
        dateFormat.format(DateTime.parse(data['createdAt']));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Car Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            // Image list (horizontal scroll)
            SizedBox(
              height: 150.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data['images']?.length ?? 0,
                itemBuilder: (context, index) {
                  final imageData = data['images'][index];
                  final imageBytes = imageData != null
                      ? Uint8List.fromList(
                          List<int>.from(jsonDecode(imageData)))
                      : null;

                  return Container(
                    width: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: imageBytes != null
                        ? Image.memory(imageBytes) // Display the image
                        : const Placeholder(), // Fallback in case image is null
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Text('Model: ${data['carModel'] ?? 'Unknown'}'),
            Text('Type: ${data['carType'] ?? 'Unknown'}'),
            Text('Color: ${data['carColor'] ?? 'Unknown'}'),
            Text('ID: ${data['carId'] ?? 'Unknown'}'),
            Text('Employee: ${data['employeeName'] ?? 'Unknown'}'),
            /*Text('Purchase Price: ${data['purchasePrice'] ?? '0'} JD'),
            Text(
                'Expected Selling Price: ${data['expectedSellingPrice'] ?? '0'} JD'),
            Text('Expected Cost: ${data['expectedCost'] ?? '0'} JD'),*/
            Text('Created At: $formattedDate'),
            const SizedBox(height: 16.0),
            const Text(
              'Repairs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (repairs.isNotEmpty)
              ...repairs.map<Widget>((repair) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('${repair['type']} - ${repair['cost']} JD'),
                );
              }).toList()
            else
              const Text('No repairs available.'),
            const SizedBox(height: 8.0),
            Text('Total Repair Cost: ${totalRepairCost} JD',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 16.0),
            const Text(
              'Governmental Costs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (governmentalCosts.isNotEmpty)
              ...governmentalCosts.map<Widget>((cost) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('${cost['name']} - ${cost['cost']} JD'),
                );
              }).toList()
            else
              const Text('No governmental costs available.'),
            const SizedBox(height: 8.0),
            Text('Total Governmental Cost: ${totalGovCost} JD',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

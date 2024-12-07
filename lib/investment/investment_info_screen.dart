import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvestmentInfoScreen extends StatelessWidget {
  const InvestmentInfoScreen({Key? key, required this.data}) : super(key: key);
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${data['carType']} ${data['carModel']} investment info'),
        
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarDetails(),
            const SizedBox(height: 16.0),
            _buildSellingInfo(),
            const SizedBox(height: 16.0),
            _buildAfterSellingInfo(),
            const SizedBox(height: 16.0),
            _buildROISection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarDetails() {
    final List<dynamic> repairs = data['repair'] ?? [];
    final List<dynamic> governmentalCosts = data['govCosts'] ?? [];

    final num totalRepairCost = repairs.fold<num>(
      0,
          (sum, repair) => sum + (int.tryParse(repair['cost'] ?? '0') ?? 0),
    );

    final num totalGovCost = governmentalCosts.fold<num>(
      0,
          (sum, cost) => sum + (int.tryParse(cost['cost'] ?? '0') ?? 0),
    );

    final DateFormat dateFormat = DateFormat('yyyy/MM/dd hh:mm a');
    final String formattedDate =
    dateFormat.format(DateTime.parse(data['createdAt']));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Car Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
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
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Placeholder(),
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
            Text('Purchase Price: ${data['purchasePrice'] ?? '0'} JD'),
            Text('Paid Price: ${data['paidPrice'] ?? '0'} JD'),
            Text(
                'Expected Selling Price: ${data['expectedSellingPrice'] ?? '0'} JD'),
            Text('Expected Cost: ${data['expectedCost'] ?? '0'} JD'),
            Text('Created At: $formattedDate'),
            const SizedBox(height: 16.0),
            _buildCostsSection('Repairs', repairs, totalRepairCost),
            const SizedBox(height: 16.0),
            _buildCostsSection(
                'Governmental Costs', governmentalCosts, totalGovCost),
          ],
        ),
      ),
    );
  }

  Widget _buildCostsSection(String title, List<dynamic> items, num totalCost) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        if (items.isNotEmpty)
          ...items.map<Widget>((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child:
              Text('${item['type'] ?? item['name']} - ${item['cost']} JD'),
            );
          }).toList()
        else
          const Text('No data available.'),
        const SizedBox(height: 8.0),
        Text('Total $title Cost: $totalCost JD',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildSellingInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selling Info',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text('Selling Price: ${data['sellingPrice'] ?? 'Unknown'} JD'),
            Text('Buyer Name: ${data['buyerName'] ?? 'Unknown'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAfterSellingInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'After Selling Info',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              data['afterSellingInfo'] ?? 'No information provided.',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildROISection() {
    final sellingPrice = double.tryParse(data['sellingPrice'] ?? '0') ?? 0;
    final totalGovCosts = double.tryParse(data['totalGovCosts']?.toString() ?? '0') ?? 0;
    final totalRepairs = double.tryParse(data['totalRepairs']?.toString() ?? '0') ?? 0;
    final purchasePrice = double.tryParse(data['purchasePrice'] ?? '0') ?? 0;

    final roi = purchasePrice > 0
        ? (((sellingPrice - totalGovCosts - totalRepairs - purchasePrice) /
        purchasePrice) *
        100)
        : 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Return on Investment (ROI)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text('ROI: ${roi.toStringAsFixed(2)}%',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

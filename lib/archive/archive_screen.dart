import 'dart:convert'; // For jsonDecode
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_website/archive/add_archive_screen.dart';
import 'package:todo_website/archive/archive_info_screen.dart';
import 'package:todo_website/home/cubit/home_cubit.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isEnglish = HomeCubit.get(context).en;
        return Scaffold(
          appBar: AppBar(
            title: Text(isEnglish ? 'Archive' : 'الأرشيف'),
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
                return Center(
                  child: Text(isEnglish
                      ? 'No cars available.'
                      : 'لا توجد سيارات متوفرة.'),
                );
              }

              final cars = snapshot.data!.docs
                  .map((doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    data['collectionId'] = doc.id;

                    // Check if repair or govCosts lists are empty
                    bool hasRepairs = (data['repair'] ?? []).isNotEmpty;
                    bool hasGovCosts = (data['govCosts'] ?? []).isNotEmpty;

                    // Only include the car if it has repairs or governmental costs
                    if (hasRepairs || hasGovCosts) {
                      return {
                        'type': data['carType'] ??
                            (isEnglish ? 'Unknown' : 'غير معروف'),
                        'id':
                            data['carId'] ?? (isEnglish ? 'No ID' : 'بدون رقم'),
                        'image': data['images'] != null
                            ? Uint8List.fromList(List<int>.from(
                                jsonDecode(data['images'].first)))
                            : null,
                        'isSold': data['isSold'] ?? false,
                        'createdAt': data['createdAt'] ?? 'Unknown',
                        'data': data,
                      };
                    } else {
                      return null;
                    }
                  })
                  .where((car) => car != null)
                  .toList();

              // Group cars by `createdAt` date
              final groupedCars = <String, List<Map<String, dynamic>>>{};
              for (var car in cars) {
                String date = car!['createdAt'] != 'Unknown'
                    ? DateFormat('yyyy/MM/dd').format(
                        DateTime.parse(car['createdAt']),
                      )
                    : (isEnglish ? 'Unknown Date' : 'تاريخ غير معروف');
                if (!groupedCars.containsKey(date)) {
                  groupedCars[date] = [];
                }
                groupedCars[date]!.add(car);
              }

              // Sort groups by date in descending order
              final sortedGroupKeys = groupedCars.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return sortedGroupKeys.isNotEmpty
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: sortedGroupKeys.map((date) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Wrap(
                                runSpacing: 8.0,
                                children: groupedCars[date]!
                                    .map((car) =>
                                        _buildCarCard(car, context, isEnglish))
                                    .toList(),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  : Center(
                      child: Text(isEnglish
                          ? 'No cars available.'
                          : 'لا توجد سيارات متوفرة.'),
                    );
            },
          ),
        );
      },
    );
  }

  Widget _buildCarCard(
      Map<String, dynamic> car, BuildContext context, bool isEnglish) {
    // Determine the border color based on the `isSold` field
    final borderColor = car['isSold'] ? Colors.red : Colors.green;
    final statusText = car['isSold']
        ? (isEnglish ? "Sold" : "تم البيع")
        : (isEnglish ? "Available" : "متوفر");
    final statusColor = car['isSold'] ? Colors.red : Colors.green;

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => car['isSold']
                    ? ArchiveInfoScreen(data: car['data'])
                    : AddArchiveScreen(
                        data: car['data'],
                      )));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
              color: borderColor, width: 2.0), // Set the border color here
        ),
        elevation: 4.0,
        child: SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
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
                    ? Center(
                        child: Text(
                          isEnglish ? 'No Image' : 'لا توجد صورة',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    : null,
              ),

              // Status Badge: Sold or Not Sold
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12.0)),
                ),
                child: Center(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8.0),

              // Car Type
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

              // Car ID
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

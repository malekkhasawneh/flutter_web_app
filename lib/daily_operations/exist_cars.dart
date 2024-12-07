import 'dart:convert'; // For jsonDecode
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_website/daily_operations/add_daily_operation_screen.dart';
import 'package:todo_website/home/cubit/home_cubit.dart';

class CarCardsScreen extends StatelessWidget {
  const CarCardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isEnglish = HomeCubit.get(context).en;
        return Scaffold(
          appBar: AppBar(
            title: Text(isEnglish ? 'Operations' : 'العمليات'),
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

              // Group cars by date
              final Map<String, List<Map<String, dynamic>>> groupedCars = {};
              for (var doc in snapshot.data!.docs) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                String date = DateFormat('yyyy/MM/dd').format(
                  DateTime.parse(data['createdAt']),
                );

                if (!groupedCars.containsKey(date)) {
                  groupedCars[date] = [];
                }
                data['collectionId'] = doc.id;
                if (!data['isSold'] ?? false) {
                  groupedCars[date]!.add({
                    'type': data['carType'] ?? (isEnglish ? 'Unknown' : 'غير معروف'),
                    'id': data['carId'] ?? (isEnglish ? 'No ID' : 'بدون رقم'),
                    'image': data['images'] != null
                        ? Uint8List.fromList(
                        List<int>.from(jsonDecode(data['images'].first)))
                        : null,
                    'data': data,
                  });
                }
                if (groupedCars[date]!.isEmpty) {
                  groupedCars.remove(date);
                }
              }

              // Sort the dates
              final sortedDates = groupedCars.keys.toList()
                ..sort((a, b) => b.compareTo(a)); // Descending order

              return sortedDates.isEmpty
                  ? Center(
                child: Text(isEnglish
                    ? 'No cars available'
                    : 'لا توجد سيارات متوفرة'),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final cars = groupedCars[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Cars under this date
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: cars
                            .map((car) => _buildCarCard(car, context, isEnglish))
                            .toList(),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCarCard(
      Map<String, dynamic> car, BuildContext context, bool isEnglish) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddDailyOperationsScreen(data: car['data']),
          ),
        );
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
                    ? Center(
                  child: Text(
                    isEnglish ? 'No Image' : 'لا توجد صورة',
                    style: const TextStyle(color: Colors.white),
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

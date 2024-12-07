import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_website/home/cubit/home_cubit.dart';

class ArchiveInfoScreen extends StatelessWidget {
  const ArchiveInfoScreen({Key? key, required this.data}) : super(key: key);
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isEnglish = HomeCubit.get(context).en;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              isEnglish ? 'Inventory in Process' : 'المخزون قيد التنفيذ',
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCarDetails(isEnglish),
                const SizedBox(height: 16.0),
                _buildSellingInfo(isEnglish),
                const SizedBox(height: 16.0),
                _buildAfterSellingInfo(isEnglish),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarDetails(bool isEnglish) {
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
            Text(
              isEnglish ? 'Car Details' : 'تفاصيل السيارة',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    List<int>.from(jsonDecode(imageData)),
                  )
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
            Text('${isEnglish ? "Model" : "الموديل"}: ${data['carModel'] ?? (isEnglish ? 'Unknown' : 'غير معروف')}'),
            Text('${isEnglish ? "Type" : "النوع"}: ${data['carType'] ?? (isEnglish ? 'Unknown' : 'غير معروف')}'),
            Text('${isEnglish ? "Color" : "اللون"}: ${data['carColor'] ?? (isEnglish ? 'Unknown' : 'غير معروف')}'),
            Text('${isEnglish ? "ID" : "المعرف"}: ${data['carId'] ?? (isEnglish ? 'Unknown' : 'غير معروف')}'),
            Text('${isEnglish ? "Employee" : "الموظف"}: ${data['employeeName'] ?? (isEnglish ? 'Unknown' : 'غير معروف')}'),
            Text('${isEnglish ? "Purchase Price" : "سعر الشراء"}: ${data['purchasePrice'] ?? '0'} JD'),
            Text('${isEnglish ? "Expected Selling Price" : "سعر البيع المتوقع"}: ${data['expectedSellingPrice'] ?? '0'} JD'),
            Text('${isEnglish ? "Expected Cost" : "التكلفة المتوقعة"}: ${data['expectedCost'] ?? '0'} JD'),
            Text('${isEnglish ? "Created At" : "تاريخ الإنشاء"}: $formattedDate'),
            const SizedBox(height: 16.0),
            _buildCostsSection(
              isEnglish ? 'Repairs' : 'الإصلاحات',
              repairs,
              totalRepairCost,
              isEnglish,
            ),
            const SizedBox(height: 16.0),
            _buildCostsSection(
              isEnglish ? 'Governmental Costs' : 'التكاليف الحكومية',
              governmentalCosts,
              totalGovCost,
              isEnglish,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostsSection(
      String title,
      List<dynamic> items,
      num totalCost,
      bool isEnglish,
      ) {
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
              child: Text(
                '${item['type'] ?? item['name']} - ${item['cost']} JD',
              ),
            );
          }).toList()
        else
          Text(isEnglish ? 'No data available.' : 'لا توجد بيانات.'),
        const SizedBox(height: 8.0),
        Text(
          '${isEnglish ? "Total" : "إجمالي"} $title: $totalCost JD',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSellingInfo(bool isEnglish) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEnglish ? 'Selling Info' : 'معلومات البيع',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text('${isEnglish ? "Selling Price" : "سعر البيع"}: ${data['sellingPrice'] ?? (isEnglish ? 'Unknown' : 'غير معروف')} JD'),
            Text('${isEnglish ? "Buyer Name" : "اسم المشتري"}: ${data['buyerName'] ?? (isEnglish ? 'Unknown' : 'غير معروف')}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAfterSellingInfo(bool isEnglish) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEnglish ? 'After Selling Info' : 'معلومات ما بعد البيع',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              data['afterSellingInfo'] ??
                  (isEnglish ? 'No information provided.' : 'لا توجد معلومات.'),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

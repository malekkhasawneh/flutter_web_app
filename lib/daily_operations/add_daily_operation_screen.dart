import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_website/home/cubit/home_cubit.dart';

class AddDailyOperationsScreen extends StatefulWidget {
  const AddDailyOperationsScreen({Key? key, required this.data})
      : super(key: key);
  final Map<String, dynamic> data;

  @override
  State<AddDailyOperationsScreen> createState() =>
      _AddDailyOperationsScreenState();
}

class _AddDailyOperationsScreenState extends State<AddDailyOperationsScreen> {
  List<Map<String, String>> repairs = [];
  List<Map<String, String>> governmentalCosts = [];

  final TextEditingController repairTypeController = TextEditingController();
  final TextEditingController repairCostController = TextEditingController();

  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController serviceCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    log('============================ vvv ${widget.data['repair']}');

    // Use null-aware operator and check for null
    repairs = (widget.data['repair'] ?? []).isNotEmpty
        ? (widget.data['repair'] as List<dynamic>)
            .map((item) => Map<String, String>.from(item))
            .toList()
        : [];

    governmentalCosts = (widget.data['govCosts'] ?? []).isNotEmpty
        ? (widget.data['govCosts'] as List<dynamic>)
            .map((item) => Map<String, String>.from(item))
            .toList()
        : [];
  }

  void _addRepair() {
    if (repairTypeController.text.isNotEmpty &&
        repairCostController.text.isNotEmpty) {
      setState(() {
        repairs.add({
          'type': repairTypeController.text,
          'cost': repairCostController.text,
        });
      });
      repairTypeController.clear();
      repairCostController.clear();
    }
  }

  void _addGovernmentalCost() {
    if (serviceNameController.text.isNotEmpty &&
        serviceCostController.text.isNotEmpty) {
      setState(() {
        governmentalCosts.add({
          'name': serviceNameController.text,
          'cost': serviceCostController.text,
        });
      });
      serviceNameController.clear();
      serviceCostController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isEnglish = HomeCubit.get(context).en;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isEnglish ? 'Daily Operations' : 'العمليات اليومية',
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnglish ? 'Repair' : 'الإصلاح',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                _buildRepairSection(isEnglish),
                const SizedBox(height: 24.0),
                Text(
                  isEnglish ? 'Governmental Costs' : 'التكاليف الحكومية',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                _buildGovernmentalCostSection(isEnglish),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () async {
                    if (repairs.isNotEmpty || governmentalCosts.isNotEmpty) {
                      await addDailyOperation(context, isEnglish);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEnglish
                              ? 'Please insert operations to add'
                              : 'يرجى إدخال العمليات للإضافة'),
                        ),
                      );
                    }
                  },
                  child: Text(isEnglish ? 'Save' : 'حفظ'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRepairSection(bool isEnglish) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: repairTypeController,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Repair Type' : 'نوع الإصلاح',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: repairCostController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Cost' : 'التكلفة',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: _addRepair,
          child: Text(isEnglish ? 'Add Repair' : 'إضافة إصلاح'),
        ),
        const SizedBox(height: 16.0),
        repairs.isNotEmpty
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 16.0),
                child: Text(isEnglish ? 'Repairs:' : 'الإصلاحات:'),
              )
            : const SizedBox.shrink(),
        ...repairs.map((repair) => ListTile(
              title: Text(
                '${isEnglish ? 'Repair' : 'الإصلاح'}: ${repair['type']!}',
              ),
              subtitle: Text(
                '${isEnglish ? 'Cost' : 'التكلفة'}: ${repair['cost']}',
              ),
              trailing: TextButton.icon(
                onPressed: () {
                  repairs.remove(repair);
                  setState(() {});
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: Text(
                  isEnglish ? 'Delete' : 'حذف',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )),
        repairs.isNotEmpty
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 16.0),
                child: Text(
                  '${isEnglish ? 'Total' : 'الإجمالي'}: ${totalRepairPrice()}',
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildGovernmentalCostSection(bool isEnglish) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: serviceNameController,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Service Name' : 'اسم الخدمة',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: serviceCostController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: isEnglish ? 'Cost' : 'التكلفة',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: _addGovernmentalCost,
          child: Text(isEnglish ? 'Add Cost' : 'إضافة تكلفة'),
        ),
        const SizedBox(height: 16.0),
        governmentalCosts.isNotEmpty
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 16.0),
                child: Text(
                    isEnglish ? 'Governmental Costs:' : 'التكاليف الحكومية:'),
              )
            : const SizedBox.shrink(),
        ...governmentalCosts.map((cost) => ListTile(
              title: Text(
                '${isEnglish ? 'Service' : 'الخدمة'}: ${cost['name']!}',
              ),
              subtitle: Text(
                '${isEnglish ? 'Cost' : 'التكلفة'}: ${cost['cost']}',
              ),
              trailing: TextButton.icon(
                onPressed: () {
                  governmentalCosts.remove(cost);
                  setState(() {});
                },
                icon: const Icon(Icons.delete, color: Colors.red),
                label: Text(
                  isEnglish ? 'Delete' : 'حذف',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )),
        governmentalCosts.isNotEmpty
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 16.0),
                child: Text(
                  '${isEnglish ? 'Total' : 'الإجمالي'}: ${totalGovPrice()}',
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  double totalGovPrice() {
    double total = 0;
    for (var cost in governmentalCosts) {
      total += double.parse(cost['cost'] ?? '0');
    }
    return total;
  }

  double totalRepairPrice() {
    double total = 0;
    for (var cost in repairs) {
      total += double.parse(cost['cost'] ?? '0');
    }
    return total;
  }

  Future<void> addDailyOperation(BuildContext context, bool isEnglish) async {
    try {
      await FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.data['collectionId'])
          .update({
        "repair": repairs,
        "govCosts": governmentalCosts,
        'totalRepairs': totalRepairPrice(),
        'totalGovCosts': totalGovPrice()
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish
              ? 'The operations added successfully'
              : 'تمت إضافة العمليات بنجاح'),
        ),
      );
    } on FirebaseException catch (e) {
      log('===================================== e $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isEnglish ? 'Failed to add operations' : 'فشل في إضافة العمليات'),
        ),
      );
    }
  }

  @override
  void dispose() {
    repairTypeController.dispose();
    repairCostController.dispose();
    serviceNameController.dispose();
    serviceCostController.dispose();
    super.dispose();
  }
}

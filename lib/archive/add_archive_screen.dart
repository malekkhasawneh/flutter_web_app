import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_website/home/cubit/home_cubit.dart';

class AddArchiveScreen extends StatefulWidget {
  const AddArchiveScreen({Key? key, required this.data}) : super(key: key);
  final Map<String, dynamic> data;

  @override
  State<AddArchiveScreen> createState() => _AddArchiveScreenState();
}

class _AddArchiveScreenState extends State<AddArchiveScreen> {
  TextEditingController sellingPrice = TextEditingController();
  TextEditingController buyerName = TextEditingController();
  TextEditingController afterSellingInfo = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isEnglish = HomeCubit.get(context).en;

        return Scaffold(
          appBar: AppBar(
            title: Text(isEnglish ? 'Add Archive Info' : 'إضافة معلومات الأرشيف'),
            automaticallyImplyLeading: false,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width > 600
                    ? 600
                    : double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEnglish
                            ? 'Add Archive Information'
                            : 'إضافة معلومات الأرشيف',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: sellingPrice,
                        decoration: InputDecoration(
                          labelText:
                          isEnglish ? 'Selling Price' : 'سعر البيع',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isEnglish
                                ? 'Selling Price is required'
                                : 'سعر البيع مطلوب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: buyerName,
                        decoration: InputDecoration(
                          labelText: isEnglish
                              ? "Buyer's name"
                              : 'اسم المشتري',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isEnglish
                                ? "Buyer's name is required"
                                : 'اسم المشتري مطلوب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: afterSellingInfo,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: isEnglish
                              ? 'After Selling Information'
                              : 'معلومات ما بعد البيع',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isEnglish
                                ? 'After Selling Information is required'
                                : 'معلومات ما بعد البيع مطلوبة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_key.currentState!.validate()) {
                            await addArchive(context, isEnglish);
                          }
                        },
                        child: Text(
                          isEnglish ? 'Save Information' : 'حفظ المعلومات',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> addArchive(BuildContext context, bool isEnglish) async {
    try {
      await FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.data['collectionId'])
          .update({
        "sellingPrice": sellingPrice.text,
        "buyerName": buyerName.text,
        "afterSellingInfo": afterSellingInfo.text,
        "isSold": true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish
              ? 'The info added successfully'
              : 'تمت إضافة المعلومات بنجاح'),
        ),
      );
    } on FirebaseException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish
              ? 'Failed to add data'
              : 'فشل في إضافة البيانات'),
        ),
      );
    }
  }
}

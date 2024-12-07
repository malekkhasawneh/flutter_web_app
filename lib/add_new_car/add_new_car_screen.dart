import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_website/home/cubit/home_cubit.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({Key? key}) : super(key: key);

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final List<Uint8List> _images = [];
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _carTypeController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _carColorController = TextEditingController();
  final TextEditingController _carIdController = TextEditingController();
  final TextEditingController _purchasePriceController =
  TextEditingController();
  final TextEditingController _paidPriceController = TextEditingController();
  final TextEditingController _expectedSellingPriceController =
  TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _expectedCostController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only upload up to 3 images.')),
      );
      return;
    }

    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        _images.add(bytes);
      });
    }
  }

  Future<void> _addCarToFirestore() async {
    try {
      final data = {
        'carType': _carTypeController.text,
        'carModel': _carModelController.text,
        'carColor': _carColorController.text,
        'carId': _carIdController.text,
        'purchasePrice': _purchasePriceController.text ?? '0.0',
        'expectedSellingPrice': _expectedSellingPriceController.text ?? '0.0',
        'employeeName': _employeeNameController.text,
        'expectedCost': _expectedCostController.text ?? '0.0',
        'images': _images.isNotEmpty
            ? _images.map((img) => img.toString()).toList()
            : [],
        'createdAt': DateTime.now().toString(),
        'isSold': false,
        'govCosts': [],
        'repair': [],
        'sellingPrice': '',
        'afterSellingInfo': '',
        'buyerName': '',
        'totalGovCosts': 0,
        'totalRepairs': 0,
        'paidPrice': _paidPriceController.text
      };

      await FirebaseFirestore.instance.collection('cars').add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car added successfully!')),
      );

      // Clear fields
      _carTypeController.clear();
      _carModelController.clear();
      _carColorController.clear();
      _carIdController.clear();
      _purchasePriceController.clear();
      _paidPriceController.clear();
      _expectedSellingPriceController.clear();
      _employeeNameController.clear();
      _expectedCostController.clear();
      setState(() {
        _images.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding car: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isEnglish = HomeCubit.get(context).en;

        return Scaffold(
          appBar: AppBar(
            title: Text(isEnglish ? 'Add Car' : 'إضافة سيارة'),
            centerTitle: true,
            
            backgroundColor: Colors.transparent,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: constraints.maxWidth > 600 ? 600 : double.infinity,
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _key,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isEnglish ? 'Add New Car' : 'إضافة سيارة جديدة',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              context,
                              isEnglish ? 'Car Type' : 'نوع السيارة',
                              _carTypeController,
                            ),
                            _buildTextField(
                              context,
                              isEnglish ? 'Car Model' : 'موديل السيارة',
                              _carModelController,
                            ),
                            _buildTextField(
                              context,
                              isEnglish ? 'Car Color' : 'لون السيارة',
                              _carColorController,
                            ),
                            _buildTextField(
                              context,
                              isEnglish ? 'Car ID' : 'رقم السيارة',
                              _carIdController,
                            ),
                            _buildTextField(
                              context,
                              isEnglish ? 'Purchase Price' : 'سعر الشراء',
                              _purchasePriceController,
                              isNumber: true,
                            ),
                            _buildTextField(
                              context,
                              isEnglish ? 'Paid Price' : 'السعر المدفوع',
                              _paidPriceController,
                              isNumber: true,
                            ),
                            _buildTextField(
                              context,
                              isEnglish
                                  ? 'Expected Selling Price'
                                  : 'السعر المتوقع للبيع',
                              _expectedSellingPriceController,
                              isNumber: true,
                            ),
                            _buildTextField(
                              context,
                              isEnglish ? 'Employee Name' : 'اسم الموظف',
                              _employeeNameController,
                            ),
                            _buildTextField(
                              context,
                              isEnglish ? 'Expected Cost' : 'التكلفة المتوقعة',
                              _expectedCostController,
                              isNumber: true,
                            ),
                            const SizedBox(height: 16),
                            _buildImagePicker(isEnglish),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (_key.currentState!.validate() &&
                                    _images.isNotEmpty) {
                                  _addCarToFirestore();
                                } else if (_images.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isEnglish
                                          ? 'Add at least one image'
                                          : 'أضف صورة على الأقل'),
                                    ),
                                  );
                                }
                              },
                              child: Text(isEnglish ? 'Add Car' : 'إضافة سيارة'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context, String label,
      TextEditingController controller,
      {bool isNumber = false}) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isEnglish = HomeCubit.get(context).en;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return isEnglish
                    ? 'This field is required'
                    : 'هذا الحقل مطلوب';
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _buildImagePicker(bool isEnglish) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEnglish ? 'Upload Images (max: 3):' : 'تحميل الصور (أقصى حد: 3):',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _images.isEmpty
                ? Text(
              isEnglish ? 'No images selected.' : 'لم يتم اختيار صور.',
              style: const TextStyle(color: Colors.grey),
            )
                : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _images
                  .map(
                    (imageBytes) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.memory(
                        imageBytes,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _images.remove(imageBytes);
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4.0),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

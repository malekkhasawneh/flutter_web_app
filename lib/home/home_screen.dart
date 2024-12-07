import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_website/add_new_car/add_new_car_screen.dart';
import 'package:todo_website/archive/archive_screen.dart';
import 'package:todo_website/daily_operations/exist_cars.dart';
import 'package:todo_website/home/cubit/home_cubit.dart';
import 'package:todo_website/inventory_in_process/inventory_in_proccess_cars.dart';
import 'package:todo_website/investment/investment_screen.dart';
import 'package:todo_website/login/login_repo.dart';
import 'package:todo_website/login/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key, required this.hasPermission}) : super(key: key);
  final bool hasPermission;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isEnglish = HomeCubit.get(context).en;
        return Scaffold(
          appBar: AppBar(
            title: Text(isEnglish ? 'Home' : 'الرئيسية'),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: InkWell(
                  onTap: () async {
                    await LoginRepo.logout().then((val) {
                      if (val) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      }
                    });
                  },
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return MobileHomeView(hasPermission: hasPermission);
              } else {
                return DesktopHomeView(hasPermission: hasPermission);
              }
            },
          ),
        );
      },
    );
  }
}

class MobileHomeView extends StatelessWidget {
  MobileHomeView({super.key, required this.hasPermission});

  final bool hasPermission;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isEnglish = HomeCubit.get(context).en;
        final List<Map<String, dynamic>> tabs = [
          {"id": 1, "title": isEnglish ? "Inventory in process" : "المخزون قيد التنفيذ"},
          {"id": 2, "title": isEnglish ? "Daily operations and payment" : "العمليات اليومية والدفع"},
          {"id": 3, "title": isEnglish ? "Investment" : "الاستثمار"},
          {"id": 4, "title": isEnglish ? "Archive" : "الأرشيف"},
          {"id": 5, "title": isEnglish ? "Add new" : "إضافة جديد"},
        ];

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: tabs.length,
          itemBuilder: (context, index) {
            return HomeCard(
              title: tabs[index]['title'],
              onTap: () {
                if (hasPermission || tabs[index]['id'] <= 2) {
                  log('Pressed ${tabs[index]['id']}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => handleNavigate(tabs[index]['id']),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(isEnglish
                        ? "You don't have permission to access the page"
                        : "ليس لديك إذن للوصول إلى الصفحة"),
                  ));
                }
              },
            );
          },
        );
      },
    );
  }
}

class DesktopHomeView extends StatelessWidget {
  DesktopHomeView({super.key, required this.hasPermission});

  final bool hasPermission;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isEnglish = HomeCubit.get(context).en;
        final List<Map<String, dynamic>> tabs = [
          {"id": 1, "title": isEnglish ? "Inventory in process" : "المخزون قيد التنفيذ"},
          {"id": 2, "title": isEnglish ? "Daily operations and payment" : "العمليات اليومية والدفع"},
          {"id": 3, "title": isEnglish ? "Investment" : "الاستثمار"},
          {"id": 4, "title": isEnglish ? "Archive" : "الأرشيف"},
          {"id": 5, "title": isEnglish ? "Add new car" : "إضافة سيارة"},
        ];

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(
                tabs.length,
                    (index) => InkWell(
                  onTap: () {
                    if (hasPermission || tabs[index]['id'] <= 2) {
                      log('Pressed ${tabs[index]['id']}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => handleNavigate(tabs[index]['id']),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isEnglish
                            ? "You don't have permission to access the page"
                            : "ليس لديك إذن للوصول إلى الصفحة"),
                      ));
                    }
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        tabs[index]['title'],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HomeCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const HomeCard({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget handleNavigate(int id) {
  switch (id) {
    case 1:
      return const InventoryInProcessCars();
    case 2:
      return const CarCardsScreen();
    case 3:
      return const InvestmentScreen();
    case 4:
      return const ArchiveScreen();
    case 5:
      return const AddCarScreen();
    default:
      return const AddCarScreen();
  }
}

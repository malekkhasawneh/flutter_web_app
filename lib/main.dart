import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:todo_website/home/cubit/home_cubit.dart';
import 'package:todo_website/login/login_screen.dart';
import 'package:todo_website/login/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAt7QAb7xJjKdkvmOEfmbEswlcisY7WAzc",
          authDomain: "todoapp-f916a.firebaseapp.com",
          projectId: "todoapp-f916a",
          storageBucket: "todoapp-f916a.firebasestorage.app",
          messagingSenderId: "594771333154",
          appId: "1:594771333154:web:665dacd65fece030bffa7b"));
  runApp(BlocProvider<HomeCubit>(
    create: (_) => HomeCubit(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          supportedLocales: const [
            Locale('ar'), // Arabic
            Locale('en'), // English
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: HomeCubit.get(context).en
              ? const Locale('en')
              : const Locale('ar'),
          title: 'Todo app',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}

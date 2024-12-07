import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_website/home/cubit/home_cubit.dart';
import 'package:todo_website/home/home_screen.dart';
import 'package:todo_website/login/login_repo.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return const MobileLoginView();
          } else {
            return const DesktopLoginView();
          }
        },
      ),
    );
  }
}

class MobileLoginView extends StatelessWidget {
  const MobileLoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  HomeCubit.get(context).en ? 'Welcome!' : 'مرحبا!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  HomeCubit.get(context).en
                      ? 'Login to continue'
                      : 'قم بتسجيل الدخول للمتابعة',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                LoginForm(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DesktopLoginView extends StatelessWidget {
  const DesktopLoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: Container(
                color: Colors.blue,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          HomeCubit.get(context).en ? 'Welcome!' : 'مرحبا!',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          HomeCubit.get(context).en
                              ? 'Sign in to access your account.'
                              : 'قم بتسجيل الدخول للوصول إلى حسابك.',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32.0),
                  child: LoginForm(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

TextEditingController userName = TextEditingController();
TextEditingController password = TextEditingController();
GlobalKey<FormState> _key = GlobalKey<FormState>();

class LoginForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Form(
          key: _key,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: userName,
                decoration: InputDecoration(
                  labelText: HomeCubit.get(context).en ? 'Username' : 'اسم المستخدم',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return HomeCubit.get(context).en
                        ? 'This field is required'
                        : 'هذا الحقل مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: HomeCubit.get(context).en ? 'Password' : 'كلمة المرور',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return HomeCubit.get(context).en
                        ? 'This field is required'
                        : 'هذا الحقل مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (_key.currentState!.validate()) {
                    await LoginRepo.login(userName.text, password.text)
                        .then((val) {
                      if ((val['login'] ?? false)) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeScreen(
                              hasPermission: val['hasPermission'],
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              HomeCubit.get(context).en
                                  ? 'Invalid username or password'
                                  : 'اسم المستخدم أو كلمة المرور غير صحيحة',
                            ),
                          ),
                        );
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  HomeCubit.get(context).en ? 'Login' : 'تسجيل الدخول',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

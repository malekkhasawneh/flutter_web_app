import 'package:flutter/material.dart';
import 'package:todo_website/login/login_repo.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return const MobileSignUpView();
          } else {
            return const DesktopSignUpView();
          }
        },
      ),
    );
  }
}

class MobileSignUpView extends StatelessWidget {
  const MobileSignUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign up to get started',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            SignUpForm(),
          ],
        ),
      ),
    );
  }
}

class DesktopSignUpView extends StatelessWidget {
  const DesktopSignUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.blue,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sign up to access your account.',
                      style: TextStyle(
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
              child: SignUpForm(),
            ),
          ),
        ),
      ],
    );
  }
}

TextEditingController signUpUsername = TextEditingController();
TextEditingController signUpPassword = TextEditingController();
TextEditingController confirmPassword = TextEditingController();
GlobalKey<FormState> signUpKey = GlobalKey<FormState>();

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool isPermissionGranted = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: signUpKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: signUpUsername,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: signUpPassword,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'This field is required';
              }
              if (val.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: confirmPassword,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'This field is required';
              }
              if (val != signUpPassword.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Give Permission',
                style: TextStyle(fontSize: 16),
              ),
              Switch(
                value: isPermissionGranted,
                onChanged: (value) {
                  setState(() {
                    isPermissionGranted = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              if (signUpKey.currentState!.validate()) {
                await LoginRepo.signUp(signUpUsername.text, signUpPassword.text,
                        isPermissionGranted)
                    .then((value) {
                  if (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User registered successfully'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to add new user'),
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
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}

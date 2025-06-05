import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // To access HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Unexpected error occurred'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Add _signUp method later based on functional_specs.md

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول - Yalla Ride')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text('سجل الدخول للمتابعة'),
          const SizedBox(height: 18),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'كلمة المرور'),
            obscureText: true,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            child: Text(_isLoading ? 'جاري التحميل...' : 'تسجيل الدخول'),
          ),
          TextButton(
            onPressed: () {
              // Navigate to SignUp screen (to be created)
              // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
            },
            child: const Text('ليس لديك حساب؟ سجل الآن'),
          ),
        ],
      ),
    );
  }
}

// Create SignUpScreen later


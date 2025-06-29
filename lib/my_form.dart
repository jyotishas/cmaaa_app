import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'database_helper.dart';
import 'login.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyForm(),
  ));
}

class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  String? _captchaCode;

  final DatabaseHelper dbHelper = DatabaseHelper();


  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    final random = Random();
    _captchaCode = List.generate(5, (index) {
      final randomIndex = random.nextInt(characters.length);
      return characters[randomIndex];
    }).join();
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }


  void _signUp() async {
    if (_formKey.currentState!.validate()) {

      String hashedPassword = hashPassword(_passwordController.text);

      final newUser = {
        'name': _nameController.text,
        'email': _emailController.text,
        'contact': _contactController.text,
        'password': hashedPassword,
      };

      try {
        int result = await dbHelper.insertUser(newUser);
        if (result > 0 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign-Up Successful!')),
          );
          _clearFields();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _contactController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _captchaController.clear();
    _generateCaptcha();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 1),
                Center(
                  child: Image.asset(
                    'assets/banner.webp',
                    height: 280,
                    width: 280,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField('Applicant Name', _nameController, 'Enter your name'),
                      _buildTextField('Applicant Email', _emailController, 'Enter your email', isEmail: true),
                      _buildTextField('Contact Number', _contactController, 'Enter your contact number', isPhone: true),
                      _buildPasswordField('Password', _passwordController, 'Enter your password'),
                      _buildConfirmPasswordField(),

                      const SizedBox(height:20),
                      const SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _captchaCode ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.refresh, size: 20),
                              tooltip: 'Refresh CAPTCHA',
                              onPressed: _generateCaptcha,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _captchaController,
                              decoration: const InputDecoration(
                                hintText: 'Enter security code',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              textStyle: const TextStyle(fontSize: 18),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green.shade900,
                            ),
                            child: const Text('Submit'),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already signed up? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                            child: const Text(
                              "Log in here",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hintText,
      {bool isEmail = false, bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(hintText: hintText),
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : isPhone
              ? TextInputType.phone
              : TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            if (isEmail && !value.contains('@')) return 'Invalid email format';
            if (isPhone && value.length != 10) return 'Invalid contact number';
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(hintText: hintText),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#\$%^&+=]).{8,15}$')
                .hasMatch(value)) {
              return 'Password must be 8-15 chars, special char, number, upper & lowercase';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.bold)),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: const InputDecoration(hintText: 'Confirm your password'),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            if (value != _passwordController.text) return 'Passwords do not match';
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

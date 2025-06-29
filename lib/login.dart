import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'dart:convert';
import 'FaceLoginScanner.dart';
import 'database_helper.dart';
import 'my_form.dart';
import 'registration_form.dart';
import 'dashboard.dart';
import 'dart:async';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'face_recognition_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forget_password.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  final _loginKey = GlobalKey<FormState>();
  final DatabaseHelper dbHelper = DatabaseHelper();
  String? _selectedLoginOption;
  String? _captchaCode;
  FaceDetector? _faceDetector;
  FaceRecognitionHelper faceHelper = FaceRecognitionHelper();
  String? matchedPassword;
  bool userExists = false;
  bool _obscurePassword = true;
  int? userId;
  String? storedEmbeddingJson;
  bool _isVerifying = false;
  bool _isVerified = false;
  bool _showFaceLogin = false;
  bool isFormSubmitted = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _generateCaptcha();
    _initFaceHelper();
  }

  void _initFaceHelper() async {
    await faceHelper.testAsset();
    await faceHelper.loadModel();
  }

  void _onLoginOptionSelected(String? option) {
    setState(() {
      _selectedLoginOption = option;
    });
  }

  // ✅ Save login session
  Future<void> _setLoginSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_logged_in', true);
    await prefs.setInt('user_id', userId);
    await prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch);


    // Debugging print statements
    print("✅ Login session saved!");
    print("📌 is_logged_in: ${prefs.getBool('is_logged_in')}");
    print("📌 user_id: ${prefs.getInt('user_id')}");
  }


  // ✅ Hash Password Function
  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> checkPhoneNumber(String mobile) async {
    setState(() {
      _isVerifying = true;
      _isVerified = false;
    });

    final dbHelper = DatabaseHelper();
    final result = await dbHelper.getUserByMobile(mobile);

    if (result.isNotEmpty) {
      setState(() {
        userExists = true;
        matchedPassword = result.first['password']?.toString();
        storedEmbeddingJson = result.first['embedding']?.toString();
        userId = int.tryParse(result.first['id'].toString());

        // 🔥 Get form submission status
        var val = result.first['is_form_submitted'];
        if (val is int) {
          isFormSubmitted = val == 1;
        } else if (val is String) {
          isFormSubmitted = val == "1";
        } else {
          isFormSubmitted = false;
        }

        _showFaceLogin = isFormSubmitted;
        _isVerifying = false;
        _isVerified = true;
      });
    } else {
      setState(() {
        userExists = false;
        matchedPassword = null;
        storedEmbeddingJson = null;
        userId = null;
        _isVerifying = false;
        _isVerified = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not registered')),
      );
    }
  }



  Future<void> handlePasswordLogin() async {
    if (!userExists || matchedPassword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please verify your phone number first')),
      );
      return;
    }

    final hashed = hashPassword(_passwordController.text);
    if (hashed == matchedPassword) {
      if (userId != null) {
        await _setLoginSession(userId!);
      }

      if (isFormSubmitted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => RegistrationForm(isEditing: true)),
        );
      }
    }
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

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    int? userId = prefs.getInt('user_id');

    if (!mounted) return;

    print("🔍 Checking login status...");
    print("📌 isLoggedIn: $isLoggedIn");
    print("📌 userId from SharedPreferences: $userId");

    print("SharedPreferences keys: ${prefs.getKeys().toList()}");
    for (var key in prefs.getKeys()) {
      print(" - $key: ${prefs.get(key)}");
    }

    if (isLoggedIn && userId != null) {
      final dbHelper = DatabaseHelper();
      Map<String, dynamic>? user = await dbHelper.getUserById(userId);
      print("DEBUG: Retrieved user from database: $user");
      if (user != null) {
        print("User data keys: ${user.keys.toList()}");
        var val = user['is_form_submitted'];
        bool isFormSubmitted = false;

        if (val != null) {
          if (val is int) {
            isFormSubmitted = val == 1;
          } else if (val is String) {
            isFormSubmitted = val == "1";
          }
        }

        print("Form Submitted value: $val, interpreted as bool: $isFormSubmitted");

        if (isFormSubmitted) {
          print("🚀 Redirecting to Dashboard because form is submitted.");
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        } else {
          print("📝 Redirecting to Registration Form because form is NOT submitted.");
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => RegistrationForm(isEditing: true)),
          );
        }
      } else {
        print("❌ User not found in database!");
      }
    } else {
      print("❌ No logged-in user found in SharedPreferences!");
    }
  }



  // ✅ Check if draft exists
  Future<bool> checkIfDraftExists(int userId) async {
    List<Map<String, dynamic>> drafts = await dbHelper.getDraft(userId);
    return drafts.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 1.0),
            child: Text('User Login'),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _loginKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 1),
                  Center(
                    child: Image.asset(
                      'assets/banner.webp',
                      height: 280,
                      width: 280,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Enter Registered Mobile Number',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    enabled: !userExists,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Mobile Number',
                      prefixText: '+91 ',
                      counterText: '',
                      suffixIcon: _isVerifying
                          ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                          : _isVerified
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : (!userExists && _mobileController.text.length == 10)
                          ? const Icon(Icons.error, color: Colors.red)
                          : null,
                    ),
                    onChanged: (value) {
                      if (value.length == 10 && !_isVerifying && !_isVerified) {
                        checkPhoneNumber(value);
                      } else {
                        setState(() {
                          _isVerified = false;
                          userExists = false;
                          matchedPassword = null;
                          storedEmbeddingJson = null;
                          userId = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Choose Your Login:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  RadioListTile<String>(
                    title: const Text('Login with Password'),
                    value: 'password',
                    groupValue: _selectedLoginOption,
                    onChanged: _onLoginOptionSelected,
                  ),
                  if (_showFaceLogin)
                    RadioListTile<String>(
                      title: const Text('Login with Facial Recognition'),
                      value: 'face',
                      groupValue: _selectedLoginOption,
                      onChanged: _onLoginOptionSelected,
                    ),

                  if (_selectedLoginOption != null) ...[
                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // CAPTCHA Display (Styled Container)
                        Container(
                          width: 100,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Text(
                            _captchaCode ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Refresh Button
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

                        // CAPTCHA Input Field
                        Expanded(
                          child: TextField(
                            controller: _captchaController,
                            decoration: InputDecoration(
                              hintText: 'Enter security code',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Buttons depending on login option
                  if (_selectedLoginOption == 'password') ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Enter Password',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: _isVerified,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isVerified
                          ? () {
                          // Validate CAPTCHA then password login
                          if (_validateCaptcha()) {
                            handlePasswordLogin();
                          } else {
                            _showCaptchaError();
                          }
                        }
                        : null,
                        child: const Text('Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade900,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ] else if (_selectedLoginOption == 'face') ...[
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isVerified
                          ? () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => FaceLoginScanner(
                              mobile: _mobileController.text.trim(),
                              faceHelper: faceHelper,
                              onResult: (success) async {
                                if (success) {
                                  await _setLoginSession(userId!);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => DashboardScreen()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Face not recognized')),
                                  );
                                }
                              },
                            ),
                          );
                        }
                        : null,
                        child: Text("Login with Face"),
                          style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade900,
                          foregroundColor: Colors.white,
                          ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  // Sign-Up Prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Not signed up? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyForm()),
                          );
                        },
                        child: const Text(
                          "Sign up here",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to check CAPTCHA input
  bool _validateCaptcha() {
    final userInput = _captchaController.text.trim();
    return userInput.toLowerCase() == (_captchaCode?.toLowerCase() ?? '');
  }

 // Function to show error if CAPTCHA is wrong
  void _showCaptchaError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incorrect CAPTCHA. Please try again.')),
    );
  }

  @override
  void dispose() {
    _faceDetector?.close();
    _mobileController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }
  void main() {
    runApp(MaterialApp(
      home: LoginPage(),
    ));
  }
}
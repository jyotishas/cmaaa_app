import 'package:flutter/material.dart';
import 'package:signing/dashboard.dart';
import 'database_helper.dart';
import 'logout.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  String userName = "";
  String userMobile = "";
  final DatabaseHelper dbHelper = DatabaseHelper(); // Create instance

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _errorText = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final dbHelper = DatabaseHelper();
    int? userId = await dbHelper.getLoggedInUserId();

    if (userId != null) {
      Map<String, dynamic>? user = await dbHelper.getUserById(
          userId);

      if (user != null) {
        setState(() {
          userName =
              user['name'] ?? 'Unknown';
          userMobile =
              user['contact'] ?? 'N/A';

          _nameController.text = userName;
          _mobileController.text = userMobile;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAndUpdatePassword() {
    setState(() {
      if (_passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        _errorText = "Password fields cannot be empty!";
      } else if (_passwordController.text != _confirmPasswordController.text) {
        _errorText = "Passwords do not match!";
      } else {
        _errorText = "";
        _updatePassword();
      }
    });
  }

  Future<void> _updatePassword() async {
    int? userId = await dbHelper.getLoggedInUserId();

    if (userId != null) {
      bool isUpdated = await dbHelper.updatePassword(
          userMobile, _passwordController.text);

      if (isUpdated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password updated successfully!"),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update password!"),
              backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("User not found!"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6E6E6E), Color(0xFFF6C2AD)], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Top Navigation Buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _topNavButton(context, Icons.dashboard, "Dashboard"),
                    _topNavButton(context, Icons.lock, "Change Password"),
                    _topNavButton(context, Icons.exit_to_app, "Logout"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Password Change Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 1,
                    color: Colors.white.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Name of the user",
                              style: TextStyle(fontWeight: FontWeight.w600 , fontSize: 16 , color: Colors.black87, fontStyle: FontStyle.italic)),
                          const SizedBox(height: 7),
                          TextField(
                            controller: _nameController,
                            readOnly: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[300],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text("Login Mobile",
                              style: TextStyle(fontWeight: FontWeight.w600 , fontSize: 16 , color: Colors.black87, fontStyle: FontStyle.italic,)),
                          const SizedBox(height: 7),
                          TextField(
                            controller: _mobileController,
                            readOnly: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[300],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text("Choose Password",
                              style: TextStyle(fontWeight: FontWeight.w600 , fontSize: 16 , color: Colors.black87, fontStyle: FontStyle.italic,)),
                          const SizedBox(height: 7),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),
                          const Text("Confirm Password",
                              style: TextStyle(fontWeight: FontWeight.w600 , fontSize: 16 , color: Colors.black87, fontStyle: FontStyle.italic,)),
                          const SizedBox(height: 7),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),
                          if (_errorText.isNotEmpty)
                            Text(
                              _errorText,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                          const SizedBox(height: 10),
                          const Text(
                            "Note: Password should be 8 to 15 characters with at least one special character (@#\$%^&+=), one numeric, one small case, and one uppercase letter.",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _passwordController.clear();
                                    _confirmPasswordController.clear();
                                    _errorText = "";
                                  });
                                },
                                icon: const Icon(
                                    Icons.refresh, color: Colors.white),
                                label: const Text("RESET"),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700),
                                onPressed: _validateAndUpdatePassword,
                                icon: const Icon(
                                    Icons.update, color: Colors.white),
                                label: const Text("UPDATE"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _topNavButton(BuildContext context, IconData icon, String title) {
    return TextButton(
      onPressed: () {
        _onMenuSelected(context, title);
      },
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  void _onMenuSelected(BuildContext context, String option) {
    switch (option) {
      case "Dashboard":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
        break;
      case "Logout":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LogoutScreen()),
        );
        break;
      default:
        print("Unknown menu option: $option");
    }
  }
}



import 'dart:convert' show jsonEncode;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signing/face_recognition_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dashboard.dart';
import 'package:signing/logout.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'change_password.dart';
import 'package:intl/intl.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

void main() {
  runApp(MaterialApp(
    home: RegistrationForm(),
  ));
}

class RegistrationForm extends StatefulWidget {
  final bool isEditing;
  const RegistrationForm({Key? key, this.isEditing = false}) : super(key: key);


  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _fatherController = TextEditingController();
  late TextEditingController _dobController = TextEditingController();
  late TextEditingController _panController = TextEditingController();
  late TextEditingController _employmentNoController = TextEditingController();
  late TextEditingController _addressController1 = TextEditingController();
  late TextEditingController _addressController2 = TextEditingController();
  late TextEditingController _addressController3 = TextEditingController();
  late TextEditingController _pincodeController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _businessaddressController = TextEditingController();
  late TextEditingController _courseController = TextEditingController();
  late TextEditingController _boardController = TextEditingController();
  late TextEditingController _collegeController = TextEditingController();
  late TextEditingController _passingDateController = TextEditingController();
  late TextEditingController _mobileController = TextEditingController();
  late TextEditingController _percentageController = TextEditingController();
  late TextEditingController _bankAccountController = TextEditingController();
  late TextEditingController _bankBranchController = TextEditingController();
  late TextEditingController _bankAddressController = TextEditingController();
  late TextEditingController _ifscController = TextEditingController();

  String? _selectedState;
  String? _selectedCategory;
  String? _photoPath;
  String? _selectedlac;
  String? _selectedcodistrict;
  String? _selectedMaritalStatus;
  String? _selectedSector;
  String? _selectedSubsector;
  String? _selectedtradetype;
  String? _selectedDistrict;
  String? _selectedBusinessDistrict;
  String? _selectedDegree;
  String? _selectedDivision;
  String? _selectedBankName;
  String? _selectedGender;
  String? _selectedBPL;
  String? _selectedBusinessActivity;
  String? _selectedGovtAssist;
  bool _isChecked = false;
  File? _selectedImage;
  final TextEditingController _dateController = TextEditingController();
  final helper = FaceRecognitionHelper();
  List<double>? embedding;
  String? savedImagePath;

  get child => null;

  Map<String, dynamic> formData = {};

  void _onMenuSelected(BuildContext context, String option) {
    if (option == "Dashboard") {
    } else if (option == "Change Password") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
      );
    } else if (option == "Logout") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LogoutScreen()),
      );
    }
  }
  Future<void> requestPermissions() async {
    await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ].request();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherController.dispose();
    _dobController.dispose();
    _panController.dispose();
    _employmentNoController.dispose();
    _addressController1.dispose();
    _addressController2.dispose();
    _addressController3.dispose();
    _pincodeController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _businessaddressController.dispose();
    _courseController.dispose();
    _boardController.dispose();
    _collegeController.dispose();
    _passingDateController.dispose();
    _percentageController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _bankBranchController.dispose();
    _bankAddressController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeForm(); // Load user and form status first
      await _loadAndProcessImage(); // Now process image with valid user
    });
  }

  Future<void> _initializeForm() async {
    if (widget.isEditing) {
      int? userId = await getLoggedInUserId();
      if (userId != null) {
        loadDraftData(userId);
      } else {
        print("No logged-in user found!");
      }
    } else {
      _resetForm();
    }
  }

  Future<void> _loadAndProcessImage() async {
    await helper.loadModel();

    if (savedImagePath == null || savedImagePath!.isEmpty) {
      print("❌ Saved image path is null or empty.");
      return;
    }

    final File imageFile = File(savedImagePath!);
    if (!await imageFile.exists()) {
      print("❌ Image file does not exist at path: $savedImagePath");
      return;
    }

    final Uint8List imageBytes = await imageFile.readAsBytes();
    final inputImage = InputImage.fromFilePath(savedImagePath!);

    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
      ),
    );

    final List<Face> faces = await faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      print("❌ No face detected in the image.");
      return;
    }

    final Face face = faces.first;
    final List<double> faceEmbedding = await helper.getEmbedding(imageBytes, face);

    setState(() {
      embedding = faceEmbedding;
    });

    print("✅ Face embedding generated: $embedding");

    await faceDetector.close();
  }

  Future<int?> getLoggedInUserId() async {
    List<Map<String, dynamic>> users = await DatabaseHelper().getUsers();
    if (users.isEmpty) {
      print("No logged-in user found!");
      return null;
    }
    final loggedInUser = users.firstWhere(
          (user) => user['is_logged_in'] == 1,
      orElse: () => {},
    );
    return loggedInUser.isNotEmpty ? loggedInUser['id'] : null;
  }

  Future<void> saveDraftData() async {
    try{

          final db = await DatabaseHelper().database;
          int? userId = await getLoggedInUserId();

          if (userId == null) {
            print("❌ Cannot save draft: No logged-in user.");
            return;
          }

          String? imagePath = _selectedImage?.path;
          Map<String, dynamic> draftData = {
            'applicant_name': _nameController.text,
            'father_name': _fatherController.text,
            'gender': _selectedGender,
            'social_category': _selectedCategory,
            'dob': _dobController.text,
            'pan_number': _panController.text,
            'employment_exchange_no': _employmentNoController.text,
            'bpl': _selectedBPL,
            'marital_status': _selectedMaritalStatus,
            'sector': _selectedSector,
            'sub_sector': _selectedSubsector,
            'trade_type': _selectedtradetype,
            'photo': imagePath,
            'address1': _addressController1.text,
            'address2': _addressController2.text,
            'address3': _addressController3.text,
            'state': _selectedState,
            'district': _selectedDistrict,
            'lac': _selectedlac,
            'co_district': _selectedcodistrict,
            'pincode': _pincodeController.text,
            'mobile': _mobileController.text,
            'email': _emailController.text,
            'business_district': _selectedBusinessDistrict,
            'business_activity': _selectedBusinessActivity,
            'business_address': _businessaddressController.text,
            'assistance': _selectedGovtAssist,
            'degree': _selectedDegree,
            'course': _courseController.text,
            'board': _boardController.text,
            'college': _collegeController.text,
            'passing_date': _passingDateController.text,
            'percentage': _percentageController.text,
            'division': _selectedDivision,
            'bank_account': _bankAccountController.text,
            'ifsc': _ifscController.text,
            'bank_name': _selectedBankName,
            'bank_branch': _bankBranchController.text,
            'bank_address': _bankAddressController.text,
            'user_id': userId,
            'status': 'draft',
          };

          print("Saving Draft Data: $draftData");

          int result = await db.insert(
            'form_data',
            draftData,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          if (result > 0) {
            print(" ✅ Draft Saved Successfully!");
          } else {
            print("⚠️ Failed to Save Draft!");
          }
    } catch(e){
      print("Error saving draft: $e");
    }
  }

  Future<void> loadDraftData(int userId) async {
    try {
      final db = await DatabaseHelper().database;
      List<Map<String, dynamic>> drafts = await db.query(
        'form_data',
        where: 'user_id = ? AND status = ?',
        whereArgs: [userId, 'draft'],
      );

      if (drafts.isNotEmpty) {
        var draft = drafts.first;
        debugPrint("✅ Loaded Draft for User ID: $userId");

        if (!mounted) return;

        setState(() {
          _nameController.text = draft['applicant_name'] ?? '';
          _fatherController.text = draft['father_name'] ?? '';
          _selectedGender = draft['gender'] ?? '';
          _selectedCategory = draft['social_category'] ?? '';
          _dobController.text = draft['dob'] ?? '';
          _panController.text = draft['pan_number'] ?? '';
          _employmentNoController.text =
              draft['employment_exchange_no'] ?? '';
          _selectedBPL = draft['bpl'] ?? '';
          _selectedMaritalStatus = draft['marital_status'] ?? '';
          _selectedSector = draft['sector'] ?? '';
          _selectedSubsector = draft['sub_sector'] ?? '';
          _selectedtradetype = draft['trade_type'] ?? '';
          _photoPath = draft['photo'];

          _selectedImage = (_photoPath != null && _photoPath!.isNotEmpty)
              ? File(_photoPath!)
              : null;

          _addressController1.text = draft['address1'] ?? '';
          _addressController2.text = draft['address2'] ?? '';
          _addressController3.text = draft['address3'] ?? '';
          _selectedState = draft['state'] ?? '';
          _selectedDistrict = draft['district'] ?? '';
          _selectedlac = draft['lac'] ?? '';
          _selectedcodistrict = draft['co_district'] ?? '';
          _pincodeController.text = draft['pincode'] ?? '';
          _mobileController.text = draft['mobile'] ?? '';
          _emailController.text = draft['email'] ?? '';
          _selectedBusinessDistrict = draft['business_district'] ?? '';
          _selectedBusinessActivity = draft['business_activity'] ?? '';
          _businessaddressController.text = draft['business_address'] ?? '';
          _selectedGovtAssist = draft['assistance'] ?? '';
          _selectedDegree = draft['degree'] ?? '';
          _courseController.text = draft['course'] ?? '';
          _boardController.text = draft['board'] ?? '';
          _collegeController.text = draft['college'] ?? '';
          _passingDateController.text = draft['passing_date'] ?? '';
          _percentageController.text = draft['percentage'] ?? '';
          _selectedDivision = draft['division'] ?? '';
          _bankAccountController.text = draft['bank_account'] ?? '';
          _ifscController.text = draft['ifsc'] ?? '';
          _selectedBankName = draft['bank_name'] ?? '';
          _bankBranchController.text = draft['bank_branch'] ?? '';
          _bankAddressController.text = draft['bank_address'] ?? '';
        });

        debugPrint("✅ Draft Loaded Successfully!");
      } else {
        debugPrint("❌ No Draft Found!");
      }
    } catch(e){
      debugPrint("⚠️ Error loading draft: $e");
    }
  }

  Future<void> saveAndNext(BuildContext context) async {
    try {
      if (!_formKey.currentState!.validate()) return;

      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.checkDatabasePath();

      int? loggedInUserId = await dbHelper.getLoggedInUserId();
      debugPrint("🆔 Logged-in User ID: $loggedInUserId");

      if (loggedInUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in!")),
        );
        return;
      }

      String? imagePath = _selectedImage?.path ?? '';
      if (_selectedImage == null || _selectedImage!.path.isEmpty) {
        print("❌ No image selected for face auth.");
        return;
      }

      // Load and process the face image first
      FaceRecognitionHelper faceHelper = FaceRecognitionHelper();
      await faceHelper.loadModel();

      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(enableContours: true),
      );

      final inputImage = InputImage.fromFilePath(imagePath);
      final List<Face> faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        debugPrint("No face detected in the image.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No face detected in the selected photo.")),
        );
        return;
      }

      final Face face = faces.first;
      Uint8List imageBytes = await File(imagePath).readAsBytes();
      List<double> embedding = await faceHelper.getEmbedding(imageBytes, face);

      if (embedding.isEmpty) {
        debugPrint("🚫 Embedding is empty.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to generate face embedding.")),
        );
        return;
      }

      Map<String, dynamic> formData = {
        'user_id': loggedInUserId,
        'applicant_name': _nameController.text,
        'father_name': _fatherController.text,
        'gender': _selectedGender,
        'social_category': _selectedCategory,
        'dob': _dobController.text,
        'pan_number': _panController.text,
        'employment_exchange_no': _employmentNoController.text,
        'bpl': _selectedBPL,
        'marital_status': _selectedMaritalStatus,
        'sector': _selectedSector,
        'sub_sector': _selectedSubsector,
        'trade_type': _selectedtradetype,
        'photo': imagePath,
        'address1': _addressController1.text,
        'address2': _addressController2.text,
        'address3': _addressController3.text,
        'state': _selectedState,
        'district': _selectedDistrict,
        'lac': _selectedlac,
        'co_district': _selectedcodistrict,
        'pincode': _pincodeController.text,
        'mobile': _mobileController.text,
        'email': _emailController.text,
        'business_district': _selectedBusinessDistrict,
        'business_activity': _selectedBusinessActivity,
        'business_address': _businessaddressController.text,
        'assistance': _selectedGovtAssist,
        'degree': _selectedDegree,
        'course': _courseController.text,
        'board': _boardController.text,
        'college': _collegeController.text,
        'passing_date': _passingDateController.text,
        'percentage': _percentageController.text,
        'division': _selectedDivision,
        'bank_account': _bankAccountController.text,
        'ifsc': _ifscController.text,
        'bank_name': _selectedBankName,
        'bank_branch': _bankBranchController.text,
        'bank_address': _bankAddressController.text,
        'status': 'final',
        'embedding': jsonEncode(embedding),
      };

      debugPrint("📌 Saving Data: $formData");
      int result = await dbHelper.saveData(formData);
      debugPrint("Save Result: $result");

      if (result > 0) {
        await dbHelper.updateUserFormSubmissionStatus(loggedInUserId);
        int deleteResult = await dbHelper.deleteDraft(loggedInUserId);
        debugPrint("🗑️ Deleted Draft Result: $deleteResult");

        await dbHelper.checkDataInDB();

        Future.delayed(Duration(milliseconds: 200), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data saved successfully!")),
            );
          }
        });

        if (!context.mounted){
          print("🚫 Context is no longer mounted, cannot navigate.");
        return;
        }

        if (context.mounted) {
          debugPrint("📍 Navigating to DashboardScreen...");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
                (route) => false, // Clears the navigation stack
          );
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save data!")),
        );
      }
    } catch(e, stacktrace) {
      debugPrint("⚠️Error saving data: $e");
      debugPrint("📌 Stacktrace: $stacktrace");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred!")),
      );
    }
  }

  void _resetForm() async {
    try {
      DatabaseHelper dbHelper = DatabaseHelper();
      int? userId = await dbHelper.getLoggedInUserId();

      if (userId != null) {
        await dbHelper.deleteDraft(userId);
      } else {
        print("No logged-in user found, draft not deleted.");
      }

      if (mounted) {
        setState(() {
          _nameController.clear();
          _fatherController.clear();
          _dobController.clear();
          _panController.clear();
          _employmentNoController.clear();
          _addressController1.clear();
          _addressController2.clear();
          _addressController3.clear();
          _pincodeController.clear();
          _mobileController.clear();
          _emailController.clear();
          _businessaddressController.clear();
          _courseController.clear();
          _boardController.clear();
          _collegeController.clear();
          _passingDateController.clear();
          _percentageController.clear();
          _bankAccountController.clear();
          _ifscController.clear();
          _bankBranchController.clear();
          _bankAddressController.clear();

          _selectedGender = null;
          _selectedCategory = null;
          _selectedBPL = null;
          _selectedMaritalStatus = null;
          _selectedSector = null;
          _selectedSubsector = null;
          _selectedtradetype = null;
          _selectedState = null;
          _selectedDistrict = null;
          _selectedlac = null;
          _selectedcodistrict = null;
          _selectedBusinessDistrict = null;
          _selectedBusinessActivity = null;
          _selectedGovtAssist = null;
          _selectedDegree = null;
          _selectedDivision = null;
          _selectedBankName = null;

          _selectedImage = null;
          _photoPath = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Form reset successfully!")),
        );
      }
    } catch(e) {
      print("Error resetting form: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to reset form!")),
        );
      }
    }
  }


  Future<void> _pickDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();


    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateFormat("dd/MM/yyyy").parse(controller.text);
      } catch (e) {
        print("Error parsing date: $e");
      }
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && context.mounted) {
      String formattedDate = DateFormat("dd/MM/yyyy").format(pickedDate);
      controller.text = formattedDate;
    }
  }

  Widget _buildDateField(String label, TextEditingController dobController, {required String hintText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Builder(
            builder: (context) => TextFormField(
              controller: dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: hintText,
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _pickDate(context, dobController),
              validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 85); // adjust compression

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      // Save to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');

      setState(() {
        _selectedImage = savedImage;
      });

      print("Image saved at: ${savedImage.path}");
      // Store `savedImage.path` in SQLite or pass it for later embedding
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 70),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6E6E6E), // Dark Grey
                  Color(0xFFF6C2AD), // Light Peach
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _topNavButton(context, Icons.dashboard , "Dashboard" ),
                _topNavButton(context, Icons.lock , "Change Password"),
                _topNavButton(context, Icons.logout , "Logout"),
              ],
            ),
          ),

          const SizedBox(height: 20), // Space below menu
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // **Form Title**
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.blueGrey),
                      child: const Text(
                        "Registration Form for Chief Minister's Atmanirbhar Asom Abhijan 2.0",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Space below title box
                  _infoBox("General Instructions", [
                    "All the * marked fields are mandatory and need to be filled up.",
                    "Click on the Verify button to validate Employment Exchange No.",
                    "To Apply for Registration of employment seeker in Employment Exchange please - Click Here",
                    "Please Note: Fresh registration with the Employment Exchange may take up to 24 hours for the verification process to be reflected in the CMAAA Portal."
                  ]),
                  const SizedBox(height: 20),
                  _infoBox("Fees & Payment", [
                    "Rs.200 for General Category (Rs.100 for SC/ST/OBC Category) at the time of submission of registration.",
                    "Mode of Payment: Online"
                  ]),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle("Information About Applicant"),
                        _buildTextField(
                          labelText: "Applicant Name (As Per Bank Details Submitted",
                          myController: _nameController, hintText: "Enter Full Name", validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                          }),
                        _buildTextField(
                            labelText: "Father's Name",
                            myController: _fatherController, hintText: "Enter Father's Name", validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "This field is required";
                            }
                            return null;
                            }),
                        _buildRadioField("Gender", ["Male", "Female", "Others"], _selectedGender, (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        }),
                        _buildDropdownField(
                            label: "Social Category",
                            options: ["General", "OBC", "SC", "ST(H)", "ST(P)"],
                            selectedValue: _selectedCategory,
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }),
                        _buildDateField("Date of Birth",_dobController, hintText: "DD/MM/YYYY", ),
                        _buildTextField(
                            labelText: "PAN Number",
                            myController: _panController, hintText: "Enter PAN Number", validator : (value) {
                              if (value == null || value.isEmpty) {
                                return "PAN Number is required";
                              }
                              if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value)) {
                                return "Invalid PAN format (e.g., ABCDE1234F)";
                              }
                              return null;
                            },
                          ),
                        _buildTextField(labelText: "Employment Exchange No.", myController: _employmentNoController, hintText: "Enter Employment Exchange No. ",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Employment Exchange Number is required";
                            }
                            if (!RegExp(r'^[A-Za-z0-9/]{6,15}$').hasMatch(value)) {
                              return "Invalid format. Use letters, numbers, and '/' (6-15 characters)";
                            }
                            return null;
                          },
                        ),
                        _buildRadioField("BPL", ["Yes", "No"], _selectedBPL, (value) {
                          setState(() {
                            _selectedBPL = value;
                          });
                        }),
                        _buildDropdownField(
                            label: "Marital Status",
                            options: ["Single", "Married","Divorced","Widowed"],
                            selectedValue: _selectedMaritalStatus,
                            onChanged: (value) {
                            setState(() {
                              _selectedMaritalStatus = value;
                           });
                        }),
                        _buildDropdownField(
                            label: "Select Sector",
                            options: ["Agriculture and Horticulture sector", "Fabrication/Hardware Business sector" , "Fisheries" , "Other sectors including services" , "Packaging sector" , "Plantation sector (Bamboo/Rubber/Agar etc)" , "Poultry/Dairy/Goatery/Piggery" , "Readymade Garment sector" , "Self-employment after professional courses" , "Stationary Business sector", "Wood based industries (Furniture sector)"],
                            selectedValue: _selectedSector,
                            onChanged: (value) {
                              setState(() {
                                _selectedSector = value;
                           });
                         }),
                        _buildDropdownField(
                            label: "Select Sub-Sector",
                            options: ["Agar Nursery", "Agarbatti Making" , "Agribusiness" , "Aluminium Fabrication" , "Aquarium & Fish Feed Shop" , "Areca Leaf Plate Making" , "Assamese Confectionery" , "Atta Chaki Unit" , "Bakery" , "Bamboo Broom Making", "Banana Chips Making" , "Beaten Rice(Chira) Making" , "Bee Keeping" , "Bio Flock" , "Boutique" , "Breeding Farms/Hatcheries" , "Broiler Farming" , "Building Materials Store" , "Cane & Bamboo Decorative Items Making" , "Cane & Bamboo Furniture Making" , "Cannel & Other Pet Feed Shop" , "Car Washing" , "Cattle Feed Manufacturing" , "Cement Based Product Making" , "Chappal Making Unit" , "Civil Engineering Firm",
                                    "Coaching & Training Services" , "Custom Printing Services" , "Custom Tailoring Services" , "Dairy Based Product Manufacturing" , "Dairy Farming" , "Decorative Candle Making" , "Dental Clinic" , "Detergent Powder Manufacturing" , "Diagnostic Laboratory" , "Distilled Water Making" , "Dry Cleaning" , "DTP Centre" , "Duck Rearing for Meat" , "Electrical Repairing Shop" , "Excercise Book Making" , "Eye Care Centre" , "Fashion & Garment Store" , "Fashion Accessories Shop" , "Fast Food Stall" , "Fish Farming" , "Fish Feed Mill" , "Fitness & Wellness Centre" , "Flex Printing" , "Flower Nursery" , "Food Truck" , "Four Wheeler Repairing" , "Gents Beauty Parlour" , "Ginger Garlic Paste Making" , "Goat Farming" , "Grocery Shop" , "Hand Made Tea" , "Handloom Weaving" , "Hardware Store" , "Honey Processing" , "Horticulture Nursery" , "Ice Cream Production" , "Jam , Jelly Squash Making" , "Jute Bag Making Unit" , "Ladies Beauty Parlour" , "Mobile Repairing" , "Mushroom Processing" , "Mustard Oil" , "Namkeen Making" , "Noodle Making" ,
                                    "Office Stationery Shop" , "Organic Mosquito Repellent Making" , "Ornamental Fish" , "Paint Shop" , "Paper Bag Making" , "Paper Bag Making Unit" , "Paper Cup Making" , "Paper Plate Making" , "Photography & Videography" , "Pickle Making" , "Pig Feed Production" , "Piglet Rearing" , "Popcorn Making" , "Pork Product Manufacturing (e.g., sausages, bacon)" , "Poultry Feed Production" , "Puffed Rice (Muri) Making" , "Readymade Garment Manufacturing" , "Rice Mill" , "School Bag Making" , "School Stationery Shop" , "School Uniform Making" , "Slipper Making Unit" , "Soap Making" , "Spice Grinding & Packaging" , "Stationery Gifts & Specialty Items" , "Supari Processing" , "Swine Breeding Farms" , "Tea Blending & Packaging" , "Tea Nursery" , "Tea Stall" , "Tent House" , "Tomato Ketchup Making" , "Traditional Assamese Jewellery Making" , "Traditional Fishery" , "Two Wheeler Repairing" , "Vermicompost" , "Veterinary Clinic" , "Welding & Fabrication Services" , "Wholesale & Distribution" , "Wooden Craft & Artisan Products" , "Wooden Craft & Artisan Products" , "Wooden Door & Window Manufacturing" , "Wooden Furniture Components" ,
                                    "Workshop for Servicing of Agriculture Machinery & Equipment"],
                            selectedValue: _selectedSubsector,
                            onChanged: (value) {
                            setState(() {
                              _selectedSubsector = value;
                            });
                        }),
                        _buildDropdownField(
                            label: "Type of Trade", options: ["Manufacturing", "Others", "Service", "Trading"],
                            selectedValue: _selectedtradetype,
                            onChanged: (value) {
                              setState(() {
                                _selectedtradetype = value;
                              });
                            }),
                        _buildImagePickerField("Upload Applicant's Passport Size Photograph", _photoPath),
                        const SizedBox(height: 20),
                        sectionTitle("Permanent Address with Mobile No"),
                        _buildTextField(labelText: "Address Line 1", myController:  _addressController1, hintText: "Enter Address Line 1",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            }),
                        _buildTextField(labelText: "Address Line 2", myController:  _addressController2, hintText: "Enter Address Line 2",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            }),
                        _buildTextField(labelText: "Address Line 3", myController: _addressController3, hintText: "Enter Address Line 3",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            }),
                        _buildDropdownField(
                            label: "State",
                            options: ["Assam"],
                            selectedValue: _selectedState,
                            onChanged:(value) {
                            setState(() {
                              _selectedState = value;
                          });
                        }),
                        _buildDropdownField(
                            label: "District",
                            options: ["Baksa", "Barpeta", "Bongaigaon", "Cachar", "Charaideo", "Chirang", "Darrang", "Dhemaji", "Dhubri", "Dibrugarh", "Dima Hasao", "Goalpara", "	Golaghat",
                                      "Hailakandi", "Jorhat", "Kamrup (Metropolitan)", "Kamrup", "Karbi Anglong", "Karimganj", "Kokrajhar", "Lakhimpur", "Majuli", "Morigaon", "Nagaon", "Nalbari", "Sibsagar", "Sonitpur", "South Salmara", "Tinsukia", "West Karbi Anglong", "Biswanath", "Hojai", "Bajali", "Tamulpur", "	Udalguri"],
                            selectedValue: _selectedDistrict,
                            onChanged:(value) {
                            setState(() {
                              _selectedDistrict = value;
                            });
                        }),
                        _buildDropdownField(
                            label: "LAC (As per New Demarcation)",options: ["Abhayapuri", "Algapur-Katlicherra", "Amri (ST)", "Bajali", "Baksa (ST)", "Baokhungri", "Barchalla", "Barhampur", "Barkhetri", "Barkhota", "Barpeta (SC)", "Behali (SC)", "Bhergaon", "Bhowanipur-Sorbhog" , "Bihpuria", "Bijni", "Bilasipara", "Binnakandi", "Birsing Jarua" , "Biswanath", "Bokajan (ST)", "Bokakhat", "Boko-Chaygaon (ST)", "Bongaigaon", "Chabua-Lahowal", "Chamaria", "Chenga", "Dalgaon","Demow" , "Dergaon", "Dhakuakhana (ST)", "Dhekiajuli", "Dhemaji (ST)",
                                    "Dhing", "Dholai (SC)", "Dhubri", "Dhuliajan" , "Dibrugarh", "Digboi", "Dimoria (SC)" , "Diphu (ST)", "Dispur", "Doomdooma", "Dotma (ST)" , "Dudhnai (ST)", "Gauripur", "Goalpara East", "Goalpara West (ST)", "Gohpur", "Golaghat", "Golakganj", "Goreswar" , "Gossaigaon", "Guwahati Central", "Haflong (ST)", "Hailakandi", "Hajo-Sualkuci (SC)",
                                    "Hojai", "Howraghat (ST)", "Jagiroad (SC)", "Jaleshwar", "Jalukbari", "Jonai (ST)", "Jorhat", "Kaliabor", "Kamalpur", "Karimganj North", "Karimganj South", "Katigorah", "Khowang", "Khumtai", "Kokrajhar (ST)", "Laharighat", "Lakhimpur", "Lakhipur", "Lumding", "Mahmora", "Majuli (ST)" , "Makum" , "Manas" , "Mandia" , "Mangaldai", "Mankachar", "Margherita", "Mariani", "Mazbat", "Morigaon", "Naduar" , "Nagaon-Batadraba" , "Naharkatia", "Nalbari",
                                    "Nazira" , "New Guwahati" , "Nowboicha (SC)", "Pakabetbari" , "Palasbari", "Parbatjhora", "Patharkandi", "Raha (SC)", "Ram Krishana Nagar (SC)" , "Rangapara", "Rangia", "Rongkhang (ST)" , "Rongonadi", "Rupahihat", "Sadiya", "Samaguri", "Sarupathar", "Sibsagar", "Sidli Chirang (ST)", "Silchar", "Sipajhar", "Sissibargaon" , "Sonai", "Sonari", "Srijangram", "Tamulpur (ST)" , "Tangla", "Teok", "Tezpur", "Tihu", "Tingkhong", "Tinsukia", "Titabar", "Udalguri (ST)", "Udharbond"],
                            selectedValue: _selectedlac,
                            onChanged: (value) {
                            setState(() {
                              _selectedlac = value;
                            });
                          }),
                        _buildDropdownField(
                            label: "Co District ",options: ["Abhayapuri", "Algapur-Katlicherra", "Bajali", "Barchalla", "Barhampur", "Barkhetri", "Barkhota", "Behali", "Bhowanipur-Sorbhog" , "Bihpuria", "Bilasipara", "Binnakandi", "Birsing Jarua" , "Bokakhat", "Boko-Chaygaon", "Chabua-Lahowal", "Chamaria", "Chenga", "Dalgaon","Demow" , "Dergaon", "Dhakuakhana", "Dharmapur-Tihu" , "Dhekiajuli",
                                  "Dhing", "Dholai", "Digboi", "Dimoria" , "Dispur", "Doomdooma", "Dudhnai", "Duliajan" , "Gauripur", "Goalpara West", "Gohpur", "Golakganj",
                                  "Jagiroad ", "Jaleshwar", "Jalukbari", "Jonai ", "Kaliabor", "Kamalpur", "Karimganj South", "Katigorah", "Khowang", "Khumtai", "Laharighat", "Lakhipur", "Lumding", "Mahmora", "Makum" , "Mandia-Jania" , "Margherita", "Mariani", "Naduar" , "Naharkatia",
                                  "Nazira" , "New Guwahati" , "Nowboicha", "Pakabetbari" , "Palasbari", "Patharkandi", "Raha", "Ram Krishana Nagar" , "Rangapara", "Rangia", "Rongonadi", "Rupahihat", "Sadiya", "Samaguri", "Sarupathar", "Sipajhar", "Sissibargaon" , "Sonai", "Sonari", "Srijangram", "Teok", "Tingkhong", "Titabar","Udharbond"],
                            selectedValue: _selectedcodistrict,
                            onChanged:(value) {
                            setState(() {
                              _selectedcodistrict = value;
                          });
                        }),
                        _buildTextField(labelText: "Pincode",myController:  _pincodeController, hintText: "Enter Pincode",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            }),
                        _buildTextField(labelText: "Mobile Number",myController:  _mobileController, hintText: "Enter Mobile Number",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            }),
                        _buildTextField(labelText: "E-Mail", myController: _emailController, hintText: "Enter E-mail",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email is required";
                              }
                              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                                return "Invalid email format";
                              }
                              return null;
                            }),
                        const SizedBox(height: 20),
                        sectionTitle("Where do you want to set up your Business"),
                        _buildDropdownField(
                            label:"District",
                            options: ["Baksa", "Barpeta", "Bongaigaon", "Cachar", "Charaideo", "Chirang", "Arrange", "Dhemaji", "Dhubri", "Dibrugarh", "Dima Hasao", "Goalpara", "	Golaghat",
                                      "Hailakandi", "Jorhat", "Kamrup Metropolitan", "Kamrup", "Karbi Anglong", "Karimganj", "Kokrajhar", "Lakhimpur", "Majuli", "Morigaon", "Nagaon", "Nalbari", "Sivasagar", "Sonitpur", "South Salmara-Mankachar", "Tinsukia", "West Karbi Anglong", "Biswanath", "Hojai", "Bajali", "Tamulpur", "	Udalguri"],
                            selectedValue: _selectedBusinessDistrict,
                            onChanged:(value) {
                            setState(() {
                              _selectedBusinessDistrict = value;
                          });
                        }),
                        _buildRadioField("Business Activity", ["Existing", "Proposed"], _selectedBusinessActivity, (value) {
                          setState(() {
                            _selectedBusinessActivity = value;
                          });
                        }),
                        _buildTextField(labelText: "Address", myController:  _businessaddressController, hintText: "Enter Address",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            }),
                        _buildRadioField("Have you Availed Any Assistance from Government", ["Yes", "No"], _selectedGovtAssist, (value) {
                          setState(() {
                            _selectedGovtAssist = value;
                          });
                        }),
                        const SizedBox(height: 20),
                        sectionTitle("Highest Academic Qualification"),
                        _buildDropdownField(
                            label: "Degree Name",
                            options:["Graduation", "HS","ITI/Polytechnic/Diploma", "Matriculation", "Post Graduation", "Professional Degree Course" , "Up to Class X"],
                            selectedValue: _selectedDegree,
                            onChanged:(value) {
                            setState(() {
                              _selectedDegree = value;
                          });
                        }),
                        _buildTextField(labelText: "Name of Course", myController:  _courseController, hintText: "Enter Name of Course",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            }),
                        _buildTextField(labelText: "Board/University", myController:  _boardController, hintText: "Enter Board/University",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            }),
                        _buildTextField(labelText: "College/Institution", myController: _collegeController, hintText: "Enter College/Institution",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            }),
                        _buildDateField("Date of Passing", _passingDateController, hintText: "DD/MM/YYYY"),
                        _buildTextField(labelText: "Percentage", myController: _percentageController, hintText: "Enter Percentage",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            }),
                        _buildDropdownField(
                            label: "Division/Class",
                            options: ["First", "Second", "Third"],
                            selectedValue: _selectedDivision,
                            onChanged: (value) {
                            setState(() {
                              _selectedDivision = value;
                          });
                        }),
                        const SizedBox(height: 20),
                        sectionTitle("Bank Details"),
                        _buildTextField(labelText: "Bank Account Number", myController:  _bankAccountController, hintText: "Enter Bank Account Number",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Bank Account Number is required";
                              }
                              if (!RegExp(r'^\d{11,18}$').hasMatch(value)) {
                                return "Invalid account number (11-18 digits)";
                              }
                              return null;
                            }),
                        _buildTextField(labelText: "IFSC Code", myController: _ifscController , hintText: "Enter IFSC Code",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "IFSC Code is required";
                            }
                            if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value)) {
                              return "Invalid IFSC Code (e.g., ABCD0123456)";
                            }
                            return null;
                          }),
                        _buildDropdownField(
                            label: "Name of Bank",
                            options: ["State Bank of India", "Bank of Baroda", "Bank of India", "Canara Bank", "Central Bank of India", "Indian Bank", "Punjab National Bank", "Union Bank of India", "UCO Bank", "Axis Bank", "Bandhan Bank", "Federal Bank", "HDFC Bank", "ICICI Bank", "I"
                              "Kotak Mahindra Bank", "YES Bank", "IDBI Bank"],
                            selectedValue: _selectedBankName,
                            onChanged: (value) {
                            setState(() {
                            _selectedBankName = value;
                          });
                        }),
                        _buildTextField(labelText: "Branch Name", myController: _bankBranchController, hintText: "Enter Branch Name",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            }),
                        _buildTextField(labelText: "Address of the Bank", myController:  _bankAddressController, hintText: "Enter Address of Bank",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "This field is required";
                              }
                              return null;
                            }),
                        sectionTitle("Declaration"),
                        Row(
                          children: [
                            Checkbox(value: _isChecked, onChanged:(value) {
                              setState(() {
                                _isChecked = value ?? false;
                              });
                            },
                            ),
                            const Expanded(child: Text("I hereby certify that all information furnished by me is true,correct and complete. I am not a defaulter of any bank and I am not a beneficiary of CMAAA 1.0.I shall furnish"
                                "all other information/documents that may be required in connection with submission of my application as an when required.I have no"
                                "objection in case my bank details mentioned above are used fpr checking my CIBIL score.The completion of the registration process does not mean the approal"
                                "of the scheme's benefits.No other members of my family(Husband,Wife,Brother or Sister) is a beneficary of CMAAA")),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.drafts, size: 18),
                                label: const Text(
                                  "Save as Draft",
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () async {
                                  await saveDraftData();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Draft Saved!")),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.task_alt_rounded, size: 18),
                                label: const Text(
                                  "Save & Next",
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    print("Form is valid, attempting to save...");
                                    await saveAndNext(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Please fill all required fields!")),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.restart_alt, size: 18),
                                label: const Text(
                                  "Reset",
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: _resetForm,
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
        ],
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
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }


  Widget _buildImagePickerField(String label, String? photoPath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Upload Applicant's Passport Size Photograph",
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        _selectedImage != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            _selectedImage!,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
        )
            : (photoPath != null && photoPath.isNotEmpty)
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(photoPath),
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 100,
            width: 100,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 50, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera),
              label: const Text("Capture"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text("Gallery"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
            ),
            )],
        ),
      ],
    );
  }

Widget _buildTextField({required String labelText, required TextEditingController myController, TextInputType keyboardType = TextInputType.text, String? hintText, String? Function(String?)? validator,}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: myController,
          keyboardType: keyboardType,
          maxLines: keyboardType == TextInputType.multiline ? null : 1,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hintText ?? "Enter $labelText", // Ensuring hintText works
            border: OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          validator: validator,
        ),
      ],
    ),
  );
}


Widget _buildRadioField(String labelText, List<String> options, String? selectedValue, ValueChanged<String?> onChanged) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Row(
          children: options.map((option) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: option,
                  groupValue: selectedValue,
                  onChanged: onChanged,
                ),
                Text(option),
                const SizedBox(width: 10), // Add spacing between options
              ],
            );
          }).toList(),
        ),
      ],
    ),
  );
}


Widget _buildDropdownField({
  required String label,
  required List<String> options,
  required String? selectedValue,
  required void Function(String?) onChanged,
  String? hintText = "Select an option",
  String? Function(String?)? validator,
}){
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: options.contains(selectedValue) ? selectedValue : null,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            hint: Text(hintText!),
            items: options.map((String option) {
              return DropdownMenuItem(
                  value: option,
                  child: Text(option),
              );
            }).toList(),
            isExpanded: true,
            onChanged: onChanged,
            validator: validator ?? (value) => value == null ? 'Required' : null,
          ),
        ),
      ],
    ),
  );
}

  Widget _infoBox(String title, List<String> points) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        border: Border.all(color: Colors.blue, width: 1), // Blue Border
        borderRadius: BorderRadius.circular(8), // Rounded Corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...points.map((point) =>
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                        Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.red,
                            height: 1.4,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
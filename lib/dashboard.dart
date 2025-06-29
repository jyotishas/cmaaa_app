import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:signing/AppAck.dart';
import 'package:signing/form_preview_screen.dart';
import 'acknowledgement.dart';
import 'application_preview_screen.dart';
import 'change_password.dart';
import 'database_helper.dart';
import 'application_form.dart';
import 'package:sqflite/sqflite.dart';
import 'logout.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> registrations = [];
  List<Map<String, dynamic>> applications = [];
  bool isLoading = true;
  String userName = "User";
  bool hasSubmittedApplication() {
    return applications.any((app) => app['status'] == 'Submitted');
  }

  String? _selectedChangeSector = "No";
  String? _selectedNewSector;
  String? _selectedNewSubSector;

  late DatabaseHelper dbHelper;
  int? userId;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    _loadData();
  }

  void _onMenuSelected(BuildContext context, String option) {
    switch (option) {
      case "Change Password":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
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

  Future<void> _loadData() async {
    try {
      print("🚀 Fetching user data...");

      userId = await dbHelper.getLoggedInUserId(); // Use class-level variable
      if (userId == null) {
        print("❌ No logged-in user found!");
        return;
      }

      print("🔎 Fetching user details for user ID: $userId...");
      Map<String, dynamic>? user = await dbHelper.getUserById(userId!);

      print("📤 Fetching registrations...");
      List<Map<String, dynamic>> fetchedRegistrations = await dbHelper.getRegistrations(userId!);

      print("📤 Fetching applications...");
      List<Map<String, dynamic>> fetchedApplications = await dbHelper.getApplications(userId!);

      print("🆔 User : $user");
      print("📜 Registrations Fetched: $fetchedRegistrations");

      if (mounted) {
        setState(() {
          userName = user?['name'] ?? "User";
          registrations = fetchedRegistrations;
          applications = fetchedApplications;
          isLoading = false;
        });
      }
    } catch (e, stacktrace) {
      print("❌ Error fetching user data: $e");
      print("📌 Stacktrace: $stacktrace");
    }
  }


  Future<AcknowledgementData?> getAcknowledgementData(int userId) async {
    final db = await dbHelper.database;

    // Query from registration table
    final regResult = await db.query(
      'registrations',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Query from form_data table
    final formResult = await db.query(
      'form_data',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (regResult.isEmpty || formResult.isEmpty) return null;
    final reg = regResult.first;
    final form = formResult.first;

    final permanentAddress =
        '${form['address1']}, ${form['address2']}, ${form['address3']}';

    return AcknowledgementData(
      reg_No: reg['regNo'] as String,
      submitted_on: reg['submissionDate'] as String,
      applicant_Name: form['applicant_name'] as String,
      permanentadd: permanentAddress,
      ackdistrict: form['district'] as String,
      acklac: form['lac'] as String,
      ackpincode: form['pincode'] as String,
      ackmobile: form['mobile'] as String,
    );
  }

  Future<AppAckData?> getAppAckData(int userId) async {
    final db = await dbHelper.database;

    // Step 1: Query applications table
    final appResult = await db.query(
      'applications',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Step 2: Query form_data table
    final formResult = await db.query(
      'form_data',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Step 3: Query application_data table
    final appDataResult = await db.query(
      'application_data',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Check for missing data
    if (appResult.isEmpty || formResult.isEmpty || appDataResult.isEmpty) return null;

    final app = appResult.first;
    final form = formResult.first;
    final appData = appDataResult.first;

    Map<String, dynamic> preFilledData = {
      'sector': form['sector'],
      'sub_sector': form['sub_sector'],
    };

    print("Selected Change Sector: $_selectedChangeSector");
    print("Selected New Sector: $_selectedNewSector");
    print("Selected New SubSector: $_selectedNewSubSector");
    print("Pre-Filled Data - Sector: ${preFilledData['sector']}");
    print("Pre-Filled Data - SubSector: ${preFilledData['sub_sector']}");

    final String finalSector = _selectedChangeSector == "Yes"
        ? (_selectedNewSector != null && _selectedNewSector!.isNotEmpty
        ? _selectedNewSector
        : preFilledData['sector'] ?? '')
        : (preFilledData['sector'] ?? '');

    final String finalSubSector = _selectedChangeSector == "Yes"
        ? (_selectedNewSubSector != null && _selectedNewSubSector!.isNotEmpty
        ? _selectedNewSubSector
        : preFilledData['sub_sector'] ?? '')
        : (preFilledData['sub_sector'] ?? '');

    final permanentAddress =
        '${form['address1'] ?? ''}, ${form['address2'] ?? ''}, ${form['address3'] ?? ''}';

    final businessAddress =
        '${appData['business_address1'] ?? ''}, ${appData['business_address2'] ?? ''}, ${appData['business_address3'] ?? ''}';


    return AppAckData(
      App_reg_No: app['appRefNo'] as String? ?? '',
      App_applicant_Name: form['applicant_name'] as String? ?? '',
      App_submitted_on: app['submissionDate'] as String? ?? '',
      App_permanentadd: permanentAddress,
      App_sector: finalSector,
      App_subsector: finalSubSector,
      App_bus_address: businessAddress,
      App_district: appData['businessdistrict'] as String? ?? '',
      App_lac: appData['business_lac'] as String? ?? '',
      App_sub_district: appData['business_sub_district'] as String? ?? '',
      App_block: appData['business_block'] as String? ?? '',
      App_pincode: appData['business_pincode'] as String? ?? '',
      App_mobile: appData['business_mobile'] as String? ?? '',
    );
  }



  Future<bool> checkIfDraftExists(int userId) async {
    try {
      final db = await DatabaseHelper().database;
      List<Map<String, dynamic>> drafts = await db.query(
        'application_data',
        where: 'user_id = ? AND status = ? AND form_type = ?',
        whereArgs: [userId, 'incomplete', 'application'],
      );
      return drafts.isNotEmpty;
    } catch (e) {
      debugPrint("⚠️ Error checking draft existence: $e");
      return false;
    }
  }


  void _showLoadingDialog(BuildContext context, String appRefNo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(
              child: Text("Getting Data of $appRefNo. Please Wait....",
              style: TextStyle(
                color: Colors.black, // darker text
                fontWeight: FontWeight.bold, // optional: makes it stand out more
              ),
            ),
            )],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _getTrackingData(String appRefNo) async {
    final dbPath = await getDatabasesPath();
    final db = await openDatabase(join(dbPath, 'users.db'));

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT a.submissionDate, f.applicant_name
    FROM applications a
    JOIN form_data f ON a.user_id = f.user_id
    WHERE a.appRefNo = ?
    LIMIT 1
  ''', [appRefNo]);

    if (result.isNotEmpty) {
      final data = result.first;
      return {
        'processedOn': data['submissionDate'],
        'processedBy': 'Application submission by ${data['applicant_name']}',
        'actionTaken': 'Application Submitted',
        'remarks': 'Application submission by ${data['applicant_name']}',
      };
    } else {
      return null;
    }
  }


  void _showTrackingDialog(BuildContext context, Map<String, dynamic> data, String appRefNo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Application Reference: $appRefNo',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: Text('Field', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataColumn(
                  label: Text('Value', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('Processed on', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(data['processedOn'] ?? '')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Processed by', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(data['processedBy'] ?? '')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Action taken', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(data['actionTaken'] ?? '')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(data['remarks'] ?? '')),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6E6E6E), Color(0xFFF6C2AD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _topNavButton(context, Icons.dashboard, "Dashboard"),
                    _topNavButton(context, Icons.lock, "Change Password"),
                    _topNavButton(context, Icons.exit_to_app, "Logout"),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                        SizedBox(height: 20),
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : _buildRegistrationStatus(registrations),
                        SizedBox(height: 20),
                        SizedBox(height: 20),
                        if (!hasSubmittedApplication()) ...[
                          ElevatedButton.icon(
                            onPressed: () async {
                              int? userId = await dbHelper.getLoggedInUserId();
                              if (userId != null) {
                                bool hasExistingData = await checkIfDraftExists(userId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ApplicationFormScreen(userId: userId, isEditing: hasExistingData),
                                  ),
                                ).then((_) => _loadData());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('User not logged in.')),
                                );
                              }
                            },
                            icon: Icon(Icons.assignment),
                            label: Text("Apply Now"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.deepOrange,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              textStyle: TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 20),
                        _buildApplicationSection(applications),
                      ],
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


  Widget _buildRegistrationStatus(List<Map<String, dynamic>> registrations) {
    if (registrations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text("No Registration Found!",
                style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    var registration = registrations.first;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("CMAAA 2.0",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
                "Your registration for the Chief Minister's Atmanirbhar Asom Abhijan 2.0 has been successfully completed.",
                style: TextStyle(color: Colors.blue)),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(columns: [
                DataColumn(label: Text("Registration No")),
                DataColumn(label: Text("Scheme Name")),
                DataColumn(label: Text("Submission Date")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Action")),
              ], rows: [
                DataRow(cells: [
                  DataCell(
                      Text(registration['regNo'],
                          style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,)),
                      onTap: () {
                        int? userId = registration['user_id'];

                        if (userId != null && userId > 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormPreviewScreen(userId: userId),
                            ),
                          );
                        } else {
                          debugPrint("❌ Invalid userId in registration: $userId");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Unable to open form preview. Invalid user ID.')),
                          );
                        }
                      },),
                  DataCell(Text(registration['schemeName'])),
                  DataCell(Text(registration['submissionDate'])),
                  DataCell(Text(registration['status'],
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold,))),
                  DataCell(
                    Icon(Icons.download, color: Colors.green),
                      onTap: () async {
                        final regUserId = registration['user_id'];
                        int? userId;

                        if (regUserId is int) {
                          userId = regUserId;
                        } else if (regUserId is String) {
                          userId = int.tryParse(regUserId);
                        }

                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Invalid user ID format.')),
                          );
                          return;
                        }

                        final data = await getAcknowledgementData(userId);
                        if (data != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AcknowledgementReg(data: data),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                'Acknowledgement data not found.')),
                          );
                        }
                      }
                      ),

                ],
              ),
            ]))],
        ),
      ),
    );
  }


  Widget _buildApplicationSection(List<Map<String, dynamic>> applications) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text("No Application Found!",
                style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    var application = applications.first;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Application for Chief Minister's Atmanirbhar Asom Abhiyan 2.0",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "You have successfully submitted your application for the Chief Minister's Atmanirbhar Asom Abhijan 2.0.",
              style: TextStyle(color: Colors.blue),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text("Application Reference No")),
                  DataColumn(label: Text("Scheme Name")),
                  DataColumn(label: Text("Submission Date")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Action")),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(
                          Text(application['appRefNo'],
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,)),
                          onTap: () {
                            int? userId = application['user_id'];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ApplicationPreviewScreen(userId: userId),
                              ),
                            );
                          },),
                    DataCell(Text(application['schemeName'])),
                    DataCell(Text(application['submissionDate'])),
                    DataCell(
                      Text(
                        application['status'],
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final regUserId = application['user_id'];
                              int? userId;

                              if (regUserId is int) {
                                userId = regUserId;
                              } else if (regUserId is String) {
                                userId = int.tryParse(regUserId);
                              }

                              if (userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Invalid user ID format.')),
                                );
                                return;
                              }

                              final data = await getAppAckData(userId);
                              if (data != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AppAck(data: data),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Acknowledgement data not found.')),
                                );
                              }
                            },
                            child: Icon(Icons.download, color: Colors.green),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                              onTap: () async {
                                final appRefNo = application['appRefNo'];
                                _showLoadingDialog(context, appRefNo);

                                final trackingData = await _getTrackingData(application['appRefNo']);

                                await Future.delayed(Duration(seconds: 2)); // optional wait for UX

                                Navigator.of(context).pop(); // Dismiss loading dialog

                                if (trackingData != null) {
                                  _showTrackingDialog(context, trackingData, application['appRefNo']);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('No tracking data found for this application.')),
                                  );
                                }
                              },
                              child: Icon(Icons.track_changes_outlined, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ])
                ],
              ),
            )],
        ),
      ),
    );
  }
}

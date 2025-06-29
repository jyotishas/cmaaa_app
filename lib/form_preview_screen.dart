import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'database_helper.dart';
import 'change_password.dart';
import 'dashboard.dart';
import 'logout.dart';
import 'dart:io';


class FormPreviewScreen extends StatefulWidget {
  final int? userId;

  const FormPreviewScreen({Key? key, this.userId}) : super(key: key);

  @override
  _FormPreviewScreenState createState() => _FormPreviewScreenState();
}

class _FormPreviewScreenState extends State<FormPreviewScreen> {
  Map<String, dynamic>? formData;

  @override
  void initState() {
    super.initState();
    _fetchFormData();
  }

  Future<void> _fetchFormData() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    debugPrint("🔍 Fetching data for userId: ${widget.userId}");
    Map<String, dynamic>? data = await dbHelper.getFormDataByUserId(widget.userId!);
    debugPrint("📦 Fetched Data: $data");
    setState(() {
        formData = data;
    });
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

  void _onMenuSelected(BuildContext context, String option) {
    switch (option) {
      case "Dashboard":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
        break;
      case "Change Password":
        Navigator.pushReplacement(
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

  @override
  Widget build(BuildContext context) {
    if (formData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (formData!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No form data found.")),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6E6E6E), Color(0xFFF6C2AD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildFormContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Registration Form Preview: Verify Your Information",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),

        _buildSectionBox("Information About Applicant", [
          _buildDetailRow("Name of the Applicant : ", formData?['applicant_name']),
          _buildDetailRow("Father's Name : ", formData?['father_name']),
          _buildDetailRow("Applicant's Gender : ", formData?['gender']),
          _buildDetailRow("Social Category : ", formData?['social_category']),
          _buildDetailRow("Date of Birth : ", formData?['dob']),
          _buildDetailRow("PAN Number : ", formData?['pan_number']),
          _buildDetailRow("Employment Exchange No. : ", formData?['employment_exchange_no']),
          _buildDetailRow("BPL : ", formData?['bpl'] == '1' ? "Yes" : "No"),
          _buildDetailRow("Marital Status : ", formData?['marital_status']),
          _buildDetailRow("Select Sector : ", formData?['sector']),
          _buildDetailRow("Select Sub Sector : ", formData?['sub_sector']),
          _buildDetailRow("Type of Trade : ", formData?['trade_type']),
          _buildPhotoRow("Applicant's Passport Size Photo : ", formData?['photo']),
        ]),

        _buildSectionBox("Permanent Address with Mobile No", [
          _buildDetailRow("Address Line 1 : ", formData?['address1']),
          _buildDetailRow("Address Line 2 : ", formData?['address2']),
          _buildDetailRow("Address Line 3 : ", formData?['address3']),
          _buildDetailRow("State : ", formData?['state']),
          _buildDetailRow("District : ", formData?['district']),
          _buildDetailRow("LAC : ", formData?['lac']),
          _buildDetailRow("Sub District : ", formData?['co_district']),
          _buildDetailRow("Pincode : ", formData?['pincode']),
          _buildDetailRow("Mobile Number : ", formData?['mobile']),
          _buildDetailRow("Email : ", formData?['email']),
        ]),

        _buildSectionBox("Where do you want to set up your Business", [
          _buildDetailRow("District : ", formData?['business_district']),
          _buildDetailRow("Address : ", formData?['business_address']),
          _buildDetailRow(
            "Business Activity :",
            formData?['business_activity'] == "Existing" ? "Existing" : "Proposed",
          ),
          _buildDetailRow("Have you Availed Any Assistance : ", formData?['assistance'] == '1' ? "Yes" : "No"),
        ]),

        _buildSectionBox("Highest Academic Qualification", [
          _buildDetailRow("Degree Name : ", formData?['degree']),
          _buildDetailRow("Name of Course : ", formData?['course']),
          _buildDetailRow("Board/University: ", formData?['board']),
          _buildDetailRow("College/Institution : ", formData?['college']),
          _buildDetailRow("Date of Passing : ", formData?['passing_date']),
          _buildDetailRow("Percentage : ", formData?['percentage']),
          _buildDetailRow("Division/Class : ", formData?['division']),
        ]),

        _buildSectionBox("Bank Details", [
          _buildDetailRow("Bank Account Number : ", formData?['bank_account']),
          _buildDetailRow("IFSC Code : ", formData?['ifsc']),
          _buildDetailRow("Name of Bank : ", formData?['bank_name']),
          _buildDetailRow("Branch Name : ", formData?['bank_branch']),
          _buildDetailRow("Address of the Bank : ", formData?['bank_address']),
        ]),

        _buildSectionBox("Declaration", [
          _buildDeclaration()
        ]),

        const SizedBox(height: 20),
        _buildPrintButton(),
      ],
    );
  }

  Widget _buildSectionBox(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(5), // Slightly rounded corners
        border: Border.all(
          color: Colors.green.shade700, // Green border like in your screenshot
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }


  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Value
          Expanded(
            flex: 5,
            child: Text(
              value?.isNotEmpty == true ? value! : "N/A",
              style: const TextStyle(
                fontSize: 14.2,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDeclaration() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(value: true, onChanged: (value) {}), // Always checked
              const Expanded(
                child: Text(
                  "I hereby certify that all information furnished by me is true, correct, and complete. "
                      "I am not a defaulter of any bank and I am not a beneficiary of CMAAA 1.0. "
                      "I shall furnish all other information/documents that may be required in connection with "
                      "submission of my application. I have no objection in case my bank details are used for checking my CIBIL score. "
                      "The completion of registration does not mean scheme approval.",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoRow(String label, String? path) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: path != null && File(path).existsSync()
                ? Image.file(
              File(path),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            )
                : Text(
              "No photo available",
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPrintButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.print, color: Colors.black),
        label: const Text("Print", style: TextStyle(color: Colors.black)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        onPressed: () {
          _printForm(); // Add printing functionality here
        },
      ),
    );
  }

  void _printForm() async {
    final pdf = pw.Document();

    Uint8List? photoBytes;
    final photoPath = formData?['photo'];

    // Only try to read photo if path exists and file exists
    if (photoPath != null && File(photoPath).existsSync()) {
      photoBytes = await File(photoPath).readAsBytes();
    }


    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Header row with title on left and photo on right
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Title text takes most of the width
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Text(
                      "Registration Form Preview",
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                      pw.Text(
                          "Information About Applicant",
                            style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal800,
                          ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left side: Applicant details
                      pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children : [
                      _buildPdfDetailRow("Name of the Applicant", formData?['applicant_name']),
                      _buildPdfDetailRow("Father's Name", formData?['father_name']),
                      _buildPdfDetailRow("Gender", formData?['gender']),
                      _buildPdfDetailRow("Social Category", formData?['social_category']),
                      _buildPdfDetailRow("Date of Birth", formData?['dob']),
                      _buildPdfDetailRow("PAN Number", formData?['pan_number']),
                      _buildPdfDetailRow("Employment Exchange No.", formData?['employment_exchange_no']),
                      _buildPdfDetailRow("BPL", formData?['bpl'] == '1' ? 'Yes' : 'No'),
                      _buildPdfDetailRow("Marital Status", formData?['marital_status']),
                      _buildPdfDetailRow("Sector", formData?['sector']),
                      _buildPdfDetailRow("Sub Sector", formData?['sub_sector']),
                      _buildPdfDetailRow("Type of Trade", formData?['trade_type']),
                      ],
                    ),
                    ),
                        pw.SizedBox(width: 15),

                       // Right side: Photo container
                        pw.Container(
                        width: 120,
                        height: 150,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey),
                        ),
                        child: photoBytes != null
                            ? pw.Image(pw.MemoryImage(photoBytes), fit: pw.BoxFit.cover)
                            : pw.Center(child: pw.Text("No Photo")),
                        ),
                       ],
                      ),
                  ],
                ),
            ),

                pw.SizedBox(height: 20),

                    _buildPdfSection("Permanent Address with Mobile No", [
                      _buildPdfDetailRow("Address Line 1", formData?['address1']),
                      _buildPdfDetailRow("Address Line 2", formData?['address2']),
                      _buildPdfDetailRow("Address Line 3", formData?['address3']),
                      _buildPdfDetailRow("State", formData?['state']),
                      _buildPdfDetailRow("District", formData?['district']),
                      _buildPdfDetailRow("LAC", formData?['lac']),
                      _buildPdfDetailRow("Sub District", formData?['co_district']),
                      _buildPdfDetailRow("Pincode", formData?['pincode']),
                      _buildPdfDetailRow("Mobile Number", formData?['mobile']),
                      _buildPdfDetailRow("Email", formData?['email']),
                    ]),

                    _buildPdfSection("Where do you want to set up your Business", [
                      _buildPdfDetailRow("District", formData?['business_district']),
                      _buildPdfDetailRow("Address", formData?['business_address']),
                      _buildPdfDetailRow("Business Activity", formData?['business_activity'] ?? "Proposed"),
                      _buildPdfDetailRow("Have you Availed Any Assistance", formData?['assistance'] == '1' ? "Yes" : "No"),
                    ]),

                    _buildPdfSection("Highest Academic Qualification", [
                      _buildPdfDetailRow("Degree Name", formData?['degree']),
                      _buildPdfDetailRow("Course", formData?['course']),
                      _buildPdfDetailRow("Board/University", formData?['board']),
                      _buildPdfDetailRow("College/Institution", formData?['college']),
                      _buildPdfDetailRow("Date of Passing", formData?['passing_date']),
                      _buildPdfDetailRow("Percentage", formData?['percentage']),
                      _buildPdfDetailRow("Division/Class", formData?['division']),
                    ]),

                    _buildPdfSection("Bank Details", [
                      _buildPdfDetailRow("Bank Account Number", formData?['bank_account']),
                      _buildPdfDetailRow("IFSC Code", formData?['ifsc']),
                      _buildPdfDetailRow("Bank Name", formData?['bank_name']),
                      _buildPdfDetailRow("Branch Name", formData?['bank_branch']),
                      _buildPdfDetailRow("Bank Address", formData?['bank_address']),
                    ]),

                    _buildPdfSection("Declaration", [
                      pw.Text(
                        "I hereby certify that all information furnished by me is true, correct, and complete. "
                            "I am not a defaulter of any bank and I am not a beneficiary of CMAAA 1.0. "
                            "I shall furnish all other information/documents that may be required in connection with "
                            "submission of my application. I have no objection in case my bank details are used for checking my CIBIL score. "
                            "The completion of registration does not mean scheme approval.",
                        style: pw.TextStyle(fontSize: 12),
              ),
            ]),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }


  pw.Widget _buildPdfSection(String title, List<pw.Widget> children,) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 10),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue700, width: 1.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Wrap(
        crossAxisAlignment: pw.WrapCrossAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800,),
          ),
          pw.Spacer(),
          ...children,
          pw.Spacer(),
        ],
      ),
    );
  }


  pw.Widget _buildPdfDetailRow(String label, String? value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text("$label:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(
            flex: 5,
            child: pw.Text(value ?? "N/A"),
          ),
        ],
      ),
    );
  }
}

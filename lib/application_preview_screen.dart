import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mime/mime.dart';
import 'database_helper.dart';
import 'change_password.dart';
import 'dart:typed_data';
import 'dashboard.dart';
import 'logout.dart';
import 'dart:io';

class ApplicationPreviewScreen extends StatefulWidget {
  final int? userId;

  const ApplicationPreviewScreen({super.key, this.userId});

  @override
  _ApplicationPreviewScreenState createState() => _ApplicationPreviewScreenState();
}

class _ApplicationPreviewScreenState extends State<ApplicationPreviewScreen> {
  Map<String, dynamic>? applicationData;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _fetchApplicationData();
    } else {
      debugPrint("❗ userId is null. Cannot fetch application data.");
    }
  }

  Future<void> _fetchApplicationData() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    debugPrint("🔍 Fetching data for userId: ${widget.userId}");
    Map<String, dynamic>? data = await dbHelper.getCombinedUserData(widget.userId!);
    debugPrint("📦 Fetched Data: $data");
    setState(() {
      applicationData = data;
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
    if (applicationData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (applicationData!.isEmpty) {
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
            "Application Form Preview: Verify Your Information",
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
          _buildDetailRow("Name of the Applicant : ", applicationData?['applicant_name']),
          _buildDetailRow("Father's Name : ", applicationData?['father_name']),
          _buildDetailRow("Applicant's Gender : ", applicationData?['gender']),
          _buildDetailRow("Social Category : ", applicationData?['social_category']),
          _buildDetailRow("Date of Birth : ", applicationData?['dob']),
          _buildDetailRow("PAN Number : ", applicationData?['pan_number']),
          _buildDetailRow("Employment Exchange No. : ", applicationData?['employment_exchange_no']),
          _buildDetailRow("BPL : ", applicationData?['bpl'] == '1' ? "Yes" : "No"),
          _buildDetailRow("Marital Status : ", applicationData?['marital_status']),
          _buildDetailRow("Select Sector : ", applicationData?['sector']),
          _buildDetailRow("Select Sub Sector : ", applicationData?['sub_sector']),
          _buildDetailRow("Type of Trade : ", applicationData?['trade_type']),
          _buildPhotoRow("Applicant's Passport Size Photo : ", applicationData?['photo'])
        ]),

        _buildSectionBox("Permanent Address with Mobile No", [
          _buildDetailRow("Address Line 1 : ", applicationData?['address1']),
          _buildDetailRow("Address Line 2 : ", applicationData?['address2']),
          _buildDetailRow("Address Line 3 : ", applicationData?['address3']),
          _buildDetailRow("State : ", applicationData?['state']),
          _buildDetailRow("District : ", applicationData?['district']),
          _buildDetailRow("LAC : ", applicationData?['lac']),
          _buildDetailRow("Sub District : ", applicationData?['co_district']),
          _buildDetailRow("Pincode : ", applicationData?['pincode']),
          _buildDetailRow("Mobile Number : ", applicationData?['mobile']),
          _buildDetailRow("Email : ", applicationData?['email']),
        ]),

        _buildSectionBox("Highest Academic Qualification", [
          _buildDetailRow("Degree Name : ", applicationData?['degree']),
          _buildDetailRow("Name of Course : ", applicationData?['course']),
          _buildDetailRow("Board/University: ", applicationData?['board']),
          _buildDetailRow("College/Institution : ", applicationData?['college']),
          _buildDetailRow("Date of Passing : ", applicationData?['passing_date']),
          _buildDetailRow("Percentage : ", applicationData?['percentage']),
          _buildDetailRow("Division/Class : ", applicationData?['division']),
        ]),

        _buildSectionBox("Bank Details", [
          _buildDetailRow("Bank Account Number : ", applicationData?['bank_account']),
          _buildDetailRow("IFSC Code : ", applicationData?['ifsc']),
          _buildDetailRow("Name of Bank : ", applicationData?['bank_name']),
          _buildDetailRow("Branch Name : ", applicationData?['bank_branch']),
          _buildDetailRow("Address of the Bank : ", applicationData?['bank_address']),
        ]),

        const SizedBox(height: 20),
        _buildSectionBox("Business Details",[
        _buildEmploymentSection(),
        const SizedBox(height: 10),
        _buildEntrepreneurshipSection(),
        const SizedBox(height: 10),
        _buildDetailRow("Business Activity : ", applicationData?['business_activity']),
        const SizedBox(height: 10),
        _buildConditionalPreview(),
        const SizedBox(height: 10),
        _buildCommunicationAddressSection(),
        const SizedBox(height: 10),
        _buildUnitRegistrationSection()  ,
        ]),

        const SizedBox(height: 20),
        _buildSectionBox("Business Plan",[
        _buildDetailRow("Briefly Describe Your Business Plan : ", applicationData?['business_plan']),
         const SizedBox(height: 10),
        _buildDetailRow("Sector selected in the Registration Form : ", applicationData?['sector']),
         const SizedBox(height: 10),
        _buildDetailRow("Sub Sector selected in the Registration Form : ", applicationData?['sub_sector']),
         const SizedBox(height: 10),
        _buildSectorChangePreviewSection(),
         const SizedBox(height: 10),
        _buildProjectReportPreviewSection(),
          const SizedBox(height: 10),
        _buildDetailRow("Proposed Project Cost : ", applicationData?['proposed_project_cost']),
          const SizedBox(height: 10),
        _buildDetailRow("Amount anticipated as Bank Loan (in Rs.), if any : ", applicationData?['amount_anticipated']),
          const SizedBox(height: 10),
        _buildDetailRow("Self Contribution (in Rs.), if any : ", applicationData?['self_contribution']),
          const SizedBox(height: 10),
        _buildDetailRow("DPR Amount : ", applicationData?['dpr_amount']),
          const SizedBox(height: 10),
        _buildLandAvailabilityPreviewSection(),
          const SizedBox(height: 10),
        _buildPreviousExperiencePreviewSection(),
          const SizedBox(height: 10),
        _buildSkillTrainingExperiencePreviewSection(),
        const SizedBox(height: 10),
        _buildSkillTrainingRequirementPreviewSection(),
        const SizedBox(height: 10),
        _buildDetailRow("Manpower requirement for business (including self) : ", applicationData?['manpower_req']),
          const SizedBox(height: 10),
        _buildDetailRow("Power requirement in KW : ", applicationData?['power_req']),
          const SizedBox(height: 10),
        ]),

        const SizedBox(height: 20),
        _buildSectionBox("ATTACH ENCLOSURE(S)",[
        _buildAttachmentEnclosuresPreviewSection() ,
      ]),

        const SizedBox(height: 20),
        _buildSectionBox("Declaration",[
        _buildDeclarationPreview(),
        ]),

        const SizedBox(height: 20),
        _buildPrintButton(),
      ]);
  }

  Widget _buildEmploymentSection() {
    String currentlyEmployed = (applicationData?['currently_employed'] ?? "No").toString().trim();

    List<Widget> children = [
      _buildPreFilledField("Currently Employed ", currentlyEmployed),
    ];

    if (currentlyEmployed == "Yes") {
      children.addAll([
        _buildPreFilledField("Employer Name ", applicationData?['employer_name'] ?? 'Not Provided'),
        _buildPreFilledField("Employer Type ", applicationData?['employer_type'] ?? 'Not Provided'),
        _buildPreFilledField("Employer Address ", applicationData?['employer_address'] ?? 'Not Provided'),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildEntrepreneurshipSection() {
    String isFirstTime = (applicationData?['first_time_entrepreneur'] ?? "Yes").toString().trim();

    List<Widget> children = [
      _buildPreFilledField("Are you first time Entrepreneur ", isFirstTime),
    ];

    if (isFirstTime == "No") {
      children.addAll([
        _buildPreFilledField("Previous Sector ", applicationData?['previous_sector'] ?? 'Not Provided'),
        _buildPreFilledField("Previous Business Description ", applicationData?['previous_business_description'] ?? 'Not Provided'),
        _buildPreFilledField("Availed Any Govt Assistance ", applicationData?['govt_assistance'] ?? 'Not Provided'),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children : children,
    );
  }


  Widget _buildConditionalPreview() {
    if (applicationData == null) {
      return const Text("No data available.");
    }

    String businessActivity = applicationData!['business_activity'] ?? '';

    if (businessActivity == 'Proposed') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreFilledField("Date of Commencement :",
              "${applicationData?['proposed_month'] ?? 'Not selected'} ${applicationData?['proposed_year'] ?? 'Not selected'}"),
          _buildPreFilledField("Proposed Name of the Enterprise ", applicationData?['proposed_name'] ?? "Not provided"),
          _buildPreFilledField("Type of Enterprise", applicationData?['type_of_enterprise'] ?? "Not selected"),
          const SizedBox(height: 10),
          const Text(
            "Proposed Business Address",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildPreFilledField("Address Line 1 ", applicationData?['business_address1'] ?? "Not provided"),
          _buildPreFilledField("Address Line 2 ", applicationData?['business_address2'] ?? "Not provided"),
          _buildPreFilledField("Address Line 3 ", applicationData?['business_address3'] ?? "Not provided"),
          _buildPreFilledField("State ", applicationData?['business_state'] ?? "Not selected"),
          _buildPreFilledField("District ", applicationData?['businessdistrict'] ?? "Not selected"),
          _buildPreFilledField("Legislative Assembly Constituency (LAC) ", applicationData?['business_lac'] ?? "Not selected"),
          _buildPreFilledField("Sub District ", applicationData?['business_sub_district'] ?? "Not selected"),
          _buildPreFilledField("Block ", applicationData?['business_block'] ?? "Not selected"),
          _buildPreFilledField("Pincode ", applicationData?['business_pincode'] ?? "Not provided"),
          _buildPreFilledField("Landmark Details ", applicationData?['landmark_details'] ?? "Not provided"),
          _buildPreFilledField("Mobile Number ", applicationData?['business_mobile'] ?? "Not provided"),
        ],
      );
    }

    if (businessActivity == 'Existing') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreFilledField("Existing Business Activity Location ", applicationData?['existing_bus_loc'] ?? "Not selected"),
          _buildPreFilledField("Date of Commencement ",
              "${applicationData?['existing_month'] ?? 'Not selected'} ${applicationData?['existing_year'] ?? 'Not selected'}"),
          _buildPreFilledField("Name of the Existing Enterprise ", applicationData?['existing_name'] ?? "Not provided"),
          _buildPreFilledField("Type of Enterprise", applicationData?['type_of_enterprise'] ?? "Not selected"),
          const SizedBox(height: 10),
          const Text(
            "Existing Business Address",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildPreFilledField("Address Line 1 ", applicationData?['business_address1'] ?? "Not provided"),
          _buildPreFilledField("Address Line 2 ", applicationData?['business_address2'] ?? "Not provided"),
          _buildPreFilledField("Address Line 3 ", applicationData?['business_address3'] ?? "Not provided"),
          _buildPreFilledField("State ", applicationData?['business_state'] ?? "Not selected"),
          _buildPreFilledField("District ", applicationData?['businessdistrict'] ?? "Not selected"),
          _buildPreFilledField("Legislative Assembly Constituency (LAC) ", applicationData?['business_lac'] ?? "Not selected"),
          _buildPreFilledField("Sub District ", applicationData?['business_sub_district'] ?? "Not selected"),
          _buildPreFilledField("Block ", applicationData?['business_block'] ?? "Not selected"),
          _buildPreFilledField("Pincode ", applicationData?['business_pincode'] ?? "Not provided"),
          _buildPreFilledField("Landmark Details ", applicationData?['landmark_details'] ?? "Not provided"),
          _buildPreFilledField("Mobile Number ", applicationData?['business_mobile'] ?? "Not provided"),
        ],
      );
    }

    return const Text("Invalid business activity.");
  }

  Widget _buildCommunicationAddressSection() {
    List<Widget> children = [
      const Padding(
        padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
        child: Text(
          "Communication Address",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(height: 10),
      _buildPreFilledField("Address Line 1 ", applicationData?['communication_address1'] ?? 'Not Provided'),
      _buildPreFilledField("Address Line 2 ", applicationData?['communication_address2'] ?? 'Not Provided'),
      _buildPreFilledField("Address Line 3 ", applicationData?['communication_address3'] ?? 'Not Provided'),
      _buildPreFilledField("State ", applicationData?['communication_state'] ?? 'Not Provided'),
      _buildPreFilledField("District ", applicationData?['communication_district'] ?? 'Not Provided'),
      _buildPreFilledField("Legislative Assembly Constituency (LAC) ", applicationData?['communication_lac'] ?? 'Not Provided'),
      _buildPreFilledField("Sub District ", applicationData?['communication_sub_district'] ?? 'Not Provided'),
      _buildPreFilledField("Block ", applicationData?['communication_block'] ?? 'Not Provided'),
      _buildPreFilledField("Pincode ", applicationData?['communication_pincode'] ?? 'Not Provided'),
      _buildPreFilledField("Landmark ", applicationData?['communication_landmark'] ?? 'Not Provided'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children : children,
    );
  }

  Widget _buildUnitRegistrationSection() {
    String unitRegistered = (applicationData?['unit_registered'] ?? "No").toString().trim();

    List<Widget> children = [
      _buildPreFilledField("Whether Unit is Registered ", unitRegistered),
    ];

    if (unitRegistered == "Yes") {
      children.add(
        _buildPreFilledField(
          "UDYAM Registration No. ",
          applicationData?['udyam_reg_no'] ?? 'Not Provided',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children : children,
    );
  }

  Widget _buildSectorChangePreviewSection() {
    String wantToChangeSector = (applicationData?['change_sector'] ?? 'No').toString().trim();

    List<Widget> children = [
      _buildPreFilledField("Do you want to change the sector ", wantToChangeSector),
    ];

    if (wantToChangeSector == "Yes") {
      children.addAll([
        _buildPreFilledField("New Sector ", applicationData?['new_sector'] ?? 'Not Provided'),
        _buildPreFilledField("New Sub-Sector ", applicationData?['new_sub_sector'] ?? 'Not Provided'),
        _buildPreFilledField("Type of Trade ", applicationData?['type_of_trade'] ?? 'Not Provided'),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children : children,
    );
  }

  Widget _buildProjectReportPreviewSection() {
    String hasPreparedReport = (applicationData?['has_prepared_project_report'] ?? 'No').toString().trim();

    List<Widget> children = [
      _buildPreFilledField("Have you prepared the Project Report ", hasPreparedReport),
    ];

    if (hasPreparedReport == "Yes") {
      String isAsPerFormat = (applicationData?['project_report_format'] ?? 'Not Provided').toString().trim();
      String projectNo = applicationData?['project_no'] ?? 'Not Provided';
      String uploadedReportFile = applicationData?['project_report'] ?? 'File not uploaded';

      children.addAll([
        _buildPreFilledField("Is the project report as per CMAAA format ", isAsPerFormat),
        _buildPreFilledField("Enter Project No ", projectNo),
        _buildPreFilledField("Uploaded Project Report" , uploadedReportFile),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children : children,
    );
  }

  Widget _buildLandAvailabilityPreviewSection() {
    String landAvailability = (applicationData?['land_availability'] ?? 'No').toString().trim();
    String landArrangement = applicationData?['land_arrangement'] ?? 'Not Provided';
    String landArea = applicationData?['land_area'] ?? 'Not Provided';
    String uploadedLandDoc = applicationData?['land_doc'] ?? 'No document uploaded';

    List<Widget> children = [
      _buildPreFilledField("Land/Building Availability for Business Establishment ", landAvailability),
    ];

    if (landAvailability == "No") {
      children.addAll([
        _buildPreFilledField("Proposed Land/Building Arrangement ", landArrangement),
      ]);
    }

    if (landAvailability == "Yes") {
      children.addAll([
        _buildPreFilledField("Existing Land/Building Arrangement ", landArrangement),
        _buildPreFilledField("Land/Building Area (in sqft) ", landArea),
        _buildPreFilledField("Uploaded Land Document ", uploadedLandDoc),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children : children,
    );
  }

  Widget _buildPreviousExperiencePreviewSection() {
    String prevExperience = (applicationData?['previous_exp'] ?? 'No').toString().trim();
    String yearsOfExperience = applicationData?['years_expe'] ?? 'Not Provided';
    String uploadedExperienceDoc = applicationData?['exp_proof'] ?? 'No document uploaded';

    List<Widget> children = [
      _buildPreFilledField("Previous Experience in Similar Sector ", prevExperience),
    ];

    if (prevExperience == "Yes") {
      children.addAll([
        _buildPreFilledField("Years of Experience ", yearsOfExperience),
        _buildPreFilledField("Uploaded Experience Certification ", uploadedExperienceDoc),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildSkillTrainingExperiencePreviewSection() {
    String skillTrainingExperience = (applicationData?['skill_training'] ?? 'No').toString().trim();
    String uploadedSuppDoc = applicationData?['supporting_doc'] ?? 'No document uploaded';
    String institutionName = applicationData?['institution_name'] ?? 'Not Provided';
    String trainingName = applicationData?['training_name'] ?? 'Not Provided';
    String trainingDuration = applicationData?['training_duration'] ?? 'Not Provided';


    List<Widget> children = [
      _buildPreFilledField("Skill Training Experience in the Selected Sector ", skillTrainingExperience),
    ];

    if (skillTrainingExperience == "Yes") {
      children.addAll([
        _buildPreFilledField("Uploaded Supporting Document ", uploadedSuppDoc),
        _buildPreFilledField("Institution Name ", institutionName),
        _buildPreFilledField("Training Name ", trainingName),
        _buildPreFilledField("Training Duration (in months) ", trainingDuration),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildSkillTrainingRequirementPreviewSection() {
    final String skillTraining = applicationData?['skill_training_req'] ?? 'Not Provided';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPreFilledField("Skill Training Requirement ", skillTraining),
      ],
    );
  }

  Widget _buildAttachmentEnclosuresPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFileThumbnail("Identity Proof ", applicationData?['identity_proof']),
        _buildFileThumbnail("Address Proof of the Applicant ", applicationData?['address_proof']),
        _buildFileThumbnail("Education Qualification ", applicationData?['qualification_proof']),
        _buildFileThumbnail("Employment Exchange Registration Card ", applicationData?['emp_exchange_reg_card']),
        _buildFileThumbnail("Bank Passbook/Cancelled Check Book ", applicationData?['bank_passbook']),
        _buildFileThumbnail("PAN Card ", applicationData?['pan_card']),
      ],
    );
  }

  Widget _buildFileThumbnail(String label, String? filePath) {
    if (filePath == null || filePath.isEmpty) {
      return _buildPreFilledField(label, "Not Uploaded");
    }

    final mimeType = lookupMimeType(filePath);
    final isImage = mimeType != null && mimeType.startsWith('image');
    final isPDF = mimeType == 'application/pdf';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
        ),
        const SizedBox(height: 6),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: isImage
              ? Image.file(File(filePath), height: 120, fit: BoxFit.cover)
              : Row(
            children: [
              Icon(isPDF ? Icons.picture_as_pdf : Icons.insert_drive_file, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  filePath.split('/').last,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeclarationPreview() {
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
                  "I hereby certify that all information furnished by me is true, correct and complete. "
                      "I am not a defaulter of any bank. Mere submission of the application form under this scheme "
                      "does not guarantee benefits under this scheme. I am aware that any misrepresentation "
                      "or omission of facts may result in the rejection of my application or subsequent actions as per the applicable laws.",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
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

  Widget _buildPreFilledField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(value),
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
                : Text("  No photo available",
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
          _printForm();
        },
      ),
    );
  }

  void _printForm() async {
    final pdf = pw.Document();

    Uint8List? photoBytes;
    final photoPath = applicationData?['photo'];

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
                            "Application Form Preview",
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
                          _buildPdfDetailRow("Name of the Applicant", applicationData?['applicant_name']),
                          _buildPdfDetailRow("Father's Name", applicationData?['father_name']),
                          _buildPdfDetailRow("Gender", applicationData?['gender']),
                          _buildPdfDetailRow("Social Category", applicationData?['social_category']),
                          _buildPdfDetailRow("Date of Birth", applicationData?['dob']),
                          _buildPdfDetailRow("PAN Number", applicationData?['pan_number']),
                          _buildPdfDetailRow("Employment Exchange No.", applicationData?['employment_exchange_no']),
                          _buildPdfDetailRow("BPL", applicationData?['bpl'] == '1' ? 'Yes' : 'No'),
                          _buildPdfDetailRow("Marital Status", applicationData?['marital_status']),
                          _buildPdfDetailRow("Sector", applicationData?['sector']),
                          _buildPdfDetailRow("Sub Sector", applicationData?['sub_sector']),
                          _buildPdfDetailRow("Type of Trade", applicationData?['trade_type']),
                           ],
                         ),),
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
                        _buildPdfDetailRow("Address Line 1", applicationData?['address1']),
                        _buildPdfDetailRow("Address Line 2", applicationData?['address2']),
                        _buildPdfDetailRow("Address Line 3", applicationData?['address3']),
                        _buildPdfDetailRow("State", applicationData?['state']),
                        _buildPdfDetailRow("District", applicationData?['district']),
                        _buildPdfDetailRow("LAC", applicationData?['lac']),
                        _buildPdfDetailRow("Sub District", applicationData?['co_district']),
                        _buildPdfDetailRow("Pincode", applicationData?['pincode']),
                        _buildPdfDetailRow("Mobile Number", applicationData?['mobile']),
                        _buildPdfDetailRow("Email", applicationData?['email']),
                        ]),

                        pw.SizedBox(height: 25),

                        _buildPdfSection("Highest Academic Qualification", [
                        _buildPdfDetailRow("Degree Name", applicationData?['degree']),
                        _buildPdfDetailRow("Course", applicationData?['course']),
                        _buildPdfDetailRow("Board/University", applicationData?['board']),
                        _buildPdfDetailRow("College/Institution", applicationData?['college']),
                        _buildPdfDetailRow("Date of Passing", applicationData?['passing_date']),
                        _buildPdfDetailRow("Percentage", applicationData?['percentage']),
                        _buildPdfDetailRow("Division/Class", applicationData?['division']),
                        ]),

                        _buildPdfSection("Bank Details", [
                        _buildPdfDetailRow("Bank Account Number", applicationData?['bank_account']),
                        _buildPdfDetailRow("IFSC Code", applicationData?['ifsc']),
                        _buildPdfDetailRow("Bank Name", applicationData?['bank_name']),
                        _buildPdfDetailRow("Branch Name", applicationData?['bank_branch']),
                        _buildPdfDetailRow("Bank Address", applicationData?['bank_address']),
                        ]),


                        _buildPdfSection("Business Details",[
                          pw.SizedBox(height: 10),
                        _buildPdfEmploymentSection(),
                        _buildPdfEntrepreneurshipSection(),
                        _buildPdfDetailRow("Business Activity ", applicationData?['business_activity']),
                          pw.SizedBox(height: 5),
                        ..._buildPdfConditionalPreview(),
                        _buildPdfCommunicationAddressSection(applicationData),
                        _buildPdfUnitRegistrationSection(applicationData)  ,
                        ]),

                      _buildPdfSection("Business Plan",[
                          pw.SizedBox(height: 10),
                        _buildPdfDetailRow("Briefly Describe Your Business Plan ", applicationData?['business_plan']),
                        _buildPdfDetailRow("Sector selected in the Registration Form ", applicationData?['sector']),
                        _buildPdfDetailRow("Sub Sector selected in the Registration Form ", applicationData?['sub_sector']),
                        _buildPdfSectorChangePreviewSection(applicationData),
                        _buildPdfProjectReportPreviewSection(applicationData),
                        _buildPdfDetailRow("Proposed Project Cost ", applicationData?['proposed_project_cost']),
                        _buildPdfDetailRow("Amount anticipated as Bank Loan (in Rs.), if any ", applicationData?['amount_anticipated']),
                        _buildPdfDetailRow("Self Contribution (in Rs.), if any ", applicationData?['self_contribution']),
                        _buildPdfDetailRow("DPR Amount ", applicationData?['dpr_amount']),
                        _buildPdfLandAvailabilityPreviewSection(applicationData),
                        _buildPdfPreviousExperiencePreviewSection(applicationData),
                        _buildPdfSkillTrainingExperiencePreviewSection(applicationData),
                        _buildPdfSkillTrainingRequirementPreviewSection(),
                        _buildPdfDetailRow("Manpower requirement for business (including self) ", applicationData?['manpower_req']),
                        _buildPdfDetailRow("Power requirement in KW ", applicationData?['power_req']),
                      ]),

                        _buildPdfSection("Declaration", [
                        pw.Text(
                          "I hereby certify that all information furnished by me is true, correct and complete. "
                              "I am not a defaulter of any bank. Mere submission of the application form under this scheme "
                              "does not guarantee benefits under this scheme. I am aware that any misrepresentation "
                              "or omission of facts may result in the rejection of my application or subsequent actions as per the applicable laws.",
                        style: pw.TextStyle(fontSize: 12),
                        ),
              ])];
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
      padding: const pw.EdgeInsets.symmetric(vertical: 6), // spacing between rows
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 200, // fixed width for label
            child: pw.Text(
              "$label:",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value ?? "N/A",
              style: pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfEmploymentSection() {
    String currentlyEmployed = (applicationData?['currently_employed'] ?? "No").toString().trim();

    List<pw.Widget> children = [
        pw.SizedBox(height: 5),
      _buildPdfPreFilledField("Currently Employed ", currentlyEmployed),
    ];

    if (currentlyEmployed == "Yes") {
      children.addAll([
          pw.SizedBox(height: 5),
        _buildPdfPreFilledField("Employer Name ", applicationData?['employer_name'] ?? 'Not Provided'),
        _buildPdfPreFilledField("Employer Type ", applicationData?['employer_type'] ?? 'Not Provided'),
        _buildPdfPreFilledField("Employer Address ", applicationData?['employer_address'] ?? 'Not Provided'),
      ]);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  pw.Widget _buildPdfEntrepreneurshipSection() {
    String isFirstTime = (applicationData?['first_time_entrepreneur'] ?? "Yes").toString().trim();

    List<pw.Widget> children = [
      pw.SizedBox(height: 5),
      _buildPdfPreFilledField("Are you first time Entrepreneur ", isFirstTime),
    ];

    if (isFirstTime == "No") {
      children.addAll([
        pw.SizedBox(height: 5),
        _buildPdfPreFilledField("Previous Sector ", applicationData?['previous_sector'] ?? 'Not Provided'),
        _buildPdfPreFilledField("Previous Business Description ", applicationData?['previous_business_description'] ?? 'Not Provided'),
        _buildPdfPreFilledField("Availed Any Govt Assistance ", applicationData?['govt_assistance'] ?? 'Not Provided'),
      ]);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  List<pw.Widget> _buildPdfConditionalPreview() {
    if (applicationData == null) {
      return [pw.Text("No data available.")];
    }

    String businessActivity = applicationData!['business_activity'] ?? '';

    if (businessActivity == 'Proposed') {
      return [
        _buildPdfPreFilledField("Date of Commencement :",
            "${applicationData?['proposed_month'] ?? 'Not selected'} ${applicationData?['proposed_year'] ?? 'Not selected'}"),
        _buildPdfPreFilledField("Proposed Name of the Enterprise ", applicationData?['proposed_name'] ?? "Not provided"),
        _buildPdfPreFilledField("Type of Enterprise", applicationData?['type_of_enterprise'] ?? "Not selected"),
        pw.SizedBox(height: 10),
        pw.Text(
          "Proposed Business Address",
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        _buildPdfPreFilledField("Address Line 1 ", applicationData?['business_address1'] ?? "Not provided"),
        _buildPdfPreFilledField("Address Line 2 ", applicationData?['business_address2'] ?? "Not provided"),
        _buildPdfPreFilledField("Address Line 3 ", applicationData?['business_address3'] ?? "Not provided"),
        _buildPdfPreFilledField("State ", applicationData?['business_state'] ?? "Not selected"),
        _buildPdfPreFilledField("District ", applicationData?['businessdistrict'] ?? "Not selected"),
        _buildPdfPreFilledField("Legislative Assembly Constituency (LAC) ", applicationData?['business_lac'] ?? "Not selected"),
        _buildPdfPreFilledField("Sub District ", applicationData?['business_sub_district'] ?? "Not selected"),
        _buildPdfPreFilledField("Block ", applicationData?['business_block'] ?? "Not selected"),
        _buildPdfPreFilledField("Pincode ", applicationData?['business_pincode'] ?? "Not provided"),
        _buildPdfPreFilledField("Landmark Details ", applicationData?['landmark_details'] ?? "Not provided"),
        _buildPdfPreFilledField("Mobile Number ", applicationData?['business_mobile'] ?? "Not provided"),
      ];
    }

    if (businessActivity == 'Existing') {
      return [
        _buildPdfPreFilledField("Existing Business Activity Location ", applicationData?['existing_bus_loc'] ?? "Not selected"),
        _buildPdfPreFilledField("Date of Commencement ",
            "${applicationData?['existing_month'] ?? 'Not selected'} ${applicationData?['existing_year'] ?? 'Not selected'}"),
        _buildPdfPreFilledField("Name of the Existing Enterprise ", applicationData?['existing_name'] ?? "Not provided"),
        _buildPdfPreFilledField("Type of Enterprise", applicationData?['type_of_enterprise'] ?? "Not selected"),
        pw.SizedBox(height: 10),
        pw.Text(
          "Existing Business Address",
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        _buildPdfPreFilledField("Address Line 1 ", applicationData?['business_address1'] ?? "Not provided"),
        _buildPdfPreFilledField("Address Line 2 ", applicationData?['business_address2'] ?? "Not provided"),
        _buildPdfPreFilledField("Address Line 3 ", applicationData?['business_address3'] ?? "Not provided"),
        _buildPdfPreFilledField("State ", applicationData?['business_state'] ?? "Not selected"),
        _buildPdfPreFilledField("District ", applicationData?['businessdistrict'] ?? "Not selected"),
        _buildPdfPreFilledField("Legislative Assembly Constituency (LAC) ", applicationData?['business_lac'] ?? "Not selected"),
        _buildPdfPreFilledField("Sub District ", applicationData?['business_sub_district'] ?? "Not selected"),
        _buildPdfPreFilledField("Block ", applicationData?['business_block'] ?? "Not selected"),
        _buildPdfPreFilledField("Pincode ", applicationData?['business_pincode'] ?? "Not provided"),
        _buildPdfPreFilledField("Landmark Details ", applicationData?['landmark_details'] ?? "Not provided"),
        _buildPdfPreFilledField("Mobile Number ", applicationData?['business_mobile'] ?? "Not provided"),
      ];
    }

    return [pw.Text("Invalid business activity.")];
  }



  pw.Widget _buildPdfCommunicationAddressSection(Map<String, dynamic>? applicationData) {
    List<pw.Widget> children = [
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 16.0, bottom: 8.0),
        child: pw.Text(
          "Communication Address",
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.SizedBox(height: 10),
      _buildPdfPreFilledField("Address Line 1", applicationData?['communication_address1'] ?? 'Not Provided'),
      _buildPdfPreFilledField("Address Line 2", applicationData?['communication_address2'] ?? 'Not Provided'),
      _buildPdfPreFilledField("Address Line 3", applicationData?['communication_address3'] ?? 'Not Provided'),
      _buildPdfPreFilledField("State", applicationData?['communication_state'] ?? 'Not Provided'),
      _buildPdfPreFilledField("District", applicationData?['communication_district'] ?? 'Not Provided'),
      _buildPdfPreFilledField("Legislative Assembly Constituency (LAC)", applicationData?['communication_lac'] ?? 'Not Provided'),
      _buildPdfPreFilledField("Sub District", applicationData?['communication_sub_district'] ?? 'Not Provided'),
      _buildPdfPreFilledField("Block", applicationData?['communication_block'] ?? 'Not Provided'),
      _buildPdfPreFilledField("Pincode", applicationData?['communication_pincode'] ?? 'Not Provided'),
      _buildPdfPreFilledField("Landmark", applicationData?['communication_landmark'] ?? 'Not Provided'),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  pw.Widget _buildPdfUnitRegistrationSection(Map<String, dynamic>? applicationData) {
    String unitRegistered = (applicationData?['unit_registered'] ?? "No").toString().trim();

    List<pw.Widget> children = [
      _buildPdfPreFilledField("Whether Unit is Registered", unitRegistered),
    ];

    if (unitRegistered == "Yes") {
      children.add(
        _buildPdfPreFilledField(
          "UDYAM Registration No.",
          applicationData?['udyam_reg_no'] ?? 'Not Provided',
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  pw.Widget _buildPdfSectorChangePreviewSection(Map<String, dynamic>? applicationData) {
    String wantToChangeSector = (applicationData?['change_sector'] ?? 'No').toString().trim();

    List<pw.Widget> children = [
      _buildPdfPreFilledField("Do you want to change the sector", wantToChangeSector),
    ];

    if (wantToChangeSector == "Yes") {
      children.addAll([
        _buildPdfPreFilledField("New Sector", applicationData?['new_sector'] ?? 'Not Provided'),
        _buildPdfPreFilledField("New Sub-Sector", applicationData?['new_sub_sector'] ?? 'Not Provided'),
        _buildPdfPreFilledField("Type of Trade", applicationData?['type_of_trade'] ?? 'Not Provided'),
      ]);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  pw.Widget _buildPdfProjectReportPreviewSection(Map<String, dynamic>? applicationData) {
    String hasPreparedReport = (applicationData?['has_prepared_project_report'] ?? 'No').toString().trim();

    List<pw.Widget> children = [
      _buildPdfPreFilledField("Have you prepared the Project Report", hasPreparedReport),
    ];

    if (hasPreparedReport == "Yes") {
      String isAsPerFormat = (applicationData?['project_report_format'] ?? 'Not Provided').toString().trim();
      String projectNo = applicationData?['project_no'] ?? 'Not Provided';

      children.addAll([
        _buildPdfPreFilledField("Is the project report as per CMAAA format", isAsPerFormat),
        _buildPdfPreFilledField("Enter Project No", projectNo),
      ]);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  pw.Widget _buildPdfLandAvailabilityPreviewSection(Map<String, dynamic>? applicationData) {
    String landAvailability = (applicationData?['land_availability'] ?? 'No').toString().trim();
    String landArrangement = applicationData?['land_arrangement'] ?? 'Not Provided';
    String landArea = applicationData?['land_area'] ?? 'Not Provided';

    List<pw.Widget> children = [
      _buildPdfPreFilledField("Land/Building Availability for Business Establishment", landAvailability),
    ];

    if (landAvailability == "No") {
      children.add(
        _buildPdfPreFilledField("Proposed Land/Building Arrangement", landArrangement),
      );
    }

    if (landAvailability == "Yes") {
      children.addAll([
        _buildPdfPreFilledField("Existing Land/Building Arrangement", landArrangement),
        _buildPdfPreFilledField("Land/Building Area (in sqft)", landArea),
      ]);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  pw.Widget _buildPdfPreviousExperiencePreviewSection(Map<String, dynamic>? applicationData) {
    String prevExperience = (applicationData?['previous_exp'] ?? 'No').toString().trim();
    String yearsOfExperience = applicationData?['years_expe'] ?? 'Not Provided';

    List<pw.Widget> children = [
      _buildPdfPreFilledField("Previous Experience in Similar Sector", prevExperience),
    ];

    if (prevExperience == "Yes") {
      children.add(
        _buildPdfPreFilledField("Years of Experience", yearsOfExperience),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  pw.Widget _buildPdfSkillTrainingExperiencePreviewSection(Map<String, dynamic>? applicationData) {
    String skillTrainingExperience = (applicationData?['skill_training'] ?? 'No').toString().trim();
    String institutionName = applicationData?['institution_name'] ?? 'Not Provided';
    String trainingName = applicationData?['training_name'] ?? 'Not Provided';
    String trainingDuration = applicationData?['training_duration'] ?? 'Not Provided';

    List<pw.Widget> children = [
      _buildPdfPreFilledField("Skill Training Experience in the Selected Sector", skillTrainingExperience),
    ];

    if (skillTrainingExperience == "Yes") {
      children.addAll([
        _buildPdfPreFilledField("Institution Name", institutionName),
        _buildPdfPreFilledField("Training Name", trainingName),
        _buildPdfPreFilledField("Training Duration (in months)", trainingDuration),
      ]);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  pw.Widget _buildPdfSkillTrainingRequirementPreviewSection() {
    final String skillTraining = applicationData?['skill_training_req'] ?? 'Not Provided';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildPdfPreFilledField("Skill Training Requirement", skillTraining),
      ],
    );
  }

  pw.Widget _buildPdfPreFilledField(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 200,
            child: pw.Text(
              "$label:",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
















































































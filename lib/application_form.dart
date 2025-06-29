import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:signing/dashboard.dart';
import 'change_password.dart';
import 'logout.dart';
import 'database_helper.dart';

class ApplicationFormScreen extends StatefulWidget {
  final int userId;
  final bool isEditing;
  const ApplicationFormScreen({Key? key, required this.userId, required this.isEditing}) : super(key: key);

  @override
  _ApplicationFormScreenState createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? preFilledData;
  final TextEditingController _currentEmployerName = TextEditingController();
  final TextEditingController _currentEmployerAddress = TextEditingController();
  final TextEditingController _proposedNameController = TextEditingController();
  final TextEditingController _existingNameController = TextEditingController();
  final TextEditingController _busAddressController1 = TextEditingController();
  final TextEditingController _busAddressController2 = TextEditingController();
  final TextEditingController _busAddressController3 = TextEditingController();
  final TextEditingController _busPincodeController = TextEditingController();
  final TextEditingController _busLandmarkController = TextEditingController();
  final TextEditingController _busMobileController = TextEditingController();
  final TextEditingController _commAddressController1 = TextEditingController();
  final TextEditingController _commAddressController2 = TextEditingController();
  final TextEditingController _commAddressController3 = TextEditingController();
  final TextEditingController _commPincodeController = TextEditingController();
  final TextEditingController _commLandmarkController = TextEditingController();
  final TextEditingController _udyamRegNo = TextEditingController();
  final TextEditingController _businessPlanController = TextEditingController();
  final TextEditingController _projectNoController = TextEditingController();
  final TextEditingController _amtAnticipatedController = TextEditingController();
  final TextEditingController _selfContriController = TextEditingController();
  final TextEditingController _dprAmtController = TextEditingController();
  final TextEditingController _landArea = TextEditingController();
  final TextEditingController _YearsofExp = TextEditingController();
  final TextEditingController _InstitutionName = TextEditingController();
  final TextEditingController _TrainingName = TextEditingController();
  final TextEditingController _TrainingDuration = TextEditingController();
  final TextEditingController _skillTrainingReqController = TextEditingController();
  final TextEditingController _manPowerReqController = TextEditingController();
  final TextEditingController _powerReqController = TextEditingController();
  final TextEditingController _prevBusDesc = TextEditingController();


  String? _selectedEmployerType;
  String? _selectedproposedMonth;
  String? _selectedproposedYear;
  String? _selectedexistingMonth;
  String? _selectedexistingYear;
  String? _selectedexistingBusLoc;
  String? _selectedEmployment;
  String? _selectedEntrepreneur;
  String? _selectedPrevSector;
  String? _selectedAssist;
  String? _selectedEnterprise;
  String? _selectedBusState;
  String? _selectedBusDistrict;
  String? _selectedBusLac;
  String? _selectedBusSubDistrict;
  String? _selectedBusBlock;
  String? _selectedCommState;
  String? _selectedCommDistrict;
  String? _selectedCommLac;
  String? _selectedCommSubDistrict;
  String? _selectedCommBlock;
  String? _selectedReg;
  String? _selectedChangeSector;
  String? _selectedNewSector;
  String? _selectedNewSubSector;
  String? _selectedTrade;
  String? _selectedProjRep;
  String? _selectedRep;
  String? _selectedProjCost;
  String? _selectedLandAvail;
  String? _selectedLandArrangement;
  String? _selectedPrevExp;
  String? _selectedSkillExp;
  String? _selectedSkillReq;
  String? _selectedSkillError;

  PlatformFile? projRep;
  PlatformFile? landDoc;
  PlatformFile? ExpProof;
  PlatformFile? SuppDoc;
  PlatformFile? identityProof;
  PlatformFile? addressProof;
  PlatformFile? qualificationProof;
  PlatformFile? empExchangeRegCard;
  PlatformFile? bankPassBook;
  PlatformFile? panCard;

  bool _isChecked = false;
  late String businessActivity;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<String> _years = List.generate(16, (index) => (DateTime.now().year - 10 + index).toString(),);

  final List<String> skillOptions = [
    'Business specific Skill Training',
    'Financial/Accounting Training',
    'Marketing',
    'Leadership and Management',
    'Business Planning and Strategy',
    'Others',
  ];

  Map<String, bool> selectedSkills = {
    'Business specific Skill Training': false,
    'Financial/Accounting Training': false,
    'Marketing': false,
    'Leadership and Management': false,
    'Business Planning and Strategy': false,
    'Others': false,
  };

  String getSelectedSkills() {
    List<String> selected = [];
    selectedSkills.forEach((key, value) {
      if (value) {
        if (key == 'Others' && _skillTrainingReqController.text.isNotEmpty) {
          selected.add('Others: ${_skillTrainingReqController.text}');
        } else if (key != 'Others') {
          selected.add(key);
        }
      }
    });
    return selected.join(', ');
  }


  void _onMenuSelected(BuildContext context, String option) {
    if (option == "Dashboard") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
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

  @override
  void dispose() {
    _currentEmployerName.dispose();
    _currentEmployerAddress.dispose();
    _proposedNameController.dispose();
    _existingNameController.dispose();
    _prevBusDesc.dispose();
    _busAddressController1.dispose();
    _busAddressController2.dispose();
    _busAddressController3.dispose();
    _busPincodeController.dispose();
    _busLandmarkController.dispose();
    _busMobileController.dispose();
    _commAddressController1.dispose();
    _commAddressController2.dispose();
    _commAddressController3.dispose();
    _commAddressController3.dispose();
    _commPincodeController.dispose();
    _commLandmarkController.dispose();
    _udyamRegNo.dispose();
    _businessPlanController.dispose();
    _projectNoController.dispose();
    _amtAnticipatedController.dispose();
    _selfContriController.dispose();
    _dprAmtController.dispose();
    _landArea.dispose();
    _YearsofExp.dispose();
    _InstitutionName.dispose();
    _TrainingName.dispose();
    _TrainingDuration.dispose();
    _manPowerReqController.dispose();
    _powerReqController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchRegistrationData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
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

  Future<void> _fetchRegistrationData() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.getFormDataByUserId(widget.userId);

    if (data != null) {
      setState(() {
        preFilledData = data;
        businessActivity = data['business_activity'];
      });
    } else {
      print("⚠️ No registration data found for userId: ${widget.userId}");
    }
  }

  Future<void> saveDraftData() async {
    try {
      int? userId = await getLoggedInUserId();

      if (userId == null) {
        print("❌ Cannot save draft: No logged-in user.");
        return;
      }

      Map<String, dynamic> draftData = {
        'currently_employed': _selectedEmployment,
        'entrepreneur': _selectedEntrepreneur,
        'proposed_month': _selectedproposedMonth,
        'proposed_year' : _selectedproposedYear,
        'proposed_name': _proposedNameController.text,
        'existing_month': _selectedexistingMonth,
        'existing_year' : _selectedexistingYear,
        'existing_bus_loc' : _selectedexistingBusLoc,
        'existing_name' : _existingNameController.text,
        'type_of_enterprise': _selectedEnterprise,
        'business_address1': _busAddressController1.text,
        'business_address2': _busAddressController2.text,
        'business_address3': _busAddressController3.text,
        'business_state': _selectedBusState,
        'businessdistrict': _selectedBusDistrict,
        'business_lac': _selectedBusLac,
        'business_sub_district': _selectedBusSubDistrict,
        'business_block': _selectedBusBlock,
        'business_pincode': _busPincodeController.text,
        'business_landmark': _busLandmarkController.text,
        'business_mobile': _busMobileController.text,
        'communication_address1': _commAddressController1.text,
        'communication_address2': _commAddressController2.text,
        'communication_address3': _commAddressController3.text,
        'communication_state': _selectedCommState,
        'communication_district': _selectedCommDistrict,
        'communication_lac': _selectedCommLac,
        'communication_sub_district': _selectedCommSubDistrict,
        'communication_block': _selectedCommBlock,
        'communication_pincode': _commPincodeController.text,
        'communication_landmark': _commLandmarkController.text,
        'unit_registered': _selectedReg,
        'business_plan': _businessPlanController.text,
        'change_of_sector': _selectedChangeSector,
        'prepared_project_report': _selectedProjRep,
        'proposed_project_cost': _selectedProjCost,
        'amount_anticipated': _amtAnticipatedController.text,
        'self_contribution': _selfContriController.text,
        'dpr_amount': _dprAmtController.text,
        'land_availability': _selectedLandAvail,
        'previous_exp': _selectedPrevExp,
        'skill_training': _selectedSkillExp,
        'skill_training_req': getSelectedSkills(),
        'manpower_req': _manPowerReqController.text,
        'power_req': _powerReqController.text,
        'identity_proof': identityProof?.path,
        'address_proof': addressProof?.path,
        'qualification_proof': qualificationProof?.path,
        'emp_exchange_reg_card': empExchangeRegCard?.path,
        'bank_passbook': bankPassBook?.path,
        'pan_card': panCard?.path,
        'user_id': userId,
        'status': 'incomplete',
        'form_type' : 'application',
      };

      if (_selectedEmployment == "Yes") {
        draftData.addAll({
          'employer_name': _currentEmployerName.text,
          'employer_type': _selectedEmployerType,
          'employer_address': _currentEmployerAddress.text,
        });
      }

      if (_selectedEntrepreneur == "No") {
        draftData.addAll({
          'prev_sector': _selectedPrevSector,
          'prev_sec_desc': _prevBusDesc.text,
          'govt_assist': _selectedAssist,
        });
      }

      if (_selectedReg == "Yes") {
        draftData.addAll({
          'udyam_regNo': _udyamRegNo.text,
        });
      }

      if (_selectedChangeSector == "Yes") {
        draftData.addAll({
          'new_sector': _selectedNewSector,
          'new_sub_sector': _selectedNewSubSector,
          'type_of_trade': _selectedTrade,
        });
      }

      if (_selectedProjRep == "Yes") {
        draftData.addAll({
          'report': _selectedRep,
          'project_no': _projectNoController.text,
          'project_report': projRep?.path,
        });
      }

      if (_selectedLandAvail == "Yes") {
        draftData.addAll({
          'land_arrangement': _selectedLandArrangement,
          'land_doc': landDoc?.path,
          'land_area': _landArea,
        });
      }

      if (_selectedLandAvail == "No") {
        draftData.addAll({
          'land_arrangement': _selectedLandArrangement,
        });
      }

      if (_selectedPrevExp == "Yes") {
        draftData.addAll({
          'years_exp': _YearsofExp,
          'exp_proof': ExpProof?.path,
        });
      }

      if (_selectedSkillExp == "Yes") {
        draftData.addAll({
          'supporting_doc': SuppDoc,
          'institution_name': _InstitutionName.text,
          'training_name': _TrainingName.text,
          'training_duration': _TrainingDuration.text,
        });
      }

      print("Saving Draft Data: $draftData");

      int result = await DatabaseHelper().insertApplicationForm(draftData);

      if (result > 0) {
        print(" ✅ Draft Saved Successfully!");
      } else {
        print("⚠️ Failed to Save Draft!");
      }
    } catch (e) {
      print("Error saving draft: $e");
    }
  }

  Future<void> loadDraftData(int userId) async {
    try {
      final db = await DatabaseHelper().database;
      List<Map<String, dynamic>> drafts = await db.query(
        'application_data',
        where: 'user_id = ? AND status = ? AND form_type = ?',
        whereArgs: [userId, 'incomplete', 'application'],
      );

      if (drafts.isNotEmpty) {
        var draft = drafts.first;
        debugPrint("✅ Loaded Draft for User ID: $userId");

        if (!mounted) return;

        setState(() {
          _selectedEmployment = draft['currently_employed'] ?? '';
          if ( _selectedEmployment == "Yes") {
            _currentEmployerName.text = draft['employer_name'] ?? '';
            _selectedEmployerType = draft['employer_type'] ?? '';
            _currentEmployerAddress.text = draft['employer_address'] ?? '';
          }
          _selectedEntrepreneur = draft['entrepreneur'] ?? '';
          if ( _selectedEntrepreneur == "No") {
            _selectedPrevSector = draft['prev_sector'] ?? '';
            _prevBusDesc.text = draft['prev_sec_desc'] ?? '';
            _selectedAssist = draft['govt_assist'] ?? '';
          }
          _selectedproposedMonth = draft['proposed_month'] ?? '';
          _selectedproposedYear = draft['proposed_year'] ?? '';
          _proposedNameController.text = draft['proposed_name'] ?? '';
          _selectedexistingMonth = draft['existing_month'] ?? '';
          _selectedexistingYear = draft['existing_year'] ?? '';
          _selectedexistingBusLoc = draft['existing_bus_loc'] ?? '';
          _existingNameController.text = draft['existing_name'] ?? '';
          _selectedEnterprise = draft['type_of_enterprise'] ?? '';
          _busAddressController1.text = draft['business_address1'] ?? '';
          _busAddressController2.text = draft['business_address2'] ?? '';
          _busAddressController3.text = draft['business_address3'] ?? '';
          _selectedBusState = draft['business_state'] ?? '';
          _selectedBusDistrict = draft['businessdistrict'] ?? '';
          _selectedBusLac = draft['business_lac'] ?? '';
          _selectedBusSubDistrict = draft['business_sub_district'] ?? '';
          _selectedBusBlock = draft['business_block'] ?? '';
          _busPincodeController.text = draft['business_pincode'] ?? '';
          _busLandmarkController.text = draft['business_landmark'] ?? '';
          _busMobileController.text = draft['business_mobile'] ?? '';
          _commAddressController1.text = draft['communication_address1'] ?? '';
          _commAddressController2.text = draft['communication_address2'] ?? '';
          _commAddressController3.text = draft['communication_address3'] ?? '';
          _selectedCommState = draft['communication_state'] ?? '';
          _selectedCommDistrict = draft['communication_district'] ?? '';
          _selectedCommLac = draft['communication_lac'] ?? '';
          _selectedCommSubDistrict = draft['communication_sub_district'] ?? '';
          _selectedCommBlock = draft['communication_block'] ?? '';
          _commPincodeController.text = draft['communication_pincode'] ?? '';
          _commLandmarkController.text = draft['communication_landmark'] ?? '';
          _selectedReg = draft['unit_registered'] ?? '';
          if ( _selectedReg == "Yes") {
            _udyamRegNo.text = draft['udyam_regNo'] ?? '';
          }
          _businessPlanController.text = draft['business_plan'] ?? '';
          _selectedChangeSector = draft['change_of_sector'] ?? '';
          if ( _selectedChangeSector == "Yes") {
            _selectedNewSector = draft['new_sector'] ?? '';
            _selectedNewSubSector = draft['new_sub_sector'] ?? '';
            _selectedTrade = draft['type_of_trade'] ?? '';
          }
          _selectedProjRep = draft['prepared_project_report'] ?? '';
          if ( _selectedProjRep == "Yes") {
            _selectedRep = draft['report'] ?? '';
            _projectNoController.text = draft['project_no'] ?? '';
            projRep = draft['project_report'] != null ? _createPlatformFileFromPath(draft['project_report']) : null;
          }
          _selectedProjCost = draft['proposed_project_cost'] ?? '';
          _amtAnticipatedController.text = draft['amount_anticipated'] ?? '';
          _selfContriController.text = draft['self_contribution'] ?? '';
          _dprAmtController.text = draft['dpr_amount'] ?? '';
          _selectedLandAvail = draft['land_availability'] ?? '';
          if ( _selectedLandAvail == "Yes") {
            _selectedLandArrangement = draft['land_arrangement'] ?? '';
            landDoc = draft['land_doc'] != null ? _createPlatformFileFromPath(draft['land_doc']) : null;
            _landArea.text = draft['land_area'] ?? '';
          }
          if ( _selectedLandAvail == "No") {
            _selectedLandArrangement = draft['land_arrangement'] ?? '';
          }
          _selectedPrevExp = draft['previous_exp'] ?? '';
          if ( _selectedPrevExp == "Yes") {
            _YearsofExp.text = draft['years_exp'] ?? '';
            ExpProof = draft['exp_proof'] != null ? _createPlatformFileFromPath(draft['exp_proof']) : null;
          }
          _selectedSkillExp = draft['skill_training'] ?? '';
          if ( _selectedSkillExp == "Yes") {
            SuppDoc = draft['supporting_doc'] != null ? _createPlatformFileFromPath(draft['supporting_doc']) : null;
            _InstitutionName.text = draft['institution_name'] ?? '';
            _TrainingName.text = draft['training_name'] ?? '';
            _TrainingDuration.text = draft['training_duration'] ?? '';
          }
          _selectedSkillReq = draft['skill_training_req'] ?? '';
          if (_selectedSkillReq!.contains('Others:')) {
            _skillTrainingReqController.text = _selectedSkillReq!.split('Others:')[1].trim();
          } else {
            _skillTrainingReqController.clear();
          }
          _manPowerReqController.text = draft['manpower_req'] ?? '';
          _powerReqController.text = draft['power_req'] ?? '';
          identityProof = draft['identity_proof'] != null ? _createPlatformFileFromPath(draft['identity_proof']) : null;
          addressProof = draft['address_proof'] != null ? _createPlatformFileFromPath(draft['address_proof']) : null;
          qualificationProof = draft['qualification_proof'] != null ? _createPlatformFileFromPath(draft['qualification_proof']) : null;
          empExchangeRegCard = draft['emp_exchange_reg_card'] != null ? _createPlatformFileFromPath(draft['emp_exchange_reg_card']) : null;
          bankPassBook = draft['bank_passbook'] != null ? _createPlatformFileFromPath(draft['bank_passbook']) : null;
          panCard = draft['pan_card'] != null ? _createPlatformFileFromPath(draft['pan_card']) : null;
        });

        debugPrint("✅ Draft Loaded Successfully!");
      } else {
        debugPrint("❌ No Draft Found!");
      }
    } catch (e) {
      debugPrint("⚠️ Error loading draft: $e");
    }
  }

  PlatformFile? _createPlatformFileFromPath(String? path) {
    if (path == null || path.isEmpty) return null;

    try {
      final file = File(path);
      if (!file.existsSync()) return null;

      final fileName = file.path
          .split('/')
          .last;
      final fileBytes = file.readAsBytesSync();

      return PlatformFile(
        name: fileName,
        path: file.path,
        size: file.lengthSync(),
        bytes: fileBytes,
      );
    } catch (e) {
      debugPrint("Error creating PlatformFile: $e");
      return null;
    }
  }

  Future<void> saveAndNext(BuildContext context) async {
        // ✅ First, validate that at least one skill is selected
        if (!selectedSkills.containsValue(true)) {
          setState(() {
            _selectedSkillError = "Please select at least one skill training requirement.";
          });
          return; // Don't proceed if not valid
        }

        // ✅ Then convert checklist into comma-separated string
        _selectedSkillReq = selectedSkills.entries
            .where((entry) => entry.value && entry.key != 'Others')
            .map((entry) => entry.key)
            .join(", ");

        if (selectedSkills['Others'] == true && _skillTrainingReqController.text.isNotEmpty) {
          _selectedSkillReq = _selectedSkillReq!.isNotEmpty
              ? '$_selectedSkillReq, ${_skillTrainingReqController.text}'
              : _skillTrainingReqController.text;
        }

        // ✅ Proceed with your save logic (to SQLite, Firebase, etc.)
        print("Selected Skills: $_selectedSkillReq");
        try {
          if (!_formKey.currentState!.validate()) {
            return;
          }

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

          Map<String, dynamic> formData = {
            'user_id': loggedInUserId,
            'currently_employed': _selectedEmployment,
            'entrepreneur': _selectedEntrepreneur,
            'proposed_month': _selectedproposedMonth,
            'proposed_year' : _selectedproposedYear,
            'proposed_name': _proposedNameController.text,
            'existing_month': _selectedexistingMonth,
            'existing_year': _selectedexistingYear,
            'existing_bus_loc' : _selectedexistingBusLoc,
            'existing_name': _existingNameController.text,
            'type_of_enterprise': _selectedEnterprise,
            'business_address1': _busAddressController1.text,
            'business_address2': _busAddressController2.text,
            'business_address3': _busAddressController3.text,
            'business_state': _selectedBusState,
            'businessdistrict': _selectedBusDistrict,
            'business_lac': _selectedBusLac,
            'business_sub_district': _selectedBusSubDistrict,
            'business_block': _selectedBusBlock,
            'business_pincode': _busPincodeController.text,
            'business_landmark': _busLandmarkController.text,
            'business_mobile': _busMobileController.text,
            'communication_address1': _commAddressController1.text,
            'communication_address2': _commAddressController2.text,
            'communication_address3': _commAddressController3.text,
            'communication_state': _selectedCommState,
            'communication_district': _selectedCommDistrict,
            'communication_lac': _selectedCommLac,
            'communication_sub_district': _selectedCommSubDistrict,
            'communication_block': _selectedCommBlock,
            'communication_pincode': _commPincodeController.text,
            'communication_landmark': _commLandmarkController.text,
            'unit_registered': _selectedReg,
            'business_plan': _businessPlanController.text,
            'change_of_sector': _selectedChangeSector,
            'prepared_project_report': _selectedProjRep,
            'proposed_project_cost': _selectedProjCost,
            'amount_anticipated': _amtAnticipatedController.text,
            'self_contribution': _selfContriController.text,
            'dpr_amount': _dprAmtController.text,
            'land_availability': _selectedLandAvail,
            'previous_exp': _selectedPrevExp,
            'skill_training': _selectedSkillExp,
            'skill_training_req': getSelectedSkills(),
            'manpower_req': _manPowerReqController.text,
            'power_req': _powerReqController.text,
            'identity_proof': identityProof?.path,
            'address_proof': addressProof?.path,
            'qualification_proof': qualificationProof?.path,
            'emp_exchange_reg_card': empExchangeRegCard?.path,
            'bank_passbook': bankPassBook?.path,
            'pan_card': panCard?.path,
            'status': 'completed',
          };

      if (_selectedEmployment == "Yes") {
        formData.addAll({
          'employer_name': _currentEmployerName.text,
          'employer_type': _selectedEmployerType,
          'employer_address': _currentEmployerAddress.text,
        });
      }

      if (_selectedEntrepreneur == "No") {
        formData.addAll({
          'prev_sector': _selectedPrevSector,
          'prev_sec_desc': _prevBusDesc.text,
          'govt_assist': _selectedAssist,
        });
      }

      if (_selectedReg == "Yes") {
        formData.addAll({
          'udyam_regNo': _udyamRegNo.text,
        });
      }

      if (_selectedChangeSector == "Yes") {
        formData.addAll({
          'new_sector': _selectedNewSector,
          'new_sub_sector': _selectedNewSubSector,
          'type_of_trade': _selectedTrade,
        });
      }

      if (_selectedProjRep == "Yes") {
        formData.addAll({
          'report': _selectedRep,
          'project_no': _projectNoController.text,
          'project_report': projRep?.path,
        });
      }

      if (_selectedLandAvail == "Yes") {
        formData.addAll({
          'land_arrangement': _selectedLandArrangement,
          'land_doc': landDoc?.path,
          'land_area': _landArea,
        });
      }

      if (_selectedLandAvail == "No") {
        formData.addAll({
          'land_arrangement': _selectedLandArrangement,
        });
      }

      if (_selectedPrevExp == "Yes") {
        formData.addAll({
          'years_exp': _YearsofExp,
          'exp_proof': ExpProof?.path,
        });
      }

      if (_selectedSkillExp == "Yes") {
        formData.addAll({
          'supporting_doc': SuppDoc,
          'institution_name': _InstitutionName.text,
          'training_name': _TrainingName.text,
          'training_duration': _TrainingDuration.text,
        });
      }

      debugPrint("📌 Saving Data: $formData");

      int result = await dbHelper.insertFinalApplicationForm(formData);
      debugPrint("Save Result: $result");

      if (result == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You have already submitted the application!")),
        );
        return;
      }

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

        if (!context.mounted) {
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
    } catch (e, stacktrace) {
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
          _selectedEmployment = null;
          _currentEmployerName.clear();
          _selectedEmployerType = null;
          _currentEmployerAddress.clear();
          _selectedEntrepreneur = null;
          _selectedPrevSector = null;
          _prevBusDesc.clear();
          _selectedAssist = null;
          _selectedproposedMonth = null;
          _selectedproposedYear = null;
          _proposedNameController.clear();
          _selectedexistingMonth = null;
          _selectedexistingYear = null;
          _selectedexistingBusLoc = null;
          _existingNameController.clear();
          _selectedEnterprise = null;
          _busAddressController1.clear();
          _busAddressController2.clear();
          _busAddressController3.clear();
          _selectedBusState = null;
          _selectedBusDistrict = null;
          _selectedBusLac = null;
          _selectedBusSubDistrict = null;
          _selectedBusBlock = null;
          _busPincodeController.clear();
          _busPincodeController.clear();
          _busMobileController.clear();
          _commAddressController1.clear();
          _commAddressController2.clear();
          _commAddressController3.clear();
          _selectedCommState = null;
          _selectedCommDistrict = null;
          _selectedCommLac = null;
          _selectedCommSubDistrict = null;
          _selectedCommBlock = null;
          _commPincodeController.clear();
          _commPincodeController.clear();
          _selectedReg = null;
          _udyamRegNo.clear();
          _businessPlanController.clear();
          _selectedChangeSector = null;
          _selectedNewSector = null;
          _selectedNewSubSector = null;
          _selectedTrade = null;
          _selectedProjRep = null;
          _selectedRep = null;
          _projectNoController.clear();
          projRep = null;
          _selectedProjCost = null;
          _amtAnticipatedController.clear();
          _selfContriController.clear();
          _dprAmtController.clear();
          _selectedLandAvail = null;
          _selectedLandArrangement = null;
          landDoc = null;
          _landArea.clear();
          _selectedPrevExp = null;
          _YearsofExp.clear();
          ExpProof = null;
          _selectedSkillExp = null;
          SuppDoc = null;
          _InstitutionName.clear();
          _TrainingName.clear();
          _TrainingDuration.clear();
          _selectedSkillReq = null;
          _manPowerReqController.clear();
          _powerReqController.clear();
          identityProof = null;
          addressProof = null;
          qualificationProof = null;
          empExchangeRegCard = null;
          bankPassBook = null;
          panCard = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Form reset successfully!")),
        );
      }
    } catch (e) {
      print("Error resetting form: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to reset form!")),
        );
      }
    }
  }

  Future<void> pickProjectReport() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final file = result.files.first;
      if (file.size <= 5 * 1024 * 1024) {
        setState(() => projRep = file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📁 File size should not exceed 5MB')),
        );
      }
    }
  }

  Future<void> picklandDoc() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final file = result.files.first;
      if (file.size <= 2 * 1024 * 1024) {
        setState(() => landDoc = file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📁 File size should not exceed 2MB')),
        );
      }
    }
  }

  Future<void> pickExpProof() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final file = result.files.first;
      if (file.size <= 2 * 1024 * 1024) {
        setState(() => ExpProof = file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📁 File size should not exceed 2MB')),
        );
      }
    }
  }

  Future<void> pickSuppDoc() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final file = result.files.first;
      if (file.size <= 2 * 1024 * 1024) {
        setState(() => SuppDoc = file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📁 File size should not exceed 2MB')),
        );
      }
    }
  }

  Future<void> pickIdentityProof() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final file = result.files.first;
      if (file.size <= 1024 * 1024) {
        setState(() => identityProof = file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📁 File size should not exceed 1MB')),
        );
      }
    }
  }

  Future<void> pickAddressProof() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final file = result.files.first;
      if (file.size <= 1024 * 1024) {
        setState(() => addressProof = file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📁 File size should not exceed 1MB')),
        );
      }
    }
  }

  Future<void> pickQualificationProof() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final file = result.files.first;
      if (file.size <= 1024 * 1024) {
        setState(() => qualificationProof = file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📁 File size should not exceed 1MB')),
        );
      }
    }
  }

  Future<void> pickEmpExchangeCard() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final file = result.files.first;
      if (file.size <= 1024 * 1024) {
        setState(() => empExchangeRegCard = file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📁 File size should not exceed 1MB')),
        );
      }
    }
  }

  Future<void> pickBankPassbook() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final file = result.files.first;
      if (file.size <= 1024 * 1024) {
        setState(() => bankPassBook = file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📁 File size should not exceed 1MB')),
        );
      }
    }
  }

  Future<void> pickPanCard() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      final file = result.files.first;
      if (file.size <= 1024 * 1024) {
        setState(() => panCard = file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📁 File size should not exceed 1MB')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (preFilledData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 70),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6E6E6E), Color(0xFFF6C2AD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _topNavButton(context, Icons.dashboard, "Dashboard"),
                _topNavButton(context, Icons.lock, "Change Password"),
                _topNavButton(context, Icons.logout, "Logout"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: Colors.blueGrey),
                        child: const Text(
                          "Application Form for Chief Minister's Atmanirbhar Asom Abhijan 2.0",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _infoBox("General Instructions", [
                      "All the * marked fields are mandatory and need to be filled up.",
                      "Following documents are required at time of application submission -",
                      "Identity Proof (PAN/Driving License/Passport/Bank Passbook/Aadhaar/Voter ID Card)",
                      "Address Proof of the Applicant",
                      "Education Qualification",
                      "Employment Exchange Registration Card",
                      "Bank Passbook/Cancelled Check Book",
                      "PAN Card",
                      "Upload Project Report"
                    ]),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sectionTitle("Information About Applicant"),
                          _buildPreFilledField("Name of the Applicant", preFilledData!['applicant_name']),
                          _buildPreFilledField("Father's Name", preFilledData!['father_name']),
                          _buildPreFilledField("Applicant's Gender", preFilledData!['gender']),
                          _buildPreFilledField("Social Category", preFilledData!['social_category']),
                          _buildPreFilledField("Date of Birth", preFilledData!['dob']),
                          _buildPreFilledField("PAN Number", preFilledData!['pan_number']),
                          _buildPreFilledField("Employment Exchange No.", preFilledData!['employment_exchange_no']),
                          _buildPreFilledField("BPL", preFilledData!['bpl']),
                          _buildPreFilledField("Marital Status", preFilledData!['marital_status']),
                          _buildPreFilledField("Select Sectors", preFilledData!['sector']),
                          _buildPreFilledField("Select Sub Sectors", preFilledData!['sub_sector']),
                          _buildPreFilledField("Type of Trade", preFilledData!['trade_type']),

                          const SizedBox(height: 20),
                          sectionTitle("Permanent Address with Mobile No."),
                          _buildPreFilledField("Address Line 1", preFilledData!['address1']),
                          _buildPreFilledField("Address Line 2", preFilledData!['address2']),
                          _buildPreFilledField("Address Line 3", preFilledData!['address3']),
                          _buildPreFilledField("State", preFilledData!['state']),
                          _buildPreFilledField("District", preFilledData!['district']),
                          _buildPreFilledField("Legislative Assembly Constituency (LAC)", preFilledData!['lac']),
                          _buildPreFilledField("Sub District", preFilledData!['co_district']),
                          _buildPreFilledField("Pincode", preFilledData!['pincode']),
                          _buildPreFilledField("Mobile Number", preFilledData!['mobile']),
                          _buildPreFilledField("E-Mail", preFilledData!['email']),

                          const SizedBox(height: 20),
                          sectionTitle("Highest Academic Qualification"),
                          _buildPreFilledField("Degree Name", preFilledData!['degree']),
                          _buildPreFilledField("Name of the Course", preFilledData!['course']),
                          _buildPreFilledField("Board/University", preFilledData!['board']),
                          _buildPreFilledField("College/Institution", preFilledData!['college']),
                          _buildPreFilledField("Date of Passing", preFilledData!['passing_date']),
                          _buildPreFilledField("Percentage", preFilledData!['percentage']),
                          _buildPreFilledField("Division/Class", preFilledData!['division']),

                          const SizedBox(height: 20),
                          sectionTitle("Bank Details"),
                          _buildPreFilledField("Bank Account Number", preFilledData!['bank_account']),
                          _buildPreFilledField("IFSC Code", preFilledData!['ifsc']),
                          _buildPreFilledField("Name of the Bank", preFilledData!['bank_name']),
                          _buildPreFilledField("Branch Name", preFilledData!['bank_branch']),
                          _buildPreFilledField("Address of the Bank", preFilledData!['bank_address']),

                          const SizedBox(height: 20),
                          sectionTitle("Business Details"),
                          _buildRadioField("Currently Employed ?", ["Yes", "No"], _selectedEmployment, (value) {
                            setState(() {
                              _selectedEmployment = value;
                            });
                          }),

                          if(_selectedEmployment == "Yes") ...[
                            _buildTextField(labelText: "Employer Name", myController:  _currentEmployerName, hintText: "Enter Employer Name",),

                            _buildDropdownField(
                                label: "Employer Type",
                                hintText: "Please select",
                                options: ["Private", "Semi-Govt", "Self"],
                                selectedValue: _selectedEmployerType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEmployerType = value;
                                  });
                                }),

                            _buildEditableLongTextField("Employer Address", _currentEmployerAddress ),

                          ],

                          _buildRadioField("Are you first time Entrepreneur ?", ["Yes", "No"], _selectedEntrepreneur, (value) {
                            setState(() {
                              _selectedEntrepreneur = value;
                            });
                          }),

                          if(_selectedEntrepreneur == "No") ...[
                            _buildDropdownField(
                                label: "Previous Sector",
                                hintText: "Please select",
                                options: ["Agriculture and Horticulture sector", "Fabrication/Hardware Business sector" , "Fisheries" , "Other sectors including services" , "Packaging sector" , "Plantation sector (Bamboo/Rubber/Agar etc)" , "Poultry/Dairy/Goatery/Piggery" , "Readymade Garment sector" , "Self-employment after professional courses" , "Stationary Business sector", "Wood based industries (Furniture sector)"],
                                selectedValue: _selectedPrevSector,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPrevSector = value;
                                  });
                                }),
                            _buildEditableLongTextField("Previous Business Description", _prevBusDesc,  hintText : "Describe Your Previous Business Plan" ),
                            _buildRadioField("Have you Availed Any Assistance from Government", ["Yes", "No"], _selectedAssist, (value) {
                              setState(() {
                                _selectedAssist = value;
                              });
                            }),
                          ],

                          _buildPreFilledField(
                              "Business Activity", preFilledData!= null && preFilledData!['business_activity'] != null
                              ? preFilledData!['business_activity']
                              : 'No data available',
                          ),
                          _buildConditionalQuestions(),
                          const SizedBox(height : 5),
                          const Text("Communication Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                          _buildTextField(labelText: "Address Line 1", myController:  _commAddressController1, hintText: "Enter address line 1",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              }),
                          _buildTextField(labelText: "Address Line 2", myController:  _commAddressController2, hintText: "Enter address line 2",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              }),
                          _buildTextField(labelText: "Address Line 3", myController:  _commAddressController3, hintText: "Enter address line 3",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              }),
                          _buildDropdownField(
                              label: "State",
                              hintText: "Please select",
                              options: ["Assam"],
                              selectedValue: _selectedCommState,
                              onChanged:(value) {
                                setState(() {
                                  _selectedCommState = value;
                                });
                              }),
                          _buildDropdownField(
                              label: "District",
                              hintText: "Please select",
                              options: ["Baksa", "Barpeta", "Bongaigaon", "Cachar", "Charaideo", "Chirang", "Darrang", "Dhemaji", "Dhubri", "Dibrugarh", "Dima Hasao", "Goalpara", "	Golaghat",
                                "Hailakandi", "Jorhat", "Kamrup (Metropolitan)", "Kamrup", "Karbi Anglong", "Karimganj", "Kokrajhar", "Lakhimpur", "Majuli", "Morigaon", "Nagaon", "Nalbari", "Sibsagar", "Sonitpur", "South Salmara", "Tinsukia", "West Karbi Anglong", "Biswanath", "Hojai", "Bajali", "Tamulpur", "	Udalguri"],
                              selectedValue: _selectedCommDistrict,
                              onChanged:(value) {
                                setState(() {
                                  _selectedCommDistrict = value;
                                });
                              }),
                          _buildDropdownField(
                              label: "Legislative Assembly Constituency (LAC)",
                              hintText: "Please select",
                              options: ["Abhayapuri", "Algapur-Katlicherra", "Amri (ST)", "Bajali", "Baksa (ST)", "Baokhungri", "Barchalla", "Barhampur", "Barkhetri", "Barkhota", "Barpeta (SC)", "Behali (SC)", "Bhergaon", "Bhowanipur-Sorbhog" , "Bihpuria", "Bijni", "Bilasipara", "Binnakandi", "Birsing Jarua" , "Biswanath", "Bokajan (ST)", "Bokakhat", "Boko-Chaygaon (ST)", "Bongaigaon", "Chabua-Lahowal", "Chamaria", "Chenga", "Dalgaon","Demow" , "Dergaon", "Dhakuakhana (ST)", "Dhekiajuli", "Dhemaji (ST)",
                                "Dhing", "Dholai (SC)", "Dhubri", "Dhuliajan" , "Dibrugarh", "Digboi", "Dimoria (SC)" , "Diphu (ST)", "Dispur", "Doomdooma", "Dotma (ST)" , "Dudhnai (ST)", "Gauripur", "Goalpara East", "Goalpara West (ST)", "Gohpur", "Golaghat", "Golakganj", "Goreswar" , "Gossaigaon", "Guwahati Central", "Haflong (ST)", "Hailakandi", "Hajo-Sualkuci (SC)",
                                "Hojai", "Howraghat (ST)", "Jagiroad (SC)", "Jaleshwar", "Jalukbari", "Jonai (ST)", "Jorhat", "Kaliabor", "Kamalpur", "Karimganj North", "Karimganj South", "Katigorah", "Khowang", "Khumtai", "Kokrajhar (ST)", "Laharighat", "Lakhimpur", "Lakhipur", "Lumding", "Mahmora", "Majuli (ST)" , "Makum" , "Manas" , "Mandia" , "Mangaldai", "Mankachar", "Margherita", "Mariani", "Mazbat", "Morigaon", "Naduar" , "Nagaon-Batadraba" , "Naharkatia", "Nalbari",
                                "Nazira" , "New Guwahati" , "Nowboicha (SC)", "Pakabetbari" , "Palasbari", "Parbatjhora", "Patharkandi", "Raha (SC)", "Ram Krishana Nagar (SC)" , "Rangapara", "Rangia", "Rongkhang (ST)" , "Rongonadi", "Rupahihat", "Sadiya", "Samaguri", "Sarupathar", "Sibsagar", "Sidli Chirang (ST)", "Silchar", "Sipajhar", "Sissibargaon" , "Sonai", "Sonari", "Srijangram", "Tamulpur (ST)" , "Tangla", "Teok", "Tezpur", "Tihu", "Tingkhong", "Tinsukia", "Titabar", "Udalguri (ST)", "Udharbond"],
                              selectedValue: _selectedCommLac,
                              onChanged:(value) {
                                setState(() {
                                  _selectedCommLac = value;
                                });
                              }),
                          _buildDropdownField(
                              label: "Sub District",
                              hintText: "Please select",
                              options: ["Abhayapuri", "Algapur-Katlicherra", "Bajali", "Barchalla", "Barhampur", "Barkhetri", "Barkhota", "Behali", "Bhowanipur-Sorbhog" , "Bihpuria", "Bilasipara", "Binnakandi", "Birsing Jarua" , "Bokakhat", "Boko-Chaygaon", "Chabua-Lahowal", "Chamaria", "Chenga", "Dalgaon","Demow" , "Dergaon", "Dhakuakhana", "Dharmapur-Tihu" , "Dhekiajuli",
                                "Dhing", "Dholai", "Digboi", "Dimoria" , "Dispur", "Doomdooma", "Dudhnai", "Duliajan" , "Gauripur", "Goalpara West", "Gohpur", "Golakganj",
                                "Jagiroad ", "Jaleshwar", "Jalukbari", "Jonai ", "Kaliabor", "Kamalpur", "Karimganj South", "Katigorah", "Khowang", "Khumtai", "Laharighat", "Lakhipur", "Lumding", "Mahmora", "Makum" , "Mandia-Jania" , "Margherita", "Mariani", "Naduar" , "Naharkatia",
                                "Nazira" , "New Guwahati" , "Nowboicha", "Pakabetbari" , "Palasbari", "Patharkandi", "Raha", "Ram Krishana Nagar" , "Rangapara", "Rangia", "Rongonadi", "Rupahihat", "Sadiya", "Samaguri", "Sarupathar", "Sipajhar", "Sissibargaon" , "Sonai", "Sonari", "Srijangram", "Teok", "Tingkhong", "Titabar","Udharbond"],
                              selectedValue: _selectedCommSubDistrict,
                              onChanged:(value) {
                                setState(() {
                                  _selectedCommSubDistrict = value;
                                });
                              }),
                          _buildDropdownField(
                              label: "Block",
                              hintText: "Please select",
                              options: ["Sissiborgaon", "Barama", "Gobardhana", "Chenga", "Bajali", "Ruposhi", "Diyungbra", "Jatinga Valley", "South Hailakandi", "Chayani", "Bezera (Pt)", "Ramkrishna Nagar", "Barhampur", "Raha", "Dalgaon-Sialmari", "Kalaigaon", "Pub Chaiduar", "Dangtol", "Dalgaon-Sialmari", "Jamadarhat", "Nayeralga", "Lahoal", "Krishnai",
                                "North West Jorhat", "Ghilamara", "Telahi", "Fekamari", "Tamulpur", "Rowta", "Lakhipur", "Boitamari", "Chakchaka", "Baska", "Baghmara", "Chaiduar", "Kalain", "Sonai", "Pachim-Mangaldai", "Debitola", "Katlicherra", "Rampur", "Lowairpoa", "Moirabari", "Laokhowa", "Borbhag", "Tihu", "Nazira", "Mazbat", "Sarukhetri", "Mandia", "Pakabetbari",
                                "Salchapra", "Matia", "Morongi", "Boko", "Hajo", "Langsomepi", "Narayanpur", "Sakomatha", "Manikpur", "Barjalenga", "Gomariguri", "Patharkandi", "Mahamaya-Btc", "Barkhetri", "Amguri", "Demow", "Itakhuli", "Kakopathar", "Bhergaon", "Paschim-Mangaldai", "Barpeta", "West Abhaipur", "Hatidhura", "Golaghat East", "Binakandi", "Kamalpur", "Rangia", "Chandrapur", "Bilashipara-Btc", "Golakganj-Btc",
                                "Kachugaon", "Laharighat", "Mayang", "Batadrava", "Gaurisagar", "Borsola", "Palonghat", "Sonari", "Sidli-Chirang", "Joypur", "Golaghat South", "Dhalpukhuri", "Udali", "Chamaria", "Chaygaon", "Chapor-Salkocha-Btc", "Debitola", "Golakganj", "Karunabari", "Madhupur", "Rangapara", "Guijan", "Margherita", "Pub-Mangaldai", "Bhabanipur", "Udharbond", "Murkongselek", "Bilasipara", "Hailakandi",
                                "Bihdia -Jajikona", "Dimoria", "Rongmongwe", "Boginadi", "Ujani Majuli", "Kapili", "Balipara", "Borchala", "Gabhoru", "Mankachar", "South Salmara Part", "Hapjan", "Odalguri", "Chinthong", "Socheng", "Rajabazar", "Pub-Mangaldai", "Dhemaji", "Golakganj", "Samelangso", "Badarpur", "Dullavcherra", "Hatidhura", "Saikhowa", "Dhamdhama", "Jalah", "Silchar", "Hatidhura", "South Salmara", "Golaghat North",
                                "Golaghat West", "Kakodonga", "Lumding", "Jorhat Central", "Jorhat East", "Goroimari", "Dotma", "Batabraba (Part)", "Bhurbandha", "Dolongghat (Part)", "Kapili Pt.I", "Pachim Kaliabor", "Rupahi", "Barigog Banbhag", "Bechimari", "Amri", "Khoirabari", "Birshing-Jarua", "Chapar Salkocha", "Lakhipur", "Lala", "Bokajan", "Nilip", "Rupshi", "Lakhimpur", "Kaliabor", "Pakhimoria", "Dhekiajuli", "Sadiya",
                                "Rongkhang", "Gomaphulbari", "Tapang", "Manikpur Part", "Sipajhar", "Machkhowa", "Khowang", "Tengakhat", "Tingkhong", "Harangajao", "Balijana", "Kharmuza", "Algapur", "Sualkuchi", "Howraghat", "Lumbajong", "Kokrajhar", "Bihpuria", "Dhakuakhana", "Juria", "Kalaigaon", "Agomani", "Kaliapani", "South Karimganj", "Bilasipara", "Gossaigaon", "Majuli", "Dolongghat", "Khagarijan", "Srijangram", "Tapattary",
                                "Binnakandi", "Katigorah", "Narsingpur", "Lakuwa", "Bechimari", "Jaleswar", "Kuchdhowa", "Jugijan", "Titabor", "Rani (Pt)", "North Karimganj", "Paschim Nalbari", "Pub Nalbari", "Bihaguri", "Khoirabari", "Biswanath", "Borkhola", "Gauripur", "Panitola", "Diyang Valley", "Jorhat", "Chapar Salkocha", "Mahamaya", "Kathiatoli", "Sivasagar", "Goreswar", "Nagrijuli", "Gobardhana", "Behali", "Sootea", "Banskandi",
                                "Sapekhati", "Borobazar", "Bordoloni", "Mahamaya", "Rupshi", "Barbaruah", "New Sangbar", "Rongjuli", "Golaghat Central", "Bezera", "Bongaon", "Rani", "Debitola-Btc", "Rupshi-Btc", "Nowboicha", "Bajiagaon", "Moirabari Part", "Naduar"
                              ],
                              selectedValue: _selectedCommBlock,
                              onChanged:(value) {
                                setState(() {
                                  _selectedCommBlock = value;
                                });
                              }),
                          _buildTextField(labelText: "Pincode", myController:  _commPincodeController, hintText: "Enter Pincode",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              }),
                          _buildTextField(labelText: "Landmark Details ( If Any )", myController:  _commLandmarkController, hintText: "Enter Landmark Details",),
                          _buildRadioField("Whether Unit is Registered ?", ["Yes", "No"], _selectedReg, (value) {
                            setState(() {
                              _selectedReg = value;
                            });
                          }),
                          if(_selectedReg == "Yes") ...[
                            _buildTextField(labelText: "If yes,please mention UDYAM Registration No. ", myController:  _udyamRegNo, hintText: "Enter UDYAM Registration No.",)],
                          const SizedBox(height: 5),
                          const Text("Business Plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          _buildEditableLongTextField("Briefly Describe Your Business Plan", _businessPlanController),
                          _buildPreFilledField("Sector selected in the Registration Form", preFilledData!['sector']),
                          _buildPreFilledField("Sub Sector selected in the Registration Form", preFilledData!['sub_sector']),
                          _buildRadioField(
                              "Do you want to change the sector ?",
                              ["Yes", "No"],
                              _selectedChangeSector,
                                  (value) {
                                    setState(() {
                                      _selectedChangeSector = value;
                            });
                          },),

                          if(_selectedChangeSector == "Yes") ...[
                                _buildDropdownField(
                                    label: "New Sector",
                                    hintText: "Please select",
                                    options: ["Agriculture and Horticulture sector", "Fabrication/Hardware Business sector" , "Fisheries" , "Other sectors including services" , "Packaging sector" , "Plantation sector (Bamboo/Rubber/Agar etc)" , "Poultry/Dairy/Goatery/Piggery" , "Readymade Garment sector" , "Self-employment after professional courses" , "Stationary Business sector", "Wood based industries (Furniture sector)"],
                                    selectedValue: _selectedNewSector,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedNewSector = value;
                                      });
                                    }),
                                _buildDropdownField(
                                    label: "Sub-Sector",
                                    hintText: "Please select",
                                    options: ["Agar Nursery", "Agarbatti Making" , "Agribusiness" , "Aluminium Fabrication" , "Aquarium & Fish Feed Shop" , "Areca Leaf Plate Making" , "Assamese Confectionery" , "Atta Chaki Unit" , "Bakery" , "Bamboo Broom Making", "Banana Chips Making" , "Beaten Rice(Chira) Making" , "Bee Keeping" , "Bio Flock" , "Boutique" , "Breeding Farms/Hatcheries" , "Broiler Farming" , "Building Materials Store" , "Cane & Bamboo Decorative Items Making" , "Cane & Bamboo Furniture Making" , "Cannel & Other Pet Feed Shop" , "Car Washing" , "Cattle Feed Manufacturing" , "Cement Based Product Making" , "Chappal Making Unit" , "Civil Engineering Firm",
                                      "Coaching & Training Services" , "Custom Printing Services" , "Custom Tailoring Services" , "Dairy Based Product Manufacturing" , "Dairy Farming" , "Decorative Candle Making" , "Dental Clinic" , "Detergent Powder Manufacturing" , "Diagnostic Laboratory" , "Distilled Water Making" , "Dry Cleaning" , "DTP Centre" , "Duck Rearing for Meat" , "Electrical Repairing Shop" , "Excercise Book Making" , "Eye Care Centre" , "Fashion & Garment Store" , "Fashion Accessories Shop" , "Fast Food Stall" , "Fish Farming" , "Fish Feed Mill" , "Fitness & Wellness Centre" , "Flex Printing" , "Flower Nursery" , "Food Truck" , "Four Wheeler Repairing" , "Gents Beauty Parlour" , "Ginger Garlic Paste Making" , "Goat Farming" , "Grocery Shop" , "Hand Made Tea" , "Handloom Weaving" , "Hardware Store" , "Honey Processing" , "Horticulture Nursery" , "Ice Cream Production" , "Jam , Jelly Squash Making" , "Jute Bag Making Unit" , "Ladies Beauty Parlour" , "Mobile Repairing" , "Mushroom Processing" , "Mustard Oil" , "Namkeen Making" , "Noodle Making" ,
                                      "Office Stationery Shop" , "Organic Mosquito Repellent Making" , "Ornamental Fish" , "Paint Shop" , "Paper Bag Making" , "Paper Bag Making Unit" , "Paper Cup Making" , "Paper Plate Making" , "Photography & Videography" , "Pickle Making" , "Pig Feed Production" , "Piglet Rearing" , "Popcorn Making" , "Pork Product Manufacturing (e.g., sausages, bacon)" , "Poultry Feed Production" , "Puffed Rice (Muri) Making" , "Readymade Garment Manufacturing" , "Rice Mill" , "School Bag Making" , "School Stationery Shop" , "School Uniform Making" , "Slipper Making Unit" , "Soap Making" , "Spice Grinding & Packaging" , "Stationery Gifts & Specialty Items" , "Supari Processing" , "Swine Breeding Farms" , "Tea Blending & Packaging" , "Tea Nursery" , "Tea Stall" , "Tent House" , "Tomato Ketchup Making" , "Traditional Assamese Jewellery Making" , "Traditional Fishery" , "Two Wheeler Repairing" , "Vermicompost" , "Veterinary Clinic" , "Welding & Fabrication Services" , "Wholesale & Distribution" , "Wooden Craft & Artisan Products" , "Wooden Craft & Artisan Products" , "Wooden Door & Window Manufacturing" , "Wooden Furniture Components" ,
                                      "Workshop for Servicing of Agriculture Machinery & Equipment"],
                                    selectedValue: _selectedNewSubSector,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedNewSubSector = value;
                                      });
                                    }),
                                _buildDropdownField(
                                    label: "Type of Trade",
                                    hintText: "Please select",
                                    options: ["Manufacturing", "Others", "Service", "Trading"],
                                    selectedValue: _selectedTrade,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedTrade = value;
                                      });
                                    },),
                          ],
                          _buildRadioField("Have you prepared the Project Report ?", ["Yes", "No"], _selectedProjRep, (value) {
                            setState(() {
                              _selectedProjRep = value;
                            });
                          }),

                          if(_selectedProjRep == "Yes") ...[
                          _buildRadioField("Is the project report as per CMAAA format ?", ["Yes", "No"], _selectedRep, (value) {
                            setState(() {
                              _selectedRep = value;
                            });
                          }),
                          _buildTextField(labelText: "Enter Project No", myController:  _projectNoController, hintText: "Enter Project No",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              }),
                          _buildFileUploadSection("Upload Project Report (Max. Size 5MB)", projRep, pickProjectReport),],
                          const SizedBox(height:12),
                          const Text("If you have not prepared the project report, download project templates from the link provided and attach the file in this section "),
                          const SizedBox(height:12),
                          _buildDropdownField(
                              label: "Proposed Project Cost",
                              hintText: "Please select",
                              options: ["Less than 2.5 Lakhs", "2.5 Lakhs - 5 Lakhs", "5 - 7.5 Lakhs", "More than 7.5 Lakhs"],
                              selectedValue: _selectedProjCost,
                              onChanged: (value) {
                                setState(() {
                                  _selectedProjCost = value;
                                });
                              }),
                          _buildTextField(labelText: "Amount anticipated as Bank Loan (in Rs.), if any", myController:  _amtAnticipatedController, hintText: "Enter Amount anticipated as Bank Loan ",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              }),
                          _buildTextField(labelText: "Self Contribution (in Rs.), if any", myController:  _selfContriController, hintText: "Enter Self Contribution",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              }),
                          _buildTextField(labelText: "DPR Amount", myController:  _dprAmtController, hintText: "Enter DPR Amount",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              }),
                          _buildRadioField("Land/Building Availability for Business Establishment ?", ["Yes", "No"], _selectedLandAvail, (value) {
                            setState(() {
                              _selectedLandAvail = value;
                            });
                          }),

                          if(_selectedLandAvail == "Yes") ...[
                            _buildDropdownField(
                              label: "Existing Land/Building Arrangement",
                              hintText: "Please select",
                              options: ["Own", "Rent", "Lease"],
                              selectedValue: _selectedLandArrangement,
                              onChanged: (value) {
                                setState(() {
                                  _selectedLandArrangement = value;
                                });
                              }),
                            _buildFileUploadSection("Upload Land document (Max. Size 2MB)", landDoc, picklandDoc),
                            _buildTextField(labelText: "Land/Building Area (in sqft)", myController:  _landArea,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                }),
                          ],
                          if(_selectedLandAvail == "No") ...[
                            _buildDropdownField(
                              label: "Proposed Land/Building Arrangement",
                              hintText: "Please select", options: ["Rent", "Lease"],
                              selectedValue: _selectedLandArrangement,
                              onChanged: (value) {
                                setState(() {
                                  _selectedLandArrangement = value;
                                });
                              }),
                          ],

                          _buildRadioField("Previous Experience in similar sector ?", ["Yes", "No"], _selectedPrevExp, (value) {
                            setState(() {
                              _selectedPrevExp = value;
                            });
                          }),

                          if(_selectedPrevExp == "Yes") ...[
                            _buildTextField(labelText: "If Yes, Years of Experience", myController:  _YearsofExp,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                }),
                            _buildFileUploadSection("Upload experience certification (Max. Size 2MB)", landDoc, picklandDoc),
                          ],

                          _buildRadioField("Skill Training Experience in the selected sector ?", ["Yes", "No"], _selectedSkillExp, (value) {
                            setState(() {
                              _selectedSkillExp = value;
                            });
                          }),
                          if(_selectedSkillExp == "Yes") ...[
                            _buildFileUploadSection("Upload supporting document (Max. Size 2MB)", SuppDoc, pickSuppDoc),
                            _buildTextField(labelText: "Name of the Institution", myController:  _InstitutionName,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                }),
                            _buildTextField(labelText: "Name of the Training", myController:  _TrainingName,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                }),
                            _buildTextField(labelText: "Training Duration (in months)", myController:  _TrainingDuration,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "This field is required";
                                  }
                                  return null;
                                }),
                          ],

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Skill Training Requirement",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                              ),
                              const SizedBox(height: 8),
                              ...skillOptions.map((skill) {
                                return Transform.scale(
                                  scale: 1,
                                  child: CheckboxListTile(
                                    title: Text(
                                      skill,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    value: selectedSkills[skill],
                                    controlAffinity: ListTileControlAffinity.leading,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        selectedSkills[skill] = value ?? false;
                                        _selectedSkillError = null;
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                              if (selectedSkills['Others'] == true)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14.5),
                                  child: TextFormField(
                                    controller: _skillTrainingReqController,
                                    decoration: const InputDecoration(
                                      hintText: 'Specify other training',
                                      labelText: 'Other Skill Training',
                                    ),
                                    validator: (value) {
                                      if (selectedSkills['Others'] == true &&
                                          (value == null || value.isEmpty)) {
                                        return 'Please specify the other training required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              if (_selectedSkillError != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    _selectedSkillError!,
                                    style: const TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),


                          _buildTextField(labelText: "Manpower requirement for business (including self)", myController:  _manPowerReqController, hintText: "Enter Manpower requirement for business (including self)",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              }),
                          _buildTextField(labelText: "Power requirement in KW", myController:  _powerReqController, hintText: "Enter Power requirement in KW",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "This field is required";
                                }
                                return null;
                              }),

                          const SizedBox(height: 20),
                          sectionTitle("ATTACH ENCLOSURE(S)"),
                          _buildFileUploadSection("Identity Proof", identityProof, pickIdentityProof),
                          _buildFileUploadSection("Address Proof of the Applicant", addressProof, pickAddressProof),
                          _buildFileUploadSection("Education Qualification", qualificationProof, pickQualificationProof),
                          _buildFileUploadSection("Employment Exchange Registration Card", empExchangeRegCard, pickEmpExchangeCard),
                          _buildFileUploadSection("Bank Passbook/Cancelled Check Book", bankPassBook, pickBankPassbook),
                          _buildFileUploadSection("PAN Card", panCard, pickPanCard),


                          const SizedBox(height: 20),
                          sectionTitle("Declaration"),
                          Row(
                            children: [
                              Checkbox(
                                value: _isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    _isChecked = value ?? false;
                                  });
                                },
                              ),
                              const Expanded(
                                child: Text(
                                  "I hereby certify that all information furnished by me is true, correct and complete. "
                                      "I am not a defaulter of any bank. Mere submission of the application form under this scheme "
                                      "does not guarantee benefits under this scheme. I am aware that any misrepresentation "
                                      "or omission of facts may result in the rejection of my application or subsequent actions as per the applicable laws.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.drafts),
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
                                  icon: const Icon(Icons.task_alt_rounded),
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
                                  icon: const Icon(Icons.restart_alt),
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
                          const SizedBox(height: 20),
                        ],
                      ),
                    )],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPreFilledField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Slightly more space
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: const BoxConstraints(
              minHeight: 60, // Minimum height
            ),
            width: double.infinity,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              softWrap: true,
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
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController myController,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: myController,
            keyboardType: keyboardType,
            maxLines: keyboardType == TextInputType.multiline ? null : 1,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 14.5
              ),
              border: const OutlineInputBorder(),
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


  Widget _buildEditableLongTextField(String label, TextEditingController controller, {String? hintText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: null, // Allows expansion as user types
            minLines: 4,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              hintText: hintText,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              } else if (value.trim().split(RegExp(r'\s+')).length > 200) {
                return 'Please limit your response to 200 words or fewer';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }


  Widget _buildRadioField(
      String labelText,
      List<String> options,
      String? selectedValue,
      ValueChanged<String?> onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
          ),
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
                  Text(
                    option,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.9,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }


  Widget _buildDropdownField({
    String? label,
    String? hintText,
    required List<String> options,
    required String? selectedValue,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(label!, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
          ],
          SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              value: options.contains(selectedValue) ? selectedValue : null,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: hintText != null ? Text(hintText!) : null,
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


  Widget _buildFileUploadSection(String label, PlatformFile? file, VoidCallback onPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.upload_file),
          label: const Text("Choose File"),
        ),
        const SizedBox(height: 4),
        Text(
          file != null ? "Selected: ${file.name}" : "No file selected",
          style: TextStyle(color: file != null ? Colors.green : Colors.grey),
        ),
      ],
    );
  }


  Widget _infoBox(String title, List<String> points) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        border: Border.all(color: Colors.blue, width: 1),
        borderRadius: BorderRadius.circular(8),
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
          ...points.asMap().entries.map((entry) {
            int index = entry.key;
            String point = entry.value;

            // Special handling
            bool isFirstLine = index == 0;
            bool isInstructionLine = point == "Following documents are required at time of application submission -";
            bool isDocumentItem = index > 1; // shift all lines after index 1

            return Padding(
              padding: EdgeInsets.only(
                top: 4,
                bottom: 4,
                left: isDocumentItem ? 16.0 : 0, // Indent document items
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isFirstLine && !isInstructionLine)
                    const Icon(Icons.circle, size: 7, color: Colors.black),
                  if (!isFirstLine && !isInstructionLine)
                    const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: isFirstLine ? Colors.red : Colors.black,
                        fontWeight: isFirstLine || isInstructionLine
                            ? FontWeight.normal
                            : FontWeight.bold,
                        fontStyle: isFirstLine ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConditionalQuestions() {
    if (preFilledData != null && preFilledData!['business_activity'] == 'Proposed') {
      return Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Date of Commencement",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      hintText: "Month",
                      options: _months,
                      selectedValue: _selectedexistingMonth,
                      onChanged: (value) {
                        setState(() {
                          _selectedexistingMonth = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      hintText: "Year",
                      options: _years,
                      selectedValue: _selectedexistingYear,
                      onChanged: (value) {
                        setState(() {
                          _selectedexistingYear = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildTextField(labelText: "Proposed Name of the Enterprise", myController:  _proposedNameController, hintText: "Enter Name of the Enterprise",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                return null;
              }),
          _buildDropdownField(
              label: "Type of Enterprise",
              hintText: "Please select",
              options: ["Proprietorship", "Partnership", "Limited Liability Partnership(LLP)", "Private Limited Company", "Public Limited Company", "One Person Company(OPC)", "Joint Venture", "Non-Profit Company"],
              selectedValue: _selectedEnterprise,
              onChanged:(value) {
                setState(() {
                  _selectedEnterprise = value;
                });
              }),

          const SizedBox(height : 5),
          const Text("Proposed Business Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          _buildTextField(labelText: "Address Line 1", myController:  _busAddressController1, hintText: "Enter address line 1",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                return null;
              }),
          _buildTextField(labelText: "Address Line 2", myController:  _busAddressController2, hintText: "Enter address line 2",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                return null;
              }),
          _buildTextField(labelText: "Address Line 3", myController:  _busAddressController3, hintText: "Enter address line 3",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                return null;
              }),
          _buildDropdownField(
              label: "State",
              hintText: "Please select",
              options: ["Assam"],
              selectedValue: _selectedBusState,
              onChanged:(value) {
                setState(() {
                  _selectedBusState = value;
                });
              }),
          _buildDropdownField(
              label: "District",
              hintText: "Please select",
              options: ["Baksa", "Barpeta", "Bongaigaon", "Cachar", "Charaideo", "Chirang", "Darrang", "Dhemaji", "Dhubri", "Dibrugarh", "Dima Hasao", "Goalpara", "	Golaghat",
                "Hailakandi", "Jorhat", "Kamrup (Metropolitan)", "Kamrup", "Karbi Anglong", "Karimganj", "Kokrajhar", "Lakhimpur", "Majuli", "Morigaon", "Nagaon", "Nalbari", "Sibsagar", "Sonitpur", "South Salmara", "Tinsukia", "West Karbi Anglong", "Biswanath", "Hojai", "Bajali", "Tamulpur", "	Udalguri"],
              selectedValue: _selectedBusDistrict,
              onChanged:(value) {
                setState(() {
                  _selectedBusDistrict = value;
                });
              }),
          _buildDropdownField(
              label: "Legislative Assembly Constituency (LAC)",
              hintText: "Please select",
              options: ["Abhayapuri", "Algapur-Katlicherra", "Amri (ST)", "Bajali", "Baksa (ST)", "Baokhungri", "Barchalla", "Barhampur", "Barkhetri", "Barkhota", "Barpeta (SC)", "Behali (SC)", "Bhergaon", "Bhowanipur-Sorbhog" , "Bihpuria", "Bijni", "Bilasipara", "Binnakandi", "Birsing Jarua" , "Biswanath", "Bokajan (ST)", "Bokakhat", "Boko-Chaygaon (ST)", "Bongaigaon", "Chabua-Lahowal", "Chamaria", "Chenga", "Dalgaon","Demow" , "Dergaon", "Dhakuakhana (ST)", "Dhekiajuli", "Dhemaji (ST)",
                "Dhing", "Dholai (SC)", "Dhubri", "Dhuliajan" , "Dibrugarh", "Digboi", "Dimoria (SC)" , "Diphu (ST)", "Dispur", "Doomdooma", "Dotma (ST)" , "Dudhnai (ST)", "Gauripur", "Goalpara East", "Goalpara West (ST)", "Gohpur", "Golaghat", "Golakganj", "Goreswar" , "Gossaigaon", "Guwahati Central", "Haflong (ST)", "Hailakandi", "Hajo-Sualkuci (SC)",
                "Hojai", "Howraghat (ST)", "Jagiroad (SC)", "Jaleshwar", "Jalukbari", "Jonai (ST)", "Jorhat", "Kaliabor", "Kamalpur", "Karimganj North", "Karimganj South", "Katigorah", "Khowang", "Khumtai", "Kokrajhar (ST)", "Laharighat", "Lakhimpur", "Lakhipur", "Lumding", "Mahmora", "Majuli (ST)" , "Makum" , "Manas" , "Mandia" , "Mangaldai", "Mankachar", "Margherita", "Mariani", "Mazbat", "Morigaon", "Naduar" , "Nagaon-Batadraba" , "Naharkatia", "Nalbari",
                "Nazira" , "New Guwahati" , "Nowboicha (SC)", "Pakabetbari" , "Palasbari", "Parbatjhora", "Patharkandi", "Raha (SC)", "Ram Krishana Nagar (SC)" , "Rangapara", "Rangia", "Rongkhang (ST)" , "Rongonadi", "Rupahihat", "Sadiya", "Samaguri", "Sarupathar", "Sibsagar", "Sidli Chirang (ST)", "Silchar", "Sipajhar", "Sissibargaon" , "Sonai", "Sonari", "Srijangram", "Tamulpur (ST)" , "Tangla", "Teok", "Tezpur", "Tihu", "Tingkhong", "Tinsukia", "Titabar", "Udalguri (ST)", "Udharbond"],
              selectedValue: _selectedBusLac,
              onChanged:(value) {
                setState(() {
                  _selectedBusLac = value;
                });
              }),
          _buildDropdownField(
              label: "Sub District",
              hintText: "Please select",
              options: ["Abhayapuri", "Algapur-Katlicherra", "Bajali", "Barchalla", "Barhampur", "Barkhetri", "Barkhota", "Behali", "Bhowanipur-Sorbhog" , "Bihpuria", "Bilasipara", "Binnakandi", "Birsing Jarua" , "Bokakhat", "Boko-Chaygaon", "Chabua-Lahowal", "Chamaria", "Chenga", "Dalgaon","Demow" , "Dergaon", "Dhakuakhana", "Dharmapur-Tihu" , "Dhekiajuli",
                "Dhing", "Dholai", "Digboi", "Dimoria" , "Dispur", "Doomdooma", "Dudhnai", "Duliajan" , "Gauripur", "Goalpara West", "Gohpur", "Golakganj",
                "Jagiroad ", "Jaleshwar", "Jalukbari", "Jonai ", "Kaliabor", "Kamalpur", "Karimganj South", "Katigorah", "Khowang", "Khumtai", "Laharighat", "Lakhipur", "Lumding", "Mahmora", "Makum" , "Mandia-Jania" , "Margherita", "Mariani", "Naduar" , "Naharkatia",
                "Nazira" , "New Guwahati" , "Nowboicha", "Pakabetbari" , "Palasbari", "Patharkandi", "Raha", "Ram Krishana Nagar" , "Rangapara", "Rangia", "Rongonadi", "Rupahihat", "Sadiya", "Samaguri", "Sarupathar", "Sipajhar", "Sissibargaon" , "Sonai", "Sonari", "Srijangram", "Teok", "Tingkhong", "Titabar","Udharbond"],
              selectedValue: _selectedBusSubDistrict,
              onChanged:(value) {
                setState(() {
                  _selectedBusSubDistrict = value;
                });
              }),
          _buildDropdownField(
              label: "Block",
              hintText: "Please select",
              options: ["Sissiborgaon", "Barama", "Gobardhana", "Chenga", "Bajali", "Ruposhi", "Diyungbra", "Jatinga Valley", "South Hailakandi", "Chayani", "Bezera (Pt)", "Ramkrishna Nagar", "Barhampur", "Raha", "Dalgaon-Sialmari", "Kalaigaon", "Pub Chaiduar", "Dangtol", "Dalgaon-Sialmari", "Jamadarhat", "Nayeralga", "Lahoal", "Krishnai",
                "North West Jorhat", "Ghilamara", "Telahi", "Fekamari", "Tamulpur", "Rowta", "Lakhipur", "Boitamari", "Chakchaka", "Baska", "Baghmara", "Chaiduar", "Kalain", "Sonai", "Pachim-Mangaldai", "Debitola", "Katlicherra", "Rampur", "Lowairpoa", "Moirabari", "Laokhowa", "Borbhag", "Tihu", "Nazira", "Mazbat", "Sarukhetri", "Mandia", "Pakabetbari",
                "Salchapra", "Matia", "Morongi", "Boko", "Hajo", "Langsomepi", "Narayanpur", "Sakomatha", "Manikpur", "Barjalenga", "Gomariguri", "Patharkandi", "Mahamaya-Btc", "Barkhetri", "Amguri", "Demow", "Itakhuli", "Kakopathar", "Bhergaon", "Paschim-Mangaldai", "Barpeta", "West Abhaipur", "Hatidhura", "Golaghat East", "Binakandi", "Kamalpur", "Rangia", "Chandrapur", "Bilashipara-Btc", "Golakganj-Btc",
                "Kachugaon", "Laharighat", "Mayang", "Batadrava", "Gaurisagar", "Borsola", "Palonghat", "Sonari", "Sidli-Chirang", "Joypur", "Golaghat South", "Dhalpukhuri", "Udali", "Chamaria", "Chaygaon", "Chapor-Salkocha-Btc", "Debitola", "Golakganj", "Karunabari", "Madhupur", "Rangapara", "Guijan", "Margherita", "Pub-Mangaldai", "Bhabanipur", "Udharbond", "Murkongselek", "Bilasipara", "Hailakandi",
                "Bihdia -Jajikona", "Dimoria", "Rongmongwe", "Boginadi", "Ujani Majuli", "Kapili", "Balipara", "Borchala", "Gabhoru", "Mankachar", "South Salmara Part", "Hapjan", "Odalguri", "Chinthong", "Socheng", "Rajabazar", "Pub-Mangaldai", "Dhemaji", "Golakganj", "Samelangso", "Badarpur", "Dullavcherra", "Hatidhura", "Saikhowa", "Dhamdhama", "Jalah", "Silchar", "Hatidhura", "South Salmara", "Golaghat North",
                "Golaghat West", "Kakodonga", "Lumding", "Jorhat Central", "Jorhat East", "Goroimari", "Dotma", "Batabraba (Part)", "Bhurbandha", "Dolongghat (Part)", "Kapili Pt.I", "Pachim Kaliabor", "Rupahi", "Barigog Banbhag", "Bechimari", "Amri", "Khoirabari", "Birshing-Jarua", "Chapar Salkocha", "Lakhipur", "Lala", "Bokajan", "Nilip", "Rupshi", "Lakhimpur", "Kaliabor", "Pakhimoria", "Dhekiajuli", "Sadiya",
                "Rongkhang", "Gomaphulbari", "Tapang", "Manikpur Part", "Sipajhar", "Machkhowa", "Khowang", "Tengakhat", "Tingkhong", "Harangajao", "Balijana", "Kharmuza", "Algapur", "Sualkuchi", "Howraghat", "Lumbajong", "Kokrajhar", "Bihpuria", "Dhakuakhana", "Juria", "Kalaigaon", "Agomani", "Kaliapani", "South Karimganj", "Bilasipara", "Gossaigaon", "Majuli", "Dolongghat", "Khagarijan", "Srijangram", "Tapattary",
                "Binnakandi", "Katigorah", "Narsingpur", "Lakuwa", "Bechimari", "Jaleswar", "Kuchdhowa", "Jugijan", "Titabor", "Rani (Pt)", "North Karimganj", "Paschim Nalbari", "Pub Nalbari", "Bihaguri", "Khoirabari", "Biswanath", "Borkhola", "Gauripur", "Panitola", "Diyang Valley", "Jorhat", "Chapar Salkocha", "Mahamaya", "Kathiatoli", "Sivasagar", "Goreswar", "Nagrijuli", "Gobardhana", "Behali", "Sootea", "Banskandi",
                "Sapekhati", "Borobazar", "Bordoloni", "Mahamaya", "Rupshi", "Barbaruah", "New Sangbar", "Rongjuli", "Golaghat Central", "Bezera", "Bongaon", "Rani", "Debitola-Btc", "Rupshi-Btc", "Nowboicha", "Bajiagaon", "Moirabari Part", "Naduar"
              ],
              selectedValue: _selectedBusBlock,
              onChanged:(value) {
                setState(() {
                  _selectedBusBlock = value;
                });
              }),
          _buildTextField(labelText: "Pincode", myController:  _busPincodeController, hintText: "Enter Pincode",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                return null;
              }),
          _buildTextField(labelText: "Landmark Details ( If Any )", myController:  _busLandmarkController, hintText: "Enter landmark details",),
          _buildTextField(labelText: "Mobile Number", myController:  _busMobileController, hintText: "Enter mobile number",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                return null;
              }),
        ],
      );
    } else if (preFilledData != null && preFilledData!['business_activity'] == 'Existing') {
      return Column(
        children: [
          _buildRadioField("Existing Business Activity Location ?", ["In Assam", "Outside Assam"], _selectedexistingBusLoc, (value) {
            setState(() {
              _selectedexistingBusLoc = value;
            });
          }),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Date of Commencement",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      hintText: "Month",
                      options: _months,
                      selectedValue: _selectedexistingMonth,
                      onChanged: (value) {
                        setState(() {
                          _selectedexistingMonth = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      hintText: "Year",
                      options: _years,
                      selectedValue: _selectedexistingYear,
                      onChanged: (value) {
                        setState(() {
                          _selectedexistingYear = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildTextField(labelText: "Name of the Existing Enterprise", myController:  _existingNameController, hintText: "Enter Name of the Enterprise",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                return null;
              }),
          _buildDropdownField(
              label: "Type of Enterprise",
              hintText: "Please select",
              options: ["Proprietorship", "Partnership", "Limited Liability Partnership(LLP)", "Private Limited Company", "Public Limited Company", "One Person Company(OPC)", "Joint Venture", "Non-Profit Company"],
              selectedValue: _selectedEnterprise,
              onChanged:(value) {
                setState(() {
                  _selectedEnterprise = value;
                });
              }),
          const SizedBox(height : 5),
          const Text("Existing Business Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _buildTextField(labelText: "Address Line 1", myController:  _busAddressController1, hintText: "Enter address line 1",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                return null;
              }),
          _buildTextField(labelText: "Address Line 2", myController:  _busAddressController2, hintText: "Enter address line 2",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                return null;
              }),
          _buildTextField(labelText: "Address Line 3", myController:  _busAddressController3, hintText: "Enter address line 3",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                return null;
              }),
          _buildDropdownField(
              label: "State",
              hintText: "Please select",
              options: ["Assam"],
              selectedValue: _selectedBusState,
              onChanged:(value) {
                setState(() {
                  _selectedBusState = value;
                });
              }),
          _buildDropdownField(
              label: "District",
              hintText: "Please select",
              options: ["Baksa", "Barpeta", "Bongaigaon", "Cachar", "Charaideo", "Chirang", "Darrang", "Dhemaji", "Dhubri", "Dibrugarh", "Dima Hasao", "Goalpara", "	Golaghat",
                "Hailakandi", "Jorhat", "Kamrup (Metropolitan)", "Kamrup", "Karbi Anglong", "Karimganj", "Kokrajhar", "Lakhimpur", "Majuli", "Morigaon", "Nagaon", "Nalbari", "Sibsagar", "Sonitpur", "South Salmara", "Tinsukia", "West Karbi Anglong", "Biswanath", "Hojai", "Bajali", "Tamulpur", "	Udalguri"],
              selectedValue: _selectedBusDistrict,
              onChanged:(value) {
                setState(() {
                  _selectedBusDistrict = value;
                });
              }),
          _buildDropdownField(
              label: "Legislative Assembly Constituency (LAC)",
              hintText: "Please select",
              options: ["Abhayapuri", "Algapur-Katlicherra", "Amri (ST)", "Bajali", "Baksa (ST)", "Baokhungri", "Barchalla", "Barhampur", "Barkhetri", "Barkhota", "Barpeta (SC)", "Behali (SC)", "Bhergaon", "Bhowanipur-Sorbhog" , "Bihpuria", "Bijni", "Bilasipara", "Binnakandi", "Birsing Jarua" , "Biswanath", "Bokajan (ST)", "Bokakhat", "Boko-Chaygaon (ST)", "Bongaigaon", "Chabua-Lahowal", "Chamaria", "Chenga", "Dalgaon","Demow" , "Dergaon", "Dhakuakhana (ST)", "Dhekiajuli", "Dhemaji (ST)",
                "Dhing", "Dholai (SC)", "Dhubri", "Dhuliajan" , "Dibrugarh", "Digboi", "Dimoria (SC)" , "Diphu (ST)", "Dispur", "Doomdooma", "Dotma (ST)" , "Dudhnai (ST)", "Gauripur", "Goalpara East", "Goalpara West (ST)", "Gohpur", "Golaghat", "Golakganj", "Goreswar" , "Gossaigaon", "Guwahati Central", "Haflong (ST)", "Hailakandi", "Hajo-Sualkuci (SC)",
                "Hojai", "Howraghat (ST)", "Jagiroad (SC)", "Jaleshwar", "Jalukbari", "Jonai (ST)", "Jorhat", "Kaliabor", "Kamalpur", "Karimganj North", "Karimganj South", "Katigorah", "Khowang", "Khumtai", "Kokrajhar (ST)", "Laharighat", "Lakhimpur", "Lakhipur", "Lumding", "Mahmora", "Majuli (ST)" , "Makum" , "Manas" , "Mandia" , "Mangaldai", "Mankachar", "Margherita", "Mariani", "Mazbat", "Morigaon", "Naduar" , "Nagaon-Batadraba" , "Naharkatia", "Nalbari",
                "Nazira" , "New Guwahati" , "Nowboicha (SC)", "Pakabetbari" , "Palasbari", "Parbatjhora", "Patharkandi", "Raha (SC)", "Ram Krishana Nagar (SC)" , "Rangapara", "Rangia", "Rongkhang (ST)" , "Rongonadi", "Rupahihat", "Sadiya", "Samaguri", "Sarupathar", "Sibsagar", "Sidli Chirang (ST)", "Silchar", "Sipajhar", "Sissibargaon" , "Sonai", "Sonari", "Srijangram", "Tamulpur (ST)" , "Tangla", "Teok", "Tezpur", "Tihu", "Tingkhong", "Tinsukia", "Titabar", "Udalguri (ST)", "Udharbond"],
              selectedValue: _selectedBusLac,
              onChanged:(value) {
                setState(() {
                  _selectedBusLac = value;
                });
              }),
          _buildDropdownField(
              label: "Sub District",
              hintText: "Please select",
              options: ["Abhayapuri", "Algapur-Katlicherra", "Bajali", "Barchalla", "Barhampur", "Barkhetri", "Barkhota", "Behali", "Bhowanipur-Sorbhog" , "Bihpuria", "Bilasipara", "Binnakandi", "Birsing Jarua" , "Bokakhat", "Boko-Chaygaon", "Chabua-Lahowal", "Chamaria", "Chenga", "Dalgaon","Demow" , "Dergaon", "Dhakuakhana", "Dharmapur-Tihu" , "Dhekiajuli",
                "Dhing", "Dholai", "Digboi", "Dimoria" , "Dispur", "Doomdooma", "Dudhnai", "Duliajan" , "Gauripur", "Goalpara West", "Gohpur", "Golakganj",
                "Jagiroad ", "Jaleshwar", "Jalukbari", "Jonai ", "Kaliabor", "Kamalpur", "Karimganj South", "Katigorah", "Khowang", "Khumtai", "Laharighat", "Lakhipur", "Lumding", "Mahmora", "Makum" , "Mandia-Jania" , "Margherita", "Mariani", "Naduar" , "Naharkatia",
                "Nazira" , "New Guwahati" , "Nowboicha", "Pakabetbari" , "Palasbari", "Patharkandi", "Raha", "Ram Krishana Nagar" , "Rangapara", "Rangia", "Rongonadi", "Rupahihat", "Sadiya", "Samaguri", "Sarupathar", "Sipajhar", "Sissibargaon" , "Sonai", "Sonari", "Srijangram", "Teok", "Tingkhong", "Titabar","Udharbond"],
              selectedValue: _selectedBusSubDistrict,
              onChanged:(value) {
                setState(() {
                  _selectedBusSubDistrict = value;
                });
              }),
          _buildDropdownField(
              label: "Block",
              hintText: "Please select",
              options: ["Sissiborgaon", "Barama", "Gobardhana", "Chenga", "Bajali", "Ruposhi", "Diyungbra", "Jatinga Valley", "South Hailakandi", "Chayani", "Bezera (Pt)", "Ramkrishna Nagar", "Barhampur", "Raha", "Dalgaon-Sialmari", "Kalaigaon", "Pub Chaiduar", "Dangtol", "Dalgaon-Sialmari", "Jamadarhat", "Nayeralga", "Lahoal", "Krishnai",
                "North West Jorhat", "Ghilamara", "Telahi", "Fekamari", "Tamulpur", "Rowta", "Lakhipur", "Boitamari", "Chakchaka", "Baska", "Baghmara", "Chaiduar", "Kalain", "Sonai", "Pachim-Mangaldai", "Debitola", "Katlicherra", "Rampur", "Lowairpoa", "Moirabari", "Laokhowa", "Borbhag", "Tihu", "Nazira", "Mazbat", "Sarukhetri", "Mandia", "Pakabetbari",
                "Salchapra", "Matia", "Morongi", "Boko", "Hajo", "Langsomepi", "Narayanpur", "Sakomatha", "Manikpur", "Barjalenga", "Gomariguri", "Patharkandi", "Mahamaya-Btc", "Barkhetri", "Amguri", "Demow", "Itakhuli", "Kakopathar", "Bhergaon", "Paschim-Mangaldai", "Barpeta", "West Abhaipur", "Hatidhura", "Golaghat East", "Binakandi", "Kamalpur", "Rangia", "Chandrapur", "Bilashipara-Btc", "Golakganj-Btc",
                "Kachugaon", "Laharighat", "Mayang", "Batadrava", "Gaurisagar", "Borsola", "Palonghat", "Sonari", "Sidli-Chirang", "Joypur", "Golaghat South", "Dhalpukhuri", "Udali", "Chamaria", "Chaygaon", "Chapor-Salkocha-Btc", "Debitola", "Golakganj", "Karunabari", "Madhupur", "Rangapara", "Guijan", "Margherita", "Pub-Mangaldai", "Bhabanipur", "Udharbond", "Murkongselek", "Bilasipara", "Hailakandi",
                "Bihdia -Jajikona", "Dimoria", "Rongmongwe", "Boginadi", "Ujani Majuli", "Kapili", "Balipara", "Borchala", "Gabhoru", "Mankachar", "South Salmara Part", "Hapjan", "Odalguri", "Chinthong", "Socheng", "Rajabazar", "Pub-Mangaldai", "Dhemaji", "Golakganj", "Samelangso", "Badarpur", "Dullavcherra", "Hatidhura", "Saikhowa", "Dhamdhama", "Jalah", "Silchar", "Hatidhura", "South Salmara", "Golaghat North",
                "Golaghat West", "Kakodonga", "Lumding", "Jorhat Central", "Jorhat East", "Goroimari", "Dotma", "Batabraba (Part)", "Bhurbandha", "Dolongghat (Part)", "Kapili Pt.I", "Pachim Kaliabor", "Rupahi", "Barigog Banbhag", "Bechimari", "Amri", "Khoirabari", "Birshing-Jarua", "Chapar Salkocha", "Lakhipur", "Lala", "Bokajan", "Nilip", "Rupshi", "Lakhimpur", "Kaliabor", "Pakhimoria", "Dhekiajuli", "Sadiya",
                "Rongkhang", "Gomaphulbari", "Tapang", "Manikpur Part", "Sipajhar", "Machkhowa", "Khowang", "Tengakhat", "Tingkhong", "Harangajao", "Balijana", "Kharmuza", "Algapur", "Sualkuchi", "Howraghat", "Lumbajong", "Kokrajhar", "Bihpuria", "Dhakuakhana", "Juria", "Kalaigaon", "Agomani", "Kaliapani", "South Karimganj", "Bilasipara", "Gossaigaon", "Majuli", "Dolongghat", "Khagarijan", "Srijangram", "Tapattary",
                "Binnakandi", "Katigorah", "Narsingpur", "Lakuwa", "Bechimari", "Jaleswar", "Kuchdhowa", "Jugijan", "Titabor", "Rani (Pt)", "North Karimganj", "Paschim Nalbari", "Pub Nalbari", "Bihaguri", "Khoirabari", "Biswanath", "Borkhola", "Gauripur", "Panitola", "Diyang Valley", "Jorhat", "Chapar Salkocha", "Mahamaya", "Kathiatoli", "Sivasagar", "Goreswar", "Nagrijuli", "Gobardhana", "Behali", "Sootea", "Banskandi",
                "Sapekhati", "Borobazar", "Bordoloni", "Mahamaya", "Rupshi", "Barbaruah", "New Sangbar", "Rongjuli", "Golaghat Central", "Bezera", "Bongaon", "Rani", "Debitola-Btc", "Rupshi-Btc", "Nowboicha", "Bajiagaon", "Moirabari Part", "Naduar"
              ],
              selectedValue: _selectedBusBlock,
              onChanged:(value) {
                setState(() {
                  _selectedBusBlock = value;
                });
              }),
          _buildTextField(labelText: "Pincode", myController:  _busPincodeController, hintText: "Enter Pincode",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                return null;
              }),
          _buildTextField(labelText: "Landmark Details ( If Any )", myController:  _busLandmarkController, hintText: "Enter landmark details",),
          _buildTextField(labelText: "Mobile Number", myController:  _busMobileController, hintText: "Enter mobile number",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "This field is required";
                }
                return null;
              }),
        ],
      );
    } else {
      return Text("No specific questions available.");
    }
  }
}



import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'users.db');
    print('Database Path: $path');

    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        print('Creating tables...');
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('⚡ Upgrading database from v$oldVersion to v$newVersion');
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE form_data ADD COLUMN user_id INTEGER;');
        }
      },
    );
  }

  // USERS TABLE
  Future<void> _createTables(Database db) async {
    await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            contact TEXT,
            password TEXT,
            is_logged_in INTEGER DEFAULT 0 
          )
        ''');

    // FORM DATA TABLE
    await db.execute('''
          CREATE TABLE form_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            applicant_name TEXT,
            father_name TEXT,
            gender TEXT,
            social_category TEXT,
            dob TEXT,
            pan_number TEXT,
            employment_exchange_no TEXT,
            bpl TEXT,
            marital_status TEXT,
            sector TEXT,
            sub_sector TEXT,
            trade_type TEXT,
            photo TEXT,
            address1 TEXT,
            address2 TEXT,
            address3 TEXT,
            state TEXT,
            district TEXT,
            lac TEXT,
            co_district TEXT,
            pincode TEXT,
            mobile TEXT,
            email TEXT,
            business_district TEXT,
            business_activity TEXT,
            business_address TEXT,
            assistance TEXT,
            degree TEXT,
            course TEXT,
            board TEXT,
            college TEXT,
            passing_date TEXT,
            percentage TEXT,
            division TEXT,
            bank_account TEXT,
            ifsc TEXT,
            bank_name TEXT,
            bank_branch TEXT,
            bank_address TEXT
          )
        ''');

    // REGISTRATION TABLE
    await db.execute('''
          CREATE TABLE registration (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            regNo TEXT UNIQUE,
            schemeName TEXT,
            submissionDate TEXT,
            status TEXT
        )
       ''');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    print("Database Closed.");
  }


  Future<void> checkDatabasePath() async {
    String path = join(await getDatabasesPath(), 'users.db');
    print("📍 Database Path: $path");
  }


  //INSERT A NEW USER
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  //FETCH ALL USERS
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // HASHING FUNC
  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  //USER LOGIN
  Future<int?> loginUser(String mobile, String password) async {
    final db = await database;

    String hashedPassword = hashPassword(password);
    print("🔍 Hashed Password for Login Attempt: $hashedPassword");

    List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'contact = ? AND password = ?',
      whereArgs: [mobile, hashedPassword],
    );

    if (users.isNotEmpty) {
      int userId = users.first['id'];
      String userName = users.first['name'];
      print("✅ User found! User ID: $userId, Name: $userName");

      await updateUserLoginStatus(userId, 1);

      List<Map<String, dynamic>> submittedForms = await db.query(
        'form_data',
        where: 'user_id = ? AND status = ?',
        whereArgs: [userId, 'final'],
      );

      bool hasSubmitted = submittedForms.isNotEmpty;
      print("📌 Form submission status: $hasSubmitted");


      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);
      await prefs.setString('user_Name', userName);
      await prefs.setBool('has_Submitted_Form', hasSubmitted);
      await prefs.setInt('login_time', DateTime
          .now()
          .millisecondsSinceEpoch);

      print(
          "📌 Stored User ID in SharedPreferences: ${prefs.getInt('user_id')}");
      print(
          "✅ Login successful! User ID: $userId, Form Submitted: $hasSubmitted");

      return userId;
    } else {
      print("❌ Login failed: No matching user found.");
      return null;
    }
  }

  //USER LOGIN STATUS
  Future<void> updateUserLoginStatus(int userId, int status) async {
    final db = await database;

    int count = await db.update(
      'users',
      {'is_logged_in': status},
      where: 'id = ?',
      whereArgs: [userId],
    );
    print("Updated is_logged_in rows: $count");
  }


  // FETCH THE LOGGED-IN USER
  Future<int?> getLoggedInUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      print("✅ Retrieved user ID from SharedPreferences: $userId");
      return userId;
    } else {
      print("❌ No logged-in user found in SharedPreferences");
      return null;
    }
  }


  //INSERT FORM DATA
  Future<int> insertForm(Map<String, dynamic> formData) async {
    final db = await database;

    int? userId = await getLoggedInUserId();
    if (userId == null) {
      print("User ID is null! Cannot save form data.");
      return 0;
    }


    List<Map<String, dynamic>> existingSubmissions = await db.query(
      'form_data',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'final'],
    );

    if (existingSubmissions.isNotEmpty) {
      print("❌ Submission already exists for User ID: $userId");
      return 0; // Prevent duplicate submissions
    }


    formData['user_id'] = userId;
    print("✅ Inserting form data for user ID: $userId");

    return await db.insert(
      'form_data',
      formData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //SAVE DRAFT
  Future<int> saveDraft(Map<String, dynamic> formData, int userId) async {
    try {
      final db = await database;
      if (userId == null) {
        print("❌ ERROR: User ID is NULL. Cannot save draft.");
        return 0;
      }
      formData['user_id'] = userId;
      formData['status'] = 'incomplete';

      print("📝 Checking for existing drafts...");
      List<Map<String, dynamic>> existingDraft = await db.query(
        'form_data',
        where: 'user_id = ? AND status = ?',
        whereArgs: [userId, 'draft'],
      );
      print("🔍 Existing draft: $existingDraft");

      if (existingDraft.isNotEmpty) {
        int updatedCount = await db.update(
          'form_data',
          formData,
          where: 'user_id = ? AND status = ?',
          whereArgs: [userId, 'draft'],
        );
        print("✅ Draft updated for User ID: $userId");
        return updatedCount;
      } else {
        int insertedId = await db.insert('form_data', formData);
        print("✅ Draft saved for User ID: $userId");
        return insertedId;
      }
    } catch (e) {
      print("❌ ERROR saving draft: $e");
      return 0;
    }
  }

  // FETCH ALL DRAFTS
  Future<List<Map<String, dynamic>>> getDraft(int userId) async {
    try {
      final db = await database;
      print("📌 Fetching Drafts for User ID: $userId");
      return await db.query(
        'form_data',
        where: 'user_id = ? AND status = ?',
        whereArgs: [userId, 'draft'],
      );
    } catch (e) {
      print("❌ ERROR fetching drafts: $e");
      return [];
    }
  }

  // DELETE DRAFT
  Future<int> deleteDraft(int userId) async {
    try {
      final db = await database;
      print("📌 Checking existing draft for deletion...");
      List<Map<String, dynamic>> existingDraft = await db.query(
        'form_data',
        where: 'user_id = ? AND status = ?',
        whereArgs: [userId, 'draft'],
      );

      if (existingDraft.isNotEmpty) {
        int result = await db.delete(
          'form_data',
          where: 'user_id = ? AND status = ?',
          whereArgs: [userId, 'draft'],
        );
        print("📌 Deleted Draft for User ID: $userId, Result: $result");
        return result;
      } else {
        print("❌ No draft found for User ID: $userId, nothing to delete.");
        return 0;
      }
    } catch (e) {
      print("❌ ERROR deleting draft: $e");
      return 0;
    }
  }

  //SAVE FINAL DATA
  Future<int> saveData(Map<String, dynamic> formData) async {
    final db = await database;
    int? userId = await getLoggedInUserId();
    if (userId == null) {
      print("❌ No user ID found, cannot save form data.");
      return 0;
    }
    formData['user_id'] = userId; // Ensure user_id is assigned
    return await db.insert('form_data', formData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }


  //CHECK DATA IN DB
  Future<void> checkDataInDB() async {
    final db = await DatabaseHelper().database;
    List<Map<String, dynamic>> records = await db.query('form_data');
    List<Map<String, dynamic>> registrations = await db.query('registrations');

    print("📌 Database Records: $records");
    print("📌 Registrations in DB: $registrations");
  }


  //INSERT REG DATA
  Future<int> insertRegistration(Map<String, dynamic> registrations) async {
    final db = await DatabaseHelper().database;
    return await db.insert('registrations', registrations,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //FETCH ALL REG
  Future<List<Map<String, dynamic>>> getRegistrations(int userId) async {
    final db = await database;

    // Check if the user has completed form submission
    final List<Map<String, dynamic>> formData = await db.query(
      "form_data",
      where: "user_id = ? AND status = ?",
      whereArgs: [userId, 'final'],
    );


    if (formData.isNotEmpty) {
      // User has submitted form, check if registration already exists
      final List<Map<String, dynamic>> existingReg = await db.query(
        "registrations",
        where: "user_id = ?",
        whereArgs: [userId],
      );

      if (existingReg.isEmpty) {
        // If no registration exists, create one
        String regNo = generateCustomRegNo(userId);
        String submissionDate = formatSubmissionDate(DateTime.now());

        await db.insert("registrations", {
          "user_id": userId,
          "regNo": regNo,
          "submissionDate": submissionDate,
          "status": "Submitted",
          "schemeName": "Registration Form for Chief Minister's Atmanirbhar Asom Abhijan 2.0"
        });

        print("✅ Registration Created: $regNo");
      }
    }


    final List<Map<String, dynamic>> registrations = await db.query(
      "registrations",
      where: "user_id = ?",
      whereArgs: [userId],
    );

    return registrations;
  }

  String generateCustomRegNo(int userId) {
    DateTime now = DateTime.now();
    String year = now.year.toString();
    String dayMonth = "${now.day.toString().padLeft(2, '0')}${now.month
        .toString().padLeft(2, '0')}";

    Random random = Random();
    int uniqueNumber = random.nextInt(9000000) + 1000000;

    return "CMAAA/$year/$dayMonth$uniqueNumber/$userId";
  }

  String formatSubmissionDate(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
  }

  //UPDATE REG STATUS
  Future<int> updateRegistrationStatus(String regNo, String newStatus) async {
    final db = await database;
    return await db.update(
      'registrations',
      {'status': newStatus},
      where: 'regNo = ?',
      whereArgs: [regNo],
    );
  }

  //DELETE REG STATUS
  Future<int> deleteRegistration(String regNo) async {
    final db = await database;
    return await db.delete(
      'registrations',
      where: 'regNo = ?',
      whereArgs: [regNo],
    );
  }

  //GET USER INFO
  Future<Map<String, dynamic>?> getUserInfo() async {
    final db = await database;
    int? userId = await getLoggedInUserId();

    if (userId == null) return null;

    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['id', 'name', 'contact','is_form_submitted'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      print("Fetched User Data: ${result.first}");
      return result.first;
    } else {
      print("No user found with ID: $userId");
      return null;
    }
  }

  // UPDATE PASSWORD
  Future<bool> updatePassword(String contact, String newPassword) async {
    final db = await database;
    String hashedPassword = hashPassword(newPassword);
    int result = await db.update(
      "users",
      {"password": hashedPassword},
      where: "contact = ?",
      whereArgs: [contact],
    );
    return result > 0;
  }

  Future<int> updateUserFormSubmissionStatus(int userId) async {
    final db = await database;
    int updatedRows = await db.update(
      'users',
      {'is_form_submitted': 1},
      where: 'id = ?',
      whereArgs: [userId],
    );
    debugPrint(
        "✅ Updated is_form_submitted for user $userId. Rows affected: $updatedRows");
    return updatedRows;
  }

  Future<void> debugPrintUsers() async {
    final db = await database;
    List<Map<String, dynamic>> users = await db.query('users');
    debugPrint("📌 Current Users Table Data: $users");
  }

  Future<Map<String, dynamic>?> getFormDataByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'form_data',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      debugPrint("✅ Retrieved Form Data: ${result.first}");
      return result.first;
    }
    return null;
  }

  Future<int> insertApplicationForm(Map<String, dynamic> formData) async {
    final db = await database;

    int? userId = await getLoggedInUserId();
    if (userId == null) {
      print("🚫 User ID is null! Cannot insert application form.");
      return 0;
    }

    formData['user_id'] = userId;
    formData['form_type'] = 'application';

    final String status = formData['status'] ?? 'incomplete';

    try {
      if (status == 'completed') {
        // Prevent multiple final submissions
        List<Map<String, dynamic>> existingFinals = await db.query(
          'application_data',
          where: 'user_id = ? AND status = ? AND form_type = ?',
          whereArgs: [userId, 'completed', 'application'],
        );

        if (existingFinals.isNotEmpty) {
          print("❌ Final submission already exists for User ID: $userId");
          return 0;
        }

        // Insert new final
        int result = await db.insert(
          'application_data',
          formData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print("✅ Application form submitted for User ID: $userId");
        return result;
      } else {
        // Check if a draft already exists for the user
        List<Map<String, dynamic>> existingDrafts = await db.query(
          'application_data',
          where: 'user_id = ? AND status = ? AND form_type = ?',
          whereArgs: [userId, 'incomplete', 'application'],
        );

        if (existingDrafts.isNotEmpty) {
          // Update existing draft
          int result = await db.update(
            'application_data',
            formData,
            where: 'user_id = ? AND status = ? AND form_type = ?',
            whereArgs: [userId, 'incomplete', 'application'],
          );
          print("🔄 Draft updated for User ID: $userId");
          return result;
        } else {
          // Insert new draft
          int result = await db.insert(
            'application_data',
            formData,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          print("✅ Draft saved for User ID: $userId");
          return result;
        }
      }
    } catch (e) {
      print("❌ Error inserting/updating application form: $e");
      return 0;
    }
  }


  Future<int> saveApplicationDraft(Map<String, dynamic> formData,
      int userId) async {
    try {
      final db = await database;
      if (userId == null) {
        print("❌ ERROR: User ID is NULL. Cannot save draft.");
        return 0;
      }

      formData['user_id'] = userId;
      formData['status'] = 'incomplete';
      formData['form_type'] = 'application';

      print("📝 Checking for existing draft...");
      final existingDraft = await db.query(
        'application_data',
        where: 'user_id = ? AND status = ? AND form_type = ?',
        whereArgs: [userId, 'incomplete', 'application'],
      );

      if (existingDraft.isNotEmpty) {
        final updatedCount = await db.update(
          'application_data',
          formData,
          where: 'user_id = ? AND status = ? AND form_type = ?',
          whereArgs: [userId, 'incomplete', 'application'],
        );
        print("✅ Draft updated for User ID: $userId");
        return updatedCount;
      } else {
        final insertedId = await db.insert('application_data', formData);
        print("✅ Draft saved for User ID: $userId");
        return insertedId;
      }
    } catch (e) {
      print("❌ ERROR saving draft: $e");
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getApplicationDraft(int userId) async {
    try {
      final db = await database;
      print("📌 Fetching application draft for User ID: $userId");
      return await db.query(
        'application_data',
        where: 'user_id = ? AND status = ? AND form_type = ?',
        whereArgs: [userId, 'incomplete', 'application'],
      );
    } catch (e) {
      print("❌ ERROR fetching draft: $e");
      return [];
    }
  }

  Future<int> deleteApplicationDraft(int userId) async {
    try {
      final db = await database;
      print("🗑️ Checking for draft to delete...");

      final draft = await db.query(
        'application_data',
        where: 'user_id = ? AND status = ? AND form_type = ?',
        whereArgs: [userId, 'incomplete', 'application'],
      );

      if (draft.isNotEmpty) {
        final deletedCount = await db.delete(
          'application_data',
          where: 'user_id = ? AND status = ? AND form_type = ?',
          whereArgs: [userId, 'incomplete', 'application'],
        );
        print("✅ Deleted draft for User ID: $userId");
        return deletedCount;
      } else {
        print("⚠️ No draft found for deletion.");
        return 0;
      }
    } catch (e) {
      print("❌ ERROR deleting draft: $e");
      return 0;
    }
  }


  Future<int> insertFinalApplicationForm(Map<String, dynamic> formData) async {
    final db = await database;

    int userId = formData['user_id'];

    // Check if a final submission already exists
    final existing = await db.query(
      'application_data',
      where: 'user_id = ? AND status = ? AND form_type = ?',
      whereArgs: [userId, 'completed', 'application'],
    );

    if (existing.isNotEmpty) {
      return -1; // Indicates already submitted
    }

    return await db.insert(
      'application_data',
      formData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> saveFinalApplication(Map<String, dynamic> formData) async {
    try {
      final db = await database;
      int? userId = await getLoggedInUserId();

      if (userId == null) {
        print("❌ ERROR: No logged-in user. Cannot save final application.");
        return 0;
      }

      formData['user_id'] = userId;
      formData['status'] = 'completed';
      formData['form_type'] = 'application';

      // Check for existing final submission
      final existingFinal = await db.query(
        'application_data',
        where: 'user_id = ? AND status = ? AND form_type = ?',
        whereArgs: [userId, 'completed', 'application'],
      );

      if (existingFinal.isNotEmpty) {
        print("⚠️ Final application already exists for User ID: $userId");
        return 0;
      }

      // Save final data
      final result = await db.insert('application_data', formData);
      print("✅ Final application submitted for User ID: $userId");

      // Optionally delete draft after final submission
      await deleteApplicationDraft(userId);

      return result;
    } catch (e) {
      print("❌ ERROR saving final application: $e");
      return 0;
    }
  }

  //INSERT APPLICATION DATA
  Future<int> insertApplication(Map<String, dynamic> application) async {
    final db = await DatabaseHelper().database;
    return await db.insert('applications', application,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //FETCH ALL APPLICATIONS
  Future<List<Map<String, dynamic>>> getApplications(int userId) async {
    final db = await database;

    // Check if user has submitted final application form
    final List<Map<String, dynamic>> formData = await db.query(
      "application_data",
      where: "user_id = ? AND status = ?",
      whereArgs: [userId, 'completed'],
    );

    if (formData.isNotEmpty) {
      // Check if application already exists
      final List<Map<String, dynamic>> existingApp = await db.query(
        "applications",
        where: "user_id = ?",
        whereArgs: [userId],
      );

      if (existingApp.isEmpty) {
        String appRefNo = generateCustomAppRefNo(userId);
        String submissionDate = formatSubmissionDate(DateTime.now());

        await db.insert("applications", {
          "user_id": userId,
          "appRefNo": appRefNo,
          "submissionDate": submissionDate,
          "status": "Submitted",
          "schemeName": "Application Form for Chief Minister's Atmanirbhar Asom Abhijan 2.0"
        });

        print("✅ Application Created: $appRefNo");
      }
    }

    final List<Map<String, dynamic>> applications = await db.query(
      "applications",
      where: "user_id = ?",
      whereArgs: [userId],
    );

    return applications;
  }

  String generateCustomAppRefNo(int userId) {
    DateTime now = DateTime.now();
    String year = now.year.toString();
    String dayMonth = "${now.day.toString().padLeft(2, '0')}${now.month
        .toString().padLeft(2, '0')}";

    Random random = Random();
    int uniqueNumber = random.nextInt(9000000) + 1000000;

    return "CMAAA/APP/$year/$dayMonth$uniqueNumber/$userId";
  }

//UPDATE APPLICATION STATUS
  Future<int> updateApplicationStatus(String appRefNo, String newStatus) async {
    final db = await database;
    return await db.update(
      'applications',
      {'status': newStatus},
      where: 'appRefNo = ?',
      whereArgs: [appRefNo],
    );
  }

  //DELETE APPLICATION
  Future<int> deleteApplication(String appRefNo) async {
    final db = await database;
    return await db.delete(
      'applications',
      where: 'appRefNo = ?',
      whereArgs: [appRefNo],
    );
  }

  String formatAppSubmissionDate(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
  }

  Future<Map<String, dynamic>> getCombinedUserData(int userId) async {
    final db = await database;

    final List<Map<String, dynamic>> registration = await db.query(
      'form_data',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final List<Map<String, dynamic>> application = await db.query(
      'application_data',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Combine both maps into one
    Map<String, dynamic> combined = {};

    if (registration.isNotEmpty) {
      combined.addAll(registration.first);
    }

    if (application.isNotEmpty) {
      combined.addAll(application.first);
    }

    return combined;
  }


  Future<bool> isFormSubmitted(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['is_form_submitted'],
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return (result.first['is_form_submitted'] ?? 0) == 1;
    }
    return false;
  }


  Future<List<Map<String, dynamic>>> getUserByMobile(String mobile) async {
    final db = await database;

    return await db.rawQuery('''
    SELECT users.id, users.password, users.is_form_submitted, form_data.embedding
    FROM users
    LEFT JOIN form_data ON users.contact = form_data.mobile
    WHERE users.contact = ?
    LIMIT 1
  ''', [mobile]);
  }
}

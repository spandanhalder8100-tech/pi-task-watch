import 'package:flutter/foundation.dart';
import 'package:pi_task_watch/controllers/timesheet_controller.dart';
import 'package:pi_task_watch/exports.dart';
import 'package:pi_task_watch/models/timesheet_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  // Shared preferences keys
  static const String _keyEmail = 'user_email';
  static const String _keyPassword = 'user_password';
  static const String _keyDb = 'user_db';
  static const String _keyIsLoggedIn = 'is_logged_in';

  /// Safely converts any value to boolean
  /// Handles: bool, int (1=true, 0=false), string ('true', '1', 'yes'=true)
  static bool _safeBoolConversion(dynamic value) {
    if (value == null) return false;

    if (value is bool) {
      return value;
    } else if (value is int) {
      return value == 1;
    } else if (value is String) {
      final lowerCase = value.toLowerCase().trim();
      return lowerCase == 'true' || lowerCase == '1' || lowerCase == 'yes';
    } else {
      // For any other type, convert to string and check
      final stringValue = value.toString().toLowerCase().trim();
      return stringValue == 'true' || stringValue == '1';
    }
  }

  //
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  Rx<UserModel?> get user => _user;
  final RxBool _authLoading = false.obs;
  RxBool get authLoading => _authLoading;

  // Add specific loading states for post-login operations
  final RxBool _settingsLoading = false.obs;
  RxBool get settingsLoading => _settingsLoading;
  final RxBool _timesheetLoading = false.obs;
  RxBool get timesheetLoading => _timesheetLoading;

  // settings rx
  final Rx<SettingsModel?> _settings = Rx<SettingsModel?>(null);
  Rx<SettingsModel?> get settings => _settings;

  /// Simple auto-login method - checks for saved credentials and logs in if found
  Future<bool> attemptAutoLogin() async {
    try {
      // Don't auto-login if user is already logged in
      if (_user.value != null) {
        if (kDebugMode) print("✅ User already logged in");
        return true;
      }

      // Don't auto-login if already in progress
      if (_authLoading.value) {
        if (kDebugMode) print("⏳ Login already in progress");
        return false;
      }

      if (kDebugMode) print("� Checking for saved credentials...");

      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

      if (!isLoggedIn) {
        if (kDebugMode) print("❌ No saved login flag found");
        return false;
      }

      final email = prefs.getString(_keyEmail) ?? '';
      final password = prefs.getString(_keyPassword) ?? '';
      final db = prefs.getString(_keyDb) ?? '';

      if (email.isEmpty || password.isEmpty || db.isEmpty) {
        if (kDebugMode) print("❌ Incomplete saved credentials");
        return false;
      }

      if (kDebugMode) {
        print("✅ Found complete credentials:");
        print("   Email: $email");
        print("   Database: $db");
        print("   Starting auto-login...");
      }

      // Perform the login
      final user = await signIn(
        db: db,
        email: email,
        password: password,
        rememberMe: true,
      );

      return user != null;
    } catch (e) {
      if (kDebugMode) print("❌ Auto-login error: $e");
      return false;
    }
  }

  // Save user credentials
  Future<void> saveUserCredentials({
    required String email,
    required String password,
    required String db,
    required bool rememberMe,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (rememberMe) {
        await prefs.setString(_keyEmail, email);
        await prefs.setString(_keyPassword, password);
        await prefs.setString(_keyDb, db);
        await prefs.setBool(_keyIsLoggedIn, true);
        if (kDebugMode) {
          print("✅ Credentials saved successfully: email=$email, db=$db");
        }
      } else {
        await clearSavedCredentials();
        if (kDebugMode) print("🗑️ Credentials cleared (rememberMe=false)");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error saving credentials: $e");
    }
  }

  // Clear saved credentials
  Future<void> clearSavedCredentials() async {
    try {
      Get.find<TrackerController>().setUser(user: null);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyPassword);
      await prefs.remove(_keyDb);
      await prefs.setBool(_keyIsLoggedIn, false);
      if (kDebugMode) print("🗑️ All saved credentials cleared");
    } catch (e) {
      if (kDebugMode) print("Error clearing credentials: $e");
    }
  }

  /// Debug method to check what's currently saved
  Future<void> debugSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      final email = prefs.getString(_keyEmail) ?? '';
      final password = prefs.getString(_keyPassword) ?? '';
      final db = prefs.getString(_keyDb) ?? '';

      if (kDebugMode) {
        print("🔍 DEBUG - Current saved credentials:");
        print("   isLoggedIn: $isLoggedIn");
        print("   email: ${email.isNotEmpty ? email : 'EMPTY'}");
        print("   password: ${password.isNotEmpty ? '***SET***' : 'EMPTY'}");
        print("   database: ${db.isNotEmpty ? db : 'EMPTY'}");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error checking saved credentials: $e");
    }
  }

  //
  Future<List<String>> getAllDb() async {
    try {
      // Get the base server URL entered by user
      final baseUrl = AppConstant.apiServerUrl;

      if (baseUrl.isEmpty) {
        print("❌ No server URL configured. Please enter a server URL first.");
        return [];
      }

      // Always print the database fetch URL (not just in debug mode)
      print(
        "╔════════════════════════════════════════════════════════════════",
      );
      print("║ 📡 FETCHING DATABASE LIST");
      print("║ Server URL: $baseUrl");
      print("║ Using OdooRpcApiManager.getDbList()");
      print(
        "╚════════════════════════════════════════════════════════════════",
      );

      // Use the proper Odoo RPC method to get database list
      final dbListResponse = await OdooRpcApiManager.getDbList(
        serverUrl: baseUrl,
      );

      print("📥 Database API Response received");
      print("   Raw data: ${dbListResponse.rawData}");

      // Check if the request was successful
      if (dbListResponse.isError) {
        print("❌ Error fetching databases: ${dbListResponse.message}");
        return [];
      }

      // Extract the database list
      // rawData is a Map like: {result: [primacy], success: true, message: ...}
      if (dbListResponse.rawData != null) {
        dynamic dbList;

        // Check if rawData is a Map with a 'result' field
        if (dbListResponse.rawData is Map) {
          final dataMap = dbListResponse.rawData as Map;
          dbList = dataMap['result'];
        } else if (dbListResponse.rawData is List) {
          // If it's already a List, use it directly
          dbList = dbListResponse.rawData;
        }

        // Now check if we have a valid list
        if (dbList != null && dbList is List) {
          final result = dbList.map((e) => e.toString()).toList();
          print("✅ Successfully fetched ${result.length} database(s): $result");
          return result;
        }
      }

      print("⚠️ No database list found in response");
      print("   Response data: ${dbListResponse.rawData}");
      return [];
    } catch (e) {
      print("❌ Error fetching databases: $e");
      print("   Stack trace: ${StackTrace.current}");
      return [];
    }
  }

  //
  //
  Future<UserModel?> signIn({
    required String db,
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // Check if user is already logged in
      if (_user.value != null) {
        if (kDebugMode) print("✅ User already logged in");
        return _user.value;
      }

      if (kDebugMode) {
        print("\n════════════════════════════════════════════════════════");
        print("🔐 LOGIN REQUEST DETAILS");
        print("════════════════════════════════════════════════════════");
        print("📍 API Server URL: ${AppConstant.apiServerUrl}");
        print("📍 API Base URL: ${AppConstant.apiBaseUrl}");
        print("📍 Login Endpoint: ${AppConstant.apiBaseUrl}/login");
        print("────────────────────────────────────────────────────────");
        print("📊 Login Data:");
        print("   • Database: $db");
        print("   • Email/Username: $email");
        print("   • Password: ${"*" * password.length}");
        print("   • Remember Me: $rememberMe");
        print("════════════════════════════════════════════════════════\n");
      }

      _authLoading.value = true;
      // Get all databases for verification
      await getAllDb();

      // Configure and authenticate with OdooRpcApiManager
      OdooRpcApiManager.configure(
        authMode: OdooAuthMode.session,
        serverUrl: AppConstant.apiServerUrl,
        database: db,
        username: email,
        password: password,
      );

      final dList = await OdooRpcApiManager.getDbList(
        serverUrl: AppConstant.apiServerUrl,
      );
      print("Database list: ${dList.rawData}");

      final odooUser = await OdooRpcApiManager.authenticate(
        showLog: kDebugMode,
      );

      print("base url : ${AppConstant.apiServerUrl}");
      print("db : $db");
      print("email : $email");
      print("password : $password");

      print("d result : ${odooUser.isOdooRpc} ${odooUser.rawData}");

      if (odooUser.isError) {
        showToast(
          "Invalid credentials or database not found",
          idSuccess: false,
        );
        return null;
      }

      final apiResponse = await ApiManager.postRequest(
        endPoint: "login",
        data: {"db": db, "login": email, "password": password},
      );

      if (kDebugMode) {
        print("────────────────────────────────────────────────────────");
        print("📥 LOGIN API RESPONSE");
        print("────────────────────────────────────────────────────────");
        print("   • Status Code: ${apiResponse.statusCode}");
        print("   • Response Body: ${apiResponse.rawResponse.body}");
        print("   • Parsed Body: ${apiResponse.body}");
        print("────────────────────────────────────────────────────────\n");
      }

      // Extract session ID from cookies with proper error handling
      String nSessionId = '';

      // Get all headers and look for set-cookie
      final headers = apiResponse.rawResponse.headers;

      // Check for set-cookie header (case-insensitive)
      String? cookieValue;
      for (final entry in headers.entries) {
        if (entry.key.toLowerCase() == 'set-cookie') {
          cookieValue = entry.value;
          break;
        }
      }

      if (cookieValue != null && cookieValue.isNotEmpty) {
        // Split by comma to handle multiple cookies in one header
        final cookies = cookieValue.split(',');

        for (String cookie in cookies) {
          final trimmedCookie = cookie.trim();
          if (trimmedCookie.startsWith('session_id=')) {
            final parts = trimmedCookie.split('=');
            if (parts.length >= 2) {
              // Extract value and remove any trailing attributes (like path, domain, etc.)
              nSessionId = parts.sublist(1).join('=').split(';')[0].trim();
              break;
            }
          }
        }
      }

      if (nSessionId.isNotEmpty) {
        OdooRpcApiManager.setSessionId(nSessionId);
        if (kDebugMode) print("Session ID extracted successfully");
      } else {
        if (kDebugMode) print("Warning: No valid session_id found in cookies");
      }

      final result = apiResponse.body['result'];

      // Safely convert success to boolean using helper function
      final bool isSuccess = _safeBoolConversion(result['success']);

      if (kDebugMode) {
        print(
          "Success value: ${result['success']} (${result['success'].runtimeType}) → converted to: $isSuccess",
        );
      }

      // Show toast message based on success/failure
      showToast(result['message'], idSuccess: isSuccess);

      // If login successful
      if (isSuccess) {
        final user = UserModel.fromJson(result);
        _user.value = user;

        if (kDebugMode) print("🔧 Loading user settings...");
        _settingsLoading.value = true;

        // Get settings after successful login
        final settings = await getSettingData();
        _settingsLoading.value = false;

        SettingsModel finalSettings;
        if (settings == null) {
          if (kDebugMode) {
            print("⚠️ Settings API failed, using default settings");
          }
          finalSettings = SettingsModel.createDefault();
          showToast(
            "Login successful. Using default settings.",
            idSuccess: true,
          );
        } else {
          finalSettings = settings;
          if (kDebugMode) {
            print(
              "✅ Settings loaded: idle=${finalSettings.idleThreshold.inMinutes}min, "
              "session=${finalSettings.calculationDuration.inMinutes}min, "
              "screenshots=${finalSettings.perSessionScreenshot}",
            );

            // Check if settings are using fallback values due to API returning zeros
            if (finalSettings.isUsingFallbackValues) {
              print(
                "⚠️ Warning: Using fallback values - API may have returned zeros",
              );
            }
          }
        }

        if (kDebugMode) print("📋 Loading user timesheets...");
        _timesheetLoading.value = true;

        final timesheets = await Get.find<TimesheetController>()
            .getAllTimesheet(date: DateTime.now());

        _timesheetLoading.value = false;

        Get.find<TrackerController>().onFullyReady(
          settings: finalSettings,
          user: user,
          workedDuration: TimesheetModel.calculateTotalDuration(
            timesheetList: timesheets,
          ),
        );

        // Save credentials if login is successful - regardless of rememberMe
        // We'll use rememberMe parameter to determine saving behavior
        await saveUserCredentials(
          email: email,
          password: password,
          db: db,
          rememberMe: rememberMe,
        );

        if (kDebugMode) print("✅ Authentication flow completed successfully");
        return user;
      }

      return null;
    } catch (e) {
      if (kDebugMode) print("Error during sign in: $e");
      showToast("Sign in failed. Please try again.", idSuccess: false);

      // _user.value = null;

      return null;
    } finally {
      _authLoading.value = false;
      _settingsLoading.value = false;
      _timesheetLoading.value = false;
    }
  }

  // Logout method to clear credentials
  Future<void> logout() async {
    try {
      _user.value = null;
      await clearSavedCredentials();
      // Add any additional logout logic here
    } catch (e) {
      if (kDebugMode) print("Error during logout: $e");
    }
  }

  Future<SettingsModel?> getSettingData() async {
    try {
      if (kDebugMode) print("🔧 Fetching settings from API...");

      final apiResponse = await ApiManager.getRequest(endPoint: "settings");

      if (!apiResponse.isSuccess) {
        if (kDebugMode) {
          print("❌ Settings API returned error: ${apiResponse.message}");
        }
        return null;
      }

      if (apiResponse.data == null) {
        if (kDebugMode) print("❌ Settings API returned null data");
        return null;
      }

      // Log the raw API response for debugging
      if (kDebugMode) {
        print("📋 Raw settings data: ${apiResponse.data}");
      }

      final result = SettingsModel.fromJson(apiResponse.data);
      _settings.value = result;

      if (kDebugMode) {
        print("✅ Settings processed successfully:");
        print("   - Idle threshold: ${result.idleThreshold.inMinutes} minutes");
        print(
          "   - Session duration: ${result.calculationDuration.inMinutes} minutes",
        );
        print("   - Screenshots per session: ${result.perSessionScreenshot}");
        print("   - Offline time: ${result.offlineTime} minutes");
        print("   - Timezone: ${result.timezone}");
        print("   - Maintenance mode: ${result.maintenance}");
      }

      return result;
    } catch (e) {
      if (kDebugMode) print("❌ Error fetching settings data: $e");
      return null;
    }
  }
}

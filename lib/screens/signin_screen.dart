import 'package:flutter/foundation.dart';

import '../exports.dart';

class SigninScreen extends StatefulWidget {
  static const String routeName = '/signin';
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _databaseSearchController = TextEditingController();
  String? _selectedDatabase;
  bool _isPasswordVisible = false;
  bool _rememberMe = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Auth controller
  final AuthController _authController = Get.find<AuthController>();

  // Database list
  final RxList<String> _databases = RxList<String>([]);
  final RxBool _loadingDatabases = RxBool(false);

  @override
  void initState() {
    super.initState();

    // Initialize server URL - show current active URL (user-given or default)
    _serverUrlController.text = AppConstant.apiServerUrl;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Fetch databases with current server URL
    if (_isValidUrl(AppConstant.apiServerUrl)) {
      _fetchDatabases();
    }

    // Fix: Schedule auto-login with a microtask to avoid build phase conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (kDebugMode) {
        print("🔐 SigninScreen: Starting auto-login check...");
        // Debug what's currently saved
        await _authController.debugSavedCredentials();
      }

      try {
        final success = await _authController.attemptAutoLogin();
        if (kDebugMode) {
          print(success ? "✅ Auto-login successful" : "❌ Auto-login failed");
        }
      } catch (e) {
        if (kDebugMode) print("⚠️ Auto-login error: $e");
      }
    });
  }

  Future<void> _fetchDatabases() async {
    _loadingDatabases.value = true;
    try {
      final databases = await _authController.getAllDb();
      _databases.value = databases;

      if (kDebugMode) {
        print(
          "✅ Fetched ${databases.length} databases from ${AppConstant.apiServerUrl}",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Failed to fetch databases: $e");
      }
      _databases.value = [];
      showToast(
        "Failed to fetch databases. Please check your server URL.",
        idSuccess: false,
      );
    } finally {
      _loadingDatabases.value = false;
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _databaseSearchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Helper method to validate URL format
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Helper method to update server URL
  void _updateServerUrl() {
    final trimmedUrl = _serverUrlController.text.trim();

    if (trimmedUrl.isEmpty) {
      showToast("Please enter a server URL", idSuccess: false);
      return;
    }

    if (!_isValidUrl(trimmedUrl)) {
      showToast(
        "Please enter a valid URL (must start with http:// or https://)",
        idSuccess: false,
      );
      return;
    }

    // Update the server URL
    AppConstant.userGivenApiServerUrl = trimmedUrl;

    print("🔗 API Server URL updated: ${AppConstant.apiServerUrl}");
    print("🔗 API Base URL updated: ${AppConstant.apiBaseUrl}");

    // Fetch databases with new URL
    _fetchDatabases();

    // Reset selected database since URL changed
    setState(() {
      _selectedDatabase = null;
    });

    showToast("API Server URL updated successfully", idSuccess: true);
  }

  // Helper method to trim text
  String _trimText(String text) {
    return text.trim();
  }

  void _handleSignIn() async {
    // Prevent multiple simultaneous sign-in attempts
    if (_authController.authLoading.value ||
        _authController.settingsLoading.value ||
        _authController.timesheetLoading.value) {
      if (kDebugMode) print("⚠️ Sign-in already in progress, ignoring request");
      return;
    }

    // Trim text fields before validation
    _emailController.text = _trimText(_emailController.text);
    _passwordController.text = _trimText(_passwordController.text);

    if (_formKey.currentState!.validate() && _selectedDatabase != null) {
      // Get auth login values with trimming
      final email = _emailController.text; // Already trimmed
      final password = _passwordController.text; // Already trimmed
      final db = _selectedDatabase!;

      // Attempt sign in
      final signInResult = await _authController.signIn(
        db: db,
        email: email,
        password: password,
        rememberMe:
            _rememberMe, // Pass the remember me flag to save credentials
      );

      if (kDebugMode && signInResult != null) {
        print("📝 Credentials saved: ${_rememberMe ? 'Yes' : 'No'}");
      }
    } else if (_selectedDatabase == null) {
      //
      showToast("Please select a database", idSuccess: false);
    }
  }

  // Debug sign in with dummy credentials
  void _handleDebugSignIn() async {
    // Prevent multiple simultaneous sign-in attempts
    if (_authController.authLoading.value ||
        _authController.settingsLoading.value ||
        _authController.timesheetLoading.value) {
      if (kDebugMode) {
        print("⚠️ Debug sign-in already in progress, ignoring request");
      }
      return;
    }

    // Set dummy values

    _emailController.text = AppConstant.debugEmail;
    _passwordController.text = AppConstant.debugPassword;

    // Select first database if available
    if (_databases.isNotEmpty && _selectedDatabase == null) {
      setState(() {
        _selectedDatabase = _databases.first;
      });
    } else if (_selectedDatabase == null) {
      // Set a default if no database is available (use lowercase to match API)
      setState(() {
        _selectedDatabase = "primacy";
      });
    }

    // Call regular sign in handler after a short delay
    Future.delayed(Duration(milliseconds: 100), () {
      _handleSignIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink.shade50, Colors.pink.shade100],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LogoCaptionWidget(),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.08),
                                spreadRadius: 5,
                                blurRadius: 15,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Obx(
                            () => Column(
                              children: [
                                // Auto-login indicator - shows when auto-login is happening
                                if (_authController.authLoading.value ||
                                    _authController.settingsLoading.value ||
                                    _authController.timesheetLoading.value) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.primaryColor.withOpacity(
                                          0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  theme.primaryColor,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                () {
                                                  if (_authController
                                                      .authLoading
                                                      .value) {
                                                    return 'Auto-login in progress...';
                                                  } else if (_authController
                                                      .settingsLoading
                                                      .value) {
                                                    return 'Loading user settings...';
                                                  } else if (_authController
                                                      .timesheetLoading
                                                      .value) {
                                                    return 'Loading timesheet data...';
                                                  } else {
                                                    return 'Initializing...';
                                                  }
                                                }(),
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: theme.primaryColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Please wait while we sign you in automatically',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 11,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Wrap the entire form in IgnorePointer when auto-login is in progress
                                IgnorePointer(
                                  ignoring:
                                      _authController.authLoading.value ||
                                      _authController.settingsLoading.value ||
                                      _authController.timesheetLoading.value,
                                  child: Column(
                                    children: [
                                      // Server URL section - only show if user can change URL
                                      if (AppConstant.userCanChangeUrl) ...[
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: CompactTextField(
                                                controller:
                                                    _serverUrlController,
                                                hintText:
                                                    'e.g. https://demo.odoo.com',
                                                labelText: 'Server URL',
                                                prefixIcon: Icon(
                                                  Icons.web_asset_outlined,
                                                ),
                                                keyboardType: TextInputType.url,
                                                validator: (value) {
                                                  final trimmedValue =
                                                      _trimText(value ?? '');
                                                  if (trimmedValue.isEmpty) {
                                                    return 'Please enter your server URL';
                                                  }
                                                  if (!_isValidUrl(
                                                    trimmedValue,
                                                  )) {
                                                    return 'Please enter a valid URL (must start with http:// or https://)';
                                                  }
                                                  return null;
                                                },
                                                onChanged: (value) {
                                                  // Optional: Update the refresh icon color in real-time
                                                  // as the user types to provide visual feedback
                                                  if (mounted) {
                                                    setState(() {});
                                                  }
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: InkWell(
                                                onTap: _updateServerUrl,
                                                child: Icon(
                                                  Icons.refresh,
                                                  color: () {
                                                    final currentUrl =
                                                        _serverUrlController
                                                            .text
                                                            .trim();
                                                    final hasUserUrl =
                                                        AppConstant
                                                                .userGivenApiServerUrl !=
                                                            null &&
                                                        AppConstant
                                                            .userGivenApiServerUrl!
                                                            .isNotEmpty;
                                                    final isValidCurrentUrl =
                                                        currentUrl.isNotEmpty &&
                                                        _isValidUrl(currentUrl);
                                                    final urlChanged =
                                                        currentUrl !=
                                                        AppConstant
                                                            .apiServerUrl;

                                                    if (hasUserUrl &&
                                                        !urlChanged) {
                                                      return Colors
                                                          .green; // URL is set and current
                                                    } else if (isValidCurrentUrl &&
                                                        urlChanged) {
                                                      return Colors
                                                          .orange; // Valid URL entered but not applied
                                                    } else if (currentUrl
                                                            .isNotEmpty &&
                                                        !_isValidUrl(
                                                          currentUrl,
                                                        )) {
                                                      return Colors
                                                          .red; // Invalid URL entered
                                                    } else {
                                                      return Colors
                                                          .grey; // Default state
                                                    }
                                                  }(),
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      // Database selector
                                      SearchableDropdown<String>(
                                        value: _selectedDatabase,
                                        items:
                                            _loadingDatabases.value
                                                ? ["Loading databases..."]
                                                : _databases,
                                        hint: "Select Database",
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedDatabase = value;
                                          });
                                        },
                                        searchController:
                                            _databaseSearchController,
                                        itemToString: (item) => item,
                                      ),
                                      const SizedBox(height: 12),

                                      // Email/Username field with trimming
                                      CompactTextField(
                                        controller: _emailController,
                                        hintText: 'Enter email or username',
                                        labelText: 'Email or Username',
                                        prefixIcon: Icon(Icons.person_outline),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) {
                                          final trimmedValue = _trimText(
                                            value ?? '',
                                          );
                                          if (trimmedValue.isEmpty) {
                                            return 'Please enter your email or username';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 12),

                                      // Password field with trimming
                                      CompactTextField(
                                        controller: _passwordController,
                                        hintText: 'Enter password',
                                        labelText: 'Password',
                                        prefixIcon: Icon(Icons.lock_outline),
                                        obscureText: !_isPasswordVisible,
                                        suffixIcon: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          onTap:
                                              () => setState(
                                                () =>
                                                    _isPasswordVisible =
                                                        !_isPasswordVisible,
                                              ),
                                          child: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        validator: (value) {
                                          final trimmedValue = _trimText(
                                            value ?? '',
                                          );
                                          if (trimmedValue.isEmpty) {
                                            return 'Please enter your password';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 8),

                                      // Remember me checkbox
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 15,
                                            width: 15,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (value) {
                                                setState(() {
                                                  _rememberMe = value ?? false;
                                                });
                                              },
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Remember me',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                          const Spacer(),
                                          TextButton(
                                            onPressed: () {
                                              // Add forgot password functionality
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 2,
                                                    horizontal: 6,
                                                  ),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              'Forgot Password?',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 14),

                                      // Sign in button
                                      CompactButton(
                                        onPressed:
                                            _authController.authLoading.value ||
                                                    _authController
                                                        .settingsLoading
                                                        .value ||
                                                    _authController
                                                        .timesheetLoading
                                                        .value
                                                ? null
                                                : _handleSignIn,
                                        text: () {
                                          if (_authController
                                              .authLoading
                                              .value) {
                                            return 'SIGNING IN...';
                                          } else if (_authController
                                              .settingsLoading
                                              .value) {
                                            return 'LOADING SETTINGS...';
                                          } else if (_authController
                                              .timesheetLoading
                                              .value) {
                                            return 'LOADING TIMESHEETS...';
                                          } else {
                                            return 'SIGN IN';
                                          }
                                        }(),
                                        icon: () {
                                          if (_authController
                                                  .authLoading
                                                  .value ||
                                              _authController
                                                  .settingsLoading
                                                  .value ||
                                              _authController
                                                  .timesheetLoading
                                                  .value) {
                                            return Icons.hourglass_empty;
                                          } else {
                                            return Icons.login;
                                          }
                                        }(),
                                      ),

                                      // Debug sign in button (only visible in debug mode)
                                      if (kDebugMode) ...[
                                        const SizedBox(height: 8),
                                        CompactButton(
                                          onPressed:
                                              _authController
                                                          .authLoading
                                                          .value ||
                                                      _authController
                                                          .settingsLoading
                                                          .value ||
                                                      _authController
                                                          .timesheetLoading
                                                          .value
                                                  ? null
                                                  : _handleDebugSignIn,
                                          text: () {
                                            if (_authController
                                                .authLoading
                                                .value) {
                                              return 'SIGNING IN...';
                                            } else if (_authController
                                                .settingsLoading
                                                .value) {
                                              return 'LOADING SETTINGS...';
                                            } else if (_authController
                                                .timesheetLoading
                                                .value) {
                                              return 'LOADING TIMESHEETS...';
                                            } else {
                                              return 'DEBUG SIGN IN';
                                            }
                                          }(),
                                          icon: () {
                                            if (_authController
                                                    .authLoading
                                                    .value ||
                                                _authController
                                                    .settingsLoading
                                                    .value ||
                                                _authController
                                                    .timesheetLoading
                                                    .value) {
                                              return Icons.hourglass_empty;
                                            } else {
                                              return Icons.bug_report;
                                            }
                                          }(),
                                          backgroundColor:
                                              Colors.amber.shade700,
                                        ),
                                        const SizedBox(height: 4),
                                        CompactButton(
                                          onPressed: () async {
                                            await _authController
                                                .clearSavedCredentials();
                                            showToast(
                                              "Debug: Credentials cleared",
                                              idSuccess: true,
                                            );
                                            if (kDebugMode) {
                                              print(
                                                "🗑️ Debug: Credentials manually cleared",
                                              );
                                            }
                                          },
                                          text: 'CLEAR SAVED CREDENTIALS',
                                          icon: Icons.delete_forever,
                                          backgroundColor: Colors.red.shade600,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Sign up link
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: theme.textTheme.bodySmall,
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to sign up screen
                                showToast("Please contact you company");
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 6,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

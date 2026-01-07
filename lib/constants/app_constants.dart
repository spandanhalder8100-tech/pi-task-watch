class AppConstant {
  static const String appName = "PI TaskWatch";

  static const bool isDebug = false;

  static const String apiScheme = isDebug ? "http" : "http";
  //
  static const String apiHostName = isDebug ? "192.168.1.17" : "192.168.1.32";
  //
  static const int? apiPort = isDebug ? 8017 : 9070;
  //
  // Enable manual URL changes - user enters database URL
  static bool userCanChangeUrl = true;
  //
  static String? userGivenApiServerUrl;
  //
  static String get apiServerUrl {
    // If user has given a URL and it's not empty, use it
    if (userGivenApiServerUrl != null && userGivenApiServerUrl!.isNotEmpty) {
      return userGivenApiServerUrl!;
    }
    // Otherwise, fall back to the default URL from constants
    return apiPort != null
        ? "$apiScheme://$apiHostName:$apiPort"
        : "$apiScheme://$apiHostName";
  }

  //
  static String get apiBaseUrl => "$apiServerUrl/api";

  //
  // static const String debugDatabase = "";
  // static const String debugEmail = "arif@primacyinfotech.com";
  // static const String debugPassword = "2743";

  static const String debugEmail = "jayadrata@primacyinfotech.com";
  static const String debugPassword = "Pifad@2023";
  //
  //

  //
  // 192.168.1.21:8022
  // Window position constants
  // static const String positionTopLeft = 'top-left';
  // static const String positionTopRight = 'top-right';
  // static const String positionBottomLeft = 'bottom-left';
  // static const String positionBottomRight = 'bottom-right';
  //
  //
}
//
// 192.168.1.10 hello world //
// http://192.168.1.16:7017/
// http://192.168.1.22:8022/
// 192.168.1.14:8022
// http://192.168.1.29:7017/
//
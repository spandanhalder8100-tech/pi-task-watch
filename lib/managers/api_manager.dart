import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:pi_task_watch/utils/get_secure_http_dio_client.dart';

import '../exports.dart';

enum RequestType { get, post, put, delete, patch, head }

class ApiManager {
  static const bool showLogGlobal = true;
  static const bool showMessageGlobal = false;
  static const bool showLoaderGlobal = false;

  static String get baseUrl => AppConstant.apiBaseUrl;

  static Future<http.Client> get httpClient => getSecureHttpClient();

  static Uri buildUri({
    required String endpoint,
    bool isFullUrl = false,
    Map<String, dynamic>? queryParameters,
  }) {
    // Remove any leading slashes from endpoint to avoid double slashes
    final String cleanEndpoint =
        endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

    // Create full URL, ensuring no double slashes or "null" strings
    final String url = isFullUrl ? endpoint : "$baseUrl/$cleanEndpoint";

    // Validate URL doesn't contain "null" string
    if (url.contains("null")) {
      final logger = Logger();
      logger.e("URL contains 'null': $url");
      // Fix the URL by removing "null"
      final cleanUrl = url.replaceAll("null", "");
      logger.i("Cleaned URL: $cleanUrl");

      if (queryParameters != null && queryParameters.isNotEmpty) {
        // Convert all values to strings for the URI builder
        final Map<String, String> stringParams = {};
        queryParameters.forEach((key, value) {
          stringParams[key] = value.toString();
        });
        return Uri.parse(cleanUrl).replace(queryParameters: stringParams);
      }

      return Uri.parse(cleanUrl);
    }

    if (queryParameters != null && queryParameters.isNotEmpty) {
      // Convert all values to strings for the URI builder
      final Map<String, String> stringParams = {};
      queryParameters.forEach((key, value) {
        stringParams[key] = value.toString();
      });
      return Uri.parse(url).replace(queryParameters: stringParams);
    }

    return Uri.parse(url);
  }

  static Future<ApiResponse> request({
    required RequestType type,
    Map<String, dynamic>? data = const <String, dynamic>{},
    required String endPoint,
    bool isFullUrl = false,
    bool showLog = showLogGlobal,
    bool showMessage = showMessageGlobal,
    bool showLoader = showLoaderGlobal,
    Map<String, dynamic>? queryParameters,
  }) async {
    final logger = Logger();

    try {
      final DateTime startTime = DateTime.now();
      final String requestId = Uuid().v1();

      // Build URI with query parameters
      final uri = buildUri(
        endpoint: endPoint,
        isFullUrl: isFullUrl,
        queryParameters: queryParameters,
      );

      final String requestUrl = uri.toString();
      final jsonBody =
          data != null && data.isNotEmpty ? jsonEncode(data) : null;

      if (showLog) {
        Map<String, dynamic> logData = <String, dynamic>{
          "REQUEST ID": requestId,
          "DATE TIME": DateFormat().format(startTime),
          "METHOD": type.name,
          "URL": requestUrl,
          "HEADERS": headers(),
          "PARAMETERS": queryParameters ?? {},
          "BODY": jsonBody,
        };

        logger.e(logData);
      }

      late http.Response rawResponse;

      if (showLoader) {
        LoadingManager.startLoading();
      }

      final client = 1 == 1 ? await httpClient : http.Client();

      switch (type) {
        case RequestType.get:
          rawResponse = await client.get(uri, headers: headers());
          break;
        case RequestType.post:
          rawResponse = await client.post(
            uri,
            headers: headers(),
            body: jsonBody,
          );
          break;
        case RequestType.put:
          rawResponse = await client.put(
            uri,
            headers: headers(),
            body: jsonBody,
          );
          break;
        case RequestType.delete:
          rawResponse = await client.delete(
            uri,
            headers: headers(),
            body: jsonBody,
          );
          break;
        case RequestType.patch:
          rawResponse = await client.patch(
            uri,
            headers: headers(),
            body: jsonBody,
          );
          break;
        case RequestType.head:
          rawResponse = await client.head(uri, headers: headers());
          break;
      }

      if (showLoader) {
        LoadingManager.dismissLoading();
      }

      final DateTime endTime = DateTime.now();
      final Duration duration = endTime.difference(startTime);

      final apiResponse = ApiResponse(
        rawResponse: rawResponse,
        requestId: requestId,
      );

      if (showMessage && apiResponse.message.trim().isNotEmpty) {
        showToast(apiResponse.message, idSuccess: apiResponse.isSuccess);
      }

      if (showLog) {
        Map<String, dynamic> logResponse = <String, dynamic>{
          "RESPONSE ID": requestId,
          "DATE TIME": DateFormat().format(endTime),
          "STATUS CODE": apiResponse.rawResponse.statusCode,
          "DURATION": "${duration.inMilliseconds} Milliseconds",
          "HEADERS": apiResponse.rawResponse.headers,
          "BODY": apiResponse.body,
        };

        logger.e(logResponse);
      }

      return apiResponse;
    } catch (e) {
      if (showLoader) {
        LoadingManager.dismissLoading();
      }
      logger.e("API REQUEST EXCEPTION: ${e.toString()}");
      throw Exception(e);
    }
  }

  static Future<ApiResponse> getRequest({
    Map<String, dynamic>? data,
    required String endPoint,
    bool isFullUrl = false,
    bool showLog = showLogGlobal,
    bool showMessage = showMessageGlobal,
    bool showLoader = showLoaderGlobal,
    Map<String, dynamic>? queryParameters,
  }) {
    return ApiManager.request(
      type: RequestType.get,
      data: data,
      endPoint: endPoint,
      isFullUrl: isFullUrl,
      showLog: showLog,
      showMessage: showMessage,
      showLoader: showLoader,
      queryParameters: queryParameters,
    );
  }

  static Future<ApiResponse> postRequest({
    Map<String, dynamic>? data,
    required String endPoint,
    bool isFullUrl = false,
    bool showLog = showLogGlobal,
    bool showMessage = showMessageGlobal,
    bool showLoader = showLoaderGlobal,
    Map<String, dynamic>? queryParameters,
  }) {
    return ApiManager.request(
      type: RequestType.post,
      data: data,
      endPoint: endPoint,
      isFullUrl: isFullUrl,
      showLog: showLog,
      showMessage: showMessage,
      showLoader: showLoader,
      queryParameters: queryParameters,
    );
  }

  static Future<ApiResponse> putRequest({
    Map<String, dynamic>? data,
    required String endPoint,
    bool isFullUrl = false,
    bool showLog = showLogGlobal,
    bool showMessage = showMessageGlobal,
    bool showLoader = showLoaderGlobal,
    Map<String, dynamic>? queryParameters,
  }) {
    return ApiManager.request(
      type: RequestType.put,
      data: data,
      endPoint: endPoint,
      isFullUrl: isFullUrl,
      showLog: showLog,
      showMessage: showMessage,
      showLoader: showLoader,
      queryParameters: queryParameters,
    );
  }

  static Future<ApiResponse> patchRequest({
    Map<String, dynamic>? data,
    required String endPoint,
    bool isFullUrl = false,
    bool showLog = showLogGlobal,
    bool showMessage = showMessageGlobal,
    bool showLoader = showLoaderGlobal,
    Map<String, dynamic>? queryParameters,
  }) {
    return ApiManager.request(
      type: RequestType.patch,
      data: data,
      endPoint: endPoint,
      isFullUrl: isFullUrl,
      showLog: showLog,
      showMessage: showMessage,
      showLoader: showLoader,
      queryParameters: queryParameters,
    );
  }

  static Future<ApiResponse> deleteRequest({
    Map<String, dynamic>? data,
    required String endPoint,
    bool isFullUrl = false,
    bool showLog = showLogGlobal,
    bool showMessage = showMessageGlobal,
    bool showLoader = showLoaderGlobal,
    Map<String, dynamic>? queryParameters,
  }) {
    return ApiManager.request(
      type: RequestType.delete,
      data: data,
      endPoint: endPoint,
      isFullUrl: isFullUrl,
      showLog: showLog,
      showMessage: showMessage,
      showLoader: showLoader,
      queryParameters: queryParameters,
    );
  }

  static Future<ApiResponse> headRequest({
    Map<String, dynamic>? data,
    required String endPoint,
    bool isFullUrl = false,
    bool showLog = showLogGlobal,
    bool showMessage = showMessageGlobal,
    bool showLoader = showLoaderGlobal,
    Map<String, dynamic>? queryParameters,
  }) {
    return ApiManager.request(
      type: RequestType.head,
      data: data,
      endPoint: endPoint,
      isFullUrl: isFullUrl,
      showLog: showLog,
      showMessage: showMessage,
      showLoader: showLoader,
      queryParameters: queryParameters,
    );
  }

  static Map<String, String> headers() {
    final token = Get.find<AuthController>().user.value?.token;
    return <String, String>{
      "Content-type": "application/json",
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*",
      if (token != null) "Authorization": "Bearer $token",
      // add standers session cockie header
      // "Cookie": "session=${OdooRpcApiManager.currentSessionId}",
      // "Cookie": "session_id=${OdooRpcApiManager.currentSessionId}",
      "Cookie":
          "session=${OdooRpcApiManager.currentSessionId}; session_id=${OdooRpcApiManager.currentSessionId}",

      // add any other headers you need
    };
  }
}

class ApiResponse<T> {
  final String requestId;
  final http.Response rawResponse;

  dynamic get body {
    dynamic r;
    try {
      r = jsonDecode(rawResponse.body);
    } catch (e) {
      print("""
        
      ---------- RESPONSE ----------
      
      ID: $requestId      
      RAW RESPONSE BODY: ${rawResponse.body}

      ---------- RESPONSE ----------
      
      """);
    }
    return r;
  }

  bool get isSuccess =>
      body['success'] == true ||
      body['status'] == 'success' ||
      body['status'] == 'ok' ||
      body['status'] == '1' ||
      body['status'] == 1;

  bool get isNotSuccess => !isSuccess;

  String get message => "${body['message'] ?? ""}";

  dynamic get data => body['data'];

  int get statusCode => rawResponse.statusCode;

  bool get isSuccessStatusCode => statusCode >= 200 && statusCode < 300;

  ApiResponse({required this.rawResponse, required this.requestId});

  // withG<T>() {}
}

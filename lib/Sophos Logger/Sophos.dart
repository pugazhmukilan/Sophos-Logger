import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity
import 'package:network_info_plus/network_info_plus.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Only allow bypass for your specific domain
        return host == 'hfw.vitap.ac.in';
      };
  }
}

class SophosLogger {
  static const String baseUrl = "https://hfw.vitap.ac.in:8090";

  final String username;
  final String password;

  SophosLogger({
    required this.username, required this.password}) {
    // Override certificate verification for this specific domain
    HttpOverrides.global = MyHttpOverrides();
  }

  /// Helper: generate current timestamp in ms
  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  /// Dispose method to clean up resources
  void dispose() {
    // Reset to default if needed
    // HttpOverrides.global = null;
  }

  /// 🔑 LOGIN
  // Future<String> login() async {
  //   print("Attempting login for user: $username");
  //   final url = Uri.parse("$baseUrl/login.xml");

  //   final body = {
  //     "mode": "191",
  //     "username": username,
  //     "password": password,
  //     "a": _timestamp(),
  //     "producttype": "0"
  //   };

  //   try {
  //     final response = await http.post(url, body: body);

  //     if (response.statusCode == 200) {
  //       print("Login successful");
  //       print("===========check alive=================");
  //       checkAlive();
  //       return response.body;
  //     } else {
  //       print("Login failed: ${response.statusCode}");
  //       return "Login failed: ${response.statusCode}";
  //     }
  //   } catch (e) {
  //     print("Login error: $e");
  //     return "Login error: $e";
  //   }
  // }


  Future<String> login() async {
    // 1. Check for Wi-Fi connection first
    final ts = _timestamp();
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (!connectivityResult.contains(ConnectivityResult.wifi)) {
      print("❌ Wi-Fi is not connected. Aborting login.");
      return "ERROR: Wi-Fi connection is required to log in.";
    }

    // Optional: Log the Wi-Fi IP to confirm you're on the right network
    final wifiIP = await NetworkInfo().getWifiIP();
    print("✅ Connected to Wi-Fi with IP: $wifiIP");



    checkAlive();




    // 2. Proceed with the login request (your existing code)
    final url = Uri.parse("$baseUrl/login.xml");
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
    };
    final body = {
      "mode": "191",
      "username": username,
      "password": password,
      "a": DateTime.now().millisecondsSinceEpoch.toString(),
      "producttype": "0"
    };

    try {
      print("🚀 Sending login request over Wi-Fi...");
      final res = await http.post(url, headers: headers, body: body);

      print("📄 Response Body: ${res.body}");

      if (res.statusCode == 200) {
        // ... (your existing XML parsing logic)
        final doc = xml.XmlDocument.parse(res.body);
        final status = doc.findAllElements("status").first.text;
        final message = doc.findAllElements("message").first.text;

        if (status == "LIVE") {
            return "SUCCESS: $message";
        } else {
            return "FAILED: $message";
        }
      }
      return "FAILED: HTTP ${res.statusCode}";
    } catch (e) {
      print("❌ An error occurred: $e");
      return "ERROR: $e";
    }
  }
  //  Future<bool> maincheckAlive() async {
  //   final url = Uri.parse("$baseUrl/login.xml");
  //   final body = {
  //     "mode": "191",  // same as login mode, but without password it just checks
  //     "username": username,
  //     "password": "", // leave blank
  //     "a": DateTime.now().millisecondsSinceEpoch.toString(),
  //     "producttype": "0"
  //   };

  //   try {
  //     final res = await http.post(url, body: body);

  //     if (res.statusCode == 200) {
  //       final doc = xml.XmlDocument.parse(res.body);
  //       final statusNode = doc.findAllElements("status").first;
  //       final status = statusNode.text;

  //       if (status == "LIVE") {
  //         return true;  // logged in
  //       } else {
  //         return false; // logged out
  //       }
  //     }
  //     return false;
  //   } catch (e) {
  //     return false;
  //   }
  // }
  
  /// ✅ Check if user session is alive
  void checkAlive() async {
    final ts = _timestamp();
    final liveUrl = Uri.parse(
          "$baseUrl/live?mode=192&username=$username&a=$ts&producttype=0");

      final res1 = await http.get(liveUrl);

      print("==============check alive before check =================");
      print(res1.body); 
  }

  /// 🔒 LOGOUT
  Future<String> logout() async {
    final ts = _timestamp();

    try {
      // Step 1: GET /live
      final liveUrl = Uri.parse(
          "$baseUrl/live?mode=192&username=$username&a=$ts&producttype=0");

      final res1 = await http.get(liveUrl);

      if (res1.statusCode != 200) {
        return "Logout Step 1 failed: ${res1.statusCode}";
      }
      print("==============logout before check =================");
      print(res1.body);
      // Step 2: POST /logout.xml
      final logoutUrl = Uri.parse("$baseUrl/logout.xml");
      final body = {
        "mode": "193",
        "username": username,
        "a": ts,
        "producttype": "0"
      };

      final res2 = await http.post(logoutUrl, body: body);

      if (res2.statusCode == 200) {
         print("==============logout after check =================");
          print(res2.body);
        return res2.body;
      } else {
        return "Logout Step 2 failed: ${res2.statusCode}";
      }
    } catch (e) {
      return "Logout error: $e";
    }
  }
}

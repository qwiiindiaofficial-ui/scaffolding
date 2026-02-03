import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
// import 'package:pointycastle/export.dart';
// import 'package:xml/xml.dart';

class UidaiAuthService {
  static const String apiVersion = "2.5";
  static const String asaLicenseKey =
      "MMxNu7a6589B5x5RahDW-zNP7rhGbZb5HsTRwbi-VVNxkoFmkHGmYKM";
  static const String lk =
      "MBni88mRNM18dKdiVyDYCuddwXEQpl68dZAGBQ2nsOlGMzC9DkOVL5s";
  static const String ac = "public";
  static const String sa = "public";
  static const String tid = "public";

  Future<String> authenticate({
    required String aadhaarNo,
    required String name,
  }) async {
    try {
      // Generate session key
      final sessionKey = _generateSessionKey();

      // Create timestamp
      final now = DateTime.now();
      final ts =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      final txn =
          "AuthDemoClient:public:${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

      // Create PID block
      final pidBlock = _createPidBlock(ts, name);

      // Create Auth XML
      final authXml = _createAuthXml(
        aadhaarNo: aadhaarNo,
        txn: txn,
        pidBlock: pidBlock,
        sessionKey: sessionKey,
      );

      // Sign XML (simplified - you'll need proper certificate handling)
      final signedXml = _signXml(authXml);

      // Make request to UIDAI
      final response = await _makeRequest(aadhaarNo, signedXml);

      return response;
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  Uint8List _generateSessionKey() {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(32, (i) => random.nextInt(256)));
  }

  String _createPidBlock(String ts, String name) {
    return '<?xml version="1.0"?><ns2:Pid ts="$ts" xmlns:ns2="http://www.uidai.gov.in/authentication/uid-auth-request-data/1.0"><ns2:Demo><ns2:Pi ms="E" mv="100" name="$name"/></ns2:Demo></ns2:Pid>';
  }

  String _createAuthXml({
    required String aadhaarNo,
    required String txn,
    required String pidBlock,
    required Uint8List sessionKey,
  }) {
    final certExpiry = _getCertificateExpiry();
    final encryptedSessionKey = _encryptSessionKey(sessionKey);
    final encryptedPid = _encryptPid(pidBlock, sessionKey);
    final hmac = _calculateHmac(pidBlock, sessionKey);

    return '''<?xml version="1.0" encoding="UTF-8"?>
<Auth uid="$aadhaarNo" ac="$ac" lk="$lk" sa="$sa" tid="$tid" txn="$txn" ver="$apiVersion" xmlns="http://www.uidai.gov.in/authentication/uid-auth-request/1.0" xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
  <Uses bio="n" otp="n" pa="n" pfa="n" pi="y" pin="n"/>
  <Meta fdc="NA" idc="NA" lot="P" lov="560094" pip="NA" udc="1122"/>
  <Skey ci="$certExpiry">$encryptedSessionKey</Skey>
  <Data type="X">$encryptedPid</Data>
  <Hmac>$hmac</Hmac>
</Auth>''';
  }

  String _getCertificateExpiry() {
    // You'll need to implement certificate parsing
    // For now, returning a placeholder
    final future = DateTime.now().add(Duration(days: 365));
    return "${future.year}${future.month.toString().padLeft(2, '0')}${future.day.toString().padLeft(2, '0')}";
  }

  String _encryptSessionKey(Uint8List sessionKey) {
    // You'll need to implement RSA encryption with public certificate
    // This is a placeholder implementation
    return base64Encode(sessionKey);
  }

  String _encryptPid(String pidBlock, Uint8List sessionKey) {
    // You'll need to implement AES encryption
    // This is a placeholder implementation
    return base64Encode(utf8.encode(pidBlock));
  }

  String _calculateHmac(String pidBlock, Uint8List sessionKey) {
    final bytes = utf8.encode(pidBlock);
    final digest = sha256.convert(bytes);
    // You'll need to encrypt this with session key
    return base64Encode(digest.bytes);
  }

  String _signXml(String authXml) {
    // You'll need to implement XML digital signature
    // This requires proper certificate handling
    // For now, returning the unsigned XML
    return authXml;
  }

  Future<String> _makeRequest(String aadhaarNo, String signedXml) async {
    final url =
        "http://auth.uidai.gov.in/$apiVersion/public/${aadhaarNo[0]}/${aadhaarNo[0]}/$asaLicenseKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/xml',
        'Content-Type': 'application/xml',
      },
      body: signedXml,
    );

    return response.body;
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UIDAI Auth Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _aadhaarController = TextEditingController(text: '999999990019');
  final _nameController = TextEditingController(text: 'Shivshankar Choudhury');
  bool _isLoading = false;
  String _response = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('UIDAI Authentication')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _aadhaarController,
              decoration: InputDecoration(labelText: 'Aadhaar Number'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _authenticate,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Authenticate'),
            ),
            SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_response),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final authService = UidaiAuthService();
      final response = await authService.authenticate(
        aadhaarNo: _aadhaarController.text,
        name: _nameController.text,
      );

      print(response);
      setState(() {
        _response = response;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_mpesa/models/mpesa.dart';
import 'package:http/http.dart';

class ApiService {
  String baseUrl = "https://sandbox.safaricom.co.ke/";
  String getTodayValidTimeStamp() {
    var datedefinedstamp = DateTime.now();
    return "${datedefinedstamp.year.toString()}${datedefinedstamp.month.toString().padLeft(2, '0')}${datedefinedstamp.day.toString().padLeft(2, '0')}${datedefinedstamp.hour.toString().padLeft(2, '0')}${datedefinedstamp.minute.toString().padLeft(2, '0')}${datedefinedstamp.second.toString().padLeft(2, '0')}";
  }

  Future<bool> stkPush(Mpesa mpesa) async {
    String timestamp = getTodayValidTimeStamp();
    var body = {
      "AccountReference": mpesa.phoneNumber,
      "BusinessShortCode": dotenv.env['short_code'],
      "PartyB": dotenv.env['short_code'],
      "Timestamp": timestamp,
      "PartyA": mpesa.phoneNumber,
      "TransactionType": "CustomerPayBillOnline",
      "Amount": mpesa.amount,
      "PhoneNumber": mpesa.phoneNumber,
      "Password": generatePasswordForStk(timestamp),
      "CallBackURL": dotenv.env["CALL_BACK_URL"],
      "TransactionDesc": "TransactionDesc"
    };
    Response response = await postCall("mpesa/stkpush/v1/processrequest",
        {"Authorization": "Bearer ${await getAccessToken()}"}, body);
    if (response.statusCode != 200) {
      return false;
    }
    return true;
  }

  Future<Response> getCall(String url, Map<String, String> headers) async {
    return await networkCall("GET", url, headers);
  }

  Future<Response> postCall(
      String url, Map<String, String> headers, body) async {
    return await networkCall("POST", url, headers, body: body);
  }

  Future<Response> networkCall(
      String method, String url, Map<String, String> headers,
      {body}) async {
    var client = Client();
    // preferably a response that can be handled;
    Response response = Response("method not supported", 500);
    Uri uri = Uri.parse(baseUrl + url);
    headers.addEntries({"content-type": "application/json"}.entries);

    try {
      if (method == 'GET') {
        response = await client.get(uri, headers: headers);
      }
      if (method == 'POST') {
        response =
            await client.post(uri, headers: headers, body: json.encode(body));
      }
    } catch (e) {
      //handle this some way
      print(e);
    }
    return response;
  }

  String generatePassword() {
    final bytes = utf8.encode(
        "${dotenv.env['consumer_key']}:${dotenv.env['consumer_secret']}");
    return base64.encode(bytes);
  }

  String generatePasswordForStk(String timestamp) {
    final bytes = utf8.encode(
        "${dotenv.env['short_code']}${dotenv.env['STK_PASSWORD']}$timestamp");
    return base64.encode(bytes);
  }

  Future<String> getAccessToken() async {
    Response response = await getCall(
        "oauth/v1/generate?grant_type=client_credentials",
        {"Authorization": "Basic ${generatePassword()}"});
    return json.decode(response.body)['access_token'];
  }
}

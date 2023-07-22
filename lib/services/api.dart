import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_mpesa/models/mpesa.dart';
import 'package:http/http.dart';

class ApiService {
  String baseUrl = "https://sandbox.safaricom.co.ke/";

  Future<bool> stkPush(Mpesa mpesa) async {
    var body = {
      "ShortCode": "600981",
      "CommandID": "CustomerPayBillOnline",
      "Amount": mpesa.amount,
      "Msisdn": mpesa.phoneNumber,
      "BillRefNumber": mpesa.phoneNumber,
    };
    Response response = await postCall("mpesa/c2b/v1/simulate",
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
    }
    return response;
  }

  String generatePassword() {
    final bytes = utf8.encode(
        "${dotenv.env['consumer_key']}:${dotenv.env['consumer_secret']}");
    return base64.encode(bytes);
  }

  Future<String> getAccessToken() async {
    Response response = await getCall(
        "oauth/v1/generate?grant_type=client_credentials",
        {"Authorization": "Basic ${generatePassword()}"});
    return json.decode(response.body)['access_token'];
  }
}

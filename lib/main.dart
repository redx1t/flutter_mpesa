import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_mpesa/models/mpesa.dart';
import 'package:flutter_mpesa/services/api.dart';

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(seconds: 2)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = true;
}

void main() async {
  await dotenv.load(fileName: ".env");
  configLoading();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Mpesa Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: EasyLoading.init(),
      home: const MyHomePage(title: 'Flutter Mpesa Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final amountController = TextEditingController();
  final phoneNumberController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    phoneNumberController.dispose();
  }

  validatePhone(String phone) {
    var regex = RegExp(
        r'(?:254|\\+254|0)?((?:(?:[0-9](?:(?:[0-9][0-9])|(?:5[789])|(?:6[89])))|(?:1(?:[1][0-5])))[0-9]{6})');
    if (regex.hasMatch(phone)) {
      return '254${(regex.firstMatch(phone))?.group(1)}';
    } else {
      return false;
    }
  }

  bool loading = false;
  void setLoading(bool value) {
    if (value) {
      EasyLoading.show(status: 'processing');
    } else {
      EasyLoading.dismiss();
    }
    setState(() {
      loading = value;
    });
  }

  processSTK() async {
    if (loading) {
      return;
    }
    setLoading(true);
    int amount = 0;
    try {
      amount = int.parse(amountController.value.text);
    } catch (e) {
      setLoading(false);
      notify("Enter a valid amount");
      return;
    }

    // preferrably to wrap this in a try and catch if the value inputted is not a valid int
    if (amount < 0) {
      notify("Enter a valid amount");
      setLoading(false);
      return;
    }
    //var instead of strong typing to ensure we validate phone number or get false if it fails
    var phoneNumber = validatePhone(phoneNumberController.value.text);
    if (phoneNumber == false) {
      notify("Enter a valid phone number");
      setLoading(false);
      return;
    }
    bool status = await ApiService().stkPush(Mpesa(amount, phoneNumber));
    if (status) {}
    setLoading(false);
  }

  void notify(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Click the button to trigger an STK push',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
              ),
              const SizedBox(
                height: 12,
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter the mpesa amount *',
                  hintText: 'Amount',
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              TextField(
                controller: phoneNumberController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter the phone number *',
                  hintText: 'Amount',
                ),
              ),
              TextButton(
                  onPressed: () async {
                    if (loading) {
                      notify("processing");
                      return;
                    }
                    await processSTK();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: const Text(
                      "Trigger STK push",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

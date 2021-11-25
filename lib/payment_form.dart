import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:vya/utils/globals.dart' as globals;

class payment_form extends StatefulWidget {
  String type;

  payment_form({Key? key, required this.type}) : super(key: key);

  @override
  _payment_formState createState() => _payment_formState(type);
}

String _checkoutid = '';
String _resultText = '';
String _MadaRegexV = "";
String _MadaRegexM = "";
String _MadaHash = "";

class _payment_formState extends State<payment_form> {
  static const platform = const MethodChannel('com.example.hyperne/paymentMethod');

  final _cardNumberText = TextEditingController();
  final _cardHolderText = TextEditingController();
  final _expiryMonthText = TextEditingController();
  final _expiryYearText = TextEditingController();
  final _CVVText = TextEditingController();
  final _STCPAYText = TextEditingController();

  String _text = "";

  String type = "";

  _payment_formState(String type) {
    this.type = type;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      // final prefs = await SharedPreferences.getInstance();
      // _MadaHash = prefs.get("MadaHash") ?? "";
      // _MadaRegexV = prefs.get("madaV") ?? "";
      // _MadaRegexM = prefs.get("madaM") ?? "";
      // await _requestMadaRegex();
    });
  }

  @override
  void dispose() async {
    // Clean up the controller when the widget is disposed.
    _cardNumberText.dispose();
    _cardHolderText.dispose();
    _expiryMonthText.dispose();
    _expiryYearText.dispose();
    _CVVText.dispose();
    _STCPAYText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("sarfa");
            _requestCheckoutId();
          },
        ),
        appBar: AppBar(
          title: Text('Custom UI'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Checkout Page",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Card Number',
                        counter: Offstage(),
                      ),
                      controller: _cardNumberText,
                      maxLength: 16,
                      keyboardType: TextInputType.number),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Holder Name',
                      counter: Offstage(),
                    ),
                    controller: _cardHolderText,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Expiry Month',
                            counter: Offstage(),
                          ),
                          controller: _expiryMonthText,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Expiry Year',
                            hintText: "ex : 2027",
                            counter: Offstage(),
                          ),
                          controller: _expiryYearText,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'CVV',
                      counter: Offstage(),
                    ),
                    controller: _CVVText,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                  ),
                  RaisedButton(
                    child: Text('PAY'),
                    onPressed: _pay,
                    padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
                  ),
                  SizedBox(height: 10),
                  if (Platform.isIOS)
                    RaisedButton(
                      child: Text('APPLEPAY'),
                      onPressed: _APPLEpay,
                      padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
                      color: Colors.black,
                      textColor: Colors.white,
                    ),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'STCPAY Number',
                      hintText: "05xxxxxxxx",
                      counter: Offstage(),
                    ),
                    controller: _STCPAYText,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                  ),
                  RaisedButton(
                    child: Text('STCPAY'),
                    onPressed: _STCPAYpay,
                    padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
                  ),
                  SizedBox(height: 35),
                  Text(
                    _resultText,
                    style: TextStyle(color: Colors.green, fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pay() async {
    if (_cardNumberText.text.isNotEmpty ||
        _cardHolderText.text.isNotEmpty ||
        _expiryMonthText.text.isNotEmpty ||
        _expiryYearText.text.isNotEmpty ||
        _CVVText.text.isNotEmpty) {
      _checkoutid = (await _requestCheckoutId())!;
      print("_checkoutid"+_checkoutid);

      print("typeeee" + type);
      String transactionStatus;
      try {
        final String result =
        await platform.invokeMethod('gethyperpayresponse', {
          "type": "ReadyUI",
          "checkoutid": _checkoutid,
          "mode": "TEST",
          "brand": type,
          "card_number": _cardNumberText.text,
          "holder_name": _cardHolderText.text,
          "month": _expiryMonthText.text,
          "year": _expiryYearText.text,
          "cvv": _CVVText.text,
          "MadaRegexV": _MadaRegexV,
          "MadaRegexM": _MadaRegexM,
          "STCPAY": "disabled"
        });
        transactionStatus = '$result';
      } on PlatformException catch (e) {
        transactionStatus = "${e.message}";
      }

      if (transactionStatus != null ||
          transactionStatus == "success" ||
          transactionStatus == "SYNC") {
        getpaymentstatus();
      } else {
        setState(() {
          _resultText = transactionStatus;
        });
      }
    } else {
      _showDialog();
    }
  }

  Future<void> _APPLEpay() async {
    _checkoutid = (await _requestCheckoutId())!;

    print("typeeee" + type);
    String transactionStatus;
    try {
      final String result = await platform.invokeMethod('gethyperpayresponse', {
        "type": "CustomUI",
        "checkoutid": _checkoutid,
        "mode": "TEST",
        "brand": "APPLEPAY",
        "card_number": _cardNumberText.text,
        "holder_name": _cardHolderText.text,
        "month": _expiryMonthText.text,
        "year": _expiryYearText.text,
        "cvv": _CVVText.text,
        "MadaRegexV": _MadaRegexV,
        "MadaRegexM": _MadaRegexM,
        "STCPAY": "disabled",
        "Amount": 1.00 // ex : 100.00 , 102.25 , 102.20
      });
      transactionStatus = '$result';
    } on PlatformException catch (e) {
      transactionStatus = "${e.message}";
    }

    if (transactionStatus != null ||
        transactionStatus == "success" ||
        transactionStatus == "SYNC") {
      getpaymentstatus();
    } else {
      setState(() {
        _resultText = transactionStatus;
      });
    }
  }

  Future<void> _STCPAYpay() async {
    if (_STCPAYText.text.isNotEmpty) {
      _checkoutid = (await _requestCheckoutId())!;
      print(_checkoutid);

      String transactionStatus = "";
      try {
        final String result =
            await platform.invokeMethod('gethyperpayresponse', {
          "type": "CustomUI",
          "checkoutid": _checkoutid,
          "mode": "TEST",
          "card_number": _cardNumberText.text,
          "holder_name": _cardHolderText.text,
          "month": _expiryMonthText.text,
          "year": _expiryYearText.text,
          "cvv": _CVVText.text,
          "STCPAY": "enabled"
        });
        transactionStatus = '$result';
      } on PlatformException catch (e) {
        transactionStatus = "${e.message}";
      }

      if (transactionStatus != null ||
          transactionStatus == "success" ||
          transactionStatus == "SYNC") {
        print(transactionStatus);
        getpaymentstatus();
      } else {
        setState(() {
          _resultText = transactionStatus;
        });
      }
    } else {
      _showDialog();
    }
  }

  Future<void> getpaymentstatus() async {
    var status;

    // String myUrl = "http://reemapp.com/shopperresultIOS.php?id=$_checkoutid";
    String myUrl =
        "http://app.vya.healthcare/api/v1/payment-status?id=F0F8C75D5A81D55A6B223DF33FE92E1F.uat01-vm-tx04&entityId=8a8294174d0595bb014d05d82e5b01d2&payment_auth_token=OGE4Mjk0MTc0ZDA1OTViYjAxNGQwNWQ4MjllNzAxZDF8OVRuSlBjMm45aA==";

    //SharedPreferences prefs = await SharedPreferences.getInstance();
    // final defaultToken = prefs.getString('userAuthToken');

    final response = await http.post(
      myUrl,
      headers: {
        'Accept': 'application/json',
        //"language": globals.defaultLanguage == 'Arabic' ? "ar" : "en",
        // HttpHeaders.authorizationHeader: "Bearer $defaultToken",
      },
    );
    status = response.body.contains('error');

    var data = json.decode(response.body);

    print("payment_status: ${data["result"].toString()}");

    setState(() {
      _resultText = data["result"].toString();
    });
  }

  // Future<String> _requestMadaRegex() async {
  //   int status;
  //   // String myUrl = "http://reemapp.com/reqcheckoutidios.php?STCPAY_Number=${_STCPAYText.text}";
  //   String myUrl = "http://reemapp.com/MadaRegex.php";
  //   final response = await http.post(myUrl,
  //       headers: {'Accept': 'application/json'}, body: {"hash": _MadaHash});
  //
  //   var data = json.decode(response.body);
  //
  //   final prefs = await SharedPreferences.getInstance();
  //
  //   status = data['result'];
  //   if (status == 1 || status == 2) {
  //     final key = 'MadaHash';
  //     final value = data['hash'];
  //     prefs.setString(key, value);
  //     prefs.setString("MadaV", data['Visa']);
  //     prefs.setString("MadaM", data['Master']);
  //
  //     _MadaHash = value;
  //     _MadaRegexV = data['Visa'];
  //     _MadaRegexM = data['Master'];
  //   }
  //
  //   print("madastatus" + status.toString());
  //   print("madahash" + _MadaHash);
  //   print("madaVisa" + _MadaRegexV);
  //   print("madaMaster" + _MadaRegexM);
  // }

  Future<String?> _requestCheckoutId() async {
    var status;
   // Response response;
    String myUrl = "https://tayseerme.com/api/zinfogpay/";
    Map datamap = {
      'email': 'shereefklr@gmail.com',
      'hyappli_number': '1738057',
      'card_type': 'VISA',
      'hycheck_type': 'loan',
      'hyservice_id': '',
      'amount': '10'
    };

    final response = await http.post(
      myUrl,
      body:  datamap,
     // headers: {'Content-Type': 'application/json'},
    );
    status = response.body.contains('error');

    var data = json.decode(response.body);

    print(data['id']);
    if (status) {
      print('data : ${data["error"]}');
    } else {

      // print("s");
      return data['id'];
    }
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Alert!"),
          content: new Text("Please fill all fields"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

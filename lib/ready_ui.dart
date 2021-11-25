import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;



class Ready_UI extends StatefulWidget {
  @override
  _Ready_UIState createState() => _Ready_UIState();
}

String _checkoutid = '';
String _resultText = '';

String _custUserId = '';
String entityId = '';
double netPrice = 0.0;
int id = 1;
int payId = 0;
String radioItem = '';
String defaultLocation = '';
int defaultLocationId = 0;

class _Ready_UIState extends State<Ready_UI> {
  static const platform = const MethodChannel('com.example.hyperne/paymentMethod');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('READY UI'),
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
                  RaisedButton(
                    child: Text('Credit Card'),
                    onPressed: () {
                      _checkoutpage("credit");
                    },
                    padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
                  ),
                  SizedBox(height: 15),
                  RaisedButton(
                    child: Text('Mada'),
                    onPressed: () {
                      _checkoutpage("mada");
                    },
                    padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  if (Platform.isIOS)
                    RaisedButton(
                      child: Text('APPLEPAY'),
                      onPressed: () {
                        _checkoutpage("APPLEPAY");
                      },
                      padding: EdgeInsets.fromLTRB(22, 0, 22, 0),
                      color: Colors.black,
                      textColor: Colors.white,
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





  Future<void> _checkoutpage(String type) async {
    //  requestCheckoutId();

    var status;
    String statusCodeValFromCheckoutPage = '';
    String myUrl = "https://tayseerme.com/api/zinfogpay/";
    Map datamap = {
      'email': 'shereefklr@gmail.com',
      'hyappli_number': '1738057',
      'card_type': 'VISA',
      'hycheck_type': 'loan',
      'hyservice_id': '',
      'amount': '10'
    };

    setState(() {
      if (radioItem == 'MADA')
        entityId = '8ac9a4ce79410c53017950712e677fbf';
      else
        entityId = '8ac9a4ce79410c5301795062aeec7f7b';
    });

    final response = await http.post(myUrl,
        body:datamap

    );
    status = response.body.contains('error');

    var data = json.decode(response.body);


    print("sarfas");

    print('data: $data');
    if (status) {

      print('data ERROR : ${data["error"]}');

    } else {
      print('data CHECKOUT ID : ${data["id"]}');
      _checkoutid = '${data["id"]}';

      String transactionStatus;
      try {
        final String result =
            await platform.invokeMethod('gethyperpayresponse', {
          "type": "ReadyUI",
          "mode": "TEST",
          "checkoutid": _checkoutid,
          "brand": type,
        });
        print("====================");
        transactionStatus = '$result';



        print('=== ===: $transactionStatus');
      } on PlatformException catch (e) {
        transactionStatus = "${e.message}";
      }

      if (transactionStatus != null ||
          transactionStatus == "success" ||
          transactionStatus == "SYNC") {
        print("status");
        print(transactionStatus);
        getpaymentstatus(checkOutId: _checkoutid,entity:"8a8294174b7ecb28014b9699220015ca" );
      } else {
        setState(() {
          _resultText = transactionStatus;
        });
      }
    }
  }

  Future<void> getpaymentstatus({String? checkOutId,String? entity}) async {
    var status;

    String myUrl =
        "https://tayseerme.com/api/zinfogstatus/";

    Map body = {
      'entityID': entity,
      'checkoutID': checkOutId,
    };

    final response = await http.post(
      myUrl,
      body: body
    );
    status = response.body.contains('error');

    var data = json.decode(response.body);

    //print("payment_status: ${data["result"].toString()}");

    setState(() {
      _resultText = data["result"].toString();
    });
  }
}

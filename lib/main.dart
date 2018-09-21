import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_cryptocurrency/Crypto.dart';
import 'package:connectivity/connectivity.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var connectivityResult;

  Future<List<Crypto>> _getCryptoCurrency() async {
    connectivityResult = await (new Connectivity().checkConnectivity());
    List<Crypto> currencyList = [];
    var data = await http.get("https://api.coinmarketcap.com/v1"
        "/ticker/?limit=50");
    print(data);
    var jsondata = json.decode(data.body);
    print(data.body);
    for (var v in jsondata) {
      Crypto temp = Crypto(
          v["name"], v["symbol"], v["price_usd"], v["percent_change_24h"]);
      currencyList.add(temp);
    }
    return currencyList;
  }

  void _refreshActivity() {
    _getCryptoCurrency();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crypto App"),
        backgroundColor: Colors.lightBlue,
        leading: Icon(
          Icons.monetization_on,
          size: 30.00,
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 15.00),
            child: IconButton(
              icon: Icon(
                Icons.refresh,
                size: 25.00,
              ),
              onPressed: _refreshActivity,
            ),
          ),
        ],
      ),
      body: Container(
        child: FutureBuilder(
            future: _getCryptoCurrency(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (connectivityResult == ConnectivityResult.none) {
                return Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.signal_wifi_off,
                          size: 100.00,
                          color: Colors.lightBlueAccent.withOpacity(0.50),
                        ),
                        SizedBox(
                          height: 30.00,
                        ),
                        MaterialButton(
                          child: Text(
                            "Refresh",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: _refreshActivity,
                          color: Colors.blueGrey.withOpacity(0.50),
                        )
                      ],
                    ),
                  ),
                );
              } else if (!snapshot.hasData) {
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                          height: 60.00,
                          color: index % 2 == 0
                              ? Colors.grey.withOpacity(0.10)
                              : Colors.grey.withOpacity(0.20),
                          padding:
                              EdgeInsets.fromLTRB(20.00, 10.00, 20.00, 10.00),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      snapshot.data[index].symbol,
                                      style: TextStyle(fontSize: 18.00),
                                    ),
                                    Text(
                                      snapshot.data[index].name,
                                      style: TextStyle(
                                          fontSize: 12.00,
                                          color: Colors.black54),
                                    )
                                  ],
                                ),
                                flex: 4,
                              ),
                              Expanded(
                                child: Text(
                                  snapshot.data[index].price
                                          .toString()
                                          .substring(
                                              0,
                                              (snapshot.data[index].price
                                                      .toString()
                                                      .length) -
                                                  6) +
                                      " \$",
                                  style: TextStyle(
                                      fontSize: 18.00,
                                      color: double.parse(snapshot.data[index]
                                                  .percent_change_24h) <
                                              0.0
                                          ? Colors.red
                                          : Colors.green),
                                ),
                                flex: 3,
                              ),
                              Expanded(
                                child: Text(
                                  snapshot.data[index].percent_change_24h +
                                      " %",
                                  style: TextStyle(
                                      fontSize: 18.00,
                                      color: double.parse(snapshot.data[index]
                                                  .percent_change_24h) <
                                              0.0
                                          ? Colors.red
                                          : Colors.green),
                                ),
                                flex: 2,
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 0.50,
                        child: Container(
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  );
                });
              }
            }),
      ),
    );
  }
}
import 'dart:async';
import 'package:http/http.dart'as http;
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
  Future<List<Crypto>> _getCryptoCurrency() async{
    connectivityResult = await (new Connectivity().checkConnectivity());
    List<Crypto> currencyList = [];
    var data = await http.get("https://api.coinmarketcap.com/v1/ticker/?limit=50");
    var jsondata = json.decode(data.body);
    for(var v in jsondata){
      Crypto temp = Crypto(v["name"], v["price_usd"]);
      currencyList.add(temp);
    }
    return currencyList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crypto App"),backgroundColor: Colors.lightBlue,),
      body: Container(
        child:
        FutureBuilder(
            future: _getCryptoCurrency(),
            builder: (BuildContext context,AsyncSnapshot snapshot){
              if(connectivityResult == ConnectivityResult.none){
                return Container(child: Center(child: Icon(Icons.signal_wifi_off,size: 50.00,),),);
              }
              else if(!snapshot.hasData){
                return Container(child: Center(child: CircularProgressIndicator(),),);
              }else {
                return ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(snapshot.data[index].name),
                        subtitle: Text(snapshot.data[index].price+" \$"),
                      );
                    });
              }
        }),
      ),
    );
  }
}
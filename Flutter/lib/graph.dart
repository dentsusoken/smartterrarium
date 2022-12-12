import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartterrarium/controller_page.dart';
import 'package:page_transition/page_transition.dart';

import 'main.dart';

class GraphPage extends StatelessWidget {
  const GraphPage({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'smart-terrarium',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'smart-terrarium'),
      debugShowCheckedModeBanner: false,
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
  late Future<List<RecoardResults>> res;
  @override
  void initState() {
    super.initState();
    res = getRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('smart-terrarium'),
        backgroundColor: Colors.lime,
      ),
      body: Center(
        child:Container(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: 500,
                height: 500,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topCenter,
                      width: 160,
                      height: 620,
                      child: Container(
                        width: 160,
                        height: 40,
                        child: OutlinedButton(
                          child: const Text('現在温度'),
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black,
                            shape: const StadiumBorder(),
                            side: const BorderSide(color: Colors.green),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: MyApp(), //画面遷移先
                                type: PageTransitionType.bottomToTop, //アニメーションの種類
                                duration: const Duration(milliseconds: 300),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: 500,
                      height: 100,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: 500,
                      height: 100,
                    ),
                    // Container(
                    //   width: 500,
                    //   height: 500,
                    //   child: FutureBuilder<ApiResults>(
                    //     future: res,
                    //     builder: (context, snapshot) {
                    //       if (snapshot.hasData) {
                    //         return Text(
                    //             snapshot.data!.message.toString()
                    //         );
                    //       } else if (snapshot.hasError) {
                    //         return Text("${snapshot.error}");
                    //       }
                    //       return CircularProgressIndicator();
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),//大外の黄緑のボックス
              Container(
                alignment: Alignment.center,
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.lime,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(10, 10),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      blurRadius: 20,
                    ),
                    BoxShadow(
                      offset: Offset(-10, -10),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Container(
                  alignment: Alignment.centerRight,
                  height: 400,
                  width: 300,
                  child: Container(
                    alignment: Alignment.center,
                    height: 380,
                    width: 280,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child:
                    FutureBuilder<List<RecoardResults>>(
                      future: res,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SingleChildScrollView(
                            child: Column(
                                children: [
                                  for (final record in snapshot.data!)
                                    Text(
                                        "${record.timestamp.toString().substring(5, 16)}　　温度: ${record.temperature.toStringAsFixed(1)}　　湿度: ${record.humidity.toStringAsFixed(1)}"
                                    ),
                                ]
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                  ),
                ),//現在湿度値
              ),//内側の緑色のボックス
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class RecoardResults {
  final String timestamp;
  final double temperature;
  final double humidity;
  final int heat_flag;
  RecoardResults({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.heat_flag,
  });
  factory RecoardResults.fromJson(Map<String, dynamic> json) {
    return RecoardResults(
      timestamp: json['timestamp'],
      temperature: json['temperature'],
      humidity: json['humidity'],
      heat_flag: json['heat_flag'],
    );
  }
}


Future<List<RecoardResults>> getRecords() async {
  var url = "http://192.168.11.26:8000/get_records/";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<RecoardResults> posts = List<RecoardResults>.from(l.map((model)=> RecoardResults.fromJson(model)));
    return posts;
  } else {
    throw Exception('Failed');
  }
}
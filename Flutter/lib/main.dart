import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartterrarium/controller_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smartterrarium/graph.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
  late Future<RecoardResults> res;
  @override
  void initState() {
    super.initState();
    res = getRecord();
    print(res);
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
                      alignment: Alignment.bottomCenter,
                      width: 160,
                      height: 500,
                      child: Container(
                        width: 160,
                        height: 40,
                        child: OutlinedButton(
                          child: const Text('これまでの記録'),
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black,
                            shape: const StadiumBorder(),
                            side: const BorderSide(color: Colors.green),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                              PageTransition(
                                child: GraphPage(), //画面遷移先
                                type: PageTransitionType.topToBottom, //アニメー
                                duration: const Duration(milliseconds: 300),// ションの種類
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      width: 160,
                      height: 500,
                      child: Container(
                        width: 160,
                        height: 40,
                        child: OutlinedButton(
                          child: const Text('温度設定'),
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black,
                            shape: const StadiumBorder(),
                            side: const BorderSide(color: Colors.green),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: ControllerPage(), //画面遷移先
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
                height: 300,
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
                child:              Stack(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      height: 100,
                      width: 120,
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: 200,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        ),
                        child: const Text(
                          '現在温度',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),//現在温度
                    Container(
                      alignment: Alignment.centerRight,
                      height: 200,
                      width: 300,
                      child: Container(
                        alignment: Alignment.center,
                        height: 80,
                        width: 180,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            bottomLeft: Radius.circular(50),
                          ),
                        ),
                        child: FutureBuilder<RecoardResults>(
                          future: res,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                  "${snapshot.data!.temperature.toStringAsFixed(1)}°C",
                                style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              );
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      ),
                    ),//現在温度値
                    Container(
                      alignment: Alignment.bottomRight,
                      height: 260,
                      width: 300,
                      child: Container(
                        alignment: Alignment.center,
                        height: 80,
                        width: 180,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            bottomLeft: Radius.circular(50),
                          ),
                        ),
                        child: FutureBuilder<RecoardResults>(
                          future: res,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                "${snapshot.data!.humidity.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
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
                    Container(
                      alignment: Alignment.bottomLeft,
                      height: 200,
                      width: 120,
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: 200,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        ),
                        child: const Text(
                          '現在湿度',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),//現在湿度
                  ],
              ),//真ん中の黄緑のボックス
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

Future<RecoardResults> getRecord() async {
  var url = "http://192.168.11.26:8000/get_record/";
  final response = await http.get(Uri.parse(url));
  print("****" + response.body);
  if (response.statusCode == 200) {
    return RecoardResults.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed');
  }
}
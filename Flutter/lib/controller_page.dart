//設定温度操作ページ
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

import 'main.dart';


void main() {
  runApp(const ControllerPage());
}

class ControllerPage extends StatelessWidget {
  const ControllerPage({super.key});
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
  late int night_temperature;
  late int day_temperature;
  late int diff_temperature;
  @override
  void initState() {
    super.initState();
    res = getSetting();
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
                        // 画面切り替え（現在温度ページ）
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
                                type: PageTransitionType.topToBottom, //アニメーションの種類
                                duration: const Duration(milliseconds: 300),
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
                    ),
                    // 日中設定温度上昇
                    Container(
                      alignment: Alignment.topRight,
                      width: 500,
                      height: 100,
                      // 日中設定温度上昇ボタン
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.lime,
                          shape: const CircleBorder(
                            side: BorderSide(
                              color: Colors.lime,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          day_temperature = day_temperature + 1;
                          updateSetting(day_temperature, night_temperature, diff_temperature);
                          res = getSetting();
                          setState((){});
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                    // 日中設定温度低下
                    Container(
                      alignment: Alignment.topLeft,
                      width: 500,
                      height: 100,
                      // 日中設定温度低下ボタン
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.lime,
                          shape: const CircleBorder(
                            side: BorderSide(
                              color: Colors.lime,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          day_temperature = day_temperature - 1;
                          updateSetting(day_temperature, night_temperature, diff_temperature);
                          res = getSetting();
                          setState((){});
                        },
                        child: const Icon(Icons.remove),
                      ),
                    ),
                    // 夜間設定温度上昇
                    Container(
                      alignment: Alignment.bottomRight,
                      width: 500,
                      height: 210,
                      // 夜間設定温度上昇ボタン
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.lime,
                          shape: const CircleBorder(
                            side: BorderSide(
                              color: Colors.lime,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          night_temperature = night_temperature + 1;
                          updateSetting(day_temperature, night_temperature, diff_temperature);
                          res = getSetting();
                          setState(() {});
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                    // 夜間設定温度低下
                    Container(
                      alignment: Alignment.bottomLeft,
                      width: 500,
                      height: 210,
                      // 夜間設定温度低下ボタン
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.lime,
                          shape: const CircleBorder(
                            side: BorderSide(
                              color: Colors.lime,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        onPressed: () {
                          night_temperature = night_temperature -1;
                          updateSetting(day_temperature, night_temperature, diff_temperature);
                          res = getSetting();
                          setState(() {});
                        },
                        child: const Icon(Icons.remove),
                      ),
                    ),

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
                child:Stack(
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
                          '日中設定温度',
                          style: TextStyle(
                            fontSize: 14,
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
                              day_temperature = snapshot.data!.day_temperature;
                              diff_temperature = snapshot.data!.diff_temperature;
                              return Text(
                                "$day_temperature°C",
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
                              night_temperature = snapshot.data!.night_temperature;
                              return Text(
                                "$night_temperature°C",
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
                          '夜間設定温度',
                          style: TextStyle(
                            fontSize: 14,
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
  final String message;
  final int day_temperature ;
  final int night_temperature;
  final int diff_temperature;
  RecoardResults({
    required this.message,
    required this.day_temperature,
    required this.night_temperature,
    required this.diff_temperature,
  });
  factory RecoardResults.fromJson(Map<String, dynamic> json) {
    return RecoardResults(
      message: json['message'],
      day_temperature: json['day_temperature'],
      night_temperature: json['night_temperature'],
      diff_temperature: json['diff_temperature'],
    );
  }
}

class settingRequest {
  final int day_temperature;
  final int night_temperature;
  final int diff_temperature;
  settingRequest({
    required this.day_temperature,
    required this.night_temperature,
    required this.diff_temperature,
  });
  Map<String, dynamic> toJson() => {
    'day_temperature': day_temperature,
    'night_temperature': night_temperature,
    'diff_temperature': diff_temperature,
  };
}

Future<RecoardResults> getSetting() async {
  var url = "http://192.168.11.26:8000/get_parameter_set/";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return RecoardResults.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed');
  }
}

void updateSetting(day_temperature, night_temperature, diff_temperature) async {
  var url = "http://192.168.11.26:8000/update_parameter_set/";
  var request = new settingRequest(day_temperature: day_temperature, night_temperature: night_temperature, diff_temperature: diff_temperature);
  final response = await http.post(Uri.parse(url),
      body: json.encode(request.toJson()),
      headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
  } else {
    throw Exception('Failed');
  }
}


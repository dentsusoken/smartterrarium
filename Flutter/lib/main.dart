import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


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
  static const platform = MethodChannel('test.Channel');

  // Get battery level.
  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final result = await platform.invokeMethod<int>('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }


  @override
  void initState() {
    super.initState();
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
                          'ボタン',
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
                        child: ElevatedButton(
                          onPressed: _getBatteryLevel,
                          child: const Text('バッテリー残量を取得'),
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
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(_batteryLevel),
                            ],
                          ),
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
                          '現在のバッテリー残量',
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



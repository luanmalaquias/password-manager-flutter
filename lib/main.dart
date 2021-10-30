import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gerar_senha/ui/tela_1_login.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (timer.tick >= 1) {
        timer.cancel();
        _exitApp();
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gerenciador de senhas',
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }
}

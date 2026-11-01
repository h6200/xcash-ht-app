import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api.dart';
import 'theme.dart';
import 'screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await Api.loadToken();
  runApp(const XcashApp());
}

class XcashApp extends StatelessWidget {
  const XcashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XCASH HT',
      debugShowCheckedModeBanner: false,
      theme: buildXcashTheme(),
      home: const SplashScreen(),
    );
  }
}

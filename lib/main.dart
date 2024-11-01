import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:indevche/record.dart';
import 'package:indevche/welcome.dart';
import 'package:provider/provider.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(const MainApp());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Records()),
      ],
      child: MaterialApp(
        home: const WelcomeScreen(),
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
      ),
    );
  }
}

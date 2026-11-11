import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/home-screen.dart';
import 'ui/tiksave-theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: TikSaveTheme.bgObsidian,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TikSaveApp());
}

class TikSaveApp extends StatelessWidget {
  const TikSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikSave',
      debugShowCheckedModeBanner: false,
      theme: TikSaveTheme.darkTheme,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.noScaling),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
    );
  }
}

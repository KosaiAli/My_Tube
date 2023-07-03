import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import './Models/data_center.dart';
import './Models/player_controller.dart';
import 'Screens/edit_playlist/edit_playlist_screen.dart';
import './Screens/main_screen.dart';
import 'Screens/downloads/download_single/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.storage.request();
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => DataCenter(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => DownloadSingleProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => MusicPlayer(),
        ),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          PlayListEditScreen.routeName: (ctx) => const PlayListEditScreen()
        },
        home: const MainScreen(),
      ),
    );
  }
}

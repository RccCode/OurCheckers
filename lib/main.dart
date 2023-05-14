import 'package:flutter/material.dart';
import 'package:ourcheckers/provider/room_data_provider.dart';
import 'package:ourcheckers/screens/create_room_screen.dart';
import 'package:ourcheckers/screens/game_screen.dart';
import 'package:ourcheckers/screens/join_room_screen.dart';
import 'package:ourcheckers/screens/main_menu_screen.dart';
import 'package:ourcheckers/screens/singleplayer_screen.dart';
import 'package:ourcheckers/utils/colors.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RoomDataProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OurCheckers',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
        ),
        routes: {
          MainMenuScreen.routeName: (context) => const MainMenuScreen(),
          JoinRoomScreen.routeName: (context) => const JoinRoomScreen(),
          CreateRoomScreen.routeName: (context) => const CreateRoomScreen(),
          GameScreen.routeName: (context) => const GameScreen(),
          SinglePlayerScreen.routeName: (context) => const SinglePlayerScreen(),
        },
        initialRoute: MainMenuScreen.routeName,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:ourcheckers/responsive/responsive.dart';
import 'package:ourcheckers/screens/create_room_screen.dart';
import 'package:ourcheckers/screens/game_screen.dart';
import 'package:ourcheckers/screens/join_room_screen.dart';
import 'package:ourcheckers/screens/setting_screen.dart';
import 'package:ourcheckers/screens/singleplayer_screen.dart';
import 'package:ourcheckers/widgets/custom_button.dart';

class MainMenuScreen extends StatelessWidget{
  static String routeName = '/main-menu';
  const MainMenuScreen({Key? key}) : super(key: key);

  void gameRoom(BuildContext context){
    Navigator.pushNamed(context, SinglePlayerScreen.routeName);
  }

  void createRoom(BuildContext context){
    Navigator.pushNamed(context, CreateRoomScreen.routeName);
  }

  void joinRoom(BuildContext context){
    Navigator.pushNamed(context, JoinRoomScreen.routeName);
  }

  void settingScreen(BuildContext context){
    Navigator.pushNamed(context, SettingScreen.routeName);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Responsive(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomButton(onTap: () => gameRoom(context), text: 'SinglePlayer'),
          const SizedBox(height: 20,),
          CustomButton(onTap: () => createRoom(context), text: 'Create Room'),
          const SizedBox(height: 20,),
          CustomButton(onTap: () => joinRoom(context), text: 'Join Room'),
          const SizedBox(height: 20,),
          CustomButton(onTap: () => settingScreen(context), text: 'Settings')
        ],),),
    );
  }
}


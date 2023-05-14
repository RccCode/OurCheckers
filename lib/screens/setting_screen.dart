import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';


class SettingScreen extends StatefulWidget {
  static String routeName = '/setting';
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>{

  bool Themetoggle = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Basic Settings'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
              title: Text('Language'),
              value: Text('English'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    Themetoggle = value;
                  });
                },
                initialValue: true,
                leading: Icon(Icons.format_paint), 
                title: Text('Enable custom theme'))
            ],
          ),
        ],
      ),
    );
  }
}
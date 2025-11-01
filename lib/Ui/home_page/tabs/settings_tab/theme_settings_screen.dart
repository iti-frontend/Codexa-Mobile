import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:codexa_mobile/Ui/utils/provider_ui/theme_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Theme Settings',
          style: TextStyle(color: theme.iconTheme.color),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.iconTheme,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dark Theme',
              style: TextStyle(
                fontSize: 18,
                color: theme.iconTheme.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch(
              value: themeProvider.currentTheme == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.changeThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.greenAccent,
              inactiveThumbColor: theme.iconTheme.color?.withValues(alpha: 0.8),
              inactiveTrackColor: theme.dividerColor.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

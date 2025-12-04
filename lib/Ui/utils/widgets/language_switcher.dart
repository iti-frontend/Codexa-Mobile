import 'package:codexa_mobile/Ui/home_page/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../../localization/localization_service.dart';

class LanguageSwitcherDialog extends StatelessWidget {
  const LanguageSwitcherDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).language),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Text('🇺🇸'),
            title: const Text('English'),
            onTap: () => _changeLanguage(context, 'en'),
          ),
          ListTile(
            leading: const Text('🇸🇦'),
            title: const Text('العربية'),
            onTap: () => _changeLanguage(context, 'ar'),
          ),
        ],
      ),
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) async {
    await LocalizationService.changeLanguage(languageCode);
    Navigator.of(context).pop();
    // Restart app or refresh UI
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }
}

// Language switcher in settings
class LanguageSwitcherTile extends StatelessWidget {
  const LanguageSwitcherTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(S.of(context).language),
      subtitle: Text(LocalizationService.isRTL() ? 'العربية' : 'English'),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const LanguageSwitcherDialog(),
        );
      },
    );
  }
}

import 'package:codexa_mobile/Ui/home_page/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../generated/l10n.dart';
import '../../../localization/localization_service.dart';

class LanguageSwitcherDialog extends StatelessWidget {
  const LanguageSwitcherDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);

    return AlertDialog(
      title: Text(S.of(context).language),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Text('🇺🇸'),
            title: const Text('English'),
            onTap: () => _changeLanguage(context, 'en', localizationService),
          ),
          ListTile(
            leading: const Text('🇸🇦'),
            title: const Text('العربية'),
            onTap: () => _changeLanguage(context, 'ar', localizationService),
          ),
        ],
      ),
    );
  }

  void _changeLanguage(BuildContext context, String languageCode, LocalizationService localizationService) async {
    await localizationService.changeLanguage(languageCode);
    Navigator.of(context).pop();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(languageCode == 'en'
            ? 'Language changed to English'
            : 'تم تغيير اللغة إلى العربية'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to home to apply changes
    Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
            (route) => false
    );
  }
}

// Language switcher in settings
class LanguageSwitcherTile extends StatelessWidget {
  const LanguageSwitcherTile({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(S.of(context).language),
      subtitle: Text(localizationService.isRTL() ? 'العربية' : 'English'),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const LanguageSwitcherDialog(),
        );
      },
    );
  }
}
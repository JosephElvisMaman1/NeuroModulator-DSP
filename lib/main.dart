import 'package:flutter/material.dart';
import 'ui/screens/modulator_dashboard.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NeuroModulatorApp());
}

class NeuroModulatorApp extends StatelessWidget {
  const NeuroModulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neuro-DSP Modulador de Audio Inteligente',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.slate950,
        primaryColor: AppColors.cyan500,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.cyan500,
          secondary: AppColors.violet500,
          surface: AppColors.slate900,
        ),
      ),
      home: const ModulatorDashboard(),
    );
  }
}

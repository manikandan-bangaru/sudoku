import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/services/localization_manager.dart';

import 'utils/game_routes.dart';
import 'utils/game_sizes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
  await EasyLocalization.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    EasyLocalization(
      path: LocalizationManager.path,
      fallbackLocale: LocalizationManager.fallbackLocale,
      supportedLocales: LocalizationManager.supportedLocales,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    GameSizes.init(context);

    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true,
        segmentedButtonTheme: const SegmentedButtonThemeData(
          selectedIcon: SizedBox.shrink(), // Hide tick mark
        ),
    ),
      navigatorKey: GameRoutes.navigatorKey,
      onGenerateRoute: GameRoutes.generateRoute,
      initialRoute: GameRoutes.navigationBar,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}

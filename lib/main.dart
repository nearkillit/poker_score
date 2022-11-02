import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:todo/pokerUser.dart';
import 'package:todo/provider/userProvider.dart';

import 'generated/l10n.dart';
import 'utils/custom_color.dart';

void main() {
// void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  LicenseRegistry.addLicense(() async* {
    // https://qiita.com/kaleidot725/items/938e6c8d597e7aa427fd
    // assetsで使うにはpubspecで登録が必要
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<PokerUserProvider>(
            create: (context) => PokerUserProvider(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          // ← ここです
          title: 'Poker',
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          supportedLocales: S.delegate.supportedLocales,
          theme: ThemeData(
            primarySwatch: pokerTableCorkColor,
            // https://zenn.dev/susatthi/articles/20220419-143426-flutter-custom-fonts
            fontFamily: 'KaiseiTokumin',
            scaffoldBackgroundColor: pokerTableColor,
            // textTheme: GoogleFonts.kaiseiTokuminTextTheme()
          ),
          home: PokerUser(),
        ));
  }
}

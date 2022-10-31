// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Setting`
  String get setting {
    return Intl.message(
      'Setting',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  /// `Participant`
  String get member {
    return Intl.message(
      'Participant',
      name: 'member',
      desc: '',
      args: [],
    );
  }

  /// `Mode`
  String get mode {
    return Intl.message(
      'Mode',
      name: 'mode',
      desc: '',
      args: [],
    );
  }

  /// `Round`
  String get mode_r {
    return Intl.message(
      'Round',
      name: 'mode_r',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get mode_s {
    return Intl.message(
      'Score',
      name: 'mode_s',
      desc: '',
      args: [],
    );
  }

  /// `Record the following`
  String get mode_explain {
    return Intl.message(
      'Record the following',
      name: 'mode_explain',
      desc: '',
      args: [],
    );
  }

  /// `・chips`
  String get mode_explain_s_1 {
    return Intl.message(
      '・chips',
      name: 'mode_explain_s_1',
      desc: '',
      args: [],
    );
  }

  /// `・Action in each round`
  String get mode_explain_r_1 {
    return Intl.message(
      '・Action in each round',
      name: 'mode_explain_r_1',
      desc: '',
      args: [],
    );
  }

  /// `・Chip Fluctuations in each round`
  String get mode_explain_r_2 {
    return Intl.message(
      '・Chip Fluctuations in each round',
      name: 'mode_explain_r_2',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Chips`
  String get chips {
    return Intl.message(
      'Chips',
      name: 'chips',
      desc: '',
      args: [],
    );
  }

  /// `Initial Chips`
  String get init_chip {
    return Intl.message(
      'Initial Chips',
      name: 'init_chip',
      desc: '',
      args: [],
    );
  }

  /// `Small Blind`
  String get sb {
    return Intl.message(
      'Small Blind',
      name: 'sb',
      desc: '',
      args: [],
    );
  }

  /// `For 4-10 people`
  String get for_people {
    return Intl.message(
      'For 4-10 people',
      name: 'for_people',
      desc: '',
      args: [],
    );
  }

  /// `Additional User`
  String get add_member {
    return Intl.message(
      'Additional User',
      name: 'add_member',
      desc: '',
      args: [],
    );
  }

  /// `Delete User`
  String get delete_user {
    return Intl.message(
      'Delete User',
      name: 'delete_user',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete the following user?`
  String get delete_user_confirm {
    return Intl.message(
      'Are you sure you want to delete the following user?',
      name: 'delete_user_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message(
      'Start',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `Result`
  String get result {
    return Intl.message(
      'Result',
      name: 'result',
      desc: '',
      args: [],
    );
  }

  /// `Sum`
  String get sum {
    return Intl.message(
      'Sum',
      name: 'sum',
      desc: '',
      args: [],
    );
  }

  /// `Allotment`
  String get allotment {
    return Intl.message(
      'Allotment',
      name: 'allotment',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get score {
    return Intl.message(
      'Score',
      name: 'score',
      desc: '',
      args: [],
    );
  }

  /// `Tap the user`
  String get score_explain {
    return Intl.message(
      'Tap the user',
      name: 'score_explain',
      desc: '',
      args: [],
    );
  }

  /// `action`
  String get action {
    return Intl.message(
      'action',
      name: 'action',
      desc: '',
      args: [],
    );
  }

  /// `round`
  String get round {
    return Intl.message(
      'round',
      name: 'round',
      desc: '',
      args: [],
    );
  }

  /// `current`
  String get current_of {
    return Intl.message(
      'current',
      name: 'current_of',
      desc: '',
      args: [],
    );
  }

  /// `'s turn`
  String get who_turn {
    return Intl.message(
      '\'s turn',
      name: 'who_turn',
      desc: '',
      args: [],
    );
  }

  /// `raise`
  String get raise {
    return Intl.message(
      'raise',
      name: 'raise',
      desc: '',
      args: [],
    );
  }

  /// `check`
  String get check {
    return Intl.message(
      'check',
      name: 'check',
      desc: '',
      args: [],
    );
  }

  /// `fold`
  String get fold {
    return Intl.message(
      'fold',
      name: 'fold',
      desc: '',
      args: [],
    );
  }

  /// `Who's the winner?`
  String get who_win {
    return Intl.message(
      'Who\'s the winner?',
      name: 'who_win',
      desc: '',
      args: [],
    );
  }

  /// `Please enter`
  String get please_enter {
    return Intl.message(
      'Please enter',
      name: 'please_enter',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a number`
  String get please_enter_a_number {
    return Intl.message(
      'Please enter a number',
      name: 'please_enter_a_number',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a number greater than`
  String get please_enter_gre_than {
    return Intl.message(
      'Please enter a number greater than',
      name: 'please_enter_gre_than',
      desc: '',
      args: [],
    );
  }

  /// `Please enter bet amount`
  String get please_enter_bet {
    return Intl.message(
      'Please enter bet amount',
      name: 'please_enter_bet',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ja'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

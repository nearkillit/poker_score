import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Color positionColor(String pos) {
  if (pos == 'D') {
    return Colors.deepOrange;
  } else if (pos == 'BB') {
    return Colors.green;
  } else if (pos == 'SB') {
    return Colors.greenAccent;
  } else {
    return const Color(0x00ffffff);
  }
}

// https://zenn.dev/pressedkonbu/books/flutter-reverse-lookup-dictionary/viewer/004-string-to-enum
/// ユーザーのポジション
/// D = ディーラー
/// BB = ビッグブラインド
/// SB = スモールブラインド
/// gen = 何もなし
enum PokerUserDataPosition { D, BB, SB, gen }

/// ユーザーのアクション
/// none = 初期状態
/// FOLD = フォールド
/// RAISE = レイズ
/// CHECK = チェック
/// CALL = コール
enum PokerUserDataAction { none, FOLD, RAISE, CHECK, CALL }

class PokerUserData {
  int chip;
  String name;
  PokerUserDataPosition position;

  PokerUserData({
    required this.chip,
    required this.name,
    required this.position,
  });
}

class PokerUserChipData extends PokerUserData {
  int r0;
  int r1;
  int r2;
  int r3;
  PokerUserDataAction action;

  PokerUserChipData({
    required this.r0,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.action,
    required super.chip,
    required super.name,
    required super.position,
  });
}

final clearPokerUserChipData = PokerUserChipData(
  name: '',
  chip: 0,
  position: PokerUserDataPosition.values.byName('gen'),
  action: PokerUserDataAction.values.byName('none'),
  r0: 0,
  r1: 0,
  r2: 0,
  r3: 0,
);

final List<PokerUserChipData> initPokerUserChipDataList = [
  PokerUserChipData(
    name: 'List0',
    chip: 100,
    position: PokerUserDataPosition.values.byName('gen'),
    action: PokerUserDataAction.values.byName('none'),
    r0: 0,
    r1: 0,
    r2: 0,
    r3: 0,
  ),
  PokerUserChipData(
    name: 'List1',
    chip: 100,
    position: PokerUserDataPosition.values.byName('gen'),
    action: PokerUserDataAction.values.byName('none'),
    r0: 0,
    r1: 0,
    r2: 0,
    r3: 0,
  ),
  PokerUserChipData(
    name: 'List2',
    chip: 100,
    position: PokerUserDataPosition.values.byName('gen'),
    action: PokerUserDataAction.values.byName('none'),
    r0: 0,
    r1: 0,
    r2: 0,
    r3: 0,
  ),
  PokerUserChipData(
    name: 'List3',
    chip: 100,
    position: PokerUserDataPosition.values.byName('gen'),
    action: PokerUserDataAction.values.byName('none'),
    r0: 0,
    r1: 0,
    r2: 0,
    r3: 0,
  ),
];

class PokerUserProvider with ChangeNotifier {
  /// 今回状態管理をする変数
  List<PokerUserChipData> pokerUserChipDataList = [
    ...initPokerUserChipDataList
  ];

  //// 簡単用
  /// 初期所持チップ
  int initialChip = 100;

  /// 現在選択されているユーザーのindex
  int selectUserIndex = -1;

  //// 詳細用
  /// 履歴
  List<List<PokerUserChipData>> pokerUserChipDataListHistory = [];

  /// ターン中のユーザー
  int turnUserIndex = 0;

  /// turnUserIndexの起点となるindex
  int originUserIndex = 0;

  /// 現在のポジションの位置
  int userPositionIndex = 0;

  /// ラウンド数 まだ始まっていない場合は-1
  /// ゲームが終わったら4
  int roundNumber = -1;

  /// 初期費用
  int initialCost = 10;

  /// 今賭けられている額
  int nowBet = 20;

  /// test用
  void initial() {
    // https://qiita.com/kasa_le/items/fc5379ba15e6193f37f8
    // List.of(arr) == [...arr]
    pokerUserChipDataList = [...initPokerUserChipDataList];
    turnUserIndex = 0;
    originUserIndex = 0;
    userPositionIndex = 0;
    roundNumber = -1;
    initialCost = 10;
    nowBet = 20;
    initialChip = 100;
    initPosition();
    notifyListeners();
  }

  /// 状態を変化させる処理
  /// リストへ追加
  void addList(PokerUserChipData pokerUserChipData) {
    pokerUserChipDataList.add(pokerUserChipData);
    notifyListeners();
  }

  /// リストの更新
  void updateList(PokerUserChipData pokerUserChipData, int index) {
    pokerUserChipDataList = pokerUserChipDataList.asMap().entries.map((entry) {
      int i = entry.key;
      PokerUserChipData user = entry.value;
      return i == index ? pokerUserChipData : user;
    }).toList();
    notifyListeners();
  }

  /// リストの削除
  void deleteList(int index) {
    pokerUserChipDataList.removeAt(index);
    notifyListeners();
  }

  /// リストの入れ替え
  void replaceList(List<PokerUserChipData> pokerUserChipDataL) {
    pokerUserChipDataList = pokerUserChipDataL;
    notifyListeners();
  }

  /// 履歴の追加
  void addHistory() {
    pokerUserChipDataListHistory.add(pokerUserChipDataList);
    notifyListeners();
  }

  /// positionの初期化とコストのセット
  void initGame() {
    /// turnUserIndexを0に
    turnUserIndex = 0;
    pokerUserChipDataList = pokerUserChipDataList.asMap().entries.map((entry) {
      int i = entry.key;
      PokerUserChipData user = entry.value;

      /// 左上をSBに
      if (i == 0) {
        user.position = PokerUserDataPosition.values.byName('SB');
        user.r0 = initialCost;
      }

      /// 次をBBに
      else if (i == 1) {
        user.position = PokerUserDataPosition.values.byName('BB');
        user.r0 = initialCost * 2;
      }

      /// 最後をDに
      else if (i == pokerUserChipDataList.length - 1) {
        user.position = PokerUserDataPosition.values.byName('D');
        user.r0 = 0;
      }

      /// 何も役職がない場合
      else {
        user.position = PokerUserDataPosition.values.byName('gen');
        user.r0 = 0;
      }

      user.action = PokerUserDataAction.values.byName('none');
      user.r1 = 0;
      user.r2 = 0;
      user.r3 = 0;

      return user;
    }).toList();
    notifyListeners();
  }

  /// positionの初期化
  void initPosition() {
    /// turnUserIndexを0に
    turnUserIndex = 0;
    pokerUserChipDataList = pokerUserChipDataList.asMap().entries.map((entry) {
      int i = entry.key;
      PokerUserChipData user = entry.value;

      /// 左上をSBに
      if (i == 0) {
        user.position = PokerUserDataPosition.values.byName('SB');
      }

      /// 次をBBに
      else if (i == 1) {
        user.position = PokerUserDataPosition.values.byName('BB');
      }

      /// 最後をDに
      else if (i == pokerUserChipDataList.length - 1) {
        user.position = PokerUserDataPosition.values.byName('D');
      }

      return user;
    }).toList();
    notifyListeners();
  }

  /// turnUserIndexを1つ次へ
  void nextTurnUserIndex() {
    turnUserIndex++;

    /// もしturnUserIndexが最後だったら、0に戻す
    /// そしてroundNumberを1つ進める
    if (turnUserIndex >= pokerUserChipDataList.length) {
      turnUserIndex = 0;
    }

    /// ユーザーが１周したら次のラウンドへ行く
    if (turnUserIndex == originUserIndex) {
      nextRound();
    }

    /// もし次のユーザーがフォールドしていた場合は、さらにその次へすすむ
    if (pokerUserChipDataList[turnUserIndex].action ==
        PokerUserDataAction.values.byName('FOLD')) {
      nextTurnUserIndex();
    }

    notifyListeners();
  }

  /// originUserIndexを1つ次へ
  void nextOriginUserIndex() {
    originUserIndex = nextIndexCalc(originUserIndex, 1);
    notifyListeners();
  }

  /// positionを1つ次へ
  void nextPosition() {
    userPositionIndex++;

    /// そしてroundNumberを1つ進める
    if (userPositionIndex >= pokerUserChipDataList.length) {
      userPositionIndex = 0;
    }

    pokerUserChipDataList = pokerUserChipDataList.asMap().entries.map((entry) {
      int i = entry.key;
      PokerUserChipData user = entry.value;
      PokerUserDataPosition position =
          PokerUserDataPosition.values.byName('gen');

      /// 時計回りの場合のindex
      if (i == userPositionIndex) {
        position = PokerUserDataPosition.values.byName('SB');
      } else if (i == nextIndexCalc(userPositionIndex, 1)) {
        position = PokerUserDataPosition.values.byName('BB');
      }

      /// 最後−１をDにする
      else if (i ==
          nextIndexCalc(userPositionIndex, pokerUserChipDataList.length - 1)) {
        position = PokerUserDataPosition.values.byName('D');
      }

      return PokerUserChipData(
          r0: 0,
          r1: user.r1,
          r2: user.r2,
          r3: user.r3,
          chip: user.chip,
          name: user.name,
          action: user.action,
          position: position);
    }).toList();
    notifyListeners();
  }

  /// roundNumberを1つ次へ
  void nextRound() {
    if (roundNumber > 3) {
      roundNumber = 0;
    } else {
      roundNumber++;
    }
    notifyListeners();
  }

  /// 次のゲームへ
  void nextGame() {
    /// 次のポジションへ
    nextPosition();

    /// 初期値のセット
    initialNextAllGameStatus();
    notifyListeners();
  }

  /// 次のポジションのindexの繰上げの計算、
  /// ユーザーが5人、ターンが4人目だった場合、BBは1人目になるので
  /// index=5の場合、0を返す
  int nextIndexCalc(int originIndex, int addIndex) {
    int returnIndex = originIndex + addIndex;

    if (returnIndex >= pokerUserChipDataList.length) {
      returnIndex -= pokerUserChipDataList.length;
    }
    return returnIndex;
  }

  /// BET金額確定
  void decisionBET() {
    pokerUserChipDataList = pokerUserChipDataList
      ..map((user) {
        int nb = nowBET(user);
        user.chip -= nb;
        return user;
      }).toList();
  }

  /// statusを初期化ゲーム始めた時に使う
  void initialNextAllGameStatus() {
    roundNumber = 0;
    nowBet = initialCost * 2;
    pokerUserChipDataList = pokerUserChipDataList
      ..map((user) {
        user.action = PokerUserDataAction.values.byName('none');
        user.r0 = 0;

        /// ユーザーがSBの場合
        if (user.position == PokerUserDataPosition.values.byName('SB')) {
          user.r0 = initialCost;
        }

        /// ユーザーがBBの場合
        else if (user.position == PokerUserDataPosition.values.byName('BB')) {
          user.r0 = initialCost * 2;
        }

        /// ユーザーが何の役でもない場合
        else {
          user.r0 = 0;
        }
        user.r1 = 0;
        user.r2 = 0;
        user.r3 = 0;
        return user;
      }).toList();
    nextOriginUserIndex();
    turnUserIndex = originUserIndex;
    notifyListeners();
  }

  /// 勝者が確定した時のBET金額の配分
  void distributionBETToWinner(List<int> winIndexs) {
    /// 勝者の数
    int winNumber = winIndexs.length;

    /// BETの合計値
    int sumBET = nowSumBET();

    /// 勝者へ渡される金額
    int winBET = sumBET ~/ winNumber;

    /// BETの合計値を勝者数で割ってでた余り（１未満の場合は０）
    int winBETRemainder = ((sumBET % winNumber) * winNumber) ~/ 1;

    pokerUserChipDataList = pokerUserChipDataList.asMap().entries.map((entry) {
      int i = entry.key;
      PokerUserChipData user = entry.value;

      /// 勝者だったら
      if (winIndexs.contains(i)) {
        user.chip += winBET;

        /// 勝者1人目だったらあまりの金額を足す
        if (i == winIndexs[0]) {
          user.chip += winBETRemainder;
        }
      }
      return user;
    }).toList();
    notifyListeners();
  }

  /// 現在選択されているユーザーを返す
  PokerUserChipData selectUser() {
    return selectUserIndex > -1
        ? pokerUserChipDataList[selectUserIndex]
        : clearPokerUserChipData;
  }

  /// selectUserIndexで指定されるユーザーに金額を足す
  void updateChipToSelectUser(int chip) {
    if (selectUserIndex > -1) {
      pokerUserChipDataList[selectUserIndex].chip = chip;
      notifyListeners();
    }
  }

  //// setter
  void setSelectUserIndex(int index) {
    selectUserIndex = index;
    notifyListeners();
  }

  void setRoundNumber(int number) {
    roundNumber = number;
    notifyListeners();
  }

  void setInitialChip(int chip) {
    initialChip = chip;
    notifyListeners();
  }

  void setInitialCost(int cost) {
    initialCost = cost;
    notifyListeners();
  }

  void setNowBet(int bet) {
    nowBet = bet;
    notifyListeners();
  }

  /// originUserIndexに現在のユーザーをセット
  void setNowUserIndexToOriginUserIndex() {
    originUserIndex = turnUserIndex;
    notifyListeners();
  }

  /// Rのセッター
  /// chip = 更新する金額
  void betRound(int chip) {
    pokerUserChipDataList = pokerUserChipDataList.asMap().entries.map((entry) {
      int i = entry.key;
      PokerUserChipData user = entry.value;

      /// ラウンドの金額の確定
      /// 所持金を減らす
      if (i == turnUserIndex) {
        if (roundNumber == 0) {
          user.r0 = chip;
        } else if (roundNumber == 1) {
          user.r1 = chip;
        } else if (roundNumber == 2) {
          user.r2 = chip;
        } else if (roundNumber == 3) {
          user.r3 = chip;
        }
      }

      return user;
    }).toList();
    notifyListeners();
  }

  //// 計算用
  /// あるユーザーが現時点でBETしている金額
  int nowBET(PokerUserChipData pokerUserChipData) {
    if (pokerUserChipData.r3 != 0) return pokerUserChipData.r3;
    if (pokerUserChipData.r2 != 0) return pokerUserChipData.r2;
    if (pokerUserChipData.r1 != 0) return pokerUserChipData.r1;
    return pokerUserChipData.r0;
  }

  /// 現在の全ユーザーのBETの合計
  int nowSumBET() {
    int nowSumBET = 0;
    // https://qiita.com/i88_arakawa/items/dc19fec58312ae09e7e7
    for (var element in pokerUserChipDataList) {
      nowSumBET += nowBET(element);
    }
    return nowSumBET;
  }

  //// action
  /// チェック
  void doCHECK() {
    /// CHECKした金額を現在のラウンドにセット
    betRound(nowBet);

    /// 次のユーザーへ
    nextTurnUserIndex();
    notifyListeners();
  }

  /// フォールド
  void doFOLD() {
    PokerUserChipData pokerUserChipData = pokerUserChipDataList[turnUserIndex];
    pokerUserChipData.action = PokerUserDataAction.values.byName('FOLD');

    /// ユーザーのアクションをFOLDに変更してリストを更新
    updateList(pokerUserChipData, turnUserIndex);

    /// 次のユーザーへ
    nextTurnUserIndex();

    /// ユーザーが1人になった場合勝利処理
    int _onlyOneNotFoldUserIndex = onlyOneNotFoldUserIndex();
    if (_onlyOneNotFoldUserIndex > -1) {
      win([_onlyOneNotFoldUserIndex]);
    }
    notifyListeners();
  }

  /// 1人以外全員FOLDしている状態か、その状態の場合そのユーザーのインデックスを返す、いない場合は-1
  int onlyOneNotFoldUserIndex() {
    int pokerUserChipDataListFoldNumber = 0;
    int pokerUserChipDataListNotFoldIndex = -1;
    pokerUserChipDataList.asMap().entries.forEach((entry) {
      int i = entry.key;
      PokerUserChipData user = entry.value;
      if (user.action == PokerUserDataAction.values.byName('FOLD')) {
        pokerUserChipDataListFoldNumber += 1;
      } else {
        pokerUserChipDataListNotFoldIndex = i;
      }
    });

    /// 2人以上FOLDではないユーザーが存在する場合
    if (pokerUserChipDataListFoldNumber + 1 != pokerUserChipDataList.length) {
      pokerUserChipDataListNotFoldIndex = -1;
    }

    return pokerUserChipDataListNotFoldIndex;
  }

  /// レイズ
  void doRAISE(int betNumber) {
    /// 周回の起点をレイズした人から
    setNowUserIndexToOriginUserIndex();

    /// RAISEした金額のセット
    setNowBet(betNumber);

    /// RAISEした金額を現在のラウンドにセット
    betRound(betNumber);

    /// ユーザーのターンを進める処理
    nextTurnUserIndex();
    notifyListeners();
  }

  /// 勝者が確定した時の動き
  void win(List<int> winIndexs) {
    /// 支払い金額の確定、計算
    decisionBET();

    /// 金額の分配
    distributionBETToWinner(winIndexs);

    /// 履歴の更新
    addHistory();

    /// 次のゲームへ
    nextGame();
    notifyListeners();
  }
}

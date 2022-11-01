import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo/provider/userProvider.dart';
import 'package:todo/utils/circle_painter.dart';
import 'package:todo/utils/table_widget.dart';
import 'package:todo/utils/title_widget.dart';

import 'generated/l10n.dart';
import 'utils/custom_color.dart';

/// BET金額の計算
String dispBET(int r0, int r1, int r2, int r3) {
  if (r3 != 0) return r3.toString();
  if (r2 != 0) return r2.toString();
  if (r1 != 0) return r1.toString();
  return r0.toString();
}

class PokerScore extends StatefulWidget {
  const PokerScore({Key? key}) : super(key: key);

  @override
  PokerScoreState createState() => PokerScoreState();
}

class PokerScoreState extends State<PokerScore> {
  @override
  Widget build(BuildContext context) {
    final PokerUserProvider pokerUserProvider =
        Provider.of<PokerUserProvider>(context, listen: true);
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).score)),
        body: SingleChildScrollView(
            //追加
            child: Column(
                mainAxisSize: MainAxisSize.min,
                //   // https://www.flutter-study.dev/widgets/column-row-widget
                //   mainAxisAlignment: MainAxisAlignment.center,
                children: pokerUserProvider.pokerUserChipDataList.isNotEmpty
                    ? <Widget>[
                        const PokerResultWidget(),
                        const PokerUserSeatWidget(),
                        PokerUserActionWidget(),
                      ]
                    : [])));
  }
}

/// ユーザーの座席表
class PokerUserSeatWidget extends StatefulWidget {
  const PokerUserSeatWidget({Key? key}) : super(key: key);

  @override
  State<PokerUserSeatWidget> createState() => _PokerUserSeatWidgetState();
}

class _PokerUserSeatWidgetState extends State<PokerUserSeatWidget> {
  /// ユーザーの位置
  Align userPosition(PokerUserChipData pUD, int index, int maxLength,
      int selectUserIndex, Function onTap) {
    /// maxIndexを２で割って小数点切り捨てした値
    int maxLengthDiv2 = maxLength ~/ 2;

    /// 配置するX軸の値
    double alignX = 0;

    /// -1 ~ 1 をmaxIndex等分してindexの位置を算出
    /// indexがmaxIndexの半分より小さい　⇨　机より上の表示
    if (maxLengthDiv2 > index) {
      /// 右端のポジションの場合
      if (maxLengthDiv2 == (index + 1)) {
        alignX = 1;
      } else {
        alignX = 2 / (maxLengthDiv2 - 1) * index - 1;
      }
    }

    /// indexがmaxIndexの半分より大きい　⇨　机より下の表示
    else {
      /// 右端のポジションの場合
      if (maxLengthDiv2 == index) {
        alignX = 1;
      } else {
        alignX =
            1 - 2 / (maxLength - maxLengthDiv2 - 1) * (index - maxLengthDiv2);
      }
    }

    /// ユーザーの表示
    PokerUserSmartCircleWidget pokerUserCircleWidget() {
      return PokerUserSmartCircleWidget(
          pokerUserData: pUD, onTap: onTap, isStrong: selectUserIndex == index);
    }

    /// ここのturnUserIndexが変わらない！！！
    // https://zenn.dev/pressedkonbu/articles/stack-and-align
    Align setAlign =
        Align(alignment: Alignment(alignX, 0), child: pokerUserCircleWidget());

    return setAlign;
  }

  /// 座席表
  List<Widget> userSeat(PokerUserProvider pokerUserProvider) {
    /// ユーザーのwidget
    List<Widget> newUserSeat =
        pokerUserProvider.pokerUserChipDataList.asMap().entries.map((entry) {
      int index = entry.key;
      PokerUserChipData user = entry.value;
      void onTap() {
        pokerUserProvider.setSelectUserIndex(index);
      }

      return Container(
          child: userPosition(
              user,
              index,
              pokerUserProvider.pokerUserChipDataList.length,
              pokerUserProvider.selectUserIndex,
              onTap));
    }).toList();

    /// 机
    Widget desk = Container(
        // padding: const EdgeInsets.all(5.0),
        height: 100,
        width: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black45),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(S.of(context).score_explain)));

    /// ユーザー数を２で割って小数点切り捨てした値
    int userDataDiv2 = newUserSeat.length ~/ 2;

    /// ユーザーの数が奇数の場合、ユーザー数を机の下を奇数、上を偶数にする
    /// テーブルと座席のwidget
    List<Widget> newSeat = [
      // https://flutter.ctrnost.com/basic/layout/stack/
      Stack(
        children: newUserSeat.sublist(0, userDataDiv2),
      ),
      Container(child: desk),
      Stack(
        children: newUserSeat.sublist(userDataDiv2, newUserSeat.length),
      ),
    ];

    return newSeat;
  }

  @override
  Widget build(BuildContext context) {
    final PokerUserProvider pokerUserProvider =
        Provider.of<PokerUserProvider>(context, listen: true);
    return Column(
      children: [
        TitleWidget(
          title: S.of(context).score,
        ),
        ...userSeat(pokerUserProvider)
      ],
    );
  }
}

/// アクション
class PokerUserActionWidget extends StatefulWidget {
  @override
  State<PokerUserActionWidget> createState() => _PokerUserActionWidgetState();
}

class _PokerUserActionWidgetState extends State<PokerUserActionWidget> {
  int nowBet = 0;
  final _formKey = GlobalKey<FormState>();

  // https://qiita.com/superman9387/items/a7206f72f1b1917c6117
  final _editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final PokerUserProvider pokerUserProvider =
        Provider.of<PokerUserProvider>(context, listen: true);
    PokerUserChipData user = pokerUserProvider.selectUser();

    _editController.text = "${user.chip}";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${user.name}",
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 32.0, color: Colors.black),
        ),
        Row(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          // initialValue: '${user.chip}',
                          controller: _editController,
                          maxLength: 7,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 46.0,
                              color: Colors.black),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return S.of(context).please_enter;
                            } else if (double.tryParse(value) == null) {
                              return S.of(context).please_enter_a_number;
                            } else {
                              int parseValue = int.parse(value);
                              if (parseValue <= pokerUserProvider.nowBet) {
                                return '${S.of(context).please_enter_gre_than} ${pokerUserProvider.nowBet}';
                              }
                            }
                            return null;
                          },
                          onChanged: (e) {
                            /// 数値判定
                            if (double.tryParse(e) != null) {
                              pokerUserProvider
                                  .updateChipToSelectUser(int.parse(e));
                            }
                          },
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(
                                fontSize: 26.0, color: Colors.black),
                            labelText: S.of(context).chips,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: 50,
                                  height: 30,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        // https://www.fluttercampus.com/guide/300/set-margin-elevated-button/
                                        // paddingを手動で設定すると自動じゃなくなる
                                        padding: const EdgeInsets.all(1),
                                        primary: Colors.red,
                                        onPrimary: Colors.white,
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                    onPressed: () {
                                      pokerUserProvider.updateChipToSelectUser(
                                          user.chip +
                                              pokerUserProvider.initialCost);
                                    },
                                    child: Text(
                                        '+${pokerUserProvider.initialCost}'),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: 50,
                                  height: 30,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(1),
                                        primary: Colors.red,
                                        onPrimary: Colors.white,
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    onPressed: () {
                                      pokerUserProvider.updateChipToSelectUser(
                                          user.chip +
                                              pokerUserProvider.initialCost *
                                                  2);
                                    },
                                    child: Text(
                                        '+${pokerUserProvider.initialCost * 2}'),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: 60,
                                  height: 30,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(1),
                                        primary: Colors.red,
                                        onPrimary: Colors.white,
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    onPressed: () {
                                      pokerUserProvider.updateChipToSelectUser(
                                          user.chip +
                                              pokerUserProvider.initialCost *
                                                  10);
                                    },
                                    child: Text(
                                        '+${pokerUserProvider.initialCost * 10}'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: 50,
                                  height: 30,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        // https://www.fluttercampus.com/guide/300/set-margin-elevated-button/
                                        // paddingを手動で設定すると自動じゃなくなる
                                        padding: const EdgeInsets.all(1),
                                        primary: Colors.black,
                                        onPrimary: Colors.white,
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                    onPressed: () {
                                      pokerUserProvider.updateChipToSelectUser(
                                          user.chip -
                                              pokerUserProvider.initialCost);
                                    },
                                    child: Text(
                                        '-${pokerUserProvider.initialCost}'),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: 50,
                                  height: 30,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(1),
                                        primary: Colors.black,
                                        onPrimary: Colors.white,
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    onPressed: () {
                                      pokerUserProvider.updateChipToSelectUser(
                                          user.chip -
                                              pokerUserProvider.initialCost *
                                                  2);
                                    },
                                    child: Text(
                                        '-${pokerUserProvider.initialCost * 2}'),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: 60,
                                  height: 30,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(1),
                                        primary: Colors.black,
                                        onPrimary: Colors.white,
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    onPressed: () {
                                      pokerUserProvider.updateChipToSelectUser(
                                          user.chip -
                                              pokerUserProvider.initialCost *
                                                  10);
                                    },
                                    child: Text(
                                        '-${pokerUserProvider.initialCost * 10}'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 結果
class PokerResultWidget extends StatefulWidget {
  const PokerResultWidget({Key? key}) : super(key: key);

  @override
  State<PokerResultWidget> createState() => _PokerResultWidgetState();
}

class _PokerResultWidgetState extends State<PokerResultWidget> {
  @override
  Widget build(BuildContext context) {
    final PokerUserProvider pokerUserProvider =
        Provider.of<PokerUserProvider>(context, listen: true);

    int sumDiffChip = (pokerUserProvider.pokerUserChipDataList
            .fold<int>(0, (value, element) => value + element.chip) -
        pokerUserProvider.initialChip *
            pokerUserProvider.pokerUserChipDataList.length);

    return Column(
      children: [
        TitleWidget(title: S.of(context).result),
        Table(
          border: TableBorder.all(color: const Color(0x00ffffff), width: 2),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(0.9),
            1: FlexColumnWidth(0.6),
            2: FlexColumnWidth(1.2),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: [
            TableRow(children: [
              TableHeaderWidget(
                headerWidget: Text(
                  S.of(context).name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              TableHeaderWidget(
                headerWidget: Text(
                  S.of(context).chips,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              TableHeaderWidget(
                headerWidget: Text(
                  '${S.of(context).chips} - ${S.of(context).init_chip}(${pokerUserProvider.initialChip})',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ]),
            ...pokerUserProvider.pokerUserChipDataList
                .asMap()
                .entries
                .map((entry) {
              int i = entry.key;
              PokerUserChipData user = entry.value;
              return TableRow(children: [
                Container(
                    decoration: BoxDecoration(
                      color: i == pokerUserProvider.selectUserIndex
                          ? Colors.amberAccent
                          : const Color(0x00ffffff),
                      border: Border(
                        left: BorderSide(color: pokerTableColor, width: 2),
                        right: BorderSide(color: pokerTableColor, width: 2),
                        bottom: const BorderSide(
                            color: Colors.amberAccent, width: 2),
                      ),
                    ),
                    child: SizedBox(
                      height: 26,
                      child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            primary: Colors.black,
                          ),
                          onPressed: () {
                            pokerUserProvider.setSelectUserIndex(i);
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          )),
                    )),
                Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: pokerTableColor, width: 2),
                        right: BorderSide(color: pokerTableColor, width: 2),
                        bottom: const BorderSide(
                            color: Colors.amberAccent, width: 2),
                      ),
                    ),
                    child: Text(user.chip.toString(),
                        style: const TextStyle(fontSize: 18))),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: pokerTableColor, width: 2),
                      right: BorderSide(color: pokerTableColor, width: 2),
                      bottom:
                          const BorderSide(color: Colors.amberAccent, width: 2),
                    ),
                  ),
                  child: haveChipTextWiget(
                    chip: user.chip - pokerUserProvider.initialChip,
                  ),
                ),
              ]);
            }),
            TableRow(children: [
              Container(
                child: Text(
                  '-- ${S.of(context).sum} --',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black),
                ),
              ),
              Container(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      width: 70,
                      height: 26,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(1),
                            primary: Colors.white70,
                            onPrimary: Colors.black,
                            textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white)),
                        onPressed: sumDiffChip == 0
                            ? () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const chipDistributionDialogWidget();
                                    });
                              }
                            : null,
                        child: Text(
                          S.of(context).allotment,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                  child: haveChipTextWiget(
                // https://qiita.com/i88_arakawa/items/dc19fec58312ae09e7e7
                // reduceはdartだと使わないほうがいい
                chip: sumDiffChip,
              )),
            ]),
          ],
        ),
      ],
    );
  }
}

class haveChipTextWiget extends StatelessWidget {
  int chip;
  String? message;

  haveChipTextWiget({required this.chip, this.message, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (chip > 0) {
      return Text(message ?? "+$chip",
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xfff5b2b2)));
    } else if (chip < 0) {
      return Text(message ?? "$chip",
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlueAccent));
    }
    return Text(message ?? "$chip",
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black));
  }
}

class chipDistributionDialogWidget extends StatefulWidget {
  const chipDistributionDialogWidget({Key? key}) : super(key: key);

  @override
  State<chipDistributionDialogWidget> createState() =>
      _chipDistributionDialogWidgetState();
}

class _chipDistributionDialogWidgetState
    extends State<chipDistributionDialogWidget> {
  @override
  Widget build(BuildContext context) {
    final PokerUserProvider pokerUserProvider =
        Provider.of<PokerUserProvider>(context, listen: true);

    List<DistributionChipUser> distributionUserMessages = distributionUserChip(
        pokerUserProvider.pokerUserChipDataList, pokerUserProvider.initialChip);

    return SimpleDialog(
      backgroundColor: pokerTableColor,
      title: TitleWidget(title: S.of(context).allotment),
      children: [
        Table(
          border: TableBorder.all(color: pokerTableColor, width: 1),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(0.3),
            1: FlexColumnWidth(1.0),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: [
            TableRow(children: [
              TableHeaderWidget(
                  headerWidget: Text(S.of(context).name,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              TableHeaderWidget(
                  headerWidget: Text(S.of(context).action,
                      style: const TextStyle(fontWeight: FontWeight.bold))),
            ]),
            ...distributionUserMessages.map((e) => TableRow(children: [
                  Container(
                      decoration: BoxDecoration(
                        color: pokerTableColor,
                        border: Border(
                          left: BorderSide(color: pokerTableColor, width: 2),
                          right: BorderSide(color: pokerTableColor, width: 2),
                          bottom: const BorderSide(
                              color: Colors.amberAccent, width: 2),
                        ),
                      ),
                      child: Column(
                        children: [
                          ...e.actionMessages.asMap().entries.map((entry) {
                            int i = entry.key;
                            return i == 0
                                ? Text(
                                    e.name,
                                    style: const TextStyle(fontSize: 18),
                                  )
                                : const Text(
                                    " ",
                                    style: TextStyle(fontSize: 18),
                                  );
                          })
                        ],
                      )),
                  Container(
                      decoration: BoxDecoration(
                        color: pokerTableColor,
                        border: Border(
                          left: BorderSide(color: pokerTableColor, width: 2),
                          right: BorderSide(color: pokerTableColor, width: 2),
                          bottom: const BorderSide(
                              color: Colors.amberAccent, width: 2),
                        ),
                      ),
                      child: Column(
                        children: [...e.actionMessages],
                      )),
                ]))
          ],
        ),
      ],
    );
  }
}

/// 所持チップー初期所持チップが０ではないユーザー
class DifferenceChipUser {
  int diffChip;
  int index;
  String name;

  DifferenceChipUser({
    required this.diffChip,
    required this.name,
    required this.index,
  });
}

/// 配分テーブルで表示する文字とインデックス
class DistributionChipUser {
  int index;
  String name;
  List<Widget> actionMessages;

  DistributionChipUser({
    required this.name,
    required this.actionMessages,
    required this.index,
  });
}

List<DistributionChipUser> distributionUserChip(
    List<PokerUserChipData> pokerUserChipDataList, int initialChip) {
  /// 所持チップー初期所持チップ > 0の場合の　差と名前とインデックスのリスト
  List<DifferenceChipUser> plusDiffChipUserList = [];

  /// 所持チップー初期所持チップ < 0の場合の　差と名前とインデックスのリスト
  List<DifferenceChipUser> minusDiffChipUserList = [];

  /// もらえる側のユーザーのmessage
  List<DistributionChipUser> plusDistributionChipUserList = [];

  /// 払う側のユーザーのmessage
  List<DistributionChipUser> minusDistributionChipUserList = [];

  /// もらえる側のユーザーのmessageのindex
  int plusDistributionChipUserIndex = 0;

  /// 払う側のユーザーのmessageのindex
  int minusDistributionChipUserIndex = 0;

  pokerUserChipDataList.asMap().entries.forEach((entry) {
    int i = entry.key;
    PokerUserChipData user = entry.value;
    int diffChip = user.chip - initialChip;

    /// 所持チップー初期所持チップの値が＋、ーで分ける。０は無視
    if (diffChip > 0) {
      plusDiffChipUserList.add(
          DifferenceChipUser(diffChip: diffChip, name: user.name, index: i));
    } else if (diffChip < 0) {
      minusDiffChipUserList.add(
          DifferenceChipUser(diffChip: diffChip, name: user.name, index: i));
    }
  });

  // sortとは
  // https://qiita.com/sekitaka_1214/items/59890f8a7318d14f4fc9
  // compareToとは
  // https://www.choge-blog.com/programming/dart%E6%AF%94%E8%BC%83%E3%81%AB%E4%BD%BF%E3%81%86%E3%80%8Ccompareto%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89%E3%80%8D%E3%81%A8%E3%81%AF%EF%BC%9F/
  /// 値が大きい順にソートする
  plusDiffChipUserList.sort((a, b) => b.diffChip.compareTo(a.diffChip));

  /// 値が小さい順にソートする
  minusDiffChipUserList.sort((a, b) => a.diffChip.compareTo(b.diffChip));

  /// /// messageの更新
  for (var i = 0;
      i < plusDiffChipUserList.length + minusDiffChipUserList.length;
      i++) {
    /// indexがmaxになったら終わり
    if (plusDistributionChipUserIndex >= plusDiffChipUserList.length &&
        minusDistributionChipUserIndex >= minusDiffChipUserList.length) {
      break;
    }

    /// message用のもとになるデータ
    DifferenceChipUser plusDfMUser =
        plusDistributionChipUserIndex >= plusDiffChipUserList.length
            ? plusDiffChipUserList.last
            : plusDiffChipUserList[plusDistributionChipUserIndex];
    DifferenceChipUser minusDfMUser =
        minusDistributionChipUserIndex >= minusDiffChipUserList.length
            ? minusDiffChipUserList.last
            : minusDiffChipUserList[minusDistributionChipUserIndex];

    /// plus分とminus分の合計
    int sumChip = plusDfMUser.diffChip + minusDfMUser.diffChip;

    /// 動くチップ
    int moveChip =
        sumChip > 0 ? minusDfMUser.diffChip * -1 : plusDfMUser.diffChip;

    /// /// messageの更新
    /// plus側
    /// 既にデータがある場合messageだけ更新
    if (plusDistributionChipUserList.length ==
        plusDistributionChipUserIndex + 1) {
      plusDistributionChipUserList[plusDistributionChipUserIndex]
          .actionMessages
          .add(haveChipTextWiget(
              chip: 1, message: "⇦ ${minusDfMUser.name}：$moveChip"));
    }

    /// データがない場合作成
    else {
      plusDistributionChipUserList.add(DistributionChipUser(
          index: plusDfMUser.index,
          name: plusDfMUser.name,
          actionMessages: [
            haveChipTextWiget(
                chip: 1, message: "← ${minusDfMUser.name}：$moveChip")
          ]));
    }

    /// minus側
    /// 既にデータがある場合messageだけ更新
    if (minusDistributionChipUserList.length ==
        minusDistributionChipUserIndex + 1) {
      minusDistributionChipUserList[minusDistributionChipUserIndex]
          .actionMessages
          .add(haveChipTextWiget(
              chip: -1, message: "→ ${plusDfMUser.name}：$moveChip"));
    }

    /// データがない場合作成
    else {
      minusDistributionChipUserList.add(DistributionChipUser(
          index: minusDfMUser.index,
          name: minusDfMUser.name,
          actionMessages: [
            haveChipTextWiget(
                chip: -1, message: "→ ${plusDfMUser.name}：$moveChip")
          ]));
    }

    /// /// indexの更新
    if (sumChip > 0) {
      /// plus側のdiffChipを減らす
      plusDfMUser.diffChip += minusDfMUser.diffChip;

      /// plus分の方が大きい場合、minus側のindexを進める
      minusDistributionChipUserIndex++;
    } else if (sumChip < 0) {
      /// minus側のdiffChipを減らす
      minusDfMUser.diffChip += plusDfMUser.diffChip;

      /// minus分の方が大きい場合、plus側のindexを進める
      plusDistributionChipUserIndex++;
    } else if (sumChip == 0) {
      /// 一緒の時は場合、plusもminus側もindexを進める
      plusDistributionChipUserIndex++;
      minusDistributionChipUserIndex++;
    }
  }

  return pokerUserChipDataList.asMap().entries.map((entry) {
    int i = entry.key;
    PokerUserChipData user = entry.value;
    List<DistributionChipUser> minusUser = minusDistributionChipUserList
        .where((element) => element.index == i)
        .toList();
    List<DistributionChipUser> plusUser = plusDistributionChipUserList
        .where((element) => element.index == i)
        .toList();
    // https://zenn.dev/taji/articles/f0bc864c56feda#3.%E4%BD%BF%E3%81%84%E6%96%B9
    /// minus側で見つかった場合
    if (minusUser.isNotEmpty) {
      return minusUser[0];
    }

    /// plus側で見つかった場合
    if (plusUser.isNotEmpty) {
      return plusUser[0];
    }

    return DistributionChipUser(index: i, name: user.name, actionMessages: [
      const Text(
        " ",
        style: TextStyle(fontSize: 18),
      )
    ]);
  }).toList();
}

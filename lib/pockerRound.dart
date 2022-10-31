import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo/provider/userProvider.dart';
import 'package:todo/utils/circle_painter.dart';
import 'package:todo/utils/table_widget.dart';

import 'generated/l10n.dart';
import 'utils/title_widget.dart';

/// BET金額の計算
String dispBET(int r0, int r1, int r2, int r3) {
  if (r3 != 0) return r3.toString();
  if (r2 != 0) return r2.toString();
  if (r1 != 0) return r1.toString();
  return r0.toString();
}

class PokerRound extends StatefulWidget {
  const PokerRound({Key? key}) : super(key: key);

  @override
  PokerRoundState createState() => PokerRoundState();
}

class PokerRoundState extends State<PokerRound> {
  Widget ActionWidget(int roundNumber) {
    if (roundNumber >= -1 && roundNumber < 4) {
      return PokerUserActionWidget();
    } else if (roundNumber == 4) {
      return PokerUserResultWidget();
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final PokerUserProvider pokerUserProvider =
        Provider.of<PokerUserProvider>(context, listen: true);
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).mode_r)),
        body: SingleChildScrollView(
            //追加
            child: Column(
                mainAxisSize: MainAxisSize.min,
                //   // https://www.flutter-study.dev/widgets/column-row-widget
                //   mainAxisAlignment: MainAxisAlignment.center,
                children: pokerUserProvider.pokerUserChipDataList.isNotEmpty
                    ? <Widget>[
                        const PokerUserTable(),

                        /// https://www.choge-blog.com/programming/dartlist%E3%81%AEmap%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89%E3%81%AE%E4%BD%BF%E3%81%84%E6%96%B9/
                        const PokerUserSeat(),
                        ActionWidget(pokerUserProvider.roundNumber),
                      ]
                    : [])));
  }
}

/// ユーザーデータのテーブル
class PokerUserTable extends StatelessWidget {
  const PokerUserTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PokerUserProvider pokerUserProvider =
        Provider.of<PokerUserProvider>(context, listen: true);
    return Column(children: [
      TitleWidget(
        title: S.of(context).round,
      ),
      Table(
        border: TableBorder.all(color: const Color(0x00ffffff), width: 1),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(0.4),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(0.8),
          3: FlexColumnWidth(0.6),
          4: FlexColumnWidth(0.6),
          5: FlexColumnWidth(0.6),
          6: FlexColumnWidth(0.6),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: [
          TableRow(children: [
            TableHeaderWidget(
                headerWidget: const Text(' ',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            TableHeaderWidget(
                headerWidget: Text(S.of(context).name,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            TableHeaderWidget(
                headerWidget: Text(S.of(context).chips,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            TableHeaderWidget(
                headerWidget: const Text('0R',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            TableHeaderWidget(
                headerWidget: const Text('1R',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            TableHeaderWidget(
                headerWidget: const Text('2R',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            TableHeaderWidget(
                headerWidget: const Text('3R',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            TableHeaderWidget(
                headerWidget: const Text('BET',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ]),
          ...pokerUserProvider.pokerUserChipDataList
              .map((e) => TableRow(children: [
                    TableCellWidget(
                        cellWidget:
                            PokerUserPositionCircleWidget(pokerUserData: e)),
                    TableCellWidget(
                        cellWidget: Text(
                      e.name,
                      style: const TextStyle(fontSize: 14),
                    )),
                    TableCellWidget(
                        cellWidget: Text(e.chip.toString(),
                            style: const TextStyle(fontSize: 14))),
                    TableCellWidget(
                        cellWidget: Text(e.r0.toString(),
                            style: const TextStyle(fontSize: 14))),
                    TableCellWidget(
                        cellWidget: Text(e.r1.toString(),
                            style: const TextStyle(fontSize: 14))),
                    TableCellWidget(
                        cellWidget: Text(e.r2.toString(),
                            style: const TextStyle(fontSize: 14))),
                    TableCellWidget(
                        cellWidget: Text(e.r3.toString(),
                            style: const TextStyle(fontSize: 14))),
                    TableCellWidget(
                        cellWidget: Text(pokerUserProvider.nowBET(e).toString(),
                            style: const TextStyle(fontSize: 14))),
                  ]))
        ],
      ),
    ]);
  }
}

/// ユーザーの座席表
class PokerUserSeat extends StatefulWidget {
  const PokerUserSeat({Key? key}) : super(key: key);

  @override
  State<PokerUserSeat> createState() => _PokerUserSeatState();
}

class _PokerUserSeatState extends State<PokerUserSeat> {
  /// ユーザーの位置
  Align userPosition(
      PokerUserChipData pUD, int index, int maxLength, int turnUserIndex) {
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
    PokerUserCircleWidget pokerUserCircleWidget() {
      /// fold表示
      if (pUD.action == PokerUserDataAction.values.byName('FOLD')) {
        return PokerUserCircleWidget(
          pokerUserData: pUD,
          isFold: true,
        );
      }

      /// 強調表示
      else if (index == turnUserIndex) {
        return PokerUserCircleWidget(
          pokerUserData: pUD,
          isStrong: true,
        );
      }

      return PokerUserCircleWidget(
        pokerUserData: pUD,
      );
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
      return Container(
          child: userPosition(
              user,
              index,
              pokerUserProvider.pokerUserChipDataList.length,
              pokerUserProvider.turnUserIndex));
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Center(
                  child: Text(S.of(context).setting),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 2,
                      child: PokerUserPositionCircleWidget(
                        pokerUserData: PokerUserData(
                          name: '0',
                          chip: 0,
                          position: PokerUserDataPosition.values.byName('SB'),
                        ),
                      ),
                    ),
                    const Expanded(child: Text("=")),
                    Expanded(child: Text("${pokerUserProvider.initialCost}")),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PokerUserPositionCircleWidget(
                        pokerUserData: PokerUserData(
                          name: 'List0',
                          chip: 0,
                          position: PokerUserDataPosition.values.byName('BB'),
                        ),
                      ),
                    ),
                    const Expanded(child: Text("=")),
                    Expanded(
                        child: Text("${pokerUserProvider.initialCost * 2}"))
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Center(
                  child: Text(S.of(context).current_of),
                ),
                Center(
                  child: Text(
                    'BET：${pokerUserProvider.nowBet.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Round：${pokerUserProvider.roundNumber.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

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
    return Column(children: [
      TitleWidget(
        title: S.of(context).action,
      ),
      ...userSeat(pokerUserProvider)
    ]);
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

  @override
  Widget build(BuildContext context) {
    final PokerUserProvider pokerUserProvider =
        Provider.of<PokerUserProvider>(context, listen: true);
    return pokerUserProvider.roundNumber > -1
        ? Column(
            children: [
              Text(
                  '${pokerUserProvider.pokerUserChipDataList[pokerUserProvider.turnUserIndex].name} ${S.of(context).who_turn}'),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.deepOrange,
                                    onPrimary: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      pokerUserProvider.doRAISE(nowBet);
                                    }
                                  },
                                  child: Text(S.of(context).raise),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 16),
                                  child: TextFormField(
                                    initialValue:
                                        "${pokerUserProvider.initialCost * 2}",
                                    maxLength: 8,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return S.of(context).please_enter;
                                      } else if (double.tryParse(value) ==
                                          null) {
                                        return S
                                            .of(context)
                                            .please_enter_a_number;
                                      } else {
                                        int parseValue = int.parse(value);
                                        if (parseValue <=
                                            pokerUserProvider.nowBet) {
                                          return "${S.of(context).please_enter_gre_than} ${pokerUserProvider.nowBet}";
                                        }
                                      }
                                      return null;
                                    },
                                    onChanged: (e) {
                                      /// 数値判定
                                      if (double.tryParse(e) != null) {
                                        setState(() {
                                          int parseE = int.parse(e);
                                          nowBet = parseE;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      // icon: Icon(Icons.chip),
                                      hintText: S.of(context).please_enter_bet,
                                      labelText: 'BET',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                          ),
                          onPressed: () {
                            pokerUserProvider.doCHECK();
                          },
                          child: Text(S.of(context).check),
                        ),
                      ),
                      Expanded(flex: 3, child: Container())
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey,
                            onPrimary: Colors.white,
                          ),
                          onPressed: () {
                            /// 状態をフォールドに変更
                            pokerUserProvider.doFOLD();
                          },
                          child: Text(S.of(context).fold),
                        ),
                      ),
                      Expanded(flex: 3, child: Container())
                    ],
                  ),
                ],
              )
            ],
          )
        : SizedBox(
            width: 100,
            height: 25,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                onPrimary: Colors.white,
              ),
              onPressed: () {
                pokerUserProvider.setRoundNumber(0);
              },
              child: const Text('START'),
            ),
          );
  }
}

class PokerUserResultWidget extends StatefulWidget {
  @override
  State<PokerUserResultWidget> createState() => _PokerUserResultWidgetState();
}

class _PokerUserResultWidgetState extends State<PokerUserResultWidget> {
  List<bool> isChecked = [];

  /// providerの値をisCheckedの初期値としてセットする
  void _initIsChecked(List<bool> boolList) {
    setState(() {
      isChecked = boolList;
    });
  }

  Widget listItems(int index, String name, PokerUserDataAction action,
      PokerUserProvider pokerUserProvider) {
    int maxIndex = pokerUserProvider.pokerUserChipDataList.length + 1;
    if (index == 0) {
      return Center(
          child: Text(S.of(context).who_win,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )));
    } else if (index < maxIndex) {
      return action == PokerUserDataAction.values.byName('FOLD')
          ? CheckboxListTile(
              title: Text("$name (FOLD)"),

              /// indexが配列に存在するか
              value: isChecked[index - 1],

              /// 既にFOLDしているユーザーはチェックボックスをdisabledにする
              // https://stackoverflow.com/questions/52174090/how-to-disable-checkbox-flutter
              onChanged: null,
              controlAffinity: ListTileControlAffinity.leading,
            )
          : CheckboxListTile(
              title: Text(name),

              /// indexが配列に存在するか
              value: isChecked[index - 1],

              /// 既にFOLDしているユーザーはチェックボックスをdisabledにする
              onChanged: (bool? value) {
                setState(() {
                  isChecked[index - 1] = value!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            );
    } else if (index == maxIndex) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.grey,
            onPrimary: Colors.white,
          ),
          onPressed: () {
            List<int> winIndexs = [];

            /// List<bool>をList<int>に変換
            isChecked.asMap().entries.forEach((element) {
              int i = element.key;
              bool checked = element.value;
              if (checked) winIndexs.add(i);
            });

            pokerUserProvider.win(winIndexs);
          },
          child: const Text('OK'),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final PokerUserProvider pokerUserProvider =
        Provider.of<PokerUserProvider>(context, listen: true);

    /// 初回だけ初期値をセット
    if (isChecked.length != pokerUserProvider.pokerUserChipDataList.length) {
      _initIsChecked(
          pokerUserProvider.pokerUserChipDataList.map((e) => false).toList());
    }

    return SingleChildScrollView(
        //追加
        child: ListView.builder(
      // https://qiita.com/code-cutlass/items/3a8b759056db1e8f7639
      shrinkWrap: true,
      // https://api.flutter.dev/flutter/widgets/ScrollView/shrinkWrap.html
      // physics: const NeverScrollableScrollPhysics(),
      itemCount: pokerUserProvider.pokerUserChipDataList.length + 2,
      itemBuilder: (BuildContext context, int index) {
        String name = '';
        PokerUserDataAction action = PokerUserDataAction.values.byName('none');
        if (0 < index &&
            index < pokerUserProvider.pokerUserChipDataList.length + 1) {
          name = pokerUserProvider.pokerUserChipDataList[index - 1].name;
          action = pokerUserProvider.pokerUserChipDataList[index - 1].action;
        }

        return listItems(index, name, action, pokerUserProvider);
      },
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo/pockerRound.dart';
import 'package:todo/provider/userProvider.dart';

import 'generated/l10n.dart';
import 'pockerScore.dart';
import 'utils/title_widget.dart';

/// ユーザーの限界人数
int POKER_USER_DATA_LIMIT = 10;

/// ユーザーの最低人数
int POKER_USER_DATA_HAVE = 4;

/// ゲームのバージョン
/// SMART = スマート版
/// DETAIL = ラウンド毎版
List<String> GAME_MODE_LIST = ["score", "round"];

class PokerUser extends StatefulWidget {
  const PokerUser({Key? key}) : super(key: key);

  @override
  PokerUserState createState() => PokerUserState();
}

class PokerUserState extends State<PokerUser> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  /// 追加するユーザーの初期値
  String addUserName = 'noname';
  int addUserChip = 0;
  String gameVersion = 'score';

  void resetAddUser() {
    setState(() {
      addUserName = 'noname';
      addUserChip = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final PokerUserProvider pokerUserProvider =
        Provider.of<PokerUserProvider>(context, listen: true);

    String gameVersionStr(String gameVersion) {
      if (gameVersion == "score") return S.of(context).mode_s;
      if (gameVersion == "round") return S.of(context).mode_r;
      return "";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).setting,
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.white,
            ),
            // https://qiita.com/Mono999/items/2f10663beff14e7d43dc
            onPressed: () => {
              // https://buildbox.net/flutter-licensepage/
              showLicensePage(
                context: context,
                applicationName: 'License View',
                applicationVersion: '1.0.0',
              ),
            },
            child: const Text('Licenses'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        // ignore: sort_child_properties_last
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  children: [
                    TitleWidget(title: S.of(context).setting),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                              value: gameVersion,
                              decoration: InputDecoration(
                                // icon: Icon(Icons.chip),
                                labelText: S.of(context).mode,
                              ),
                              items: GAME_MODE_LIST
                                  .map((String mode) => DropdownMenuItem(
                                      value: mode,
                                      child: Text(gameVersionStr(mode))))
                                  .toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  gameVersion = value!;
                                });
                              }),
                        ),
                        Expanded(
                            flex: 2,
                            child: PokerGameVersionExplainWidget(
                                gameVersion: gameVersion)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLength: 7,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return S.of(context).please_enter;
                                } else if (double.tryParse(value) == null) {
                                  return S.of(context).please_enter_a_number;
                                } else {
                                  int parseValue = int.parse(value);
                                  if (parseValue <= 0) {
                                    return "${S.of(context).please_enter_gre_than} 0";
                                  }
                                }
                                return null;
                              },
                              onChanged: (e) {
                                /// 数値判定
                                if (double.tryParse(e) != null) {
                                  setState(() {
                                    int parseE = int.parse(e);
                                    pokerUserProvider.setInitialChip(parseE);
                                  });
                                }
                              },
                              initialValue: '${pokerUserProvider.initialChip}',
                              decoration: InputDecoration(
                                labelText: S.of(context).init_chip,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLength: 7,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return S.of(context).please_enter;
                                } else if (double.tryParse(value) == null) {
                                  return S.of(context).please_enter_a_number;
                                } else {
                                  int parseValue = int.parse(value);
                                  if (parseValue <= 0) {
                                    return "${S.of(context).please_enter_gre_than} 0";
                                  }
                                }
                                return null;
                              },
                              onChanged: (e) {
                                /// 数値判定
                                if (double.tryParse(e) != null) {
                                  setState(() {
                                    int parseE = int.parse(e);
                                    pokerUserProvider.setInitialCost(parseE);
                                    pokerUserProvider.setNowBet(parseE * 2);
                                  });
                                }
                              },
                              initialValue: '${pokerUserProvider.initialCost}',
                              decoration: InputDecoration(
                                labelText: 'SB（${S.of(context).sb}）',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TitleWidget(
                      title: S.of(context).member,
                    ),
                    Container(
                        padding: const EdgeInsets.all(1.0),
                        child: Text(
                          "（※${S.of(context).for_people}）",
                          style: const TextStyle(fontSize: 12.0),
                        )),
                  ],
                ),
              ),
              // Expandedの意味
              // https://qiita.com/nannany_hey/items/d4114f615e4d53964121
              Expanded(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return index <
                            pokerUserProvider.pokerUserChipDataList.length
                        // https://www.choge-blog.com/programming/fluttercard-tapable/
                        ? InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    PokerUserChipData user = pokerUserProvider
                                        .pokerUserChipDataList[index];
                                    return PokerUserDialogWidget(
                                        userName: user.name,
                                        userChip: user.chip,
                                        userIndex: index);
                                  });
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return PokerUserDeleteConfirmWidget(
                                                      userName: pokerUserProvider
                                                          .pokerUserChipDataList[
                                                              index]
                                                          .name,
                                                      onPressedOK: () {
                                                        pokerUserProvider
                                                            .deleteList(index);
                                                        Navigator.of(context)
                                                            .pop();
                                                      });
                                                });
                                          },
                                          icon: const Icon(Icons.delete)),
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 0),
                                              child: Text(
                                                "${S.of(context).name}　：",
                                                style: const TextStyle(
                                                    fontSize: 16.0),
                                              ),
                                            ),
                                            Text(
                                              pokerUserProvider
                                                  .pokerUserChipDataList[index]
                                                  .name
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 0),
                                              child: Text(
                                                "${S.of(context).chips}：",
                                                style: const TextStyle(
                                                    fontSize: 16.0),
                                              ),
                                            ),
                                            Text(
                                              pokerUserProvider
                                                  .pokerUserChipDataList[index]
                                                  .chip
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return PokerUserDialogWidget();
                                  });
                            },
                            icon: const Icon(Icons.add));
                  },
                  itemCount: pokerUserProvider.pokerUserChipDataList.length >=
                          POKER_USER_DATA_LIMIT
                      ? pokerUserProvider.pokerUserChipDataList.length
                      : pokerUserProvider.pokerUserChipDataList.length + 1,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.black,
                ),
                onPressed: pokerUserProvider.pokerUserChipDataList.length >=
                        POKER_USER_DATA_HAVE
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          /// ここでポジションを再計算する
                          pokerUserProvider.initGame();

                          if (gameVersion == "score") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PokerScore()));
                          } else if (gameVersion == "round") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PokerRound()));
                          }
                        }
                      }
                    : null,
                child: Text(S.of(context).start,
                    style: const TextStyle(fontSize: 32)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PokerUserDeleteConfirmWidget extends StatefulWidget {
  String userName = "";
  Function onPressedOK;

  PokerUserDeleteConfirmWidget(
      {required this.userName, required this.onPressedOK, Key? key})
      : super(key: key);

  @override
  State<PokerUserDeleteConfirmWidget> createState() =>
      _PokerUserDeleteConfirmWidgetState();
}

class _PokerUserDeleteConfirmWidgetState
    extends State<PokerUserDeleteConfirmWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).delete_user),
      content: Column(
        children: [
          Text(S.of(context).delete_user_confirm),
          Text("・${widget.userName}")
        ],
      ),
      actions: <Widget>[
        // ボタン領域
        TextButton(
            child: Text(S.of(context).cancel),
            onPressed: () => Navigator.of(context).pop()),
        TextButton(
            child: const Text("OK"), onPressed: () => widget.onPressedOK()),
      ],
    );
  }
}

class PokerGameVersionExplainWidget extends StatelessWidget {
  String? gameVersion = "";

  PokerGameVersionExplainWidget({this.gameVersion, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget explainWidget = Container();
    if (gameVersion == "score") {
      explainWidget = Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              S.of(context).mode_explain_s_1,
              // https://qiita.com/superman9387/items/15e809dd2044f2e363c5
              softWrap: true,
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(
            width: double.infinity,
            child: Text(
              '',
              // https://qiita.com/superman9387/items/15e809dd2044f2e363c5
              softWrap: true,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      );
    } else if (gameVersion == "round") {
      explainWidget = Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              S.of(context).mode_explain_r_1,
              // https://qiita.com/superman9387/items/15e809dd2044f2e363c5
              softWrap: true,
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Text(
              S.of(context).mode_explain_r_2,
              // https://qiita.com/superman9387/items/15e809dd2044f2e363c5
              softWrap: true,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            S.of(context).mode_explain,
            // https://qiita.com/superman9387/items/15e809dd2044f2e363c5
            softWrap: true,
            textAlign: TextAlign.left,
          ),
        ),
        explainWidget,
      ],
    );
  }
}

class PokerUserDialogWidget extends StatefulWidget {
  String? userName;
  int? userChip;
  int? userIndex;

  PokerUserDialogWidget(
      {this.userName, this.userChip, this.userIndex, Key? key})
      : super(key: key);

  @override
  State<PokerUserDialogWidget> createState() => _PokerUserDialogWidgetState();
}

/// onTapも引数で持ってくる
class _PokerUserDialogWidgetState extends State<PokerUserDialogWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  /// 追加するユーザーの初期値
  String addUserName = 'noname';
  int addUserChip = 0;

  /// 追加するユーザーのデータの初期化
  void resetAddUser() {
    setState(() {
      addUserName = 'noname';
      addUserChip = 0;
    });
  }

  // https://hiyoko-programming.com/1347/
  @override
  void initState() {
    super.initState();

    // 受け取ったデータを状態を管理する変数に格納
    if (widget.userName != null) {
      addUserName = widget.userName!;
    }
    if (widget.userChip != null) {
      addUserChip = widget.userChip!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final PokerUserProvider pokerUserProvider =
        Provider.of<PokerUserProvider>(context, listen: true);

    return AlertDialog(
      title: Text(S.of(context).add_member),
      content: Form(
        key: _formKey,
        child: Container(
          constraints: const BoxConstraints(minWidth: 600),
          child: Column(
            children: [
              // https://flutter.ctrnost.com/basic/interactive/form/textfield/
              TextFormField(
                // https://qiita.com/solty_919/items/f14b443126122b666c73
                // controller: TextEditingController(text: addUserName),
                initialValue: addUserName,
                // 入力数
                maxLength: 10,
                obscureText: false,
                maxLines: 1,
                onChanged: (e) {
                  setState(() {
                    addUserName = e;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return S.of(context).please_enter;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  icon: const Icon(Icons.face),
                  labelText: S.of(context).name,
                ),
              ),
              // https://qiita.com/beckyJPN/items/912cb61cfee813bf4a70
              TextFormField(
                initialValue: '${pokerUserProvider.initialChip}',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 7,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return S.of(context).please_enter;
                  } else if (double.tryParse(value) == null) {
                    return S.of(context).please_enter_a_number;
                  } else {
                    int parseValue = int.parse(value);
                    if (parseValue <= 0) {
                      return "${S.of(context).please_enter_gre_than} 0";
                    }
                  }
                  return null;
                },
                onChanged: (e) {
                  /// 数値判定
                  if (double.tryParse(e) != null) {
                    setState(() {
                      addUserChip = int.parse(e);
                    });
                  }
                },
                decoration: InputDecoration(
                  icon: const Icon(Icons.money),
                  labelText: S.of(context).chips,
                ),
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).cancel)),
        TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                /// userIndexが存在するならupdate、存在しないならcreate
                if (widget.userIndex == null) {
                  pokerUserProvider.addList(PokerUserChipData(
                    r0: 0,
                    r1: 0,
                    r2: 0,
                    r3: 0,
                    name: addUserName,
                    chip: addUserChip,
                    action: PokerUserDataAction.values.byName('none'),
                    position: PokerUserDataPosition.values.byName('gen'),
                  ));
                } else {
                  PokerUserChipData pokerUserChipData = pokerUserProvider
                      .pokerUserChipDataList[widget.userIndex!];
                  pokerUserChipData.name = addUserName;
                  pokerUserChipData.chip = addUserChip;
                  pokerUserProvider.updateList(
                      pokerUserChipData, widget.userIndex!);
                }

                /// addUserのリセット
                resetAddUser();
                Navigator.of(context).pop();
              }
            },
            child: const Text("OK"))
      ],
    );
  }
}

import 'dart:math';

// TextStyleが変わる
import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:todo/provider/userProvider.dart';

class StrokeCirclePainter extends CustomPainter {
  /// 円のラベル
  String name;

  /// 右下の円のラベル
  /// subNameは''だったら描画しない
  String? subName;
  String? header;
  Paint paintCircle;
  Paint? subPaintCircle;

  StrokeCirclePainter(
      {required this.name,
      this.subName,
      this.header,
      required this.paintCircle,
      this.subPaintCircle});

  @override
  void paint(Canvas canvas, Size size) {
    /// 線は黒色を指定する
    /// ..なんちゃらはカスケード記法、同一処理をする時に使う
    /// https://qiita.com/Nedward/items/b71512f8c2997f52697d
    /// 円の描画
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - 3;
    canvas.drawCircle(center, radius, paintCircle);

    /// テキストの描画
    // https://zenn.dev/fastriver/books/reimpl-flutter/viewer/skia-play#%E6%96%87%E5%AD%97%E3%81%AE%E6%8F%8F%E7%94%BB
    // ParagraphBuilder builder = ParagraphBuilder(ParagraphStyle(fontSize: 30));
    double textFontSize = 15;
    dart_ui.Offset textOffset = Offset(
        0,
        size.height / 2 -
            textFontSize /
                2); // Offset(radius / 2, size.height / 2 - radius / 2);
    dart_ui.ParagraphBuilder paragraphBuilder = dart_ui.ParagraphBuilder(
        dart_ui.ParagraphStyle(textAlign: TextAlign.center));
    dart_ui.TextStyle textStyle = dart_ui.TextStyle(
      color: Colors.black,
      fontSize: textFontSize,

      /// textのpaddingを無くす
      /// https://qiita.com/saya_/items/57b8458520312ee383a4
      height: 1.0,
    );
    paragraphBuilder.pushStyle(textStyle);
    paragraphBuilder.addText(name);
    dart_ui.Paragraph paragraph = paragraphBuilder.build();
    // 名前つき引数 https://zenn.dev/kaleidot725/articles/2021-11-13-dart-constructor
    // https://api.flutter.dev/flutter/dart-ui/ParagraphConstraints-class.html
    paragraph.layout(dart_ui.ParagraphConstraints(width: size.width));
    canvas.drawParagraph(paragraph, textOffset);

    /// subNameが''以外の場合の処理
    if (subName != null && subPaintCircle != null) {
      /// 円の描画
      Offset subCenter = Offset(size.width / 8 * 7, size.height / 8 * 7);
      double subRadius = min(size.width / 5, size.height / 5) - 7;
      canvas.drawCircle(subCenter, subRadius, subPaintCircle!);

      /// テキストの描画
      double subTextFontSize = 12;
      dart_ui.Offset subTextOffset =
          Offset(size.width / 8 * 3, size.height / 8 * 7 - textFontSize / 2);
      dart_ui.ParagraphBuilder subParagraphBuilder = dart_ui.ParagraphBuilder(
          dart_ui.ParagraphStyle(textAlign: TextAlign.center));
      dart_ui.TextStyle subTextStyle = dart_ui.TextStyle(
        color: Colors.black,
        fontSize: subTextFontSize,
        height: 1.0,
      );
      subParagraphBuilder.pushStyle(subTextStyle);
      subParagraphBuilder.addText(subName!);
      dart_ui.Paragraph subParagraph = subParagraphBuilder.build();
      subParagraph.layout(dart_ui.ParagraphConstraints(width: size.width));
      canvas.drawParagraph(subParagraph, subTextOffset);
    }

    /// headerの描写
    if (header != null) {
      /// テキストの描画
      double headerTextFontSize = 16;
      dart_ui.Offset headerTextOffset = Offset(0, -textFontSize);
      dart_ui.ParagraphBuilder headerParagraphBuilder =
          dart_ui.ParagraphBuilder(
              dart_ui.ParagraphStyle(textAlign: TextAlign.center));
      dart_ui.TextStyle headerTextStyle = dart_ui.TextStyle(
        color: Colors.black,
        fontSize: headerTextFontSize,
        fontWeight: FontWeight.bold,
        height: 1.0,
      );
      headerParagraphBuilder.pushStyle(headerTextStyle);
      headerParagraphBuilder.addText(header!);
      dart_ui.Paragraph headerParagraph = headerParagraphBuilder.build();
      headerParagraph.layout(dart_ui.ParagraphConstraints(width: size.width));
      canvas.drawParagraph(headerParagraph, headerTextOffset);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class PokerUserSmartCircleWidget extends StatelessWidget {
  PokerUserChipData pokerUserData;
  bool? isStrong;
  Function? onTap;

  PokerUserSmartCircleWidget(
      {required this.pokerUserData, this.isStrong, this.onTap, Key? key})
      : super(key: key);

  StrokeCirclePainter strokeCirclePainter() {
    if ((isStrong ?? false)) {
      return StrokeCirclePainter(
        name: pokerUserData.name,
        header: "${pokerUserData.chip.toString()}",
        paintCircle: Paint()..color = Colors.amberAccent,
      );
    }
    return StrokeCirclePainter(
      name: pokerUserData.name,
      header: "${pokerUserData.chip.toString()}",
      paintCircle: Paint()
        ..strokeWidth = 3
        ..color = Colors.black
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  Widget build(BuildContext context) {
    /// https://flutterzero.com/sizedbox/
    return SizedBox(
      height: 75,
      width: 90,

      /// https://qiita.com/mkosuke/items/e506256515179d0f421b
      child: InkWell(
          onTap: () {
            if (onTap != null) {
              onTap!();
            }
          },
          child: CustomPaint(

              /// null判定
              painter: strokeCirclePainter())),
    );
  }
}

class PokerUserCircleWidget extends StatelessWidget {
  PokerUserChipData pokerUserData;
  bool? isStrong;
  bool? isFold;
  Function? onTap;

  PokerUserCircleWidget(
      {required this.pokerUserData, this.isStrong, this.isFold, Key? key})
      : super(key: key);

  StrokeCirclePainter strokeCirclePainter() {
    if ((isFold ?? false)) {
      return StrokeCirclePainter(
          name: pokerUserData.name,
          subName: pokerUserData.position.name == 'gen'
              ? ''
              : pokerUserData.position.name,
          paintCircle: Paint()..color = Colors.black,
          subPaintCircle: Paint()
            ..color = positionColor(pokerUserData.position.name));
    } else if ((isStrong ?? false)) {
      return StrokeCirclePainter(
          name: pokerUserData.name,
          subName: pokerUserData.position.name == 'gen'
              ? ''
              : pokerUserData.position.name,
          paintCircle: Paint()..color = Colors.amberAccent,
          subPaintCircle: Paint()
            ..color = positionColor(pokerUserData.position.name));
    }
    return StrokeCirclePainter(
        name: pokerUserData.name,
        subName: pokerUserData.position.name == 'gen'
            ? ''
            : pokerUserData.position.name,
        paintCircle: Paint()
          ..strokeWidth = 3
          ..color = Colors.black
          ..style = PaintingStyle.stroke,
        subPaintCircle: Paint()
          ..color = positionColor(pokerUserData.position.name));
  }

  @override
  Widget build(BuildContext context) {
    /// https://flutterzero.com/sizedbox/
    return SizedBox(
      height: 75,
      width: 90,

      /// https://qiita.com/mkosuke/items/e506256515179d0f421b
      child: InkWell(
          onTap: onTap != null
              ? () {
                  onTap!();
                }
              : null,
          child: CustomPaint(

              /// null判定
              painter: strokeCirclePainter())),
    );
  }
}

class PokerUserPositionCircleWidget extends StatelessWidget {
  PokerUserData pokerUserData;

  PokerUserPositionCircleWidget({required this.pokerUserData, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// https://flutterzero.com/sizedbox/
    return SizedBox(
      height: 20,
      width: 20,

      /// https://qiita.com/mkosuke/items/e506256515179d0f421b
      child: InkWell(
          onTap: null,
          child: CustomPaint(
            painter: StrokeCirclePainter(
              name: pokerUserData.position.name == 'gen'
                  ? ''
                  : pokerUserData.position.name,
              paintCircle: Paint()
                ..color = positionColor(pokerUserData.position.name),
            ),
          )),
    );
  }
}

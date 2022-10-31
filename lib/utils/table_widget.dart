import 'package:flutter/material.dart';

import 'custom_color.dart';

class TableCellWidget extends StatelessWidget {
  Widget cellWidget;

  TableCellWidget({required this.cellWidget, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: pokerTableColor, width: 2),
          right: BorderSide(color: pokerTableColor, width: 2),
          bottom: const BorderSide(color: Colors.amberAccent, width: 2),
        ),
      ),
      child: cellWidget,
    );
  }
}

class TableHeaderWidget extends StatelessWidget {
  Widget headerWidget;

  TableHeaderWidget({required this.headerWidget, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.amberAccent,
          border: Border.all(color: pokerTableColor, width: 2),
        ),
        child: headerWidget);
  }
}

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:maptool/edit_setting.dart';
import 'package:maptool/const.dart';
import 'package:maptool/common.dart';

class ToolTipPainter extends CustomPainter {
  final ui.Image? mapImage;
  final Position? position;

  ToolTipPainter({this.mapImage, this.position});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
    ..style = PaintingStyle.fill
    ..color = Constant.tooltipGridColor;

    EditSetting setting = EditSetting();

    if (mapImage != null) {
      double width = mapImage!.width as double;
      double height = mapImage!.height as double;

      canvas.drawImageRect(
        mapImage!,
        Rect.fromLTWH(0, 0, width, height),
        Rect.fromLTWH(0, 0, width, height),
        Paint()
      );
    }

    canvas.save();
    for (int i = 0; i < size.width / setting.gridSize; i++) {
      canvas.drawLine(Constant.zeroOffset, Offset(0, size.height), paint);
      canvas.translate(setting.gridSize.toDouble(), 0);
    }
    canvas.restore();
    canvas.save();
    for (int i = 0; i < size.height / setting.gridSize; i++) {
      canvas.drawLine(Constant.zeroOffset, Offset(size.width, 0), paint);
      canvas.translate(0, setting.gridSize.toDouble());
    }

    canvas.restore();

    //select position
    Paint rectPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Constant.tooltipSelectColor;
    canvas.drawRect(Rect.fromLTWH(position?.x as double, position?.y as double, setting.gridSize.toDouble(), setting.gridSize.toDouble()), rectPaint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

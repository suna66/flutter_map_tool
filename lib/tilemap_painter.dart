import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:maptool/edit_setting.dart';
import 'package:maptool/const.dart';
import 'package:maptool/common.dart';

class TileMapPainter extends CustomPainter {
  final Position? selectedPosition;
  final ui.Image? mapImage;
  final List<int>? backLayer;
  final List<int>? spriteLayer;

  TileMapPainter({this.selectedPosition, this.mapImage, this.backLayer, this.spriteLayer});

  @override
  void paint(Canvas canvas, Size size) {

    Paint rectPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Constant.editAreaColor;

    EditSetting setting = EditSetting();

    int width = setting.gridSize * setting.mapRowNum;
    int height = setting.gridSize * setting.mapColumeNum;

    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), rectPaint);

    if (mapImage != null)
    {
      int rowNum = mapImage!.width ~/ setting.gridSize;
      //Draw background
      for (int i = 0; i < backLayer!.length; i++) {
        int value = backLayer![i];
        if (value == -1) {
          continue;
        }
        int y = (value~/rowNum) * setting.gridSize;
        int x = (value % rowNum) * setting.gridSize;

        int cx = (i % setting.mapRowNum) * setting.gridSize;
        int cy = (i ~/setting.mapRowNum) * setting.gridSize;

        canvas.drawImageRect(mapImage!, 
          Rect.fromLTWH(x.toDouble(), y.toDouble(), setting.gridSize.toDouble(), setting.gridSize.toDouble()),
          Rect.fromLTWH(cx.toDouble(), cy.toDouble(), setting.gridSize.toDouble(), setting.gridSize.toDouble()),
          Paint()
        );
      }
      //Draw sprites
      for (int i = 0; i < spriteLayer!.length; i++) {
        int value = spriteLayer![i];
        if (value == -1) {
          continue;
        }
        int y = (value~/rowNum) * setting.gridSize;
        int x = (value % rowNum) * setting.gridSize;

        int cx = (i % setting.mapRowNum) * setting.gridSize;
        int cy = (i ~/setting.mapRowNum) * setting.gridSize;

        canvas.drawImageRect(mapImage!, 
          Rect.fromLTWH(x.toDouble(), y.toDouble(), setting.gridSize.toDouble(), setting.gridSize.toDouble()),
          Rect.fromLTWH(cx.toDouble(), cy.toDouble(), setting.gridSize.toDouble(), setting.gridSize.toDouble()),
          Paint()
        );
      }
    }

    Paint paint = Paint()
    ..style = PaintingStyle.fill
    ..color = Constant.editGridColor;

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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

}
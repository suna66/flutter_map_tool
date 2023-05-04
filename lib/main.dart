//import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:maptool/edit_setting.dart';
import 'package:maptool/const.dart';
import 'package:maptool/common.dart';
import 'package:maptool/tilemap_painter.dart';
import 'package:maptool/tooltip_painter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Tool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MiCore2d Map Tool'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ui.Image? img;
  Position? selectPosition;
  List<int>? backLayer;
  List<int>? spriteLayer;

  TooltipInfo? tooltip;
  int tipIndex = 0;

  String loadedFileName = "no_name.dat";

  EditSetting setting = EditSetting();

  TextEditingController? _gridSizeTextfield;
  TextEditingController? _mapRowSizeTextfield;
  TextEditingController? _mapColumnSizeTextfield;

  _MyHomePageState()
  {
    selectPosition = Position(0, 0);
    tooltip = TooltipInfo(1024, 500, 0, 0);
    backLayer = List<int>.filled(setting.mapColumeNum * setting.mapRowNum, -1);
    spriteLayer = List<int>.filled(setting.mapRowNum * setting.mapColumeNum, -1);
    _gridSizeTextfield = TextEditingController(text: setting.gridSize.toString());
    _mapRowSizeTextfield = TextEditingController(text: setting.mapRowNum.toString());
    _mapColumnSizeTextfield = TextEditingController(text: setting.mapColumeNum.toString());
  }

  Future getImageFile() async {
      FilePickerResult? importFileData0  = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["jpg", "jpeg", "png"]
      );
      PlatformFile? platformFile = importFileData0?.files.first;

      var filename = platformFile!.name;
      loadedFileName = CommonFunc.removeExtension(filename);

      ui.Image image = await  decodeImageFromList(platformFile!.bytes!);
      tooltip?.width = image.width;
      tooltip?.height = image.height;

      tooltip?.rowNum = image.width ~/ setting.gridSize;
      tooltip?.columnNum = image.height ~/setting.gridSize;
      setState(() {
          img = image;
      });
  }

  void onTapMap(TapDownDetails details) {
    Offset point = details.localPosition;

    if (point.dx > tooltip!.width.toDouble()) {
      return;
    }
    if (point.dy > tooltip!.height.toDouble()) {
      return;
    }

    int x = (point.dx ~/ setting.gridSize);
    int y = (point.dy ~/ setting.gridSize);

    tipIndex = y * tooltip!.rowNum + x;

    //print("${x}, ${y}");

    setState(() {
      //selectPosition = Position(x * 32, y * 32);
      selectPosition?.x = x * setting.gridSize;
      selectPosition?.y = y * setting.gridSize;
    });
  }

  void onPaintMap(TapDownDetails details) {
    Offset point = details.localPosition;

    int x = (point.dx ~/ setting.gridSize);
    int y = (point.dy ~/ setting.gridSize);

    int idx = y * setting.mapRowNum + x;

    setState(() {
      if (setting.layerName == Constant.valueBackGround) {
        backLayer?[idx] = tipIndex;
      } else {
        spriteLayer?[idx] = tipIndex;
      }
    });
  }

  void onGridSizeChange(String value) {
    int? ivalue = int.tryParse(value);
    if (ivalue == 0 || ivalue == null) {
      ivalue = 32;
    }
    setState(() {
      setting.gridSize = ivalue!;
    });
  }

  void onMapSizeChange() {
    String strRowNum = _mapRowSizeTextfield!.text;
    String strColumnNum = _mapColumnSizeTextfield!.text;
    int? rowNum = int.tryParse(strRowNum);
    int? columNum = int.tryParse(strColumnNum);
    if (rowNum == 0 || rowNum == null) {
      rowNum = 16;
    }
    if (columNum == 0 || columNum == null) {
      columNum = 16;
    }
    int oldRow = setting.mapRowNum;
    int oldColumn = setting.mapColumeNum;
    List<int> newBackLayer = List<int>.filled(rowNum * columNum, -1);
    List<int> newSpriteLayer = List<int>.filled(rowNum * columNum, -1);

    for (int i = 0; i < oldColumn; i++) {
      if (i > columNum) break;

      for (int j = 0; j < oldRow; j++) {
        if (j > rowNum) break;
        newBackLayer[i * rowNum + j] = backLayer![i * oldRow + j];
        newSpriteLayer[i * rowNum + j] = spriteLayer![i * oldRow + j];
      }
    }
    
    setState(() {
      backLayer = newBackLayer;
      spriteLayer = newSpriteLayer;
      setting.mapRowNum = rowNum!;
      setting.mapColumeNum = columNum!;
    });
  }

  void onSave() async {
    if (img == null) {
      showAlert("system hasn't load image data");
      return;
    }
    String headData = "${setting.mapRowNum},${setting.mapColumeNum}";
    String backgroundData = CommonFunc.intListToCSVString(backLayer!);
    String spriteData = CommonFunc.intListToCSVString(spriteLayer!);
    //concat all strings
    String data = "$headData,$backgroundData,$spriteData";
    CommonFunc.downloadFile(data, loadedFileName + ".dat");
  }

  void onLoad() async {
    if (img == null) {
      showAlert("system hasn't load image data");
      return;
    }
    FilePickerResult? importFileData0  = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["dat"]
      );
    PlatformFile? platformFile = importFileData0?.files.first;

    var filename = platformFile!.name;
    Uint8List bytes = platformFile.bytes!;
    List<int> utf8Data = bytes.toList();
    String data = String.fromCharCodes(utf8Data);
    List<int> tilemapList = CommonFunc.csvStringToIntList(data);
    int rowNum = tilemapList[0];
    int columnNum = tilemapList[1];
    if (rowNum == 0 || columnNum == 0) {
      showAlert("illigal format data");
      return;
    }
    int size = tilemapList.length;

    if (size < rowNum * columnNum * 2) {
      showAlert("lack of data");
      return;
    }

    List<int> backData = List<int>.filled(rowNum * columnNum, 0);
    List<int> spriteData = List<int>.filled(rowNum * columnNum, 0);

    int backStartPos = 2;
    int spriteStartPos = rowNum * columnNum + 2;
    for (int i = 0; i < rowNum * columnNum; i++) {
      backData[i] = tilemapList[backStartPos + i];
      spriteData[i] = tilemapList[spriteStartPos + i];
    }
    loadedFileName = CommonFunc.removeExtension(filename);

    setState(() {
      setting.mapRowNum = rowNum;
      setting.mapColumeNum = columnNum;
      backLayer = backData;
      spriteLayer = spriteData;
    });
  }
  
  AlertDialog alertBuilder(BuildContext context, String msg) {
    return AlertDialog(
      title: const Text(Constant.appName),
      content: Text(msg),
      actions: [
        TextButton(onPressed: () {
          Navigator.pop(context, "OK");
        }, child: const Text("OK")),
      ],
    );
  }

  void showAlert(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) => alertBuilder(context, msg)
    );
  }

  Widget getLayerDropList() {
    return DropdownButton(
      items: [
        DropdownMenuItem(value: Constant.valueBackGround, child: Text(Constant.labelBackGround)),
        DropdownMenuItem(value: Constant.valueSprites, child: Text(Constant.labelSprites)),
      ],
      onChanged: (String? value) {
        setState(() {
          setting.layerName = value!;
        });
      },
      value: setting.layerName);
  }

  Widget space() {
    return SizedBox(
      width: Constant.spaceSize.toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView( child :Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: Colors.white,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(Constant.labelGridSize),
                  Flexible(
                    child: SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _gridSizeTextfield,
                        textAlign: TextAlign.right,
                        enabled: true,
                        maxLines: 1,
                        maxLength: 3,
                        style: TextStyle(color: Colors.black),
                        onChanged: onGridSizeChange,
                      ),
                    ),
                  ),
                  space(),
                  ElevatedButton(
                    onPressed: getImageFile,
                    child: Text(Constant.labelLoadImage),
                  ),
                  space(),
                  Text(Constant.labelRowNum),
                  Flexible(
                    child: SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _mapRowSizeTextfield,
                        textAlign: TextAlign.right,
                        enabled: true,
                        maxLines: 1,
                        maxLength: 3,
                        style: TextStyle(color: Colors.black),
                        onChanged: (value){},
                      ),
                    ),
                  ),
                  Text(Constant.labelColumnNum),
                  Flexible(
                    child: SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _mapColumnSizeTextfield,
                        textAlign: TextAlign.right,
                        enabled: true,
                        maxLines: 1,
                        maxLength: 3,
                        style: TextStyle(color: Colors.black),
                        onChanged: (value){},
                      ),
                    ),
                  ),
                  space(),
                  ElevatedButton(
                    onPressed: onMapSizeChange,
                    child: Text(Constant.labelRefresh),
                  ),
                  space(),
                  getLayerDropList(),
                  space(),
                  ElevatedButton(
                    onPressed: onSave,
                    child: Text(Constant.labelSave),
                  ),
                  space(),
                  ElevatedButton(
                    onPressed: onLoad,
                    child: Text(Constant.labelLoad),
                  ),
                ],
              ),
            ),
            Container(
                color: Colors.blue,
                width: double.infinity,
                height: tooltip!.height.toDouble(),
                child: GestureDetector(
                  onTapDown: onTapMap,
                  child: CustomPaint(painter: ToolTipPainter(mapImage: img, position: selectPosition),
                )),
            ),
            SizedBox(
              height: Constant.spaceSize.toDouble(),
            ),
            Container(
              color: Colors.white,
              width: double.infinity,
              height: screenSize.height - tooltip!.height.toDouble(),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTapDown: onPaintMap,
                  child: CustomPaint(painter: TileMapPainter(selectedPosition: selectPosition, mapImage: img, backLayer: backLayer, spriteLayer: spriteLayer))
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

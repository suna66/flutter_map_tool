import 'package:universal_html/html.dart' as html;
import 'dart:convert';

class Position {
  int x;
  int y;
  Position(this.x, this.y);
}

class TooltipInfo {
  int width;
  int height;
  int rowNum;
  int columnNum;

  TooltipInfo(this.width, this.height, this.rowNum, this.columnNum);
}

class CommonFunc {

  /// downloadFile
  ///
  static void downloadFile(String data, String filename) {
    //List<int> utf8String = [0xEF, 0xBB, 0xBF, ...utf8.encode(data)];
    List<int> utf8String = [...utf8.encode(data)];
    String base64String = base64Encode(utf8String);
    final anchor = html.AnchorElement(href: "data:text/plain;charset=utf-8;base64,$base64String");
    anchor.download = filename;
    anchor.click();
  }

  static String intListToCSVString(List<int> list) {
    return list.map<String>((int value) => value.toString()).join(',');
  }

  static List<int> csvStringToIntList(String csvString) {
    return csvString.split(',').map<int>((String item) => int.parse(item)).toList();
  }

  static String removeExtension(String filename) {
    List<String> strList = filename.split(".");
    if (strList.length == 1) {
      return filename;
    }
    String name = "";
    for (int i = 0; i < strList.length - 1; i++) {
      name += strList[i];
    }
    return name;
  }
}
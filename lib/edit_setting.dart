import 'package:maptool/const.dart';

class EditSetting {
    late int gridSize;
    late int mapRowNum;
    late int mapColumeNum;
    late String layerName; 

    static final EditSetting _instance = EditSetting._internal();

    factory EditSetting() {
        return _instance;
    }

    EditSetting._internal() {
        gridSize = 32;
        mapRowNum = 16;
        mapColumeNum = 16;
        layerName = Constant.valueBackGround;
    }
}
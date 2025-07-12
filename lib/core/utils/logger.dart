import 'package:flutter/foundation.dart';

class Logger {
  static void log(String msg){
    //prevents print statements on release version
    if(kDebugMode){
      print(msg);
    }
  }
}
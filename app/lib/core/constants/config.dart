import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    // 서버
    return 'http://119.205.220.249:8090';
    // return 'https://gentletalk.kr';


    // 로컬
    // Flutter Web(Chrome)으로 실행할 때
    // if (kIsWeb) {
    //   return 'http://localhost:8080';
    // }

    // // 모바일(Android / iOS)일 때
    // try {
    //   if (Platform.isAndroid) {
    //     // 안드로이드 에뮬레이터에서 PC의 localhost 접속
    //     return 'http://10.0.2.2:8080';
    //   } else if (Platform.isIOS) {
    //     return 'http://localhost:8080';
    //   }
    // } catch (_) {
    //   // Web 등 Platform.isXXX 안 되는 경우 대비
    // }

    // // 기본값
    // return 'http://localhost:8080';
  }
}
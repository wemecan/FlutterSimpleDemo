import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_rent/Constants.dart';
import 'package:flutter_rent/net/Api.dart';

class DioFactory {
  static Dio _dio;

  static DioFactory _instance;

  static DioFactory getInstance() {
    if (_instance == null) {
      _instance = new DioFactory._();
    }
    return _instance;
  }

  Options _baseOptions;

  //正在请求token中
  bool _isReqAccessTokenIng = false;

  DioFactory._() {
    //head 参数
    Map<String, String> head = new Map();
    head["debug"] = "0";
    head["version"] = "v1.0";
    head["city"] = "nj";
    head["access-token"] = accessToken;
    head["user-token"] = "a08b47e1e764063e3807a49e83c4124d";
    //基础请求参数设置
    _baseOptions = new Options(baseUrl: Api.base, headers: head);

    //请求类
    _dio = new Dio();
    _dio.options = _baseOptions;
    _dio.interceptor.response.onSuccess = (Response rsp) async {
      print("rsp->${rsp.data}");

      if (rsp.data != null && rsp.data["code"] == -996) {
        String accessToken = await reqAccessToken();
        print("new accessToken->$accessToken");
        rsp.request.headers["access-token"] = accessToken;
        var newRsp = await new Dio().get(rsp.request.path, options: rsp.request);
        print("rsp-new:${newRsp.data}");
        return newRsp;
      } else {
        return rsp;
      }
    };
    _dio.interceptor.request.onSend = (Options o) {
      print("req->${o.data}");
      return o;
    };
  }

  getDio() {
    return _dio;
  }


  reqAccessToken() async {
    if (_isReqAccessTokenIng) {
      return accessToken;
    }
    _isReqAccessTokenIng = true;
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String random = "abcdefghijklmn";
    String signature = "app_id=46877648&app_secret=kCkrePwPpHOsYYSYWTDKzvczWRyvhknG&"
        "device_id=$deviceId&rand_str=$random&timestamp=$timestamp";

    String url = Api.base + "58bf98c1dcb63?city=nj&timestamp=$timestamp"
        "&app_id=46877648&rand_str=" + random +
        "&signature=" + _generateMd5(signature) +
        "&device_id=" + deviceId;
    Response response = await new Dio().get(url, options: _baseOptions);
    print(response.data);

    if (response.data != null && response.data["code"] == 1) {
      accessToken = response.data["data"]["access_token"];
      _baseOptions.headers["access-token"] = accessToken;
//      SPUtil.getInstance().then((spUtil) {
//        SharedPreferences sp = spUtil.getSP();
//        sp.setString("access-token", accessToken);
//      });
    }
    _isReqAccessTokenIng = false;
    return accessToken;
  }

  String _generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }


}


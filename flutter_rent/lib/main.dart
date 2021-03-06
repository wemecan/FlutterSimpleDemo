import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rent/Constants.dart';
import 'package:flutter_rent/flutter_receiver.dart';
import 'package:flutter_rent/flutter_sender.dart';
import 'package:flutter_rent/net/DioFactory.dart';
import 'package:flutter_rent/ui/HomeHouseLIstPage.dart';
import 'package:flutter_rent/ui/HomeMsgPage.dart';
import 'package:flutter_rent/ui/HomePage.dart';
import 'package:flutter_rent/ui/HomeSelfPage.dart';

void main() {
  runApp(new MyApp());

  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.red,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
  }
}

class Page {
  static String page_1 = "page_1";
  static String page_2 = "page_2";
  static String page_3 = "page_3";
  static String page_4 = "page_4";
}

class MyWidgetsFlutterBinding extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    ImageCache cache = ImageCache();
    cache.maximumSize = 100;
    return cache;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    MediaQueryData.fromWindow(context.widget.window).padding.top
    return new MaterialApp(
        theme: new ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: new _StartPage(),
        routes: {
          'home': (BuildContext context) => new _MainPage(),
          'start': (BuildContext context) => new _StartPage(),
        });
  }
}

class _StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //延迟加载
    new Timer.periodic(Duration(seconds: 3), (timer) {
      timer.cancel();
      Navigator.pushNamedAndRemoveUntil(
          context, "home", (route) => route == null);
    });

    //获取token
    DioFactory.getInstance().reqAccessToken();

    //考虑安卓跟ios的加载快慢问题，需要单独优化
    return Container(
        color: Colors.white,
        child: Image.asset(
          ResImages.image_start,
          fit: BoxFit.cover,
        ));
// 直接绘制图片 会黑屏一下
//    return Image.asset(
//      ResImages.image_start,
//      fit: BoxFit.cover,
//    );
  }
}

class _MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    print("_MainPage createState");
    return new _MainPageState();
  }
}

class _MainPageState extends State<_MainPage>
    with AutomaticKeepAliveClientMixin {
  List<Widget> _pages;
  int _curPage = 0;

  List<ChooseItem> items;

  _itemClick(ChooseItem item) {
    if (_curPage != item.index) {
      _curPage = item.index;
      _pageCon.animateToPage(_curPage,
          duration: const Duration(milliseconds: 1), curve: Curves.linear);
    }
  }

  var _pageCon = PageController(keepPage: true);

  @override
  void initState() {
    new AppInit().init();
    super.initState();
    //只实现了安卓平台代码
    FlutterReceiver.PUSH.setMessageHandler((String app) {
      print("app 主动发送的消息：" + app);
      FlutterPlugin.showToast(app);
    });

    //FlutterView实现
    FlutterReceiver.lifecycle.setMessageHandler((String app) {
      print("lifecycle：" + app);
    });
    FlutterReceiver.lifecycle.setMockMessageHandler((String app) {
      print("lifecycle Mock：" + app);
    });

    print("_MainPageState initState");
    items = <ChooseItem>[
      new ChooseItem(0, "首页", Icons.home, choose: true, callback: _itemClick),
      new ChooseItem(1, "房源", Icons.collections,
          choose: false, callback: _itemClick),
      new ChooseItem(2, "消息", Icons.message, callback: _itemClick),
      new ChooseItem(3, "我的", Icons.account_box, callback: _itemClick),
    ];
    _pages = new List();
    _pages.add(new HomeView());
    _pages.add(new HouseListView());
    _pages.add(new MsgView());
    _pages.add(new SelfView());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView.builder(
          itemCount: _pages.length,
          itemBuilder: (c, index) {
            print("PageView itemBuilder ->$index");
            return _pages[index];
          },
          controller: _pageCon,
          physics: NeverScrollableScrollPhysics(),
        ),
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomAppBar(
            child: BottomBarParent(
              items: items,
              defaultChooseItem: items[_curPage],
              pageController: _pageCon,
            )));
  }

  @override
  bool get wantKeepAlive => true;
}

//管理一组底部按钮的单选状态
class BottomBarParent extends StatefulWidget {
  final List<ChooseItem> items;
  final ChooseItem defaultChooseItem; //默认选项
  final PageController pageController;

  const BottomBarParent(
      {Key key, this.items, this.defaultChooseItem, this.pageController})
      : super(key: key);

  @override
  BottomBarParentState createState() {
    return new BottomBarParentState();
  }
}

/// BottomBarParent 重新new了，但是createState没走, _BottomBarParentState 保存了之前组件的状态
class BottomBarParentState extends State<BottomBarParent> {
  ChooseItem curItem; //默认选项

  @override
  initState() {
    curItem = widget.defaultChooseItem;
    super.initState();
  }

  //bar点击的
  _itemBarClick(ChooseItem item) {
    if (curItem != item) {
      curItem.choose = false;
      item.choose = true;
      item.callback(item);
      setState(() {
        curItem = item;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.items.map((item) {
          return BottomBarItem(
            item: item,
            itemBarClick: _itemBarClick,
          );
        }).toList());
  }
}

class BottomBarItem extends StatelessWidget {
  final ChooseItem item;
  final Function itemBarClick;

  const BottomBarItem({Key key, this.item, this.itemBarClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) => barItem();

  Widget barItem() {
    return InkResponse(
      //没类型需要动态，定义typedef 回调，类型固定,
      onTap: () {
        itemBarClick(item);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              item.icon,
              color: item.choose ? item.selColor : item.norColor,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                item.title,
                style: TextStyle(
                    fontSize: 10.0,
                    color: item.choose ? item.selColor : item.norColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChooseItem {
  ChooseItem(this.index,
      this.title,
      this.icon, {
        this.choose = false,
        this.norColor = Colors.black,
        this.selColor = Colors.orangeAccent,
        this.callback,
      });

  final int index;
  final String title;
  final Color norColor;
  final Color selColor;
  final IconData icon;
  final Function callback;
  bool choose;
}

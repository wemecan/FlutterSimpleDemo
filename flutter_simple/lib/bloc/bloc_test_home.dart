import 'package:FlutterSimple/bloc/bloc_provider.dart';
import 'package:FlutterSimple/eventbus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlocTestPage extends StatelessWidget {
  final BlocProvider _blocProvider = new BlocProvider();

  int count = 0;

  @override
  Widget build(BuildContext context) {
    FlutterEventBus.register("click_event", (data) {
      print("BlocTestPage->$data");
    });

    print("BlocTestPage build");
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Bloc模式测试"),
      ),
      body: buildContent(context),
    );
  }

  Widget buildStream() {
    return StreamBuilder(
        stream: _blocProvider.intStream,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          print("BlocTestPage StreamBuilder build ${snapshot.data}");
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "index->${snapshot.data}",
              style: TextStyle(fontSize: 17.0),
            ),
          );
        });
  }

  Widget buildContent(BuildContext c) {
    return Column(
      children: <Widget>[
        buildStream(),
        GestureDetector(
          onTap: () {
            _blocProvider.addCount();
          },
          child: Container(
              width: 300.0,
              color: Colors.green,
              height: 50.0,
              child: Center(
                  child: Text(
                "点击修改值",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ))),
        ),
        MaterialButton(
          onPressed: () {
            Navigator.push(c, CupertinoPageRoute(builder: (c) {
              return _BlocSecondPage(_blocProvider);
            }));
          },
          child: Text("跳转下一页,数据需要共享"),
        ),

        MaterialButton(
          onPressed: () {
            FlutterEventBus.sendValue("click_event", count++);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("EventBus Test"),
          ),
        ),
      ],
    );
  }
}

class _BlocSecondPage extends StatelessWidget {
  final BlocProvider _blocProvider;

  const _BlocSecondPage(this._blocProvider);

  @override
  Widget build(BuildContext context) {
    print("_BlocSecondPage build");
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Bloc第二页"),
      ),
      body: buildContent(),
    );
  }

  Widget buildStream() {
    return StreamBuilder(
        stream: _blocProvider.intStream,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          print("_BlocSecondPage StreamBuilder build ${snapshot.data}");
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("index->${snapshot.data}"),
          );
        });
  }

  Widget buildContent() {
    return Column(
      children: <Widget>[
        buildStream(),
        GestureDetector(
          onTap: () {
            _blocProvider.addCount();
          },
          child: Container(
              width: double.infinity,
              color: Colors.blue,
              height: 50.0,
              child: Center(
                  child: Text(
                "点击修改值",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ))),

        ),
        MaterialButton(
          onPressed: () {
            FlutterEventBus.sendValue("click_event", "Hello Event");
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("EventBus Test"),
          ),
        ),
      ],
    );
  }
}

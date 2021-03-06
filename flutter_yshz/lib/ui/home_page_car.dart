import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_yshz/base.dart';
import 'package:flutter_yshz/bloc/bloc_provider.dart';
import 'package:flutter_yshz/bloc/car_bloc.dart';
import 'package:flutter_yshz/common/widget/pub_title_widget.dart';
import 'package:flutter_yshz/resource.dart';

class HomePageCar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageCarState();
}

class _HomePageCarState extends State<HomePageCar>
    with BaseConfig, AutomaticKeepAliveClientMixin, AutoBlocMixin {
  CarBloc _carBloc = new CarBloc();

  @override
  bool get wantKeepAlive => true;

  @override
  CarBloc get bloc => _carBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: bloc.stream,
        builder: (BuildContext c, AsyncSnapshot snap) {
          if (snap.hasData) {
            return buildChild(snap.data);
          } else if (snap.hasError) {
            return showErrorWidget();
          } else {
            return showLoadingWidget();
          }
        });
  }

  Future<void> _refreshLoadData() {
    return bloc.loadData();
  }

  Widget buildChild(CarBean data) {
    return Column(
      children: <Widget>[
        PubTitleWidget(
          titleText: "购物车",
          needBack: false,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshLoadData,
            child: new ListView.builder(
              padding: ResDimens.no_padding,
              itemBuilder: (c, index) {
                return Text("index $index");
              },
            ),
          ),
        ),
      ],
    );
  }
}

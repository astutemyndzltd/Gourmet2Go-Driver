import 'dart:async';

import 'package:Gourmet2GoDriver/src/repository/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';

class OrderController extends ControllerMVC {

  List<Order> orders = <Order>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  StreamSubscription onMessageSubscription;
  StreamSubscription onResumeSubscription;
  StreamSubscription onLaunchSubscription;
  StreamController notificationStreamController = StreamController();

  OrderController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    this.setupFirebaseMessageListeners();
  }

  setupFirebaseMessageListeners() {
    onMessageSubscription = firebaseMessagingStreams.onMessageStream.listen(onReceiveFirebaseMessage);
    onResumeSubscription = firebaseMessagingStreams.onResumeStream.listen(onReceiveFirebaseMessage);
    onLaunchSubscription = firebaseMessagingStreams.onLaunchStream.listen(onReceiveFirebaseMessage);
  }

  @override
  void dispose() {
    onMessageSubscription.cancel();
    onResumeSubscription.cancel();
    onLaunchSubscription.cancel();
    super.dispose();
  }

  onReceiveFirebaseMessage(Map<String, dynamic> message) {
    this.refreshOrders();
    notificationStreamController.sink.add(message);
  }

  void listenForOrders({String message}) async {

    final Stream<Order> streamOfOrders = await getOrders();

    streamOfOrders.listen((order) => orders.add(order), onDone: () {
      orders.sort((order1, order2) => -1 * int.parse(order1.id).compareTo(int.parse(order2.id)));
      setState((){});
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });

  }

  void listenForOrdersHistory({String message}) async {
    final Stream<Order> stream = await getOrdersHistory();
    stream.listen((Order _order) {
      setState(() {
        orders.add(_order);
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshOrdersHistory() async {
    orders.clear();
    listenForOrdersHistory(message: S.of(context).order_refreshed_successfuly);
  }

  Future<void> refreshOrders() async {
    orders.clear();
    listenForOrders(message: S.of(context).order_refreshed_successfuly);
  }

}

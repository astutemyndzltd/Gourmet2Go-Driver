import 'dart:async';

import 'package:Gourmet2GoDriver/src/models/route_argument.dart';
import 'package:Gourmet2GoDriver/src/repository/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';

class OrderDetailsController extends ControllerMVC {
  Order order;
  GlobalKey<ScaffoldState> scaffoldKey;
  ValueNotifier<int> minutesRemaining = new ValueNotifier(0);

  StreamSubscription onMessageSubscription;
  StreamSubscription onResumeSubscription;
  StreamSubscription onLaunchSubscription;

  bool statusChanging = false;

  OrderDetailsController() {
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
    this.refreshOrder();
  }

  void listenForOrder({String id, String message}) async {
    final Stream<Order> stream = await getOrder(id);
    stream.listen((Order _order) {
      setState(() => order = _order);
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      startTimer();

      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshOrder() async {
    listenForOrder(id: order.id, message: S.of(context).order_refreshed_successfuly);
  }

  void doDeliveredOrder(Order _order) async {
    deliveredOrder(_order).then((value) {
      setState(() { this.order.orderStatus.id = '5'; });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(content: Text('Order status has been changed successfully')));
      Future.delayed(Duration(seconds: 2), () => Navigator.pushNamed(context, '/Pages', arguments: RouteArgument(id: '2')));
    });
  }

  startTimer() {
    minutesRemaining.value = order.statusDurationLeft;
    Timer.periodic(Duration(minutes: 1), (timer) {
      minutesRemaining.value--;
      if (minutesRemaining.value <= 0) timer.cancel();
    });
  }
}

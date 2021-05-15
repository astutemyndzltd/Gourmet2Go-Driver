import 'package:Gourmet2GoDriver/src/models/order.dart';
import 'package:Gourmet2GoDriver/src/repository/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/notification.dart' as model;
import '../repository/notification_repository.dart';

class NotificationController extends ControllerMVC {

  List<Order> orders = [];
  List<model.Notification> notifications = <model.Notification>[];
  int unReadNotificationsCount = 0;
  GlobalKey<ScaffoldState> scaffoldKey;

  NotificationController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    //listenForNotifications();
    listenForOrders();
  }

  void listenForOrders({String message}) async {
    final Stream<Order> streamOfOrders = await getOrders();
    streamOfOrders.listen((order) { orders.add(order); }, onDone: () {
      setState(() => unReadNotificationsCount = orders.length);
    });
  }

  void listenForNotifications({String message}) async {
    final Stream<model.Notification> stream = await getNotifications();
    stream.listen((model.Notification _notification) {
      setState(() { notifications.add(_notification); });
    }, onError: (a) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (notifications.isNotEmpty) {
        unReadNotificationsCount = notifications.where((model.Notification _n) => !_n.read ?? false).toList().length;
      } else {
        unReadNotificationsCount = 0;
      }
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshNotifications() async {
    orders.clear();
    listenForOrders(message: S.of(context).notifications_refreshed_successfuly);
  }

  refreshOrderCount() {
    orders.clear();
    listenForOrders();
  }


  void doMarkAsReadNotifications(model.Notification _notification) async {
    markAsReadNotifications(_notification).then((value) {
      setState(() {
        --unReadNotificationsCount;
        _notification.read = !_notification.read;
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('This notification has marked as read'),
      ));
    });
  }

  void doMarkAsUnReadNotifications(model.Notification _notification) {
    markAsReadNotifications(_notification).then((value) {
      setState(() {
        ++unReadNotificationsCount;
        _notification.read = !_notification.read;
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('This notification has marked as un read'),
      ));
    });
  }

  void doRemoveNotification(model.Notification _notification) async {
    removeNotification(_notification).then((value) {
      setState(() {
        if (!_notification.read) {
          --unReadNotificationsCount;
        }
        this.notifications.remove(_notification);
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Notification was removed'),
      ));
    });
  }


}

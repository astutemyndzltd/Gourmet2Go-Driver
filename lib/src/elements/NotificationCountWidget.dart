import 'dart:async';

import 'package:Gourmet2GoDriver/src/models/route_argument.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/notification_controller.dart';

class NotificationCountWidget extends StatefulWidget {

  const NotificationCountWidget({this.iconColor, this.labelColor, this.notificationStream, Key key}) : super(key: key);

  final Color iconColor;
  final Color labelColor;
  final Stream notificationStream;

  @override
  _NotificationCountWidgetState createState() => _NotificationCountWidgetState();
}

class _NotificationCountWidgetState extends StateMVC<NotificationCountWidget> {

  NotificationController _con;

  _NotificationCountWidgetState() : super(NotificationController()) {
    _con = controller;
  }


  @override
  void initState() {
    //_con.listenForCartsCount();
    widget.notificationStream?.listen((ev) => _con.refreshOrderCount());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.of(context).pushNamed('/Pages', arguments: RouteArgument(id: '1'));
      },
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: <Widget>[
          Icon(
            Icons.notifications_none,
            color: this.widget.iconColor,
            size: 28,
          ),
          Container(
            child: Text(
              _con.unReadNotificationsCount.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption.merge(
                    TextStyle(color: Theme.of(context).primaryColor, fontSize: 8, height: 1.3),
                  ),
            ),
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(color: this.widget.labelColor, borderRadius: BorderRadius.all(Radius.circular(10))),
            constraints: BoxConstraints(minWidth: 13, maxWidth: 13, minHeight: 13, maxHeight: 13),
          ),
        ],
      ),
      color: Colors.transparent,
    );
  }
}

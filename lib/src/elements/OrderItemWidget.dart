import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/route_argument.dart';
import 'FoodOrderItemWidget.dart';

class OrderItemWidget extends StatefulWidget {
  final bool expanded;
  final Order order;
  final ValueChanged<void> onCanceled;

  OrderItemWidget({Key key, this.expanded, this.order, this.onCanceled}) : super(key: key);

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: widget.order.active ? 1 : 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 14),
                padding: EdgeInsets.only(top: 20, bottom: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    Theme(
                      data: theme,
                      child: ExpansionTile(
                        initiallyExpanded: widget.expanded,
                        title: Column(
                          children: <Widget>[
                            Text('${S.of(context).order_id}: #${widget.order.id}'),
                            Text(
                              DateFormat('dd-MM-yyyy | HH:mm').format(widget.order.dateTime),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Helper.getPrice(Helper.getTotalOrdersPrice(widget.order), context, style: Theme.of(context).textTheme.headline4),
                            Text(
                              'Card - ${widget.order.payment.method} | ${widget.order.orderType}${widget.order.preorderInfo != null ? ' | Pre-Order' : ''}',
                              style: Theme.of(context).textTheme.caption,
                            )
                          ],
                        ),
                        children: <Widget>[
                          Column(
                              children: List.generate(
                                widget.order.foodOrders.length,
                                    (indexFood) {
                                  return FoodOrderItemWidget(heroTag: 'mywidget.orders', order: widget.order, foodOrder: widget.order.foodOrders.elementAt(indexFood));
                                },
                              )),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        S.of(context).delivery_fee,
                                        style: Theme.of(context).textTheme.bodyText1,
                                      ),
                                    ),
                                    Helper.getPrice(widget.order.deliveryFee, context, style: Theme.of(context).textTheme.subtitle1)
                                  ],
                                ),
                                /*Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        'Tax (${widget.order.tax}%)',
                                        style: Theme.of(context).textTheme.bodyText1,
                                      ),
                                    ),
                                    Helper.getPrice(Helper.getTaxOrder(widget.order), context, style: Theme.of(context).textTheme.subtitle1)
                                  ],
                                ),*/
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        S.of(context).total,
                                        style: Theme.of(context).textTheme.bodyText1,
                                      ),
                                    ),
                                    Helper.getPrice(Helper.getTotalOrdersPrice(widget.order), context, style: Theme.of(context).textTheme.headline4)
                                  ],
                                ),
                                Row(children: <Widget>[
                                  Container(
                                    child: Text(
                                      'Note',
                                      style: Theme.of(context).textTheme.bodyText1,
                                    ),
                                    width: 60,
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        widget.order.note,
                                        style: Theme.of(context).textTheme.bodyText2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                ]),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    // View Button
                    Container(
                      //color: Colors.green,
                      width: double.infinity,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16, bottom: 15, top: 15),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed('/OrderDetails', arguments: RouteArgument(id: widget.order.id));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                color: Theme.of(context).accentColor,
                              ),
                              child: Text(
                                'View Details',
                                //S.of(context).pickup,
                                style: TextStyle(color: Theme.of(context).primaryColor ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsetsDirectional.only(start: 20),
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 28,
          width: 140,
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100)), color: widget.order.active ? Theme.of(context).accentColor : Colors.redAccent),
          alignment: AlignmentDirectional.center,
          child: Text(
            widget.order.active ? '${widget.order.orderStatus.status}' : 'Cancel',
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context).textTheme.caption.merge(TextStyle(height: 1, color: Theme.of(context).primaryColor)),
          ),
        ),
      ],
    );
  }
}

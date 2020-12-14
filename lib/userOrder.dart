import 'dart:convert';

import 'package:flutter/material.dart';
import 'Products.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'Homepage.dart';
import 'ProductCreation.dart';
import 'userProducts.dart';
import 'Orders.dart';

class UserOrders extends StatefulWidget {
  UserOrders(this.jwt, this.payload);

//to get the user information in the payload
  factory UserOrders.fromBase64(String jwt) => UserOrders(
      jwt,
      json.decode(
          utf8.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));

  final String jwt;
  final Map<String, dynamic> payload;

  @override
  _UserOrdersState createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List ordersList;

  //products count
  int OrdersCount;

  //http healper
  Orders Helper;
  String Orderdate,day,time;
  int totalprice;
  @override
  void initState() {
    // TODO: implement initState
    Helper = Orders();
    ordersList = List();
    OrdersCount = 0;
    getUserOrders();

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader( accountName: Text("Joan Holloway"),
              accountEmail: Text(widget.payload['email']),
              currentAccountPicture: CircleAvatar(

                child:  ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: Image.asset("assets/img.jpg", width: 80, height: 80, fit: BoxFit.fill,),
                ),
              ),) ,
            
            ListTile(
              title: Text("All Product"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage.fromBase64(widget.jwt)));
              },
            ),
            ListTile(
              title: Text("My Product"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            UserProducts.fromBase64(widget.jwt)));
              },
            ),
            ListTile(
                title: Text("My Orders"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserOrders.fromBase64(widget.jwt)));
                })
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("My Orders"),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        onLoading: _onRefresh,
        onRefresh: _onRefresh,
        controller: _refreshController,


        child:  (ordersList.length<1)?Center(child: CircularProgressIndicator()):ListView.builder(
            itemCount: OrdersCount,
            itemBuilder: (BuildContext context, int position) {
               Orderdate=ordersList[position].date;
               day = Orderdate.substring(0,10);
               time= Orderdate.substring(11,Orderdate.length-5);
                totalprice =ordersList[position].quantity*ordersList[position].productPrice;
              print(time);
              return Card(
                color: Colors.white,
                elevation: 2.0,
                child: ListTile(
                  title: Text("${ordersList[position].productName}"),
                  subtitle:Column( crossAxisAlignment: CrossAxisAlignment.start,children: [
                    Text("Quantity: ${ordersList[position].quantity.toString()}"),
                    Text("Total Price: ${totalprice} SDG"),
                  ],) ,
                  //Text("Quantity: ${ordersList[position].quantity.toString()}"),
                  isThreeLine: true,
                  trailing:Column( crossAxisAlignment: CrossAxisAlignment.end,children: [
                    Text(day),
                    Text(time)
                  ],) ,
                ),
              );
            }),
      ),
    );
  }

  getUserOrders() async {
    print(widget.payload['id']);
    ordersList = await Helper.getUserOrders(widget.payload['id']);
    OrdersCount = ordersList.length;
    setState(() {
      ordersList = ordersList;
      OrdersCount = OrdersCount;
    });
  }


  _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    ordersList = List();
    String userId = widget.payload['id'];
    ordersList = await Helper.getUserOrders(userId);

    setState(() {
      OrdersCount = ordersList.length;
      ordersList = ordersList;
    });
    _refreshController.refreshCompleted();
  }
}


import 'dart:convert';

import 'package:flutter/material.dart';
import 'Products.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'Homepage.dart';
import 'ProductCreation.dart';
import 'userOrder.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:cached_network_image/cached_network_image.dart';



class UserProducts extends StatefulWidget {

  UserProducts(this.jwt, this.payload);

//to get the user information in the payload
  factory UserProducts.fromBase64(String jwt) => UserProducts(
      jwt,
      json.decode(
          utf8.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));

  final String jwt;
  final Map<String, dynamic> payload;

  @override
  _UserProductsState createState() => _UserProductsState();
}

class _UserProductsState extends State<UserProducts> {

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  List productss;

  //products count
  int productCount;

  //http healper
  Products Helper;
//imagesurl
  String imageP;
  String userID;


  @override
  void initState() {
    // TODO: implement initState
  Helper = Products();
  imageP = "http://192.168.43.250:3000/";
  getAlluserProduct();
    super.initState();


  }

  @override
  Widget build(BuildContext context) {

  PopupMenu.context=context;
  GlobalKey keyBtn = GlobalKey();
    int length = productss.length;
    var size= MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 100) / 2;
    final double itemWidth = size.width / 2;


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
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>HomePage.fromBase64(widget.jwt)));
                },
              ),
              ListTile(
                title: Text("My Product"),
                onTap: () {

                  Navigator.push(context, MaterialPageRoute(builder: (context)=> UserProducts.fromBase64(widget.jwt)));
                }
                ,
              ),
              ListTile(title: Text("My Orders"), onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> UserOrders.fromBase64(widget.jwt)));

              })
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(backgroundColor: Colors.yellowAccent.shade400,
          onPressed: () {
            Navigator.push(context ,
                MaterialPageRoute(builder: (context) =>
                    ProductCreation.fromBase64(widget.jwt)));
          } ,
          child: Icon(Icons.add,color: Colors.black,) ,
        ),
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("My Products"),
        ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: WaterDropHeader(),
          onLoading: _onRefresh,
          onRefresh: _onRefresh,
          controller: _refreshController,
          child: (productss.length<1)?Center(child: CircularProgressIndicator()): GridView.count(
childAspectRatio: (itemWidth/itemHeight),
            crossAxisCount: 2,
            children: List.generate(length, (index) {
              String imageurl;
              String path = productss[index].productImage;
              String cPath;
              if (path == null) {
                cPath='';

                imageurl = "https://www.indiaspora.org/wp-content/uploads/2018/10/image-not-available.jpg";

              } else {
                cPath = path.replaceRange(7, 7, "/");
                imageurl = imageP + cPath;
              }

              print(imageP + cPath);

              return InkWell(
                onDoubleTap: (){
deleteProduct(index);
                },
                child: Card(

                  elevation: 3.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    verticalDirection: VerticalDirection.down,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Image.network(
                          imageurl,
                          height: 130.0,
                          width: 100.0,
                            loadingBuilder: (BuildContext context,Widget child ,ImageChunkEvent loadingProgress){
                              if (loadingProgress==null)return child;
                              return CachedNetworkImage(
                                imageUrl: imageurl,
                                placeholder: (context,url) => Center(child: CircularProgressIndicator()),
                                errorWidget: (context,url,error) => new Icon(Icons.error),
                              );
                            },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 9.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                             Padding(
                               padding: const EdgeInsets.only(bottom: 5,top: 3),
                               child: Text(productss[index].name,style: TextStyle(
                                 fontSize: 16,
                                 fontWeight: FontWeight.bold,

                                 foreground: Paint()
                                   ..style = PaintingStyle.fill
                                   ..strokeWidth = 7
                                   ..color = Colors.black,),),
                             ),
                             Row(
                               children:<Widget>[
                                 Text("Price: ",style: TextStyle(
                                   fontSize: 15,
                                   foreground: Paint()
                                     ..style = PaintingStyle.stroke
                                     ..strokeWidth = 1
                                     ..color = Colors.yellow.shade900,),),
                                 Text(productss[index].price.toString() +" SDG")

                               ]
                             ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          ),
        ));
  }



  Future getAlluserProduct() async {
    productss = List();


    String userId = widget.payload['id'];
    print(userId);
    productss = await Helper.getUserProduct(userId);

    setState(() {
      productCount = productss.length;
      productss = productss;
    });


  }


  _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    productss = List();
    String userId = widget.payload['id'];
    print(userId);
    productss = await Helper.getUserProduct(userId);

    setState(() {
      productCount = productss.length;
      productss = productss;
    });
    _refreshController.refreshCompleted();
  }

  deleteProduct(int index)async{
    Helper.deleteProduct(productss[index].id);
    productss = List();
    String userId = widget.payload['id'];
    productss = await Helper.getUserProduct(userId);
    setState(() {
      productCount = productss.length;
      productss = productss;
    });
  }


  }

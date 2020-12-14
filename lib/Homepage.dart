import 'dart:convert';
import 'Products.dart';
import 'package:flutter/material.dart';

import 'ProductCreation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'userProducts.dart';
import 'ProductDetails.dart';
import 'userOrder.dart';

import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
  HomePage(this.jwt, this.payload);

//to get the user information in the payload
  factory HomePage.fromBase64(String jwt) => HomePage(
      jwt,
      json.decode(
          utf8.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));

  final String jwt;
  final Map<String, dynamic> payload;
}

class _HomePageState extends State<HomePage> {
  //all products
  List productss;

  //products count
  int productCount;

  //http healper
  Products Helper;

//imagesurl
  String imageP;

  //for refreach
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  bool refreshDeterminer;

  //for the search function
  Icon visibleIcon = Icon(Icons.search);
  Widget searchBar = Text('All Products');
  String productname;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Helper = Products();
    getAllProduct();
    imageP = "http://192.168.43.250:3000/";
    refreshDeterminer = true;
  }

  @override
  Widget build(BuildContext context) {
    //getting the user id for my product page

    var size= MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 100) / 2;
    final double itemWidth = size.width / 2;

    NetworkImage image;

    int length = productss.length;

    return Scaffold(

        drawer: Drawer(
          child: ListView(
            children: [


                UserAccountsDrawerHeader( accountName: (widget.payload['username']!=null)?Text(widget.payload['username']):Text(""),
                  accountEmail: Text(widget.payload['email']),
                  currentAccountPicture: CircleAvatar(

                    child:  ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: Image.asset("assets/img.jpg", width: 80, height: 80, fit: BoxFit.fill,),
                    ),
                  ),) ,
              ListTile(
                title: Text("All Product") ,
                onTap: () {
                  Navigator.push(context , MaterialPageRoute(
                      builder: (context) => HomePage.fromBase64(widget.jwt)));
                } ,
              ) ,
              ListTile(
                title: Text("My Product") ,
                onTap: () {
                  Navigator.push(context , MaterialPageRoute(
                      builder: (context) =>
                          UserProducts.fromBase64(widget.jwt)));
                }
                ,
              ) ,
              ListTile(title: Text("My Orders") , onTap: () {
                Navigator.push(context , MaterialPageRoute(
                    builder: (context) => UserOrders.fromBase64(widget.jwt)));
              })
            ] ,
          ) ,
        ) ,
        floatingActionButton: FloatingActionButton(backgroundColor: Colors.yellowAccent.shade400,
          onPressed: () {
            Navigator.push(context ,
                MaterialPageRoute(builder: (context) =>
                    ProductCreation.fromBase64(widget.jwt)));
          } ,
          child: Icon(Icons.add,color: Colors.black,) ,
        ) ,
        appBar: AppBar(

          title: searchBar ,
          actions: [
            IconButton(icon: visibleIcon , onPressed: () {
              setState(() {
                if (this.visibleIcon.icon == Icons.search) {
                  this.visibleIcon = Icon(Icons.cancel);
                  this.searchBar =
                      TextField(
                        textInputAction: TextInputAction.search ,
                        onSubmitted: (String text) {
                          productname = text;
                          refreshDeterminer = false;
                          getSearchedProducts(text);
                        } ,
                        style: TextStyle(
                          color: Colors.white ,
                          fontSize: 20.0 ,) ,
                      );
                }
                else {
                  setState(() {
                    this.visibleIcon = Icon(Icons.search);
                    this.searchBar = Text('Products');
                    refreshDeterminer = true;
                    getAllProduct();
                  });
                }
              });
            })
          ] ,
        ) ,
        body: SmartRefresher(
          enablePullDown: true ,
          enablePullUp: false ,
          header: WaterDropHeader() ,
          onLoading: (){  if(refreshDeterminer== true){return _onRefresh();}else{
            print(productname);

            return _onSearchRefresh(productname);
          } } ,
          onRefresh:(){  if(refreshDeterminer== true){return _onRefresh();}else{
            print(productname);

           return  _onSearchRefresh(productname);
          } },
          controller: _refreshController ,
          child: (productss.length<1)?Center(child: CircularProgressIndicator()):GridView.count(
            childAspectRatio: (itemWidth/itemHeight),
            crossAxisCount: 2 ,
            children: List.generate(length , (index) {
              String imageurl;
              String path = productss[index].productImage;
              String cPath;
              if (path == null) {
                cPath = '';

                imageurl =
                "https://www.indiaspora.org/wp-content/uploads/2018/10/image-not-available.jpg";
              } else {
                cPath = path.replaceRange(7 , 7 , "/");
                imageurl = imageP + cPath;
              }


              print(imageP + cPath);

              return GestureDetector(
                onTap: () {
                  MaterialPageRoute route = MaterialPageRoute(builder: (_) =>
                      ProductDetail.fromBase64(widget.jwt , productss[index]));
                  Navigator.push(context , route);
                } ,
                child: Card(

                  elevation: 3.0 ,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch ,
                    mainAxisSize: MainAxisSize.min ,
                    verticalDirection: VerticalDirection.down ,

                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10 , right: 10) ,
                        child: Image.network(
                          imageurl ,
                          height: 130.0 ,
                          width: 100.0 ,
                          loadingBuilder: (BuildContext context,Widget child ,ImageChunkEvent loadingProgress){
                            if (loadingProgress==null)return child;
                            return CachedNetworkImage(
                              imageUrl: imageurl,
                              placeholder: (context,url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context,url,error) => new Icon(Icons.error),
                            );
                          },

                        ) ,
                      ) ,
                      Padding(
                        padding: EdgeInsets.only(left: 9.0) ,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start ,
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
                      ) ,
                            Row(
                                children:<Widget>[
                                  Text("Price ",style: TextStyle(
                                    fontSize: 15,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 1
                                      ..color = Colors.orange.shade900,),),
                                  Text(productss[index].price.toString() +" SDG")

                                ]
                            ),
                          ] ,
                        ) ,
                      )
                    ] ,
                  ) ,
                ) ,
              );
            }) ,
          ) ,
        ));
  }

  Future getAllProduct() async {
    productss = List();

    productss = await Helper.getProduct();

    setState(() {
      productCount = productss.length;
      productss = productss;
    });
  }


  Future getSearchedProducts(String ProductName) async {
    productss = List();

    productss = await Helper.searchProduct(ProductName);

    setState(() {
      productCount = productss.length;
      productss = productss;
    });
  }

  //for the refresh pulldown
  _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    productss = List();

    productss = await Helper.getProduct();

    setState(() {
      productCount = productss.length;
      productss = productss;
    });
    _refreshController.refreshCompleted();
  }



  _onSearchRefresh(String ProductName) async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    productss = List();

    productss = await Helper.searchProduct(ProductName);

    setState(() {
      productCount = productss.length;
      productss = productss;
    });
    _refreshController.refreshCompleted();


  }



}
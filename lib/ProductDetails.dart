import 'dart:convert';

import 'package:flutter/material.dart';
import 'Product.dart';
import 'Orders.dart';
import 'Order.dart';
import 'package:progress_dialog/progress_dialog.dart';



class ProductDetail extends StatefulWidget {


  ProductDetail(this.jwt, this.payload, this.product);

  final String jwt;
  final Map<String, dynamic> payload;
  final Product product;

  factory ProductDetail.fromBase64(String jwt, Product product) =>
      ProductDetail(
          jwt,
          json.decode(
              utf8.decode(base64.decode(base64.normalize(jwt.split(".")[1])))),
          product);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
//image related
  ProgressDialog pr;

  String path;
  String imageurl;
  String cPath;
  int priceCounter;
  Orders helper;

  String imageP,userid;





  @override
  void initState() {
    userid =widget.payload['id'] ;
    imageP = "http://192.168.43.250:3000/";
    priceCounter = 1;
    helper = Orders();

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    path = widget.product.productImage;
    if (path == null) {
      cPath = '';

      imageurl =
          "https://www.indiaspora.org/wp-content/uploads/2018/10/image-not-available.jpg";
    } else {
      cPath = path.replaceRange(7, 7, "/");
      imageurl = imageP + cPath;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                height: height / 1.7,
                child: Image.network(imageurl),
              ),
              Container(
                padding: EdgeInsets.only(left: 16, right: 16 ,bottom: 40),
                child: Text("${widget.product.productDetails}"),
              ),

              //the add/minus counter
              Container(
                
                
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Price",style: TextStyle(
                      fontSize: 20,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1
                        ..color = Colors.orange.shade900,),),
                    Text("${widget.product.price*priceCounter}"+" SDG"),
                    Container(
                      width:40,
                      height:40,
                      child: FittedBox(
                        child: FloatingActionButton(
                          heroTag: "btn1",
                          onPressed: subtract,
                          child: Icon(Icons.remove ,color: Colors.black,),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),

                    Text(
                      "${priceCounter.toString()}",
                      style: TextStyle(fontSize: 15),
                    ),
                   FittedBox(child: Container(
                     width: 40,
                     height: 40,
                     child: FittedBox(
                       child: FloatingActionButton(
                          
                          heroTag: "btn2",
                          onPressed: add,
                          child: Icon(Icons.add ,color: Colors.black,),
                          backgroundColor: Colors.white,

                        ),
                     ),
                   ),
                   )
                  ],
                ),

              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Container(
                  child: ButtonTheme(minWidth: 250,height: 45,
                    child: RaisedButton( onPressed:(){

                      chooseDisplayDialog(context, "Confirmation", "Press Confirm to make your order");
                    }




                    ,color: Colors.yellowAccent.shade400, shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),


                    ) ,child: Text("Order Now",style: TextStyle(color: Colors.black),),),
                  ),
              ))

            ],

          ),

        ),

      ),
    );
  }


  void add(){


    priceCounter = priceCounter+1;
    setState(() {
    priceCounter = priceCounter;

    });

  }

  void subtract(){
if(priceCounter>0) {
  priceCounter = priceCounter - 1;
  setState(() {
    priceCounter = priceCounter;
  });
}
else{


  setState(() {
    priceCounter = priceCounter;
  });

}
  }



  void progressDialog(BuildContext context , String text) {
    pr = ProgressDialog(
        context , type: ProgressDialogType.Normal ,
        textDirection: TextDirection.rtl ,
        isDismissible: true
    );

    pr.style(
//      message: 'Downloading file...',
      message:
      text ,
      borderRadius: 10.0 ,
      backgroundColor: Colors.black ,
      elevation: 10.0 ,
      insetAnimCurve: Curves.bounceIn ,
      progress: 0.0 ,
      progressWidgetAlignment: Alignment.center ,
      maxProgress: 100.0 ,
      progressTextStyle: TextStyle(
          color: Colors.white , fontSize: 13.0 , fontWeight: FontWeight.w400) ,
      messageTextStyle: TextStyle(
          color: Colors.white , fontSize: 19.0 , fontWeight: FontWeight.w600) ,
    );
    Duration duration = Duration(seconds: 10);
    pr.show();
  }

   order() async{

    progressDialog(context,"...Please Wait");

    print(widget.product.id);
    print(priceCounter);
     String res = await helper.sendOrders(widget.product.id, priceCounter,userid);

if(res=="s"){

      pr.hide();
      displayDialog(context, "Success", "your order have been saved");

    }
    if(res=="f"){


      pr.hide();
      displayDialog(context, "Failed", "Somthing went wrong, Check your internet connection and try again");

    }
    if(res == "e"){
      displayDialog(context, "Failed", "Somthing went wrong, Check your internet connection and try again");


      pr.hide();
    }



  }

  Future chooseDisplayDialog(BuildContext context, String title, String text) {


    Widget confirm = FlatButton(onPressed: (){             Navigator.of(context).pop();     order();
     // dismiss dialog
    }, child: Text("Confirm",style: TextStyle(color:Colors.blue[500])),);

    Widget cancel = FlatButton(onPressed: (){    Navigator.of(context).pop(); // dismiss dialog
    }, child: Text("Cancel",style: TextStyle(color:Colors.blue[500])),);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        elevation: 27,
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        actions: [confirm,cancel],
        content: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }


  Future displayDialog(BuildContext context , String title , String text) {
    showDialog(

      context: context ,
      builder: (context) =>
          AlertDialog(
            backgroundColor: Colors.black,
            elevation: 27,
            title: Text(title,style: TextStyle(color: Colors.white),) ,
            content: Text(text,style: TextStyle(color: Colors.white),
            ) ,
          ) ,
    );
  }

}

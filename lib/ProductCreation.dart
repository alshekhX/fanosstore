import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Products.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
class ProductCreation extends StatefulWidget {
  @override
  _ProductCreationState createState() => _ProductCreationState();
  ProductCreation(this.jwt, this.payload);

//to get the user information in the payload
  factory ProductCreation.fromBase64(String jwt) => ProductCreation(
      jwt,
      json.decode(
          utf8.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));

  final String jwt;
  final Map<String, dynamic> payload;
}

class _ProductCreationState extends State<ProductCreation> {
  TextEditingController nameControler ,
      priceController ,
      productDetailsController;
  ProgressDialog pr;

  Products products;
  String userid;
  //File _image;
File _image;
  File _image2;

  File _image3;

  final picker = ImagePicker();
  List<Asset> images =List<Asset>();
  List path;


  String name;

  String price;

  String productDetails;

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    nameControler = TextEditingController();
    priceController = TextEditingController();
    productDetailsController = TextEditingController();

    products = Products();
    userid = widget.payload['id'];
  }

  @override
  Widget build(BuildContext context) {
    final node= FocusScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Post your Product') ,
      ) ,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(

              leading: Icon(Icons.shopping_bag_outlined) ,
              title: TextField(maxLengthEnforced: true,
                textInputAction: TextInputAction.next,          onEditingComplete: () => node.nextFocus(),
                maxLength: 35,
                controller: nameControler ,
                decoration: InputDecoration(hintText: "Name") ,
              ) ,
            ) ,
            ListTile(
              leading: Icon(Icons.attach_money_outlined) ,
              title: TextField(keyboardType:TextInputType.number ,
                textInputAction: TextInputAction.next,          onEditingComplete: () => node.nextFocus(),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: priceController ,
                decoration: InputDecoration(hintText: "Price") ,
              ) ,
            ) ,
            ListTile(
              leading: Icon(Icons.description_outlined) ,
              title: TextField( textInputAction: TextInputAction.next,
              maxLines: null,
              onEditingComplete: () => node.nextFocus(),
                controller: productDetailsController ,
                decoration: InputDecoration(hintText: "Product Details") ,
              ) ,
            ) ,
            ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(
                  left: 55 ,
                  top: 20 ,
                ) ,
                child: RaisedButton(
                  color: Colors.blue ,
                  onPressed: () {


                    _showPicker(context);
                  } ,
                  child: Text(
                    "Upload Images" ,
                    style: TextStyle(color: Colors.white) ,
                  ) ,
                ) ,
              ) ,
            ) ,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(

                children:<Widget>[
              (_image == null)


                  ? Container()
                  : InkWell(
                  onDoubleTap: (){
                    setState(() {
                      _image=null;
                    });},
                    child: Padding(
                padding: const EdgeInsets.all(8.0) ,
                child: Center(
                    child: Container(
                      width: 100,
                      height: 100,

                      child: Image.file(
                        _image ,
                      ),
                    ),
                )
                    ,
              ),
                  ) ,
              (_image2 == null)
                  ? Container()
                  : InkWell(
                onDoubleTap: (){
                  setState(() {
                    _image2=null;
                  });
                },
                    child: Padding(
                padding: const EdgeInsets.all(8.0) ,
                child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      child: Image.file(
                        _image2 ,
                      ),
                    ),
                )
                ,
              ),
                  ),
              (_image3 == null)
                  ? Container()
                  : InkWell(
                  onDoubleTap: (){
                    setState(() {
                      _image3=null;
                    });},
                    child: Padding(
                padding: const EdgeInsets.all(8.0) ,
                child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      child: Image.file(
                        _image3 ,
                      ),
                    ),
                )
                ,
              ),
                  ),]),
            ),
            Padding(
              padding: const EdgeInsets.only(top:28),
              child: Container(
                width: 180 ,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)) ,
                  child: Text(
                    "Post" ,
                    style: TextStyle(color: Colors.black) ,
                  ) ,
                  color: Colors.yellowAccent.shade400 ,
                  onPressed: () {
                    CreateProduct();
                  } ,
                ) ,
              ),
            ) ,
          ] ,
        ) ,
      ) ,
    );
  }


  Future displayDialog(BuildContext context , String title , String text) {

    showDialog(
      context: context ,
      builder: (context) =>
          AlertDialog(
            backgroundColor: Colors.black ,
            elevation: 27 ,
            title: Text(
              title ,
              style: TextStyle(color: Colors.white) ,
            ) ,
            content: Text(
              text ,
              style: TextStyle(color: Colors.white) ,
            ) ,
          ) ,
    );
  }

  Future chooseDisplayDialog(BuildContext context , String title ,
      String text) {
    Widget confirm = FlatButton(onPressed: () {
      Navigator.of(context).pop();
      confirmation();
       // dismiss dialog
    } , child: Text("Confirm" , style: TextStyle(color: Colors.blue[500])) ,);

    Widget cancel = FlatButton(onPressed: () {
      Navigator.of(context).pop(); // dismiss dialog
    } , child: Text("Cancel" , style: TextStyle(color: Colors.blue[500])) ,);

    showDialog(
      context: context ,
      builder: (context) =>
          AlertDialog(
            backgroundColor: Colors.black ,
            elevation: 27 ,
            title: Text(
              title ,
              style: TextStyle(color: Colors.white) ,
            ) ,
            actions: [confirm , cancel] ,
            content: Text(
              text ,
              style: TextStyle(color: Colors.white) ,
            ) ,
          ) ,
    );
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

  CreateProduct() async {
    name = nameControler.text;
    price = priceController.text;
    productDetails = productDetailsController.text;

    if (name.length < 1) {
      print("gghg");

      displayDialog(context , "Empty Field" , "Product name is empty");
    } else {
      if (price.length < 1) {
        displayDialog(context , "Empty Field" , "Product Price is empty");
      } else {
        if (productDetails.length < 1) {
          displayDialog(context , "Empty Field" , "Product Details is empty");
        } else {
          if (_image == null || _image2 ==null || _image3==null) {
            displayDialog(context , "Images Missing" , "You must Upload three images");
          }
          else {
            await chooseDisplayDialog(context , "Confirmation" ,
                "Press confirm to post your product");
          }
        }
      }
    }
  }

  confirmation() async {
    progressDialog(context , "...Please Wait");
    String res =
    await products.sendProduct(
        name , price , userid , productDetails , _image.path,_image2.path,_image3.path);
    if (res == "s") {
      displayDialog(context , "Success" , "your Product have been post");
      pr.hide();
    }
    if (res == "f") {
      displayDialog(context , "Failed" ,
          "Somthing went wrong, Check your internet connection and try again");
      pr.hide();
    }

    if (res == "e") {
      displayDialog(context , "Failed" ,
          "Somthing went wrong, Check your internet connection and try again");
      pr.hide();
    }
  }


  //the next 3 method are used to handle Product image upload
  _imgFromCamera() async {
  final PickedFile = await picker.getImage(
    source: ImageSource.camera,imageQuality: 50

     );

    setState(() {
      _image = File(PickedFile.path);
    });
  }

  _imgFromGallery() async {
    List<Asset> PickedFile =  await MultiImagePicker.pickImages(
    maxImages: 3,
    enableCamera: true,
    selectedAssets: images,
    cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
    materialOptions: MaterialOptions(
    actionBarColor: "#abcdef",
    actionBarTitle: "Example App",
    allViewTitle: "All Photos",
    useDetailsView: false,
    selectCircleStrokeColor: "#000000",
    ));
     path=[
    for(int index=0;index<PickedFile.length;index++)

      await  FlutterAbsolutePath.getAbsolutePath(PickedFile[index].identifier)
];
    /*await picker.getImage(
        source: ImageSource.gallery,imageQuality: 50
    );*/

          if(path.length==1){
            setState(() {
              _image=File(path[0]);
              _image2=null;
              _image3=null;
            });
    }
      if(path.length==2 ) {
        setState(() {
          _image2 = File(path[1]);
          _image = File(path[0]);
          _image3 = null;
        });
      }



          if(path.length==3) {
            setState(() {
              _image = File(path[0]);

              _image3 = File(path[2]);
              _image2 = File(path[1]);
            });

          }

       }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context ,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library) ,
                      title: new Text('Photo Library') ,
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }) ,
                  new ListTile(
                    leading: new Icon(Icons.photo_camera) ,
                    title: new Text('Camera') ,
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    } ,
                  ) ,
                ] ,
              ) ,
            ) ,
          );
        });
  }


}
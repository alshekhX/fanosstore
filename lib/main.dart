import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts_arabic/fonts.dart';
import 'package:http/http.dart' as http;
import 'Homepage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:google_fonts_arabic/google_fonts_arabic.dart';
const SERVER = 'http://192.168.43.250:3000/users';
final storage = FlutterSecureStorage();


ProgressDialog pr;
void main() {
  runApp(MyApp());
}
Map<int, Color> color = {
  50: Color.fromRGBO(255, 92, 87, .1),
  100: Color.fromRGBO(255, 92, 87, .2),
  200: Color.fromRGBO(255, 92, 87, .3),
  300: Color.fromRGBO(255, 92, 87, .4),
  400: Color.fromRGBO(255, 92, 87, .5),
  500: Color.fromRGBO(255, 92, 87, .6),
  600: Color.fromRGBO(255, 92, 87, .7),
  700: Color.fromRGBO(255, 92, 87, .8),
  800: Color.fromRGBO(255, 92, 87, .9),
  900: Color.fromRGBO(255, 92, 87, 1),
};

MaterialColor colorCustom = MaterialColor(0xFF040205, color);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: colorCustom
        ,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: login(),
    );
  }
}

class login extends StatefulWidget {

  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {




  bool login;
  @override
  void initState() {
    // TODO: implement initState
    login=true;
    super.initState();
  }
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController=TextEditingController();
  final TextEditingController _phonenumberController =TextEditingController();


  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    Widget loginW = RaisedButton(
      textColor: Colors.white ,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30)) ,

      child: Text("Login" ,style: TextStyle(color: Colors.black),) ,
      onPressed: () async {
        var email = _emailController.text;
        var password = _passwordController.text;
        if (email.length < 1)
          displayDialog(context , "Empty Field" ,

              "The Email Field is Empty");

        else if (password.length < 1) {
          displayDialog(context , "Empty Field" ,
              "The password Field is Empty");
        }
        else{
          progressDialog(context , "...Please Wait");

          var jwt = await attemplogin(email , password);


          if (jwt != null) {
            pr.hide();
            storage.write(key: "jwt" , value: jwt);
print(jwt);
            Navigator.push(
                context ,
                MaterialPageRoute(
                    builder: (context) => HomePage.fromBase64(jwt)
                )
            );
          } else {
            pr.hide();
            displayDialog(context , "An Error Occurred" ,
                "Authintication Failed");
          }
        }
      },


      color: Colors.yellowAccent.shade400 ,
    );


    Widget signupW = RaisedButton(child: Text(
      "Sign up" , style: TextStyle(color: Colors.black) ,) ,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30)) ,
      onPressed: () async {
        var email = _emailController.text;
        var password = _passwordController.text;
        var username=_usernameController.text;
        var phonenumber=_phonenumberController.text;


        if (email.length < 1)
          displayDialog(context , "Empty Field" ,
              "The Email Field is Empty");
         if (password.length < 1) {
          displayDialog(context , "Empty Field" ,
              "The password Field is Empty");}
         if(username.length<1)
           displayDialog(context , "Empty Field" ,
               "The Username Field is Empty");
        else {
          progressDialog(context , "...Please Wait");
          var res = await signup(email , password,username,phonenumber);
          if (res == 201) {
            pr.hide();
            displayDialog(context , "Success" ,
                "The user was created. Log in now.");
          }
          else if (res == 409) {
            pr.hide();
            displayDialog(
                context ,
                "This email is already registered" ,
                "Please try to sign up using another email or log in if you already have an account.");
          } else {
            pr.hide();
            print(res);
            displayDialog(context , "Error" ,
                "An unknown error occurred.");
          }
        }
      } , color:Colors.yellowAccent.shade400  ,
    );


    return Scaffold(

        appBar: AppBar(title: Text("Login or Signup") ,) ,
        body: Container(

          child: Padding(
              padding: EdgeInsets.all(12.0) ,
              child: ListView(
                  children: [
                    Container(
                      alignment: Alignment.center ,
                      padding: EdgeInsets.only(top: 10 , bottom: 40) ,
                      child: Text('فانوس' , style: TextStyle(
                          color: Colors.black ,
                          fontWeight: FontWeight.w600 ,
                          fontFamily: ArabicFonts.Reem_Kufi ,
                          package: 'google_fonts_arabic',
                          fontSize: 80) ,) ,
                    ) ,
                   (login==true)? Container(): Container(padding: EdgeInsets.all(10) ,
                      child: TextField(controller: _usernameController ,
                        textInputAction: TextInputAction.next,          onEditingComplete: () => node.nextFocus(), // Move focus to next
                        decoration: InputDecoration(focusColor: Colors.white,
                            labelText: 'Username' , border:  OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(50))
                            )) ,
                      ) ,
                    ),
                    Container(padding: EdgeInsets.all(10) ,
                      child: TextField(controller: _emailController ,
                        onEditingComplete: () => node.nextFocus(),textInputAction: TextInputAction.next,
                        decoration: InputDecoration(focusColor: Colors.white,
                            labelText: 'Email'
                            , border:  OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50))

                        )) ,
                      ) ,
                    ) ,
                    (login==true)? Container(): Container(padding: EdgeInsets.all(10) ,
                      child: TextField(controller: _phonenumberController ,
                        onEditingComplete: () => node.nextFocus(),textInputAction: TextInputAction.next,keyboardType:TextInputType.number ,inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(focusColor: Colors.white,

                            labelText: 'Phone Number' , border:  OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(50))
                            )) ,
                      ) ,
                    ),

                    Container(

                      //height: 40,
                      //width: 200,


                      padding: EdgeInsets.fromLTRB(10 , 10 , 10 , 20) ,
                      child: TextField(controller: _passwordController ,
                        decoration: InputDecoration(labelText: "Password" ,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(50))
                            )) ,) ,
                    ) ,
                    Container(

                      padding: EdgeInsets.only(left: 120 , right: 120) ,
                      child: (login==true)?loginW:signupW,
                    ) ,
                    Container(


                      padding: EdgeInsets.only(left: 20, right: 20) ,
                      child:Row(children: [
                        (login==true)?Text("Does not have an account? "):Text("If you already have an acount? "),
                        (login==true)?FlatButton(

                          textColor: Colors.blue,
                          child: Text(
                            'Sign up',
                            style: TextStyle(fontSize: 15),
                          ),
                          onPressed: () {
                            setState(() {
                              login=false;
                            });
                            //signup screen
                          },
                        ):
                        FlatButton(
                          textColor: Colors.blue,
                          child: Text(
                            'Log in',
                            style: TextStyle(fontSize: 15),
                          ),
                          onPressed: () {
                            setState(() {
                              login=true;
                            });

                            //signup screen
                          },
                        )
                      ],) ,
                    )
                  ]


              )
          ),
        )
    );
  }


  //dialog method
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


  //login method
  Future<String> attemplogin(String email , String password) async {
    var respond = await http
        .post('$SERVER/login' , body: {"email": email , "password": password});

    if (respond.statusCode == 200) return respond.body;

    return null;
  }

  Future <int> signup(String email , String password,String username,String phonenumber) async {
    var respond = await http.post("$SERVER/signup" , body: {
      "email": email ,
      "password": password,
      "username":username,
      "phonenumber":phonenumber
    });

    if (respond.statusCode == 201)
      return 201;
    else
      return respond.statusCode;
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
      insetAnimCurve: Curves.bounceInOut ,
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


}
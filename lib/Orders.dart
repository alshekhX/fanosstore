import 'dart:convert';

import 'package:http/http.dart' as http;
import 'Order.dart';


class Orders{

   static const String URL='http://192.168.43.250:3000/orders';

 Future<String> sendOrders(String productId, int quantity,String userID)async{

    try{

    dynamic res = await http.post(URL,body: {

      "productID": productId,
      "quantity": quantity.toString(),
      "userId":userID

    });



    if(res.statusCode == 201){

      print('it fuckking works');

return "s";

    }
    else{

      print(res.statusCode);
      return "f";
    }


    }

    catch(e){
      print("err: $e ");
      return "e";
    }



  }



  Future getOrders() async{

   try{
   dynamic res =  await http.get(URL);


   if(res.statusCode ==200) {
     final map = jsonDecode(res.body);

     final orders = map['order'];

     List theFinalOrders = orders.map((i)=>Order.fromJson(i)).toList();
     print(theFinalOrders);
     return theFinalOrders;

   }else{
     print("some thing is wrong");
     return List();

   }



   }
   catch(e){
print("err : $e");
return List();



   }

  }

  Future getUserOrders(String userID)async{
   try{
     dynamic res = await http.patch(URL,body: {"userID":userID});

     if(res.statusCode==200){

       final map = jsonDecode(res.body);
       final orders = map['order'];
       List theFinalOrders = orders.map((i)=>Order.fromJson(i)).toList();
       print(theFinalOrders);
       return theFinalOrders;

     }else{
       print("some thing is wrong");
       return List();

     }

     }




   catch(e){

     print("errorr: $e");
return List();



   }


  }



}
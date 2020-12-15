import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:http/http.dart' as http;
import 'package:loginjwt/main.dart';
import 'Product.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

class Products {
  static const String SEARCHURL = "http://192.168.43.250:3000/products/search";
  static const String URL = "http://192.168.43.250:3000/products";

  Future getProduct() async {
    try {
      dynamic res = await http.get(URL);
//dynamic res2 = json.decode(res).cast<Map<String, dynamic>>();

      if (200 == res.statusCode) {
//first we decode the json response;
        final map = jsonDecode(res.body);

        //then we filter it
        final productsMap = map['product'];

        //we use map to convert every record or elemnt to a product object
        List productz = productsMap.map((i) => Product.fromJson(i)).toList();

        return productz;
      } else {
        print("nt working");
        return List();
      }
    } catch (e) {
      print(e);
      return List();
    }
  }

  //sendProducts is here
  Future sendProduct(dynamic name, dynamic price, dynamic userID,dynamic productDetails, String imagePath,String imagePath2,String imagePath3) async {
    try {



    var req = http.MultipartRequest("POST",Uri.parse(URL));

    req.fields['name'] = name;
    req.fields['price'] = price;
    req.fields['userId'] = userID;
    req.fields['productDetails'] = productDetails;
    req.files.add(await http.MultipartFile.fromPath('image', imagePath));
      req.files.add(await http.MultipartFile.fromPath('image', imagePath2));
      req.files.add(await http.MultipartFile.fromPath('image', imagePath3));






    dynamic res = await req.send();

      if (res.statusCode == 200) {
        print('it works');
        return "s";
      } else {
        print(res.statusCode);
        return "f";
      }
    } catch (e) {
      print("error:$e");
      return "e";
    }
  }

  Future deleteProduct(String id)async
  {try {
    dynamic res = await http.delete("$URL/$id");
    if (res.statusCode == 200) {
      print("done deleting");
    }
    else {
      print("noo delete");
    }
  }catch(e){

    print("error: $e");
  }

  }

  Future getUserProduct(dynamic userid) async {
    try {
      dynamic res = await http.patch(URL, body: {"userID": userid});
//dynamic res2 = json.decode(res).cast<Map<String, dynamic>>();

      if (200 == res.statusCode) {
//first we decode the json response;
        final ProductJson = jsonDecode(res.body);

        //then we filter it

        //we use map to convert every record or elemnt to a product object
        List productz = ProductJson.map((i) => Product.fromJson(i)).toList();

        print(productz);
        return productz;
      } else {
        print("nt working");
        return List();
      }
    } catch (e) {
      print(e);
      return List();
    }
  }

  Future searchProduct(String productName) async {
    try {
      dynamic res =
          await http.patch(SEARCHURL, body: {"productName": productName});

      if (200 == res.statusCode) {
//first we decode the json response;
        final ProductJson = jsonDecode(res.body);
        final map = ProductJson['product'];

        //then we filter it

        //we use map to convert every record or elemnt to a product object
        List productz = map.map((i) => Product.fromJson(i)).toList();

        print(productz);
        return productz;
      } else {
        print("nt working");
        return List();
      }
    } catch (e) {
      print("error: $e");
      return List();
    }
  }
}

class Product{

  String id;
  String name;
  int price;
  String productImage;
  String productDetails;



  Product({this.id,this.name,this.price,this.productImage,this.productDetails});

  Product.fromJson( Map<String,dynamic> map){
    this.id = map['_id'];
    this.name = map['name'];
    this.price = map['price'];
    this.productImage= map['productImage'];
    this.productDetails=map['productDetails'];



  }








}
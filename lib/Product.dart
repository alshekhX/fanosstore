class Product{

  String id;
  String name;
  int price;
  String productImage;
  String productImage2;
  String productImage3;

  String productDetails;



  Product({this.id,this.name,this.price,this.productImage,this.productImage2,this.productImage3,this.productDetails});

  Product.fromJson( Map<String,dynamic> map){
    this.id = map['_id'];
    this.name = map['name'];
    this.price = map['price'];
    this.productImage= map['productImage'];
    this.productImage2=map['productImage2'];
    this.productImage3=map['productImage3'];
    this.productDetails=map['productDetails'];



  }








}

class Order{

  String id;
  String productName;
  int productPrice;
  int quantity;
  String date;

  Order(this.id,this.quantity,this.productName,this.date,this.productPrice);


  Order.fromJson(Map<String,dynamic> map){

    this.id = map['_id'];
    this.quantity=map['quantity'];
    try {
      this.productName = map['product']['name'];
    }catch(e){
      this.productName = "Product was deleted";
    }
    this.date=map['date'];
    try{
    this.productPrice=map['product']['price'];}
    catch(e){
      this.productPrice=0;
    }

  }



}
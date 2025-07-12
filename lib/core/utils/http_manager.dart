import 'package:http/http.dart' as http;
class HttpManager{
 static Future<http.Response?> getRequest(String url)async{
    try{
      return await http.get(Uri.parse(url));
    }catch(exception){
      print("http exception: ${exception}");
      return null;
    }
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Models/githubRep.dart';

void main() {
 runApp(RootWidget());
}
class RootWidget extends StatelessWidget{
  //the root screen for the app
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      color: Colors.white,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false, //hide debug banner

    );
  }
}
class HomeScreen extends StatefulWidget{
  //the main screen that shows the fetched github repositories
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen>{
  bool _screenLoading = true;//control the appearance of progress indicator
  bool _somethingWrong= false; //indicates whether there is wrong response
  bool _emptySearchResults = false;

  List<GithubRepoItem> repos=List.empty(growable: true); //repos that will be displayed on the screen

  //async function to fetch latest repositories using github rest api
  void _fetchRepos() async{

    String currentDate = DateTime.now().toString().split(" ")[0];

    //get the repos that are created at the current date
    String url = "https://api.github.com/search/repositories?q=created:${currentDate}&per_page=20";

    if(!_screenLoading){
      setState(() {
        //while waiting for response set the screen status loading to true
        _screenLoading = true;
        _somethingWrong = false;
      });
    }

    //http GET Request to fetch repositories from Github api
    http.get(Uri.parse(url)).then((response) {
      // check whether status is OK or something is wrong
      if(response.statusCode == 200){
        String responseBody = response.body;
        print("response body : ${responseBody}");
        try{
          //get repo list from json response
          var itemsJson = jsonDecode(responseBody)['items'];


          setState(() {
            _screenLoading = false;
            _somethingWrong = false;
          });
        }catch (exception){
          setState(() {
            _somethingWrong = true;
          });
        }
      }else{
        setState(() {
          _somethingWrong = true;
        });
      }


    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchRepos();
  }

  Widget screenBody(){
    //function to control what should be displayed on the screen body based on Conditions
    if (_screenLoading) {
      return const CircularProgressIndicator();
    }
    else if (_somethingWrong){
      //show error message if something is wrong
      return Row(
        children: [Text("Something Wrong"),SizedBox(width: 4,),Icon(Icons.error)],
      );
    }
    else if (!repos.isEmpty){
      return
        ListView.builder(itemBuilder: (context, index) {

      });
    }

    return const SizedBox.shrink();

  }
  double horizontalMargin= 10;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      screenBody()
      ,
    );
  }
}



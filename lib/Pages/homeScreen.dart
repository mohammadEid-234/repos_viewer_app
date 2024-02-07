import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../Constants/userMessages.dart';
import '../Models/githubRep.dart';
import '../Models/repoOwner.dart';
import '../Utils/httpManager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  //the main screen that shows the fetched github repositories
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _pageLoading = true; //control the appearance of progress indicator
  bool _somethingWrong = false; //indicates whether there is wrong response
  bool _emptySearchResults = false;
  bool _fetchingMore = false;

  String currentDate="";// determine current date to fetch latest repos

  double horizontalMargin = 15;
  double screenHeight = 0,screenWidth = 0;

  int pageIndex = 1;//this variable to control pagination
  int perPage = 10; //each page returns 10 items

  ScrollController? _scrollController ; //
  //repos that will be displayed on the screen
  List<GithubRepoItem> repos = List.empty(growable: true);

  //async function to fetch latest repositories using github rest api
  void _fetchRepos(String url) {

    setState(() {
      //while waiting for response set the screen status loading to true
      _pageLoading = true;
      _somethingWrong = false;
    });


    //http GET Request to fetch repositories from Github api
    HttpManager.getRequest(url).then((response) {
      // check whether status is OK or something is wrong
      if (response!=null && response.statusCode == 200) {
        String responseBody = response.body;
        try {
          //get repo list from json response
          List<dynamic> itemsJson = jsonDecode(responseBody)['items'];
          for (var jsonItem in itemsJson) {
            var ownerItem = jsonItem['owner'] ;
            GithubRepoItem githubRepoItem = GithubRepoItem(name: jsonItem['name']??"", //check if item is null before passing it to the constructor
                url: jsonItem['html_url']??"",
                description: jsonItem['description']??"");

            githubRepoItem.repOwner =  RepOwner(username: ownerItem['login']??"",
                avatarUrl: ownerItem['avatar_url']??"");

            repos.add(githubRepoItem);
          }

          setState(() {
            _pageLoading = false;
            _somethingWrong = false;
          });
        } catch (exception) {
          print("response exception : ${exception}");
          setState(() {
            _pageLoading = false;
            _somethingWrong = true;
          });
        }

      } else {
        setState(() {
          _pageLoading = false;
          _somethingWrong = true;
        });
      }
    });
  }

  void _fetchMore(String url) {
    setState(() {
      _fetchingMore = true;
    });
    HttpManager.getRequest(url).then((response){

      if (response!=null && response.statusCode == 200) {
        String responseBody = response.body;
        try {
          print("response : $responseBody");
          //get repo list from json response
          List<dynamic> itemsJson = jsonDecode(responseBody)['items'];
          for (var jsonItem in itemsJson) {
            var ownerItem = jsonItem['owner'] ;
            GithubRepoItem githubRepoItem = GithubRepoItem(name: jsonItem['name']??"", //check if item is null before passing it to the constructor
                url: jsonItem['html_url']??"",
                description: jsonItem['description']??"");

            githubRepoItem.repOwner =  RepOwner(username: ownerItem['login']??"",
                avatarUrl: ownerItem['avatar_url']??"");

            repos.add(githubRepoItem);
          }
          print("repos length: ${repos.length}");
          setState(() {
            _fetchingMore = false;
          });

        } catch (exception) {
          print("fetchMore response exception: $exception");
        }

      }
      else{
        print("response is null or status not 200");
        setState(() {
          _fetchingMore = false;
        });
      }
    } );
  }

  Widget pageBody() {
    //function to control what should be displayed on the screen body based on Conditions
    if (_pageLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(
            width: 10,
          ),
          Text(UserMessages.getMsg(Message.loading))
        ],
      );
    } else if (_somethingWrong) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(UserMessages.getMsg(Message.error)),
          const SizedBox(
            width: 4,
          ),
          const Icon(Icons.error,color: Colors.red,)
        ],
      );
    } else if (repos.isNotEmpty) {
      return ListView.builder(
            itemCount: repos.length+1, //+1 is for loading bar when fetching more data
            itemBuilder: (context, index) {
              if(index>= repos.length){
                /*return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );*/
                return Container(
                    margin: EdgeInsets.all(5),
                    child: TextButton(
                      onPressed: (){
                       String url =
                      "https://api.github.com/search/repositories?q=created:$currentDate&page=${++pageIndex}&per_page=$perPage";
                       print("url fetch more: ${url}");
                       _fetchMore(url);
                }, child: Text("View More")));
                  ;
              }
              return Container(
                  padding: EdgeInsets.all(10),
                  decoration:  BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromARGB(167, 146, 146, 146), blurRadius: 4.0)
                      ],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(10))

                  ),
                  margin: EdgeInsets.symmetric(horizontal: horizontalMargin,vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            repos[index].repOwner.avatarUrl.isNotEmpty?
                            repos[index].repOwner.avatarUrl:
                            "https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg"
                            //use alternative picture when avatar url is not available
                            ,
                            width: screenWidth * 0.1,
                            height: screenHeight * 0.1,
                            alignment: Alignment.topCenter,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                repos[index].repOwner.username,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              Text(
                                repos[index].name,
                                style:
                                TextStyle(
                                    fontSize:15),
                              ),
                            ],
                          ),
                        ],
                      ),

                      if(repos[index].description.isNotEmpty)
                          Text(
                            repos[index].description,
                            style: TextStyle(
                                fontSize:15),
                          )


                    ],
                  ));
            });
    }
    else if (_emptySearchResults){
      return Center(
          child: Text(
            UserMessages.getMsg(Message.noMatch),
            textAlign: TextAlign.center,
          ));
    }
    return Center(
        child: Text(
          UserMessages.getMsg(Message.noData),
          textAlign: TextAlign.center,
        ));
  }

  Widget pageHeader() {
    return SliverAppBar(
      stretch: true,
      title: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
                color: Color.fromARGB(167, 146, 146, 146), blurRadius: 4.0)
          ],
        ),
        child: TextField(
          onTap: () {},
          decoration: InputDecoration(
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search),
              suffixIcon: IconButton(onPressed: (){}, icon: Icon(Icons.manage_search_outlined)),
              hintText: "Search"),
        ),
      ),
    );
  }


  void _scrollListener() {


    if (_scrollController != null &&
        _scrollController!.position.pixels ==
            _scrollController!.position.maxScrollExtent) {
      print("scroll positon: ${_scrollController!.position}");

      //when scroll position reaches bottom fetch more data
      String url =
          "https://api.github.com/search/repositories?q=created:$currentDate&page=${++pageIndex}&per_page=$perPage";
      print("url fetch more: ${url}");
     // _fetchMore(url);
    }
  }
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController!.addListener(_scrollListener);

    currentDate = DateTime.now().toString().split(" ")[0];
    //get the repos that are created at the current date
    String url =
        "https://api.github.com/search/repositories?q=created:$currentDate&page=$pageIndex&per_page=$perPage";
    print("url: $url");
    _fetchRepos(url);

  }

  @override
  void dispose() {
    _scrollController!.removeListener(_scrollListener);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    FlutterView currentView = View.of(context);
    screenHeight = currentView.physicalSize.height / currentView.devicePixelRatio;
    screenWidth = currentView.physicalSize.width / currentView.devicePixelRatio;

    return Scaffold(

      floatingActionButton: FloatingActionButton(
        onPressed:  () {
          pageIndex = 1;
          repos.clear();
          String url = "https://api.github.com/search/repositories?q=created:$currentDate&page=$pageIndex&per_page=$perPage";
         _fetchRepos(url);
          _scrollController!.jumpTo(_scrollController!.position.minScrollExtent);
        },
        child: Icon(Icons.refresh),
      ),
      body: NestedScrollView(
          //physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          clipBehavior: Clip.none,
          headerSliverBuilder: (context, bool) {
            return <Widget>[
              pageHeader(),

            ];
          },
          body: pageBody()),
    );
  }
}
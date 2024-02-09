import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:github_reps/Constants/filterTypes.dart';
import 'package:github_reps/Pages/RepoDetails.dart';
import 'package:github_reps/Provider/searchController.dart';
import 'package:github_reps/Utils/searchTimer.dart';
import 'package:provider/provider.dart';
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
  bool _fetchingMore = false; //triggered when loading more data from api

  String currentDate = ""; // determine current date to fetch latest repos

  double horizontalMargin = 15;
  double screenHeight = 0, screenWidth = 0;

  int pageIndex = 1;
  int perPage = 20; //number of items that each page return
  int maxNumPages =
      50; // max number of pages allowed based on github api restrictions

  ScrollController? _scrollController;

  SearchTimer? _searchTimer; //controle search delay
  TextEditingController? _searchTxt;

  //repos that will be displayed on the screen
  List<GithubRepoItem> repos = List.empty(growable: true);

  TextScaler textScaler = TextScaler.noScaling; //prevent text scaling
  FilterController? _filterController;

  //async function to fetch latest repositories using github rest api
  void _fetchRepos(String url) {
    setState(() {
      //while waiting for response set the screen status loading to true
      _pageLoading = true;
      _somethingWrong = false; //set to false in-case it was already true
    });

    //http GET Request to fetch repositories from Github api
    HttpManager.getRequest(url).then((response) {
      _pageLoading = false; //stop loading after response

      // check whether status is OK or something is wrong
      if (response != null && response.statusCode == 200) {
        String responseBody = response.body;
        try {
          //get repo list from json response
          List<dynamic> itemsJson = jsonDecode(responseBody)['items'];
          for (var jsonItem in itemsJson) {
            var ownerItem = jsonItem['owner'];
            GithubRepoItem githubRepoItem = GithubRepoItem(
                name: jsonItem['name'] ?? "",
                //check if item is null before passing it to the constructor
                url: jsonItem['html_url'] ?? "",
                description: jsonItem['description'] ?? "");

            githubRepoItem.created_at = jsonItem['created_at'] ?? "";
            githubRepoItem.repOwner = RepOwner(
                username: ownerItem['login'] ?? "",
                avatarUrl: ownerItem['avatar_url'] ?? "");

            repos.add(githubRepoItem);
          }
          _somethingWrong = false;
        } catch (exception) {
          print("response exception : ${exception}");
          _somethingWrong = true;
        }
      } else {
        _somethingWrong = true;
      }
      setState(() {
      });
    });
  }

  void _fetchMore(String url) {
    setState(() {
      _fetchingMore = true;
    });
    HttpManager.getRequest(url).then((response) {
      if (response != null && response.statusCode == 200) {
        String responseBody = response.body;
        try {
          //get repo list from json response
          List<dynamic> itemsJson = jsonDecode(responseBody)['items'];
          for (var jsonItem in itemsJson) {
            var ownerItem = jsonItem['owner'];
            GithubRepoItem githubRepoItem = GithubRepoItem(
                name: jsonItem['name'] ?? "",
                //check if item is null before passing it to the constructor
                url: jsonItem['html_url'] ?? "",
                description: jsonItem['description'] ?? "");

            githubRepoItem.repOwner = RepOwner(
                username: ownerItem['login'] ?? "",
                avatarUrl: ownerItem['avatar_url'] ?? "");

            repos.add(githubRepoItem);
          }
          print("repos length: ${repos.length}");
        } catch (exception) {
          print("fetchMore response exception: $exception");
        }
      }
      setState(() {
        _fetchingMore = false;
      });
    });
  }

  void _search(String query, FilterTypes filterType) {
    pageIndex = 1;
    repos.clear();
    print("filter: ${filterType}");
    String url = "";
    if (filterType == FilterTypes.name) {
      url =
          "https://api.github.com/search/repositories?q=$query in:name&per_page=$perPage&page=$pageIndex";
    } else if (filterType == FilterTypes.description) {
      url =
          "https://api.github.com/search/repositories?q=$query in:description&per_page=$perPage&page=$pageIndex";
    } else if (filterType == FilterTypes.owner) {
      url =
          "https://api.github.com/search/repositories?q=user:$query&per_page=$perPage&page=$pageIndex";
    }
    _fetchRepos(url);
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
          const Icon(
            Icons.error,
            color: Colors.red,
          )
        ],
      );
    } else if (repos.isNotEmpty) {
      return ListView.builder(
          itemCount: repos.length + 1, //+1 is for show more button
          itemBuilder: (context, index) {
            if (index >= repos.length) {
              if (pageIndex >= maxNumPages) {
                //add space at the end of the list
                return SizedBox(
                  height: screenHeight * 0.1,
                );
              }
              return Container(

                  margin: EdgeInsets.all(5),
                  child: TextButton(
                      //disable press when fetching more
                      onPressed: _fetchingMore
                          ? null
                          : () {
                              String url =
                                  "https://api.github.com/search/repositories?q=created:$currentDate&page=${++pageIndex}&per_page=$perPage";
                              print("url fetch more: ${url}");
                              _fetchMore(url);
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "View More",
                            textScaler: textScaler,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          if (_fetchingMore) ...const [
                            SizedBox(
                              width: 10,
                            ),
                            CircularProgressIndicator()
                          ]
                        ],
                      )));
            }

            return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(167, 146, 146, 146),
                          blurRadius: 4.0)
                    ],
                    border: Border.all(color: Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                margin: EdgeInsets.symmetric(
                    horizontal: horizontalMargin, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: screenWidth * 0.1,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              shape: BoxShape.circle),
                          child: ClipOval(
                            child: Image.network(
                              repos[index].repOwner.avatarUrl.isNotEmpty
                                  ? repos[index].repOwner.avatarUrl
                                  : "https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg"
                              //use alternative picture when avatar url is not available
                              ,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Flexible( //prevent text overflow
                          fit: FlexFit.loose,
                          child: Text(
                          repos[index].repOwner.username,
                          textAlign: TextAlign.center,
                          textScaler: textScaler,
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),),

                        const Spacer(),

                      ],
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: screenHeight * 0.03, bottom: 10),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/github.png",
                            width: screenWidth * 0.05,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          //prevent text from overflow
                          Flexible(
                            fit: FlexFit.loose,
                            flex: 1,
                            child: Text(
                              repos[index].name,
                              textScaler: textScaler,
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ),
                    if (repos[index].description.isNotEmpty)
                      Text(
                        repos[index].description,
                        style: const TextStyle(fontSize: 15),
                      ),

                    Center(child: TextButton.icon(icon: Icon(Icons.remove_red_eye_outlined,),onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return RepoDetails(githubRepoItem: repos[index]);
                      }));
                    }, label: Text("Details")),)
                  ],
                ));
          });
    }

    return Center(
        child: Text(
      UserMessages.getMsg(Message.noData),
      textAlign: TextAlign.center,
    ));
  }

  Widget pageHeader() {
    //only page header rebuilds when the user change filter

    return ChangeNotifierProvider<FilterController>(
      create: (_) => _filterController!,
      child: Consumer<FilterController>(
        builder: (context, controller, child) {
          return SliverAppBar(
            title: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                      color: Color.fromARGB(167, 146, 146, 146),
                      blurRadius: 4.0)
                ],
              ),
              child: TextField(
                controller: _searchTxt,
                onChanged: (String query) {
                  /* perform search when the input stops for period
                   to reduce load on network
                   */
                  _searchTimer!.run(() {
                    _search(query, controller.filter);
                  });
                },
                decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: TextButton.icon(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(
                                  children: [
                                    ListTile(
                                      title: Text("Name"),
                                      leading: Radio(
                                          value: FilterTypes.name,
                                          groupValue: controller.filter,
                                          onChanged: (val) {
                                            controller.changeFilter(val!);
                                            Navigator.of(context).pop();
                                            _search(_searchTxt!.text, val);
                                          }),
                                    ),
                                    ListTile(
                                      title: const Text("Description"),
                                      leading: Radio(
                                          value: FilterTypes.description,
                                          groupValue: controller.filter,
                                          onChanged: (val) {
                                            controller.changeFilter(val!);
                                            Navigator.of(context).pop();
                                            _search(_searchTxt!.text, val);
                                          }),
                                    ),
                                    ListTile(
                                      title: const Text("Owner"),
                                      leading: Radio(
                                          value: FilterTypes.owner,
                                          groupValue: controller.filter,
                                          onChanged: (val) {
                                            controller.changeFilter(val!);
                                            Navigator.of(context).pop();
                                            _search(_searchTxt!.text, val);
                                          }),
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: Icon(Icons.filter_list),
                        label: Text("Filter")),
                    hintText: "Search"),
              ),
            ),
          );
        },
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
    _filterController = FilterController();
    _searchTimer = SearchTimer(milliseconds: 1200);
    _searchTxt = TextEditingController();
    currentDate = DateTime.now().toString().split(" ")[0];
    //get the repos that are created at the current date
    String url =
        "https://api.github.com/search/repositories?q=created:$currentDate&page=$pageIndex&per_page=$perPage&sort=updated&order=desc";
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
    screenHeight =
        currentView.physicalSize.height / currentView.devicePixelRatio;
    screenWidth = currentView.physicalSize.width / currentView.devicePixelRatio;

    return Scaffold(
      //refresh button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pageIndex = 1; //reset list
          repos.clear();
          _searchTxt!.clear();
          String url =
              "https://api.github.com/search/repositories?q=created:$currentDate&page=$pageIndex&per_page=$perPage";
          _fetchRepos(url);
          _scrollController!
              .jumpTo(_scrollController!.position.minScrollExtent);
        },
        child: Icon(Icons.refresh),
      ),
      body: NestedScrollView(
          controller: _scrollController,
          clipBehavior: Clip.none,
          headerSliverBuilder: (context, b) {
            return <Widget>[
              pageHeader(),
            ];
          },
          body: pageBody()),
    );
  }
}

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github_reps/core/constants/user_messages.dart';
import 'package:github_reps/core/utils/logger.dart';
import 'package:github_reps/features/home/model/github_repo.dart';
import 'package:github_reps/core/utils/http_manager.dart';

import '../model/branch.dart';

class RepoDetails extends StatefulWidget {
  GithubRepoItem? githubRepoItem;

  RepoDetails({required this.githubRepoItem, super.key});

  @override
  State<StatefulWidget> createState() {
    return _RepoDetails();
  }
}

class _RepoDetails extends State<RepoDetails> {
  bool _loadingBranches = true;
  bool _somethingWrong = false;
  double screenHeight = 0, screenWidth = 0;
  List<Branch> branches = List.empty(growable: true);
  double horizontalMargin = 5;

  void _loadBranches() {
    String userName = widget.githubRepoItem!.repOwner.username;
    String repoName = widget.githubRepoItem!.name;
    String url = "https://api.github.com/repos/$userName/$repoName/branches";
    HttpManager.getRequest(url).then((response) {
      _loadingBranches = false;
      if (response != null && response.statusCode == 200) {
        try {
          List<dynamic> jsonList = jsonDecode(response.body);
          for (var item in jsonList) {
            Logger.log("branch : $item");
            Branch branch = Branch.fromJson(item);
            branches.add(branch);

          }
        } catch (exception) {
          Logger.log("branches response exception: $exception");
          _somethingWrong = true;
        }
      } else {
        _somethingWrong = true;
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Widget pageBody() {
    //the number of scrollable items here is not large , so i used singleChildScrollView
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: 5),
              width: screenWidth * 0.35,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  shape: BoxShape.circle),
              child: ClipOval(
                child: Image.network(
                  widget.githubRepoItem!.repOwner.avatarUrl.isNotEmpty
                      ? widget.githubRepoItem!.repOwner.avatarUrl
                      : "https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg"
                  //use alternative picture when avatar url is not available
                  ,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Center(child: Text(widget.githubRepoItem!.repOwner.username
            ,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),

          ListTile(
            leading: Image.asset("assets/images/github.png",width: screenWidth*0.05,alignment: AlignmentDirectional.centerStart,),
            title: Text(widget.githubRepoItem!.name,textAlign: TextAlign.start,),),
          const SizedBox(height: 5,),
          ListTile(
            leading: Icon(Icons.calendar_month,size: screenWidth*0.05,),
            title: Text(widget.githubRepoItem!.createdAt.split("T")[0]),
          ),
          const SizedBox(height: 5,),

          ListTile(
              leading: InkWell(
                child: Icon(Icons.copy,size: screenWidth*0.05),
                onTap: () {
                  Clipboard.setData(
                          ClipboardData(text: widget.githubRepoItem!.url))
                      .then((value) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Copied!")));
                  });
                },
              ),
              title: Container(
                width: screenWidth * 0.8,
                child: TextField(
                  style: TextStyle(fontSize: 15, height: 1),
                  decoration: InputDecoration(
                      hintText: widget.githubRepoItem!.url,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400))),
                  enabled: false,
                ),
              )),
          const ListTile(
            leading: Text(
              "Branches",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (_loadingBranches)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(
                  width: 10,
                ),
                Text(UserMessages.getMsg(Message.loading))
              ],
            )
          else if (branches.isNotEmpty)
            ...[
            for(int index=0; index<branches.length; index++)
              ListTile(
                leading: Image.asset(
                  "assets/images/branch.png",
                  alignment: AlignmentDirectional.centerStart,
                  width: screenWidth * 0.1,
                ),
                title: Text(branches[index].name),
                subtitle: Text(
                  branches[index].isProtected ? "Protected" : "Not Protected",
                  style: TextStyle(
                      color: branches[index].isProtected
                          ? Colors.green
                          : Colors.red),
                ),
              )
            ]

          else if (_somethingWrong)
            Row(
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
            )
          else
            Center(
              child: Text(UserMessages.getMsg(Message.noBranches)),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FlutterView currentView = View.of(context);
    screenHeight =
        currentView.physicalSize.height / currentView.devicePixelRatio;
    screenWidth = currentView.physicalSize.width / currentView.devicePixelRatio;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Details"),
        ),
        body: pageBody());
  }
}

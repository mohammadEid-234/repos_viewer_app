import 'package:github_reps/features/home/model/repo_owner.dart';

class GithubRepoItem {

  String name, url, description,createdAt;
  RepOwner repOwner;
  GithubRepoItem({required this.name, required this.url, this.description = "",this.createdAt="",required this.repOwner});
  factory GithubRepoItem.fromJson(Map<String,dynamic> json){
    return GithubRepoItem(name: json["name"], url: json["html_url"],description: json["description"]??"",createdAt: json["created_at"]??"",
    repOwner: RepOwner.fromJson(json["owner"])

    );
  }


}

import 'package:github_reps/Models/repoOwner.dart';

class GithubRepoItem {
  String? _name, _url, _description;
  RepOwner? repOwner;

  GithubRepoItem({required String name, required String url, String description = ""}) {
    _name = name;
    _url = url;
    _description = description;
  }
}

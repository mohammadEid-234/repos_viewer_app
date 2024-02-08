import 'package:github_reps/Models/repoOwner.dart';

class GithubRepoItem {
  String? _name, _url, _description,_created_at;

  RepOwner? _repOwner;



  GithubRepoItem({required String name, required String url, String description = ""}) {
    _name = name;
    _url = url;
    _description = description;
  }

  String get name => _name!;

  set name(String value) {
    _name = value;
  }
  String get url => _url!;

  set url(String value) {
    _url = value;
  }

  String get description => _description!;

  set description(String value) {
    _description = value;
  }

  RepOwner get repOwner => _repOwner!;

  set repOwner(RepOwner value) {
    _repOwner = value;
  }

  String get created_at => _created_at!;

  set created_at(String value) {
    _created_at = value;
  }


}

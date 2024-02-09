class Branch{
  String? _name;
  bool? _protected;
  Map<String,dynamic>? _commit;

  Branch({required String name,bool protected=false}){
    _name = name;
    _protected = protected;
  }

  String get name => _name!;

  set name(String value) {
    _name = value;
  }

  bool get protected => _protected!;

  set protected(bool value) {
    _protected = value;
  }

  Map<String,dynamic> get commit => _commit??{};

  set commit(Map<String,dynamic> value) {
    _commit = value;
  }


}
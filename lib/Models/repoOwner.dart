class RepOwner {
  String? _username;
  String? _avatarUrl;

  RepOwner({required String username, required String avatarUrl}) {
    _username = username;
    _avatarUrl = avatarUrl;
  }

  String get username => _username!;

  String get avatarUrl => _avatarUrl!;

  set avatarUrl(String value) {
    _avatarUrl = value;
  }

  set username(String value) {
    _username = value;
  }
}

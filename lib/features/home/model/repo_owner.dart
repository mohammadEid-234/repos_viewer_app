class RepOwner {
  String username;
  String avatarUrl;

  RepOwner({
    required this.username,
    required this.avatarUrl,
  });

  factory RepOwner.fromJson(Map<String, dynamic> json) {
    return RepOwner(
      username: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }
}

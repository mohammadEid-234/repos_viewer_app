class Branch {
  String name;
  bool isProtected;
  Map<String, dynamic> commit;

  Branch({
    required this.name,
    this.isProtected = false,
    this.commit = const {},
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      name: json['name'] as String,
      isProtected: json['protected'] as bool? ?? false,
      commit: (json['commit'] as Map<String, dynamic>?) ?? {},
    );
  }
}

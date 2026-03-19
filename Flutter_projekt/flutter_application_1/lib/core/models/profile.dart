/// Model profila korisnika (povezan s auth.users)
class Profile {
  final String id;
  final String? fullName;
  final String role;
  final bool membershipActive;
  final String? email;

  Profile({
    required this.id,
    this.fullName,
    required this.role,
    this.membershipActive = true,
    this.email,
  });

  bool get isAdmin => role == 'admin';

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      role: json['role'] as String? ?? 'member',
      membershipActive: json['membership_active'] as bool? ?? true,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'role': role,
        'membership_active': membershipActive,
        if (email != null) 'email': email,
      };
}

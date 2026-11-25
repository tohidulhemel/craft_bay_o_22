class UserProfile {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.city,
    required this.address,
    this.avatarUrl,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String city;
  final String address;
  final String? avatarUrl;

  String get fullName {
    final combined = '$firstName $lastName'.trim();
    return combined.isEmpty ? 'CraftyBay User' : combined;
  }

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    final value = '$f$l';
    return value.isEmpty ? 'U' : value;
  }
}

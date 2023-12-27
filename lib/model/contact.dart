// models/contact.dart

class Contact {
  int? id;
  String name;
  String email;
  String? address;
  int? phone;

  Contact({
    this.id,
    required this.name,
    required this.email,
    this.address,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      address: map['address'],
      phone: map['phone'],
    );
  }
}

class Fournisseur {
  String id;
  String name;
  String contactPerson;
  String email;
  String phone;
  String address;
  String? website;
  List<String> productsSupplied;

  Fournisseur({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    this.website,
    required this.productsSupplied,
  });

  
  factory Fournisseur.fromJson(Map<String, dynamic> json) {
    return Fournisseur(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      website: json['website'],
      productsSupplied: json['products_supplied'] != null
          ? List<String>.from(json['products_supplied'])
          : [],
    );
  }

 
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'website': website,
      'products_supplied': productsSupplied,
    };
  }
}

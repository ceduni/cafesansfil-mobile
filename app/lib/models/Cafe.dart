class Cafe {
  String cafeId;
  String name;
  String slug;
  List<String> previousSlugs;
  String description;
  String imageUrl;
  String faculty;
  bool isOpen;
  String? statusMessage;
  List<OpeningHour> openingHours;
  Location location;
  Contact contact;
  List<SocialMedia> socialMedia;
  List<PaymentMethod> paymentMethods;
  List<AdditionalInfo> additionalInfo;
  List<StaffMember> staff;
  List<MenuItem> menuItems;

  Cafe({
    required this.cafeId,
    required this.name,
    required this.slug,
    required this.previousSlugs,
    required this.description,
    required this.imageUrl,
    required this.faculty,
    required this.isOpen,
    this.statusMessage,
    required this.openingHours,
    required this.location,
    required this.contact,
    required this.socialMedia,
    required this.paymentMethods,
    required this.additionalInfo,
    required this.staff,
    required this.menuItems,
  });

  factory Cafe.fromJson(Map<String, dynamic> json) {
    return Cafe(
      cafeId: json['cafe_id'],
      name: json['name'],
      slug: json['slug'],
      previousSlugs: List<String>.from(json['previous_slugs']),
      description: json['description'],
      imageUrl: json['image_url'],
      faculty: json['faculty'],
      isOpen: json['is_open'],
      statusMessage: json['status_message'],
      openingHours: List<OpeningHour>.from(
          json['opening_hours'].map((x) => OpeningHour.fromJson(x))),
      location: Location.fromJson(json['location']),
      contact: Contact.fromJson(json['contact']),
      socialMedia: List<SocialMedia>.from(
          json['social_media'].map((x) => SocialMedia.fromJson(x))),
      paymentMethods: List<PaymentMethod>.from(
          json['payment_methods'].map((x) => PaymentMethod.fromJson(x))),
      additionalInfo: List<AdditionalInfo>.from(
          json['additional_info'].map((x) => AdditionalInfo.fromJson(x))),
      staff: List<StaffMember>.from(
          json['staff'].map((x) => StaffMember.fromJson(x))),
      menuItems: List<MenuItem>.from(
          json['menu_items'].map((x) => MenuItem.fromJson(x))),
    );
  }
}

class OpeningHour {
  String day;
  List<TimeBlock> blocks;

  OpeningHour({required this.day, required this.blocks});

  factory OpeningHour.fromJson(Map<String, dynamic> json) {
    return OpeningHour(
      day: json['day'],
      blocks: List<TimeBlock>.from(
          json['blocks'].map((x) => TimeBlock.fromJson(x))),
    );
  }
}

class TimeBlock {
  String start;
  String end;

  TimeBlock({required this.start, required this.end});

  factory TimeBlock.fromJson(Map<String, dynamic> json) {
    return TimeBlock(
      start: json['start'],
      end: json['end'],
    );
  }
}

class Location {
  String pavillon;
  String local;

  Location({required this.pavillon, required this.local});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      pavillon: json['pavillon'],
      local: json['local'],
    );
  }
}

class Contact {
  String? email;
  String? phoneNumber;
  String? website;

  Contact({required this.email, this.phoneNumber, this.website});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      email: json['email'],
      phoneNumber: json['phone_number'],
      website: json['website'],
    );
  }
}

class SocialMedia {
  String platformName;
  String link;

  SocialMedia({required this.platformName, required this.link});

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      platformName: json['platform_name'],
      link: json['link'],
    );
  }
}

class PaymentMethod {
  String method;
  String? minimum;

  PaymentMethod({required this.method, this.minimum});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      method: json['method'],
      minimum: json['minimum'],
    );
  }
}

class AdditionalInfo {
  String type;
  String value;
  DateTime start;
  DateTime? end;

  AdditionalInfo(
      {required this.type, required this.value, required this.start, this.end});

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) {
    return AdditionalInfo(
      type: json['type'],
      value: json['value'],
      start: DateTime.parse(json['start']),
      end: json['end'] != null ? DateTime.parse(json['end']) : null,
    );
  }
}

class StaffMember {
  String username;
  String role;

  StaffMember({required this.username, required this.role});

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      username: json['username'],
      role: json['role'],
    );
  }
}

class MenuItem {
  String itemId;
  String name;
  String slug;
  List<String> tags;
  String description;
  String imageUrl;
  double price;
  bool inStock;
  String category;
  List<MenuItemOption> options;

  MenuItem({
    required this.itemId,
    required this.name,
    required this.slug,
    required this.tags,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.inStock,
    required this.category,
    required this.options,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemId: json['item_id'],
      name: json['name'],
      slug: json['slug'],
      tags: List<String>.from(json['tags']),
      description: json['description'],
      imageUrl: json['image_url'],
      price: double.parse(json['price'].toString()),
      inStock: json['in_stock'],
      category: json['category'],
      options: List<MenuItemOption>.from(
          json['options'].map((x) => MenuItemOption.fromJson(x))),
    );
  }
}

class MenuItemOption {
  String type;
  String value;
  double fee;

  MenuItemOption({required this.type, required this.value, required this.fee});

  factory MenuItemOption.fromJson(Map<String, dynamic> json) {
    return MenuItemOption(
      type: json['type'],
      value: json['value'],
      fee: double.parse(json['fee'].toString()),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'fee': fee,
    };
  }
}

class CafeRoleInfo {
  final String cafeName;
  final String cafeId;
  final String role;

  CafeRoleInfo(
      {required this.cafeName, required this.cafeId, required this.role});
}

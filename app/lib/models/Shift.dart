import 'dart:convert';

class Staff {
  final String id;
  final String matricule;
  final bool set;
  final String name;

  Staff({
    required this.id,
    required this.matricule,
    required this.set,
    required this.name,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['_id'],
      matricule: json['matricule'],
      set: json['set'],
      name: json['name'],
    );
  }
}

class HourlyShift {
  final String id;
  final String hourName;
  final int staffCountmin;
  final List<Staff> staff;

  HourlyShift({
    required this.id,
    required this.hourName,
    required this.staffCountmin,
    required this.staff,
  });

  factory HourlyShift.fromJson(Map<String, dynamic> json) {
    var staffList =
        (json['staff'] as List).map((staff) => Staff.fromJson(staff)).toList();
    return HourlyShift(
      id: json['_id'],
      hourName: json['hourName'],
      staffCountmin: json['staffCountmin'],
      staff: staffList,
    );
  }
}

class DayShift {
  final List<HourlyShift> hours;

  DayShift({required this.hours});

  factory DayShift.fromJson(Map<String, dynamic> json) {
    var hoursList = (json['hours'] as List)
        .map((hour) => HourlyShift.fromJson(hour))
        .toList();
    return DayShift(
      hours: hoursList,
    );
  }
}

class Shift {
  final String id;
  final String cafeId;
  final String cafeName;
  final Map<String, DayShift?> shifts;

  Shift({
    required this.id,
    required this.cafeId,
    required this.cafeName,
    required this.shifts,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    var shiftsMap = <String, DayShift?>{};
    json['shifts'].forEach((day, value) {
      if (value != null) {
        shiftsMap[day] = DayShift.fromJson(value);
      } else {
        shiftsMap[day] = null;
      }
    });

    return Shift(
      id: json['_id'],
      cafeId: json['cafe_id'],
      cafeName: json['cafe_name'],
      shifts: shiftsMap,
    );
  }
}

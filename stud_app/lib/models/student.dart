// filepath: /C:/Aditya Projects/Integration/stud_app/lib/models/student.dart

class Student {
  final int id;
  final String name;
  final String studentNumber;
  final int age;
  final String phoneNumber;
  final String image; // Add this line

  Student({
    required this.id,
    required this.name,
    required this.studentNumber,
    required this.age,
    required this.phoneNumber,
    required this.image, // Add this line
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      studentNumber: json['student_number'],
      age: json['age'],
      phoneNumber: json['phone_number'],
      image: json['image'], // Add this line
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'student_number': studentNumber,
      'age': age,
      'phone_number': phoneNumber,
      'image': image, // Add this line
    };
  }
}
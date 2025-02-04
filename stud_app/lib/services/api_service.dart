// filepath: /C:/Aditya Projects/Integration/stud_app/lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.117:5000/students';

  Future<List<Student>> getStudents() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((student) => Student.fromJson(student)).toList();
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      print('Error in getStudents: $e');
      rethrow;
    }
  }

  Future<Student> createStudent(Student student) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(student.toJson()),
      );
      if (response.statusCode == 201) {
        return Student.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create student');
      }
    } catch (e) {
      print('Error in createStudent: $e');
      rethrow;
    }
  }

  Future<Student> updateStudent(Student student) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${student.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(student.toJson()),
      );
      if (response.statusCode == 200) {
        return Student.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update student');
      }
    } catch (e) {
      print('Error in updateStudent: $e');
      rethrow;
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode != 204) {
        throw Exception('Failed to delete student');
      }
    } catch (e) {
      print('Error in deleteStudent: $e');
      rethrow;
    }
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../models/student.dart';
import '../services/api_service.dart';
import 'student_form.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Student>> futureStudents;

  @override
  void initState() {
    super.initState();
    futureStudents = apiService.getStudents();
  }

  void _showImageDialog(Uint8List imageData, String tag) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (context) {
        return ImageDialog(imageData: imageData, tag: tag);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Info'),
      ),
      body: FutureBuilder<List<Student>>(
        future: futureStudents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No students found'));
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Student Number')),
                  DataColumn(label: Text('Age')),
                  DataColumn(label: Text('Phone Number')),
                  DataColumn(label: Text('Image')), 
                  DataColumn(label: Text('Actions')),
                ],
                rows: snapshot.data!.map((student) {
                  return DataRow(cells: [
                    DataCell(Text(student.id.toString())),
                    DataCell(Text(student.name)),
                    DataCell(Text(student.studentNumber)),
                    DataCell(Text(student.age.toString())),
                    DataCell(Text(student.phoneNumber)),
                    DataCell(
                      student.image != null && student.image!.isNotEmpty
                          ? GestureDetector(
                              onTap: () => _showImageDialog(base64Decode(student.image!), 'image_${student.id}'),
                              child: Hero(
                                tag: 'image_${student.id}',
                                child: Image.memory(
                                  base64Decode(student.image!),
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                            )
                          : Text('No image'),
                    ), // Add this line
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentForm(student: student),
                              ),
                            ).then((value) {
                              setState(() {
                                futureStudents = apiService.getStudents();
                              });
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            apiService.deleteStudent(student.id).then((_) {
                              setState(() {
                                futureStudents = apiService.getStudents();
                              });
                            });
                          },
                        ),
                      ],
                    ),
                    ),
                  ]);
                }).toList(),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentForm(),
            ),
          ).then((value) {
            setState(() {
              futureStudents = apiService.getStudents();
            });
          });
        },
      ),
    );
  }
}

class ImageDialog extends StatelessWidget {
  final Uint8List imageData;
  final String tag;

  ImageDialog({required this.imageData, required this.tag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () {}, // Prevents the dialog from closing when tapping on the image
          child: Hero(
            tag: tag,
            child: Image.memory(imageData),
          ),
        ),
      ),
    );
  }
}
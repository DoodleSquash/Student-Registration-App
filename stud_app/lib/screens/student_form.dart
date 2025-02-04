import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../models/student.dart';
import '../services/api_service.dart';

class StudentForm extends StatefulWidget {
  final Student? student;

  StudentForm({this.student});

  @override
  _StudentFormState createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  late TextEditingController _nameController;
  late TextEditingController _studentNumberController;
  late TextEditingController _ageController;
  late TextEditingController _phoneNumberController;
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _studentNumberController = TextEditingController(text: widget.student?.studentNumber ?? '');
    _ageController = TextEditingController(text: widget.student?.age.toString() ?? '');
    _phoneNumberController = TextEditingController(text: widget.student?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentNumberController.dispose();
    _ageController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _imageData = result.files.first.bytes;
      });
    }
  }

  void _showImageDialog(Uint8List imageData) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Image.memory(imageData),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _studentNumberController,
                  decoration: InputDecoration(labelText: 'Student Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a student number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an age';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 20),
                _imageData != null
                    ? GestureDetector(
                        onTap: () => _showImageDialog(_imageData!),
                        child: Image.memory(_imageData!),
                      )
                    : Text('No image selected'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final student = Student(
                        id: widget.student?.id ?? 0,
                        name: _nameController.text,
                        studentNumber: _studentNumberController.text,
                        age: int.parse(_ageController.text),
                        phoneNumber: _phoneNumberController.text,
                        image: _imageData != null ? base64Encode(_imageData!) : '',
                      );
                      try {
                        if (widget.student == null) {
                          await apiService.createStudent(student);
                        } else {
                          await apiService.updateStudent(student);
                        }
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: Text(widget.student == null ? 'Add' : 'Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
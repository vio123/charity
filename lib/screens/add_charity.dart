import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCharity extends StatefulWidget {
  const AddCharity({super.key});

  @override
  State<AddCharity> createState() => _AddCharityState();
}

class _AddCharityState extends State<AddCharity> {
  final _formField = GlobalKey<FormState>();
  final cityController = TextEditingController();
  final categoryController = TextEditingController();
  final targetController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  List<String> options = ["Charity", "Education", "Animals"];
  String? selectedValue;
  String? _imageFile ; // Variable to hold the selected image file
  Uint8List? selectedImageInBytes;
  String? _imageExtension;
  // Method to pick image in flutter web
  Future<void> pickImage() async {
    try {
      // Pick image using file_picker package
      FilePickerResult? fileResult = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      // If user picks an image, save selected image to variable
      if (fileResult != null) {
        setState(() {
          _imageExtension = fileResult.files.first.extension;
          _imageFile = fileResult.files.first.name;
          selectedImageInBytes = fileResult.files.first.bytes;
        });
      }
    } catch (e) {
      // If an error occured, show SnackBar with error message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error:$e")));
    }
  }


  // Method to upload selected image in flutter web
  // This method will get selected image in Bytes
  Future<String> uploadImage(Uint8List selectedImageInBytes) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      // This is referance where image uploaded in firebase storage bucket
      Reference ref = FirebaseStorage.instance.ref().child('Images').child(fileName);
      // metadata to save image extension
      final metadata = SettableMetadata(contentType: 'image/jpg');

      // UploadTask to finally upload image
      UploadTask uploadTask = ref.putData(selectedImageInBytes, metadata);

      // After successfully upload show SnackBar
      await uploadTask.whenComplete(() => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Image Uploaded"))));
      final downloadURL = await ref.getDownloadURL();
      saveIntoDatabase(downloadURL);
      return await ref.getDownloadURL();
    } catch (e) {
      // If an error occured while uploading, show SnackBar with error message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    return '';
  }
  Future<void> saveIntoDatabase(String downloadURL) async {
    final databaseReference = FirebaseDatabase.instance.reference();
    final charityRef = databaseReference.child('charityFund').push();
    final key = charityRef.key;
    charityRef.set({
      'city': cityController.text,
      'causeName': titleController.text,
      'description': descriptionController.text,
      'imageLink': downloadURL,
      'raisedFunds': 0,
      'targetFunds': double.parse(targetController.text),
      'type' : categoryController.text,
      'id ' : key,
      'userEmail': FirebaseAuth.instance.currentUser!.email
    });

    cityController.clear();
    titleController.clear();
    descriptionController.clear();
    targetController.clear();
    categoryController.clear();
    setState(() {
      _imageFile = null;
      _imageExtension = '';
    });
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formField,
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: "City",
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter city";
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<String>(
                  value: selectedValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue;
                      categoryController.text = selectedValue!;
                    });
                  },
                  hint: Text('Select type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an option';
                    }
                    return null;
                  },
                  items: options.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter title";
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  maxLines: 10,
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter description";
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  controller: targetController,
                  decoration: InputDecoration(
                    labelText: "Target Amount",
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter amount";
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: pickImage,
                  child: Text('Choose Image'),
                ),
                SizedBox(height: 16.0),
                Text(
                  _imageFile ?? 'No Image Selected',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1BAC4B)),
                  onPressed: () async {
                    if (_formField.currentState!.validate()) {
                      if(_imageFile != null) {
                        uploadImage(selectedImageInBytes!);
                      }else{
                        saveIntoDatabase('');
                      }
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "Add charity",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

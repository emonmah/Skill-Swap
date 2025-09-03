import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart'; // Location package removed
// ignore: depend_on_referenced_packages
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isUploading = false;
  Map<String, dynamic> _userData = {};
  File? _imageFile;

  final String _imgbbApiKey = 'c6b582d652d7c1b536867982deab7857'; // Remember to add your API key here

  // Controllers for all editable fields
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _hobbiesController;
  late TextEditingController _occupationController;
  late TextEditingController _teachSkillsController;
  late TextEditingController _learnSkillsController;

  // State variables for non-text fields
  int? _age;
  String? _gender;


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: _userData['name']);
    _usernameController = TextEditingController(text: _userData['username']);
    _phoneController = TextEditingController(text: _userData['phoneNumber']);
    _bioController = TextEditingController(text: _userData['bio']);
    _occupationController = TextEditingController(text: _userData['occupation']);
    _hobbiesController = TextEditingController(text: _userData['hobbies']?.join(', '));
    _teachSkillsController = TextEditingController(text: _userData['skillsToTeach']?.join(', '));
    _learnSkillsController = TextEditingController(text: _userData['skillsToLearn']?.join(', '));

    _age = _userData['age'];
    _gender = _userData['gender'];
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _userData = doc.data() ?? {};
        _initializeControllers();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _hobbiesController.dispose();
    _occupationController.dispose();
    _teachSkillsController.dispose();
    _learnSkillsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadProfilePictureToImgBB() async {
    if (_imageFile == null) return null;
    if (_imgbbApiKey == 'c6b582d652d7c1b536867982deab7857' || _imgbbApiKey.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Image hosting is not configured.'),
        backgroundColor: Colors.red,
      ));
      return null;
    }

    setState(() => _isUploading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$_imgbbApiKey'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        return jsonResponse['data']['url'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Image upload failed. Please try again.'),
            backgroundColor: Colors.red,
        ));
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('An error occurred during image upload: $e'),
          backgroundColor: Colors.red,
      ));
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser!;

    final uploadedImageUrl = await _uploadProfilePictureToImgBB();

    final dataToSave = {
      'name': _nameController.text.trim(),
      'username': _usernameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'profilePictureUrl': uploadedImageUrl ?? _userData['profilePictureUrl'],
      'age': _age,
      'gender': _gender,
      // 'location' field is removed
      'bio': _bioController.text.trim(),
      'hobbies': _hobbiesController.text.split(',').map((e) => e.trim()).toList(),
      'occupation': _occupationController.text.trim(),
      'skillsToTeach': _teachSkillsController.text.split(',').map((e) => e.trim()).toList(),
      'skillsToLearn': _learnSkillsController.text.split(',').map((e) => e.trim()).toList(),
      'uid': user.uid,
      'email': user.email,
    };

    await _firestore.collection('users').doc(user.uid).set(dataToSave, SetOptions(merge: true));

    await _loadUserData();
    setState(() {
      _isEditing = false;
      _isLoading = false;
      _imageFile = null;
    });
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (_isUploading) const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)))),
          if (!_isUploading) TextButton(
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: const TextStyle(color: Color.fromARGB(255, 3, 3, 3), fontSize: 16),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _isEditing ? _buildEditForm() : _buildViewMode(),
              ],
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: _isEditing ? _pickImage : null,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: _imageFile != null
                ? FileImage(_imageFile!)
                : (_userData['profilePictureUrl'] != null
                    ? NetworkImage(_userData['profilePictureUrl'])
                    : null) as ImageProvider?,
            child: _imageFile == null && _userData['profilePictureUrl'] == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
        ),
        if (_isEditing) const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Tap to change profile picture'),
        ),
        const SizedBox(height: 16),
        Text(_userData['name'] ?? 'No Name', style: Theme.of(context).textTheme.headlineSmall),
        Text(_userData['username'] ?? '@username'),
      ],
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard('About Me', {
          'Email': _userData['email'],
          'Phone': _userData['phoneNumber'],
          'Bio': _userData['bio'],
          'Occupation': _userData['occupation'],
          'Hobbies': _userData['hobbies']?.join(', '),
        }),
        _buildInfoCard('Details', {
           'Age': _userData['age']?.toString(),
           'Gender': _userData['gender'],
        }),
        _buildInfoCard('Skills to Teach', {'Skills': _userData['skillsToTeach']?.join(', ')}),
        _buildInfoCard('Skills to Learn', {'Skills': _userData['skillsToLearn']?.join(', ')}),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        _buildTextField(_nameController, 'Name'),
        _buildTextField(_usernameController, 'Username'),
        _buildTextField(_phoneController, 'Phone Number'),
        _buildTextField(_bioController, 'Bio', maxLines: 3),
        _buildTextField(_occupationController, 'Occupation'),
        _buildTextField(_hobbiesController, 'Hobbies (comma-separated)'),
        const SizedBox(height: 16),
        Row(children: [
            Expanded(child: _buildAgeDropdown()),
            const SizedBox(width: 16),
            Expanded(child: _buildGenderDropdown()),
        ],),
        const SizedBox(height: 16),
        // Update Location button removed
        _buildTextField(_teachSkillsController, 'Skills to Teach (comma-separated)'),
        _buildTextField(_learnSkillsController, 'Skills to Learn (comma-separated)'),
      ],
    );
  }

  Widget _buildInfoCard(String title, Map<String, String?> data) {
    final entries = data.entries.where((e) => e.value != null && e.value!.isNotEmpty).toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            ...entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RichText(text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(text: '${e.key}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: e.value),
                ]
              )),
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
  
  Widget _buildAgeDropdown() {
    return DropdownButtonFormField<int>(
      value: _age,
      hint: const Text('Age'),
      items: List.generate(83, (index) => 18 + index).map((age) =>
        DropdownMenuItem(value: age, child: Text(age.toString()))
      ).toList(),
      onChanged: (value) => setState(() => _age = value),
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      hint: const Text('Gender'),
      items: ['Male', 'Female', 'Non-binary', 'Other'].map((gender) =>
        DropdownMenuItem(value: gender, child: Text(gender))
      ).toList(),
      onChanged: (value) => setState(() => _gender = value),
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

    
}


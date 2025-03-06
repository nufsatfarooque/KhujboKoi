import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';

class UploadRestaurantInfoScreen extends StatefulWidget {
  const UploadRestaurantInfoScreen({super.key});

  @override
  _UploadRestaurantInfoScreenState createState() =>
      _UploadRestaurantInfoScreenState();
}

class _UploadRestaurantInfoScreenState
    extends State<UploadRestaurantInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _restaurantNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dishNameController = TextEditingController();
  final TextEditingController _dishPriceController = TextEditingController();

  File? _restaurantImageFile;
  File? _menuImageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isEditing = false; // Flag to check if editing an existing restaurant
  bool _isSearching = true; // Flag to toggle between search and edit/create UI

  // List of dishes entered by the restaurant owner
  List<Map<String, dynamic>> _dishes = [];
  File? _dishImageFile;

  // Store Base64 strings for restaurant and menu images
  String? _restaurantImageBase64;
  String? _menuImageBase64;

  // Store the Firestore document ID for the restaurant
  String? _restaurantId;

  // Method to search for an existing restaurant
  Future<void> _searchRestaurant() async {
    final restaurantName = _restaurantNameController.text.trim();
    if (restaurantName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a restaurant name')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('restaurant_info')
          .where('restaurant_name', isEqualTo: restaurantName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Restaurant exists, populate the fields
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        setState(() {
          _isEditing = true;
          _isSearching = false;
          _restaurantId = doc.id; // Store the document ID
          _restaurantNameController.text = data['restaurant_name'] ?? '';
          _locationController.text = data['location'] ?? '';
          _contactNumberController.text = data['contact_number'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _dishes = List<Map<String, dynamic>>.from(data['dishes'] ?? []);

          // Load existing images (if any)
          if (data['images'] != null && data['images'] is List) {
            for (var image in data['images']) {
              if (image is Map<String, dynamic>) {
                if (image['image_type'] == 'restaurant') {
                  _restaurantImageBase64 = image['image']; // Store Base64 string
                } else if (image['image_type'] == 'menu') {
                  _menuImageBase64 = image['image']; // Store Base64 string
                }
              }
            }
          }
        });
      } else {
        // Restaurant does not exist, proceed to create a new one
        setState(() {
          _isEditing = false;
          _isSearching = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to search restaurant: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Method to pick a restaurant image
  Future<void> _pickRestaurantImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _restaurantImageFile = File(pickedFile.path);
        _restaurantImageBase64 = null; // Clear Base64 string if a new image is picked
      });
    }
  }

  // Method to pick a menu image
  Future<void> _pickMenuImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _menuImageFile = File(pickedFile.path);
        _menuImageBase64 = null; // Clear Base64 string if a new image is picked
      });
    }
  }

  // Method to pick an image for the dish
  Future<void> _pickDishImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _dishImageFile = File(pickedFile.path);
      });
    }
  }

  // Add a new dish with an image
  void _addDish() {
    if (_dishNameController.text.isNotEmpty &&
        _dishPriceController.text.isNotEmpty &&
        _dishImageFile != null) {
      setState(() {
        final imageBytes = _dishImageFile!.readAsBytesSync();
        final base64Image = base64Encode(imageBytes);

        _dishes.add({
          'dish_name': _dishNameController.text,
          'price': double.tryParse(_dishPriceController.text) ?? 0.0,
          'image': base64Image, // Store as Base64 for simplicity
        });

        // Clear inputs for the next dish
        _dishNameController.clear();
        _dishPriceController.clear();
        _dishImageFile = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete dish details and image!')),
      );
    }
  }

  // Method to upload or update restaurant info
  Future<void> _uploadOrUpdateRestaurantInfo() async {
    if (!_formKey.currentState!.validate()) {
      return; // If the form is invalid, exit
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Convert restaurant and menu images to Base64 (if any)
      String base64RestaurantImage = _restaurantImageBase64 ?? '';
      String base64MenuImage = _menuImageBase64 ?? '';

      if (_restaurantImageFile != null) {
        final imageBytes = await _restaurantImageFile!.readAsBytes();
        base64RestaurantImage = base64Encode(imageBytes);
      }

      if (_menuImageFile != null) {
        final imageBytes = await _menuImageFile!.readAsBytes();
        base64MenuImage = base64Encode(imageBytes);
      }

      // Prepare restaurant info
      final restaurantData = {
        'restaurant_name': _restaurantNameController.text,
        'location': _locationController.text,
        'contact_number': _contactNumberController.text,
        'description': _descriptionController.text,
        'dishes': _dishes,
        'images': [
          if (base64RestaurantImage.isNotEmpty)
            {'image': base64RestaurantImage, 'image_type': 'restaurant'},
          if (base64MenuImage.isNotEmpty)
            {'image': base64MenuImage, 'image_type': 'menu'},
        ],
        'uploadedAt': FieldValue.serverTimestamp(),
      };

      final firestore = FirebaseFirestore.instance;

      if (_isEditing && _restaurantId != null) {
        // Update existing restaurant using the stored document ID
        await firestore
            .collection('restaurant_info')
            .doc(_restaurantId) // Use the document ID
            .update(restaurantData);
      } else {
        // Add new restaurant
        await firestore.collection('restaurant_info').add(restaurantData);
      }

      // Reset the state
      setState(() {
        _restaurantImageFile = null;
        _menuImageFile = null;
        _dishImageFile = null;
        _isUploading = false;
        _dishes.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Restaurant info updated successfully!'
              : 'Restaurant info uploaded successfully!'),
        ),
      );

      Navigator.pop(context); // Return to the previous screen
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${_isEditing ? 'update' : 'upload'} info: $e')),
      );
    }
  }

  // Method to show expanded image in a dialog
  void _showExpandedImage(String? base64Image) {
    if (base64Image == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context); // Close the dialog when tapped
            },
            child: Hero(
              tag: base64Image, // Unique tag for Hero animation
              child: Image.memory(
                base64Decode(base64Image),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Restaurant Info' : 'Upload Restaurant Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isSearching) ...[
                // Search UI
                TextFormField(
                  controller: _restaurantNameController,
                  decoration: const InputDecoration(labelText: 'Restaurant Name'),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter the restaurant name' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _searchRestaurant,
                  icon: const Icon(Icons.search),
                  label: const Text('Search Restaurant'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green.shade300,
                  ),
                ),
              ] else ...[
                // Edit/Create UI
                _buildCard(
                  title: 'Restaurant Details',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _restaurantNameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter the name' : null,
                      ),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(labelText: 'Location'),
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter the location' : null,
                      ),
                      TextFormField(
                        controller: _contactNumberController,
                        decoration:
                        const InputDecoration(labelText: 'Contact Number'),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter the contact number'
                            : null,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter a description' : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _pickRestaurantImage,
                        icon: const Icon(Icons.photo),
                        label: const Text('Pick Restaurant Image'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green.shade300,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_restaurantImageFile != null)
                        GestureDetector(
                          onTap: () {
                            final imageBytes = _restaurantImageFile!.readAsBytesSync();
                            final base64Image = base64Encode(imageBytes);
                            _showExpandedImage(base64Image);
                          },
                          child: Hero(
                            tag: _restaurantImageFile!.path, // Unique tag for Hero animation
                            child: Image.file(
                              _restaurantImageFile!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      if (_restaurantImageBase64 != null)
                        GestureDetector(
                          onTap: () => _showExpandedImage(_restaurantImageBase64),
                          child: Hero(
                            tag: _restaurantImageBase64!, // Unique tag for Hero animation
                            child: Image.memory(
                              base64Decode(_restaurantImageBase64!),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'Menu Upload',
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickMenuImage,
                        icon: const Icon(Icons.photo_album),
                        label: const Text('Pick Menu Image'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green.shade300,
                        ),
                      ),
                      if (_menuImageFile != null)
                        GestureDetector(
                          onTap: () {
                            final imageBytes = _menuImageFile!.readAsBytesSync();
                            final base64Image = base64Encode(imageBytes);
                            _showExpandedImage(base64Image);
                          },
                          child: Hero(
                            tag: _menuImageFile!.path, // Unique tag for Hero animation
                            child: Image.file(
                              _menuImageFile!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      if (_menuImageBase64 != null)
                        GestureDetector(
                          onTap: () => _showExpandedImage(_menuImageBase64),
                          child: Hero(
                            tag: _menuImageBase64!, // Unique tag for Hero animation
                            child: Image.memory(
                              base64Decode(_menuImageBase64!),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  title: 'Dishes',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _dishNameController,
                        decoration: const InputDecoration(labelText: 'Dish Name'),
                      ),
                      TextFormField(
                        controller: _dishPriceController,
                        decoration: const InputDecoration(labelText: 'Dish Price'),
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                      ),
                      ElevatedButton.icon(
                        onPressed: _pickDishImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Pick Dish Image'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green.shade300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_dishImageFile != null)
                        Image.file(_dishImageFile!, height: 150),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addDish,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Dish'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue.shade200,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Dishes List:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      for (var i = 0; i < _dishes.length; i++)
                        ListTile(
                          title: Text(_dishes[i]['dish_name']),
                          subtitle: Text('৳${_dishes[i]['price']}'),
                          leading: _dishes[i]['image'] != null
                              ? Image.memory(
                            base64Decode(_dishes[i]['image']),
                            width: 50,
                            height: 50,
                          )
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _dishes.removeAt(i);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Dish removed successfully!')),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _isUploading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                  onPressed: _uploadOrUpdateRestaurantInfo,
                  icon: const Icon(Icons.upload),
                  label: Text(_isEditing ? 'Update Info' : 'Upload Info'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.teal.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
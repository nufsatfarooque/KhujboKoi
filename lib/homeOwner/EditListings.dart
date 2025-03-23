import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditListingScreen extends StatefulWidget {
  final String listingId;

  const EditListingScreen({super.key, required this.listingId});

  @override
  _EditListingScreenState createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amenitiesController = TextEditingController(); // New controller for amenities

  int _bedrooms = 0;
  int _bathrooms = 0;
  List<String> base64Images = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchListingDetails();
  }

  Future<void> _fetchListingDetails() async {
    try {
      DocumentSnapshot listingDoc =
      await _firestore.collection('listings').doc(widget.listingId).get();

      if (listingDoc.exists) {
        var data = listingDoc.data() as Map<String, dynamic>;

        setState(() {
          _buildingNameController.text = data['buildingName'] ?? "";
          _rentController.text = data['rent'] ?? "";
          _addressController.text = data['address'] ?? "";
          _descriptionController.text = data['description'] ?? "";
          _amenitiesController.text = data['amenities'] ?? ""; // Fetch amenities
          _bedrooms = data['bedrooms'] ?? 0;
          _bathrooms = data['bathrooms'] ?? 0;
          base64Images = List<String>.from(data['images'] ?? []);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching listing: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to pick an image and convert it to Base64
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      List<int> imageBytes = await File(image.path).readAsBytes();
      String base64String = base64Encode(imageBytes);

      setState(() {
        base64Images.add(base64String);
      });
    }
  }

  // Function to delete an image from the list
  void _deleteImage(int index) {
    setState(() {
      base64Images.removeAt(index);
    });
  }

  // Function to update listing with new images
  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _firestore.collection('listings').doc(widget.listingId).update({
        'buildingName': _buildingNameController.text,
        'rent': _rentController.text,
        'address': _addressController.text,
        'description': _descriptionController.text,
        'amenities': _amenitiesController.text, // Save amenities
        'bedrooms': _bedrooms,
        'bathrooms': _bathrooms,
        'images': base64Images,
        'approved': false, // Reset approval status
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Listing updated successfully! Pending approval.")),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      print("Error updating listing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Listing", style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.green),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏠 Building Name
                TextFormField(
                  controller: _buildingNameController,
                  decoration: const InputDecoration(labelText: "Building Name"),
                  validator: (value) => value!.isEmpty ? "Enter building name" : null,
                ),
                const SizedBox(height: 10),

                // 💰 Rent
                TextFormField(
                  controller: _rentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Rent"),
                  validator: (value) => value!.isEmpty ? "Enter rent amount" : null,
                ),
                const SizedBox(height: 10),

                // 📍 Address
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                  validator: (value) => value!.isEmpty ? "Enter address" : null,
                ),
                const SizedBox(height: 10),

                // 📝 Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Description"),
                  validator: (value) => value!.isEmpty ? "Enter description" : null,
                ),
                const SizedBox(height: 10),

                // 🛋 Amenities
                TextFormField(
                  controller: _amenitiesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Amenities"),
                  validator: (value) => value!.isEmpty ? "Enter amenities" : null,
                ),
                const SizedBox(height: 10),

                // 🛏 Bedrooms
                const Text("Bedrooms", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => setState(() => _bedrooms = (_bedrooms > 0) ? _bedrooms - 1 : 0),
                    ),
                    Text("$_bedrooms"),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => _bedrooms++),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 🚿 Bathrooms (on the next line)
                const Text("Bathrooms", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => setState(() => _bathrooms = (_bathrooms > 0) ? _bathrooms - 1 : 0),
                    ),
                    Text("$_bathrooms"),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => _bathrooms++),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 🖼 Images Section
                const Text("Images", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // GridView for existing images with delete option
                if (base64Images.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: base64Images.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(base64Images[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteImage(index),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                // 📸 Add Image Button
                TextButton.icon(
                  icon: const Icon(Icons.add_a_photo, color: Colors.green),
                  label: const Text("Add Image"),
                  onPressed: _pickImage,
                ),
                const SizedBox(height: 20),

                // ✅ Update Button
                ElevatedButton(
                  onPressed: _updateListing,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Update Listing", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
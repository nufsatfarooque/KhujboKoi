import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
// For vector icons
// For better image handling

class UploadRestaurantInfoScreen extends StatefulWidget {
  const UploadRestaurantInfoScreen({super.key});

  @override
  _UploadRestaurantInfoScreenState createState() => _UploadRestaurantInfoScreenState();
}

class _UploadRestaurantInfoScreenState extends State<UploadRestaurantInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _restaurantNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dishNameController = TextEditingController();
  final TextEditingController _dishPriceController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();

  File? _restaurantImageFile;
  File? _menuImageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isEditing = false;
  bool _isSearching = true;

  List<Map<String, dynamic>> _dishes = [];
  File? _dishImageFile;

  String? _restaurantImageBase64;
  String? _menuImageBase64;
  String? _restaurantId;

  List<Map<String, String>> _searchSuggestions = [];
  bool _isLoadingSuggestions = false;
  String _noResultsMessage = '';

  // New theme colors (updated to green gradient)
  final Color _primaryColor = const Color.fromARGB(255, 76, 175, 80); // Green (ARGB equivalent)
  final Color _secondaryColor = const Color(0xFF81C784); // Lighter green
  final Color _backgroundColor = const Color(0xFFE8F5E9); // Very light green
  final Color _accentColor = const Color.fromARGB(255, 56, 142, 60); // Darker green

  // Animation durations
  final Duration _animationDuration = const Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _fetchOwnerInfo();
    _restaurantNameController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    final searchText = _restaurantNameController.text.trim();
    if (searchText.length >= 2) {
      _fetchSearchSuggestions(searchText);
      _searchRestaurant(); // Trigger search as user types
    } else {
      setState(() {
        _searchSuggestions = [];
        _noResultsMessage = '';
      });
    }
  }

  Future<void> _fetchSearchSuggestions(String searchText) async {
    if (searchText.isEmpty) return;

    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoadingSuggestions = false;
          _noResultsMessage = 'Please log in to see your restaurants';
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        setState(() {
          _isLoadingSuggestions = false;
          _noResultsMessage = 'User data not found';
        });
        return;
      }

      final userData = userDoc.data()!;
      final currentOwnerName = userData['name'] ?? '';

      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('restaurant_info')
          .where('owner_name', isEqualTo: currentOwnerName)
          .get();

      final List<Map<String, String>> suggestions = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final restaurantName = (data['restaurant_name'] ?? '').toLowerCase();
        final location = (data['location'] ?? '').toLowerCase();
        final searchLower = searchText.toLowerCase();

        if (restaurantName.contains(searchLower) || location.contains(searchLower)) {
          suggestions.add({
            'id': doc.id,
            'name': data['restaurant_name'] ?? '',
            'location': data['location'] ?? '',
            'owner_name': data['owner_name'] ?? '',
            'type': restaurantName.contains(searchLower) ? 'name' : 'location',
          });
        }
      }

      setState(() {
        _searchSuggestions = suggestions;
        _isLoadingSuggestions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSuggestions = false;
        _noResultsMessage = 'Error fetching suggestions';
      });
      print('Error fetching suggestions: $e');
    }
  }

  void _selectSuggestion(Map<String, String> suggestion) {
    _restaurantNameController.text = suggestion['name'] ?? '';
    _searchRestaurant(suggestion['id']);
  }

  Future<void> _fetchOwnerInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          setState(() {
            _ownerNameController.text = userData['name'] ?? '';
            _ownerEmailController.text = userData['email'] ?? '';
            _ownerPhoneController.text = userData['phoneNumber'] ?? '';
          });
        }
      }
    } catch (e) {
      _showSnackbar('Failed to fetch owner info: $e');
    }
  }

  Future<void> _searchRestaurant([String? restaurantId]) async {
    final restaurantName = _restaurantNameController.text.trim();
    if (restaurantName.isEmpty) {
      setState(() {
        _noResultsMessage = '';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _searchSuggestions = [];
    });

    try {
      DocumentSnapshot? doc;

      if (restaurantId != null) {
        // If restaurantId is provided (from suggestion), fetch directly
        doc = await FirebaseFirestore.instance.collection('restaurant_info').doc(restaurantId).get();
      } else {
        // Fetch restaurant only if it matches both name and current owner's name
        final currentOwnerName = _ownerNameController.text.trim();
        final querySnapshot = await FirebaseFirestore.instance
            .collection('restaurant_info')
            .where('restaurant_name', isEqualTo: restaurantName)
            .where('owner_name', isEqualTo: currentOwnerName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          doc = querySnapshot.docs.first;
        }
      }

      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _isEditing = true;
          _isSearching = false;
          _restaurantId = doc?.id;
          _restaurantNameController.text = data['restaurant_name'] ?? '';
          _locationController.text = data['location'] ?? '';
          _contactNumberController.text = data['contact_number'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _dishes = List<Map<String, dynamic>>.from(data['dishes'] ?? []);
          _ownerNameController.text = data['owner_name'] ?? _ownerNameController.text;
          _ownerEmailController.text = data['owner_email'] ?? _ownerEmailController.text;
          _ownerPhoneController.text = data['owner_phone'] ?? _ownerPhoneController.text;

          if (data['images'] != null && data['images'] is List) {
            for (var image in data['images']) {
              if (image is Map<String, dynamic>) {
                if (image['image_type'] == 'restaurant') {
                  _restaurantImageBase64 = image['image'];
                } else if (image['image_type'] == 'menu') {
                  _menuImageBase64 = image['image'];
                }
              }
            }
          }
          _noResultsMessage = '';
        });
      } else {
        setState(() {
          _isEditing = false;
          _isSearching = true;
          _noResultsMessage = 'Restaurant not found';
          _restaurantId = null;
          _locationController.clear();
          _contactNumberController.clear();
          _descriptionController.clear();
          _dishes.clear();
          _restaurantImageFile = null;
          _menuImageFile = null;
          _restaurantImageBase64 = null;
          _menuImageBase64 = null;
        });
      }
    } catch (e) {
      _showSnackbar('Failed to search restaurant: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _pickRestaurantImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _restaurantImageFile = File(pickedFile.path);
        _restaurantImageBase64 = null; // Clear base64 when replacing with new file
      });
    }
  }

  Future<void> _pickMenuImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _menuImageFile = File(pickedFile.path);
        _menuImageBase64 = null; // Clear base64 when replacing with new file
      });
    }
  }

  Future<void> _pickDishImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _dishImageFile = File(pickedFile.path);
      });
    }
  }

  void _addDish() {
    if (_dishNameController.text.isEmpty || _dishPriceController.text.isEmpty || _dishImageFile == null) {
      _showSnackbar('Please complete dish details and image!');
      return;
    }

    setState(() {
      final imageBytes = _dishImageFile!.readAsBytesSync();
      final base64Image = base64Encode(imageBytes);

      _dishes.add({
        'dish_name': _dishNameController.text,
        'price': double.tryParse(_dishPriceController.text) ?? 0.0,
        'image': base64Image,
      });

      _dishNameController.clear();
      _dishPriceController.clear();
      _dishImageFile = null;
    });

    _showSnackbar('Dish added successfully!');
  }

  void _deleteDish(int index) {
    setState(() {
      _dishes.removeAt(index);
    });
    _showSnackbar('Dish deleted successfully!');
  }

  Future<void> _uploadOrUpdateRestaurantInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
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

      final restaurantData = {
        'restaurant_name': _restaurantNameController.text,
        'location': _locationController.text,
        'contact_number': _contactNumberController.text,
        'description': _descriptionController.text,
        'owner_name': _ownerNameController.text,
        'owner_email': _ownerEmailController.text,
        'owner_phone': _ownerPhoneController.text,
        'dishes': _dishes,
        'images': [
          if (base64RestaurantImage.isNotEmpty) {'image': base64RestaurantImage, 'image_type': 'restaurant'},
          if (base64MenuImage.isNotEmpty) {'image': base64MenuImage, 'image_type': 'menu'},
        ],
        'uploadedAt': FieldValue.serverTimestamp(),
      };

      final firestore = FirebaseFirestore.instance;

      if (_isEditing && _restaurantId != null) {
        await firestore.collection('restaurant_info').doc(_restaurantId).update(restaurantData);
      } else {
        await firestore.collection('restaurant_info').add(restaurantData);
      }

      setState(() {
        _restaurantImageFile = null;
        _menuImageFile = null;
        _dishImageFile = null;
        _isUploading = false;
        _dishes.clear();
      });

      _showSnackbar(_isEditing ? 'Restaurant info updated successfully!' : 'Restaurant info uploaded successfully!');

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showSnackbar('Failed to ${_isEditing ? 'update' : 'upload'} info: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: _accentColor,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showExpandedImage(String? base64Image) {
    if (base64Image == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Hero(
                  tag: base64Image,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 15,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        base64Decode(base64Image),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Restaurant' : 'Add Restaurant',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryColor, _secondaryColor],
            ),
          ),
        ),
        elevation: 0,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
              tooltip: 'Search Restaurant',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundColor, Colors.white],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: _buildMainContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isSearching)
              _buildSearchSection()
            else
              _buildRestaurantForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return FadeInDown(
      duration: _animationDuration,
      child: _buildModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Find Your Restaurant',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _accentColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: _primaryColor),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _isEditing = false;
                      _clearForm();
                    });
                  },
                  tooltip: 'Create New',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildSearchResults(),
            const SizedBox(height: 16),
            if (_noResultsMessage == 'Restaurant not found' && !_isLoadingSuggestions)
              _buildCreateRestaurantButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextFormField(
      controller: _restaurantNameController,
      decoration: InputDecoration(
        labelText: 'Restaurant Name',
        hintText: 'Start typing to see suggestions',
        prefixIcon: Icon(Icons.search, color: _primaryColor),
        suffixIcon: _restaurantNameController.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, color: Colors.grey),
          onPressed: () {
            setState(() {
              _restaurantNameController.clear();
              _searchSuggestions = [];
              _noResultsMessage = '';
            });
          },
        )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter the restaurant name' : null,
      style: const TextStyle(color: Colors.black87),
      onFieldSubmitted: (_) => _searchRestaurant(), // Still works for Enter key
    );
  }

  Widget _buildSearchResults() {
    if (_isLoadingSuggestions) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CircularProgressIndicator(color: _primaryColor),
        ),
      );
    }

    if (_noResultsMessage.isNotEmpty && _searchSuggestions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey.shade600,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _noResultsMessage,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _searchSuggestions.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.shade200,
          height: 1,
          indent: 70,
        ),
        itemBuilder: (context, index) {
          final suggestion = _searchSuggestions[index];
          return ListTile(
            title: Text(
              suggestion['name'] ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _accentColor,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  suggestion['location'] ?? '',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Owner: ${suggestion['owner_name'] ?? ''}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: suggestion['type'] == 'name'
                    ? _primaryColor.withOpacity(0.1)
                    : Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                suggestion['type'] == 'name' ? Icons.restaurant : Icons.location_on,
                color: suggestion['type'] == 'name' ? _primaryColor : Colors.amber.shade700,
                size: 24,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
            onTap: () => _selectSuggestion(suggestion),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateRestaurantButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isSearching = false;
          _isEditing = false;
        });
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        backgroundColor: _primaryColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Create Restaurant',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeInDown(
          duration: _animationDuration,
          child: _buildHeaderCard(),
        ),
        const SizedBox(height: 20),
        _buildDetailsSection(),
        const SizedBox(height: 20),
        _buildMenuSection(),
        const SizedBox(height: 20),
        _buildDishesSection(),
        const SizedBox(height: 24),
        _buildSubmitButton(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accentColor, _primaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Restaurant' : 'Create New Restaurant',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (_isEditing)
                  Text(
                    _restaurantNameController.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return FadeInUp(
      duration: _animationDuration,
      child: _buildModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Restaurant Details', Icons.store_mall_directory),
            const SizedBox(height: 20),
            _buildModernTextField(
              controller: _restaurantNameController,
              label: 'Restaurant Name',
              icon: Icons.storefront,
              validator: (value) => value!.isEmpty ? 'Please enter the name' : null,
            ),
            _buildModernTextField(
              controller: _locationController,
              label: 'Location',
              icon: Icons.location_on,
              validator: (value) => value!.isEmpty ? 'Please enter the location' : null,
            ),
            _buildModernTextField(
              controller: _contactNumberController,
              label: 'Contact Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'Please enter the contact number' : null,
            ),
            _buildModernTextField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description,
              maxLines: 3,
              validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 20),
            _buildSectionSubtitle('Owner Information'),
            _buildModernTextField(
              controller: _ownerNameController,
              label: 'Owner Name',
              icon: Icons.person,
              readOnly: true,
              validator: (value) => value!.isEmpty ? 'Owner name is required' : null,
            ),
            _buildModernTextField(
              controller: _ownerEmailController,
              label: 'Owner Email',
              icon: Icons.email,
              readOnly: true,
              validator: (value) => value!.isEmpty ? 'Owner email is required' : null,
            ),
            _buildModernTextField(
              controller: _ownerPhoneController,
              label: 'Owner Phone',
              icon: Icons.phone,
              readOnly: true,
              validator: (value) => value!.isEmpty ? 'Owner phone is required' : null,
            ),
            const SizedBox(height: 24),
            _buildImageUploadSection(
              title: 'Restaurant Image',
              description: 'Upload an attractive image of your restaurant',
              onPickImage: _pickRestaurantImage,
              imageFile: _restaurantImageFile,
              base64Image: _restaurantImageBase64,
              allowReplace: _isEditing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return FadeInUp(
      duration: _animationDuration,
      child: _buildModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Menu', Icons.menu_book),
            const SizedBox(height: 20),
            _buildImageUploadSection(
              title: 'Menu Image',
              description: 'Upload your restaurant\'s menu',
              onPickImage: _pickMenuImage,
              imageFile: _menuImageFile,
              base64Image: _menuImageBase64,
              allowReplace: _isEditing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishesSection() {
    return FadeInUp(
      duration: _animationDuration,
      child: _buildModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Dishes', Icons.fastfood),
            const SizedBox(height: 20),
            _buildModernTextField(
              controller: _dishNameController,
              label: 'Dish Name',
              icon: Icons.local_dining,
            ),
            _buildModernTextField(
              controller: _dishPriceController,
              label: 'Price (৳)',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildImageUploadSection(
              title: 'Dish Image',
              description: 'Add an image of the dish',
              onPickImage: _pickDishImage,
              imageFile: _dishImageFile,
              base64Image: null,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addDish,
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Add Dish',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            if (_dishes.isNotEmpty)
              Column(
                children: _dishes.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> dish = entry.value;
                  return ListTile(
                    leading: GestureDetector(
                      onTap: () => _showExpandedImage(dish['image']),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(dish['image']),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      dish['dish_name'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '৳${dish['price'].toStringAsFixed(2)}', // Changed to Taka symbol
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade400),
                      onPressed: () => _deleteDish(index),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FadeInUp(
      duration: _animationDuration,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _uploadOrUpdateRestaurantInfo,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: _primaryColor,
          elevation: 0,
        ),
        child: _isUploading
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          _isEditing ? 'Update Restaurant' : 'Add Restaurant',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildModernCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        subtitle,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _primaryColor),
          filled: true,
          fillColor: _backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
        ),
        validator: validator,
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget _buildImageUploadSection({
    required String title,
    required String description,
    required VoidCallback onPickImage,
    File? imageFile,
    String? base64Image,
    bool allowReplace = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionSubtitle(title),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: imageFile != null
                ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                if (allowReplace)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Replace',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            )
                : base64Image != null
                ? Stack(
              children: [
                GestureDetector(
                  onTap: () => _showExpandedImage(base64Image),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(base64Image),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                if (allowReplace)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Replace',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, size: 40, color: _primaryColor),
                const SizedBox(height: 8),
                Text(
                  'Tap to upload',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _clearForm() {
    _restaurantNameController.clear();
    _locationController.clear();
    _contactNumberController.clear();
    _descriptionController.clear();
    _dishNameController.clear();
    _dishPriceController.clear();
    setState(() {
      _dishes.clear();
      _restaurantImageFile = null;
      _menuImageFile = null;
      _dishImageFile = null;
      _restaurantImageBase64 = null;
      _menuImageBase64 = null;
      _restaurantId = null;
    });
  }

  @override
  void dispose() {
    _restaurantNameController.removeListener(_onSearchTextChanged);
    _restaurantNameController.dispose();
    _locationController.dispose();
    _contactNumberController.dispose();
    _descriptionController.dispose();
    _dishNameController.dispose();
    _dishPriceController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPhoneController.dispose();
    super.dispose();
  }
}
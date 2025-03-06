import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:image_picker_android/image_picker_android.dart';
//import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khujbokoi/Widgets/AmenitiesUI.dart';
import 'package:khujbokoi/screen/homeOwnerScreen.dart';
import '../pages/MapPickerScreen.dart';
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;



class AddHouse extends StatefulWidget{
  const AddHouse({super.key});
  @override
  _AddHouseState  createState()=> _AddHouseState();

}

class _AddHouseState extends State<AddHouse> {
  final formkey= GlobalKey<FormState>();
  LatLng? _selectedLocation;

  TextEditingController _BuildingController = TextEditingController();
  TextEditingController _RentController = TextEditingController();
  TextEditingController _TypeController = TextEditingController();
  TextEditingController _DescriptionController = TextEditingController();
  TextEditingController _AddressController = TextEditingController();
  TextEditingController _CityController = TextEditingController();
  TextEditingController _CountryController = TextEditingController();
  TextEditingController _AmenitiesController = TextEditingController();

  final List<String> residenceType = [
    'Family',
    'Shared',
    'Sublet',
  ];
  String selectedType ="";

  int _bedrooms=0;
  int _bathrooms=0;

  List<MemoryImage> _imageList = [];  // List to store images for display
  final List<File> _imageFileList = [];     // List to store File objects for saving/uploading

//  final ImagePicker _picker = ImagePicker();
  _selectImageFromGallery(int index) async {
    // Pick an image from the gallery
    var imageFilePickedFromGallery = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (imageFilePickedFromGallery != null) {
      // Convert the picked image to a MemoryImage for display
      MemoryImage imageFileInBytesForm = MemoryImage(
        (File(imageFilePickedFromGallery.path)).readAsBytesSync(),
      );

      // Convert the picked image to a File object for further use (e.g., uploading)
      File imageFile = File(imageFilePickedFromGallery.path);

      if (index < 0) {
        // Add the MemoryImage to display list
        _imageList.add(imageFileInBytesForm);

        // Add the File to file list for saving/uploading
        _imageFileList.add(imageFile);
      } else {
        // Replace the MemoryImage in display list
        _imageList[index] = imageFileInBytesForm;

        // Replace the File in file list
        _imageFileList[index] = imageFile;
      }

      setState(() {});  // Refresh the UI to display the updated list
    }
  }
  Future<void> addListing() async {
    if (formkey.currentState!.validate()) {
      if (_imageFileList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least one image.')),
        );
        return;
      }

      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location on the map.')),
        );
        return;
      }

      try {
        // Get the current logged-in user
        User? user = _auth.currentUser;
        String? username = user?.email;

        // Convert images to Base64 strings
        List<String> base64Images = [];
        for (var image in _imageFileList) {
          List<int> imageBytes = await image.readAsBytes();
          String base64String = base64Encode(imageBytes);
          base64Images.add(base64String);
        }

        // Add data to Firestore, including new fields
        DocumentReference listingRef = await _firestore.collection('listings').add({
          'buildingName': _BuildingController.text,
          'rent': _RentController.text,
          'description': _DescriptionController.text,
          'address': _AddressController.text,
          'username': username,
          'images': base64Images,
          'rating': 0.0,
          'timestamp': FieldValue.serverTimestamp(),
          'addressonmap': {
            'latitude': _selectedLocation!.latitude,
            'longitude': _selectedLocation!.longitude,
          },
          'approved': false, // New field: Approved status
          'bedrooms': _bedrooms, // New field: Number of bedrooms
          'bathrooms': _bathrooms, // New field: Number of bathrooms
        });

        // Update the user's document in the 'users' collection
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'listings': FieldValue.arrayUnion([listingRef.id]),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing added successfully!')),
        );

        // Clear form fields and reset values
        _BuildingController.clear();
        _RentController.clear();
        _TypeController.clear();
        _DescriptionController.clear();
        _AddressController.clear();
        setState(() {
          _imageFileList.clear();
          _imageList.clear();
          _bedrooms = 0;
          _bathrooms = 0;
        });
        // Navigate to HomeOwnerScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeOwnerScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding listing: $e')),
        );
      }
    }
  }

  initializeValues()
  {
    _BuildingController = TextEditingController(text: "");
    _RentController = TextEditingController(text: "");
    _TypeController = TextEditingController(text: "");
    _DescriptionController = TextEditingController(text: "");
    _AddressController = TextEditingController(text: "");
    _CityController = TextEditingController(text: "");
    _CountryController = TextEditingController(text: "");
    _AmenitiesController = TextEditingController(text: "");
    selectedType= residenceType.first;

    _imageList= [];

  }

  @override
  void initState(){
    super.initState();
    initializeValues();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFF7FE38D), Colors.white],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              ),
            ),

            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "KhujboKoi?",
                  style: TextStyle(color: Colors.green),
                ),
                const Text(
                  "                                                 Landlord",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                onPressed: () async {
                  if (!formkey.currentState!.validate()) {
                    return;
                  }

                  if (_imageList.isEmpty) {
                    return;
                  }

                  // Wait for the addListing function to complete
                  await addListing();

                  // Pop the current screen after adding the listing
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.upload,
                  color: Colors.green,
                  size: 35,
                ),
              ),

            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(26,26,26,0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Form(
                        key: formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //House name
                            Padding(
                              padding: const EdgeInsets.only(top:1.0 ),
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: "House Name"),
                                style: const TextStyle(
                                  fontSize: 25.0,
                                ),
                                controller: _BuildingController,
                                validator: (textInput)
                                  {
                                    if(textInput!.isEmpty)
                                      {
                                        return "please enter a valid name";
                                      }
                                    return null;
                                  }
                              )
                            ),
                            //House type
                           /* Padding(
                              padding: const EdgeInsets.only(top: 28.0),
                              child: DropdownButton(
                                  items: residenceType.map((item)
                                  {
                                    return DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 20,

                                        ),
                                      ),
                                    );

                                  }).toList(),
                                onChanged: (valueitem)
                                {
                                  setState(() {
                                    selectedType= valueitem.toString();
                                  });
                                },
                                isExpanded: true,
                                value: residenceType,
                                hint: const Text(
                                  "Select Listing Type"
                                ),
                              ),
                            ),*/
                            //Rent
                            Padding(
                              padding: const EdgeInsets.only(top:21.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[

                                  Expanded(
                                      child: TextFormField(
                                        decoration: const InputDecoration(labelText: "Rent"),
                                        style: const TextStyle(
                                          fontSize: 25.0,
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: _RentController,
                                        validator: (text){
                                          if(text!.isEmpty){
                                            return "please enter a valid rent";
                                          }
                                          return null;
                                        },
                                      ),
                                  ),

                                  const Padding(
                                    padding: EdgeInsets.only (
                                      left: 10.0,bottom:10.0
                                    ),
                                    child: Text(
                                      "৳ / month",
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            //Description
                            Padding(
                                padding: const EdgeInsets.only(top:21.0 ),
                                child: TextFormField(
                                    decoration: const InputDecoration(labelText: "Description"),
                                    style: const TextStyle(
                                      fontSize: 25.0,
                                    ),
                                    controller: _DescriptionController,
                                    maxLines: 3,
                                    minLines: 1,
                                    validator: (text)
                                    {
                                      if(text!.isEmpty)
                                      {
                                        return "please enter a valid description";
                                      }
                                      return null;
                                    }
                                )

                            ),

                            //Address
                            Padding(
                                padding: const EdgeInsets.only(top:21.0 ),
                                child: TextFormField(
                                    decoration: const InputDecoration(labelText: "Address"),
                                    style: const TextStyle(
                                      fontSize: 25.0,
                                    ),
                                    controller: _AddressController,
                                    validator: (text)
                                    {
                                      if(text!.isEmpty)
                                      {
                                        return "please enter a valid address";
                                      }
                                      return null;
                                    }
                                )
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 21.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.map),
                                      label: const Text("Set on Map"),
                                      onPressed: () async {
                                        // Navigate to the map screen and wait for the selected location
                                        final LatLng? result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MapPickerScreen(
                                              initialLocation: _selectedLocation, // Pass existing location, if any
                                            ),
                                          ),
                                        );

                                        // Update the selected location
                                        if (result != null) {
                                          setState(() {
                                            _selectedLocation = result;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  if (_selectedLocation != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        "Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, "
                                            "Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}",
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            //Bedrooms
                            const Padding(
                              padding: EdgeInsets.only(top: 30.0),
                              child: Text(
                                'Rooms',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                              ),
                              ),
                            ),
                            //Bedrooms
                            Padding(
                                padding: const EdgeInsets.only(top: 21.0,left:15.0 , right: 15.0),
                                child: Column(
                                  children: <Widget>[
                                    AmenitiesUI(
                                      Type: 'Bedrooms', // Change Type to type
                                      startValue: _bedrooms,
                                      decreaseVal: () {
                                        setState(() {
                                          if (_bedrooms > 0) {
                                            _bedrooms = _bedrooms - 1;
                                          }
                                        });
                                      },
                                      increaseVal: () {
                                        setState(() {
                                          _bedrooms = _bedrooms + 1;
                                        });
                                      },

                                    ),
                                  ],
                                ),
                            ),
                            //Bathrooms
                            Padding(
                              padding: const EdgeInsets.only(top: 21.0,left:15.0 , right: 15.0),
                              child: Column(
                                children: <Widget>[
                                  AmenitiesUI(
                                    Type: 'Bathrooms', // Change Type to type
                                    startValue: _bathrooms,
                                    decreaseVal: () {
                                      setState(() {
                                        if (_bathrooms > 0) {
                                          _bathrooms = _bathrooms - 1;
                                        }
                                      });
                                    },
                                    increaseVal: () {
                                      setState(() {
                                        _bathrooms = _bathrooms + 1;
                                      });
                                    },

                                  ),
                                ],
                              ),
                            ),
                            //Amenities
                            Padding(
                                padding: const EdgeInsets.only(top:21.0 ),
                                child: TextFormField(
                                    decoration: const InputDecoration(labelText: "Amenities"),
                                    style: const TextStyle(
                                      fontSize: 25.0,
                                    ),
                                    controller: _AmenitiesController,
                                    maxLines: 3,
                                    minLines: 1,
                                    validator: (text)
                                    {
                                      if(text!.isEmpty)
                                      {
                                        return "please enter valid amenities (comma separated)";
                                      }
                                      return null;
                                    }
                                )

                            ),
                            //Photos
                            const Padding(
                              padding: EdgeInsets.only(top:20.0),
                              child: Text(
                                'Photos',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top:20.0 , bottom: 25.0),
                                child : GridView.builder(
                                    shrinkWrap: true,
                                    itemCount: _imageList.length+1,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 25,
                                        crossAxisSpacing: 25,
                                        childAspectRatio: 3/2,
                                    ),
                                    itemBuilder: (BuildContext context, int index) {
                                       if(index == _imageList.length)
                                         {
                                           return IconButton(
                                               onPressed: (){
                                                 _selectImageFromGallery(-1);
                                               },
                                               icon: const Icon(Icons.add),
                                           );
                                         }
                                       return MaterialButton(
                                           onPressed: (){},
                                           child: Image(
                                             image: _imageList[index],
                                             fit: BoxFit.fill,
                                           ),
                                       );
                                    },

                                ),
                            ),
                          ],
                        )
                      )

                    ],
                  )
              )
            )
          ),

        )
    );
  }
}
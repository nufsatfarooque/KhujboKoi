import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:khujbokoi/components/base64imagewidget.dart';
import 'package:khujbokoi/core/property.dart';
import 'package:khujbokoi/services/database.dart';

class ListingApprovalsPanel extends StatefulWidget {
  const ListingApprovalsPanel({super.key});

  @override
  State<ListingApprovalsPanel> createState() => _ListingApprovalsPanelState();
}

DatabaseService database = DatabaseService();

void _copyToClipboard(BuildContext context, String phoneNumber) {
  Clipboard.setData(ClipboardData(text: phoneNumber));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Number copied: $phoneNumber')),
  );
}

class _ListingApprovalsPanelState extends State<ListingApprovalsPanel> {
  final Map<String, Map<String, dynamic>> _userCache = {}; // Cache user data

  Future<Map<String, dynamic>> _fetchUserData(String username) async {
    if (_userCache.containsKey(username)) {
      return _userCache[username]!;
    }
    final querySnapshot = await database.getUserbyUserName(username);
    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      _userCache[username] = userData; // Cache the user data
      return userData;
    }
    return {}; // Return an empty map if no user data found
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Property>>(
      stream: database.getPropertiesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No properties available'));
        }

        List<Property> properties = snapshot.data!;

        return ListView.builder(
          itemCount: properties.length,
          itemBuilder: (context, index) {
            final property = properties[index];
            final timePosted =
                DateFormat.yMMMd().add_jm().format(property.timestamp);
            final propertyOwner = property.username;

            return FutureBuilder<Map<String, dynamic>>(
              future: _fetchUserData(propertyOwner),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
                  return const SizedBox(); // Skip rendering if user data is missing
                }

                final userData = userSnapshot.data!;
                final userRole = userData['role'] ?? 'Unknown';
                final userPhnNumb =
                    userData['phoneNumber'] ?? 'No Number Found';
                final userEmail = userData['email'] ?? 'No email registered';
                return Card(
                  elevation: 5,
                  color: const Color.fromARGB(255, 223, 252, 229),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.orange,
                                        child: Text(
                                          userData['name'][0].toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _copyToClipboard(
                                            context, userPhnNumb),
                                        icon: const Icon(Icons.phone,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userData['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        userRole,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70),
                                      ),
                                      Text(
                                        userEmail,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70),
                                      ),
                                      Text(
                                        'Requested @: $timePosted',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Approved: ${property.approved}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 4),
                        Column(
                          
                          children: [
                            Container(
                              width:  MediaQuery.of(context).size.width , // 90% of screen width
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color:const Color.fromARGB(255, 223, 252, 229), // Light greenish background
                                borderRadius:
                                    BorderRadius.circular(12), // Rounded corners
                                border: Border.all(
                                    color: Colors.black26), // Light border
                               
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Property Type
                                  RichText(
                                    text: TextSpan(
                                      text: "Type: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: property.type,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                                                              
                                  const SizedBox(height: 6),
                                                              
                                  // Building Name
                                  RichText(
                                    text: TextSpan(
                                      text: "Building Name: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: property.buildingName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                                                              
                                  const SizedBox(height: 6),
                                                              
                                  // Address
                                  RichText(
                                    text: TextSpan(
                                      text: "Address/ Location: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: property.address,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                                                              
                                  const SizedBox(height: 6),
                                                              
                                  // Description
                                  RichText(
                                    text: TextSpan(
                                      text: "Description: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: property.description,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                                                              
                                  const SizedBox(height: 6),
                                                              
                                  // Condition (when available)
                                  //if (property.condition != null) ...[
                                  //  RichText(
                                  //    text: TextSpan(
                                  //      text: "Condition (if any): ",
                                  //      style: TextStyle(
                                  //        fontWeight: FontWeight.bold,
                                  //        color: Colors.black,
                                  //        fontSize: 14,
                                  //      ),
                                  //      children: [
                                  //        TextSpan(
                                  //          text: property.condition,
                                  //          style: TextStyle(fontWeight: FontWeight.normal),
                                  //        ),
                                  //      ],
                                  //    ),
                                  //  ),
                                  //  const SizedBox(height: 6),
                                  //],
                                                              
                                  // Rent
                                  RichText(
                                    text: TextSpan(
                                      text: "Rent Price: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "${property.rent} TK / Month",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                              
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            property.images.isNotEmpty
                                ? SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: property.images.length,
                                      itemBuilder: (context, imgIndex) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Base64ImageWidget(
                                              images: property.images,
                                              index: imgIndex),
                                        );
                                      },
                                    ),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text("No images available",
                                        style: TextStyle(color: Colors.grey)),
                                  ),
                                  SizedBox(height: 6,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                ElevatedButton(
                                    onPressed: () async => {
                                      await FirebaseFirestore.instance.collection('listings').doc(property.id).update({
                                        'approved': true,
                                      })
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            property.approved == false ?? true
                                                ? Colors.greenAccent
                                                : Colors.grey,
                                        shadowColor: Colors.black,
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        )),
                                    child: const Text('Approve',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16))),
                                SizedBox(
                                  width: 7,
                                ),
                                ElevatedButton(
                                    onPressed: () => {},
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            property.approved == false ?? true
                                                ? Colors.redAccent
                                                : Colors.grey,
                                        shadowColor: Colors.black,
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        )),
                                    child: const Text('  Deny  ',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16))),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

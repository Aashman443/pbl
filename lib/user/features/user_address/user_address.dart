import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenzo/api_connection/api_connection.dart';
import 'package:zenzo/constants/AppColor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../userPrefrences/current_user.dart';

class UserAddress extends StatefulWidget {
  final bool selectMode;
  final Function(Address)? onAddressSelected;
  final Address? currentSelectedAddress; // Added this to show currently selected address

  const UserAddress({
    Key? key,
    this.selectMode = false,
    this.onAddressSelected,
    this.currentSelectedAddress,
  }) : super(key: key);

  @override
  State<UserAddress> createState() => _UserAddressState();
}

class _UserAddressState extends State<UserAddress> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
  String? userEmail;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final alterPhoneController = TextEditingController();
  final pinCodeController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final houseController = TextEditingController();
  final roadController = TextEditingController();

  List<Address> addresses = [];
  String? selectedAddressId; // Track the selected address

  // To hold current address id for update
  String? editingAddressId;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Set initially selected address if provided
    if (widget.currentSelectedAddress != null) {
      selectedAddressId = widget.currentSelectedAddress!.id;
    }
  }

  Future<void> _loadUserData() async {
    await _currentUser.getUserInfo();
    userEmail = _currentUser.user?.userEmail;
    if (userEmail != null) {
      await fetchAddresses(userEmail!);
    }
  }

  Future<void> fetchAddresses(String email) async {
    final uri = Uri.parse('${Api.get_userAddress}?email=$email');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        List<Address> fetched =
        (data['addresses'] as List).map((addr) {
          return Address(
            id: addr['id'].toString(), // Add id here
            type: 'Home',
            place:
            '${addr['house_details']}, ${addr['road_details']}, ${addr['city']} - ${addr['pincode']}, ${addr['state']}',
            landmark: 'Alt Phone: ${addr['alternate_phone'] ?? 'N/A'}',
            phoneNumber: addr['phone_number'] ?? '',
            distance: '0 m',
            fullName: addr['full_name'] ?? '',
            alternatePhone: addr['alternate_phone'] ?? '',
            pincode: addr['pincode'] ?? '',
            state: addr['state'] ?? '',
            city: addr['city'] ?? '',
            houseDetails: addr['house_details'] ?? '',
            roadDetails: addr['road_details'] ?? '',
          );
        }).toList();

        setState(() {
          addresses = fetched;
        });
      } else {
        print("No addresses found: ${data['message']}");
      }
    } else {
      print("Error: ${response.statusCode}");
    }
  }

  Future<void> saveAddressToBackend() async {
    final uri = Uri.parse(Api.add_userAddress);

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": userEmail ?? '',
        "full_name": fullNameController.text,
        "phone_number": phoneController.text,
        "alternate_phone": alterPhoneController.text,
        "pincode": pinCodeController.text,
        "state": stateController.text,
        "city": cityController.text,
        "house_details": houseController.text,
        "road_details": roadController.text,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        print("Address saved successfully.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Address saved successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
        fetchAddresses(userEmail!); // refresh list
      } else {
        print("Failed to save address: ${json['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${json['message']}"),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } else {
      print("Server error: ${response.statusCode}");
    }
  }

  Future<void> updateAddressToBackend() async {
    if (editingAddressId == null) return;

    final uri = Uri.parse(Api.update_userAddress);

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": editingAddressId,
        "email": userEmail ?? '',
        "full_name": fullNameController.text,
        "phone_number": phoneController.text,
        "alternate_phone": alterPhoneController.text,
        "pincode": pinCodeController.text,
        "state": stateController.text,
        "city": cityController.text,
        "house_details": houseController.text,
        "road_details": roadController.text,
      }),
    );

    final json = jsonDecode(response.body);
    if (json['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Address updated successfully"),
          backgroundColor: AppColors.primary,
        ),
      );
      fetchAddresses(userEmail!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update address"),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _showAddressSheet({Address? addressToEdit}) {
    if (addressToEdit != null) {
      // Editing mode - fill controllers with existing data
      editingAddressId = addressToEdit.id;
      fullNameController.text = addressToEdit.fullName;
      phoneController.text = addressToEdit.phoneNumber;
      alterPhoneController.text = addressToEdit.alternatePhone;
      pinCodeController.text = addressToEdit.pincode;
      stateController.text = addressToEdit.state;
      cityController.text = addressToEdit.city;
      houseController.text = addressToEdit.houseDetails;
      roadController.text = addressToEdit.roadDetails;
    } else {
      // Adding new address - clear all
      editingAddressId = null;
      fullNameController.clear();
      phoneController.clear();
      alterPhoneController.clear();
      pinCodeController.clear();
      stateController.clear();
      cityController.clear();
      houseController.clear();
      roadController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(15),
                    Text(
                      addressToEdit == null ? 'Add Address' : 'Edit Address',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            fullNameController,
                            'Full Name (Required)',
                            true,
                          ),
                          Gap(20),
                          _buildTextField(
                            phoneController,
                            'Phone number (Required)',
                            true,
                          ),
                          Gap(20),
                          _buildTextField(
                            alterPhoneController,
                            'Alternate Phone number',
                            false,
                          ),
                          Gap(20),
                          _buildTextField(
                            pinCodeController,
                            'PinCode (Required)',
                            true,
                          ),
                          Gap(20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  stateController,
                                  'State (Required)',
                                  true,
                                ),
                              ),
                              Gap(10),
                              Expanded(
                                child: _buildTextField(
                                  cityController,
                                  'City (Required)',
                                  true,
                                ),
                              ),
                            ],
                          ),
                          Gap(20),
                          _buildTextField(
                            houseController,
                            'House No., Building Name (Required)',
                            true,
                          ),
                          Gap(20),
                          _buildTextField(
                            roadController,
                            'Road name, Area, Colony (Required)',
                            true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (addressToEdit == null) {
                              await saveAddressToBackend();
                            } else {
                              await updateAddressToBackend();
                            }
                            if (mounted) Navigator.pop(context);
                          }
                        },
                        child: Text(
                          addressToEdit == null
                              ? 'Save Address'
                              : 'Update Address',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      bool isRequired,
      ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator:
      isRequired
          ? (value) =>
      value == null || value.trim().isEmpty
          ? 'This field is required'
          : null
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(widget.selectMode ? 'Select Address' : 'Manage & Add Address'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: const Icon(Icons.add, color: Colors.white),
                title: const Text(
                  'Add address',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => _showAddressSheet(),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SAVED ADDRESSES',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => AddressCard(
                address: addresses[index],
                isSelected: selectedAddressId == addresses[index].id,
                onTap: widget.selectMode ? () {
                  setState(() {
                    selectedAddressId = addresses[index].id;
                  });
                  if (widget.onAddressSelected != null) {
                    widget.onAddressSelected!(addresses[index]);
                    Navigator.pop(context, addresses[index]);
                  }
                } : null,
                onEdit: () {
                  _showAddressSheet(addressToEdit: addresses[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Address {
  final String id; // Added id for update
  final String type;
  final String place;
  final String landmark;
  final String phoneNumber;
  final String distance;

  // For editing form population:
  final String fullName;
  final String alternatePhone;
  final String pincode;
  final String state;
  final String city;
  final String houseDetails;
  final String roadDetails;

  Address({
    required this.id,
    required this.type,
    required this.place,
    required this.landmark,
    required this.phoneNumber,
    required this.distance,
    required this.fullName,
    required this.alternatePhone,
    required this.pincode,
    required this.state,
    required this.city,
    required this.houseDetails,
    required this.roadDetails,
  });
}

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final bool isSelected;

  const AddressCard({
    Key? key,
    required this.address,
    this.onEdit,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isSelected
              ? BorderSide(color: AppColors.primary, width: 2)
              : BorderSide.none,
        ),
        elevation: isSelected ? 3 : 1,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 12,
                    ),
                    child: Text(
                      address.type,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                    ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 10),
              // Display the full name first
              Text(
                address.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 5),
              // Then display the address details
              Text(
                '${address.houseDetails}, ${address.roadDetails}, ${address.city} - ${address.pincode}, ${address.state}',
                style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    address.landmark,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    address.phoneNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_pin, color: Colors.orange, size: 15),
                  const SizedBox(width: 5),
                  Text(
                    address.distance,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:zenzo/api_connection/api_connection.dart';
import 'package:zenzo/constants/AppColor.dart';
import 'package:zenzo/widgets/Custom_TextField.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final discountController = TextEditingController();
  final brandController = TextEditingController();
  final ratingController = TextEditingController();
  final colorInputController = TextEditingController();

  String? selectedCategory;
  String? selectedSubCategory;
  List<XFile> productImages = [];

  List<String> sizes = ["XS", "S", "M", "L", "XL", "XXL","12-18 M","18-24 M","2-3 Y","4-5 Y","5-6 Y","7-8 Y"];
  List<String> selectedSizes = [];
  List<String> selectedColors = [];

  bool isFeatured = false;
  bool isNewArrival = false;
  bool isPublished = true;
  bool isLoading = false;

  Future<void> pickImages() async {
    final picker = ImagePicker();
    try {
      final images = await picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        setState(() {
          productImages.addAll(images);
        });
      }
    } catch (e) {
      print('Image picker error: $e');
    }
  }

  Future<void> submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (productImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text("Please select at least one image"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final uri = Uri.parse(Api.upload_product);
      final request = http.MultipartRequest('POST', uri);

      request.fields['title'] = titleController.text.trim();
      request.fields['description'] = descController.text.trim();
      request.fields['price'] = priceController.text.trim();
      request.fields['rating'] = ratingController.text.trim();
      request.fields['discount'] =
      discountController.text.trim().isEmpty ? "0" : discountController.text.trim();
      request.fields['brand_name'] = brandController.text.toUpperCase();
      request.fields['category'] = selectedCategory ?? '';
      request.fields['subcategory'] = selectedSubCategory ?? '';
      request.fields['sizes'] = jsonEncode(selectedSizes);
      request.fields['colors'] = jsonEncode(selectedColors);
      request.fields['is_featured'] = isFeatured.toString();
      request.fields['is_new_arrival'] = isNewArrival.toString();
      request.fields['is_published'] = isPublished.toString();

      for (var img in productImages) {
        final bytes = await File(img.path).readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'images[]',
          bytes,
          filename: img.name,
        ));
      }

      final streamedResponse = await request.send();
      final responseBytes = await streamedResponse.stream.toBytes();
      final responseString = String.fromCharCodes(responseBytes);

      try {
        final data = jsonDecode(responseString);
        if (streamedResponse.statusCode == 200 && data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primary,
              content: Text("Product Uploaded Successfully"),
            ),
          );
          _resetForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Upload Failed: ${data['message']}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid server response: $e")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      titleController.clear();
      descController.clear();
      priceController.clear();
      discountController.clear();
      brandController.clear();
      colorInputController.clear();
      ratingController.clear();
      selectedSizes.clear();
      selectedColors.clear();
      productImages.clear();
      selectedCategory = null;
      isFeatured = false;
      isNewArrival = false;
      isPublished = true;
    });
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.blue.shade100,
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    priceController.dispose();
    discountController.dispose();
    brandController.dispose();
    colorInputController.dispose();
    ratingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Upload Clothing Product",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text("Add New Product", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Gap(15),
                          CustomTextField(
                            controller: titleController,
                            hintText: 'Product Title',
                            validator: (value) => value!.isEmpty ? "Enter title" : null,
                          ),
                          Gap(15),
                          CustomTextField(
                            controller: descController,
                            hintText: 'Description',
                            maxLine: 3,
                            validator: (value) => value!.isEmpty ? "Enter description" : null,
                          ),
                          Gap(15),
                          CustomTextField(
                            controller: priceController,
                            hintText: 'Price',
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? "Enter price" : null,
                          ),
                          Gap(15),
                          CustomTextField(
                            controller: ratingController,
                            hintText: 'Rating',
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? "Enter rating" : null,
                          ),
                          Gap(15),
                          CustomTextField(
                            controller: discountController,
                            hintText: 'Discount Price (optional)',
                            keyboardType: TextInputType.number,
                          ),
                          Gap(15),
                          CustomTextField(
                            controller: brandController,
                            hintText: 'Brand Name',
                            validator: (value) => value!.isEmpty ? "Enter brand name" : null,
                          ),
                          Gap(15),
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: InputDecoration(labelText: "Category"),
                            items: ['Men', 'Women', 'Kids'].map((cat) {
                              return DropdownMenuItem(value: cat, child: Text(cat));
                            }).toList(),
                            onChanged: (value) => setState(() => selectedCategory = value),
                            validator: (value) => value == null ? "Select category" : null,
                          ),
                          Gap(15),
                          DropdownButtonFormField<String>(
                            value: selectedSubCategory,
                            decoration: InputDecoration(labelText: "Sub-category"),
                            items: ['T-Shirts', 'Jeans', 'Jackets', 'Dress', 'Shirt'].map((sub) {
                              return DropdownMenuItem(value: sub, child: Text(sub));
                            }).toList(),
                            onChanged: (value) => setState(() => selectedSubCategory = value),
                            validator: (value) => value == null ? "Select sub-category" : null,
                          ),
                          Gap(12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Sizes", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Wrap(
                            children: sizes.map((size) {
                              return _buildChip(size, selectedSizes.contains(size), () {
                                setState(() {
                                  selectedSizes.contains(size)
                                      ? selectedSizes.remove(size)
                                      : selectedSizes.add(size);
                                });
                              });
                            }).toList(),
                          ),
                          Gap(12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Add Colors", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Gap(5),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: colorInputController,
                                  hintText: "Enter color name",
                                ),
                              ),
                              Gap(8),
                              ElevatedButton(
                                onPressed: () {
                                  final color = colorInputController.text.trim();
                                  if (color.isNotEmpty && !selectedColors.contains(color)) {
                                    setState(() {
                                      selectedColors.add(color);
                                      colorInputController.clear();
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                child: Text("Add", style: GoogleFonts.inter(color: Colors.white)),
                              ),
                            ],
                          ),
                          Gap(8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Selected Colors", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Wrap(
                            children: selectedColors.map((color) {
                              return _buildChip(color, true, () {
                                setState(() {
                                  selectedColors.remove(color);
                                });
                              });
                            }).toList(),
                          ),
                          Gap(12),
                          ElevatedButton.icon(
                            onPressed: pickImages,
                            icon: Icon(Icons.photo, color: Colors.white),
                            label: Text("Pick Product Images", style: GoogleFonts.inter(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            ),
                          ),
                          Gap(8),
                          productImages.isEmpty
                              ? Text("No images selected.")
                              : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: productImages.map((img) {
                              return Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(img.path),
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        productImages.remove(img);
                                      });
                                    },
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          SwitchListTile(
                            value: isFeatured,
                            title: Text("Featured Product"),
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => isFeatured = val),
                          ),
                          SwitchListTile(
                            value: isNewArrival,
                            title: Text("New Arrival"),
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => isNewArrival = val),
                          ),
                          SwitchListTile(
                            value: isPublished,
                            title: Text("Publish Now"),
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => isPublished = val),
                          ),
                          Gap(16),
                          ElevatedButton(
                            onPressed: isLoading ? null : submitProduct,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                              backgroundColor: AppColors.primary,
                            ),
                            child: Text("Submit Product", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      ),
    );
  }
}

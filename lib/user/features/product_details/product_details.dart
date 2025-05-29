import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zenzo/api_connection/api_connection.dart';
import 'package:zenzo/constants/AppColor.dart';
import '../../userPrefrences/current_user.dart';
import '../Favorite_Screen/models/favorite_models.dart';
import 'ImageViewerScreen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  final CurrentUser _currentUser = Get.put(CurrentUser());
  String? selectedSize;
  String? selectedColor;
  String? userEmail;
  bool isFavorite = false;

  late List<String> sizes;
  late List<String> colors;

  @override
  void initState() {
    super.initState();
    sizes =
        widget.product['sizes'] != null
            ? List<String>.from(widget.product['sizes'])
            : [];
    colors =
        widget.product['colors'] != null
            ? List<String>.from(widget.product['colors'])
            : [];
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _currentUser.getUserInfo();
    if (mounted) {
      setState(() {
        userEmail = _currentUser.user?.userEmail;
        print("Loaded User Email in initState: $userEmail");
      });
    }
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.brown.shade100,
        backgroundColor: Colors.grey.shade200,
        labelStyle: TextStyle(color: selected ? Colors.brown : Colors.black),
      ),
    );
  }

  Future<void> _addToCart() async {
    // Validate size and color selections if they are available
    if (sizes.isNotEmpty && selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a size.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (colors.isNotEmpty && selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a color.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get user data
    await _currentUser.getUserInfo();
    final userEmail = _currentUser.user?.userEmail;
    print("Sending user ID: $userEmail");

    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Email not found. Please login again.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final url = Uri.parse(Api.add_cart);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": userEmail,
          "product_id": widget.product['id'].toString(),
          "title": widget.product['title'],
          "brand_name": widget.product['brand_name'],
          "description": widget.product['description'],
          "price": widget.product['price'],
          "rating": widget.product['rating'] ?? "4.5",
          "images": widget.product['images'],
          "selected_size": selectedSize ?? "",
          "selected_color": selectedColor ?? "",
        }),
      );

      final resData = json.decode(response.body);
      print("Add to cart response: $resData");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resData['message'] ?? 'Unknown response',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor:
              resData['success'] == true ? AppColors.primary : Colors.red,
        ),
      );
    } catch (e) {
      print("Add to cart error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addFavorite() async {
    // First ensure we have the latest user data
    await _currentUser.getUserInfo();
    final userEmail = _currentUser.user?.userEmail;
    print("Sending user ID: $userEmail");

    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not found. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print("Adding to favorite with Email: $userEmail");

    final url = Uri.parse(Api.add_favorite);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": userEmail, // Send email instead of user_id
          "product_id": widget.product['id'].toString(),
          "title": widget.product['title'],
          "brand_name": widget.product['brand_name'],
          "description": widget.product['description'],
          "price": widget.product['price'],
          "rating": widget.product['rating'] ?? "4.5",
          "images": widget.product['images'],
          "selected_size": selectedSize ?? "",
          "selected_color": selectedColor ?? "",
        }),
      );

      final resData = json.decode(response.body);
      print("Add to favorite response: $resData");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resData['message'] ?? 'Unknown response'),
          backgroundColor:
              resData['success'] == true ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print("Add to favorite error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Stack(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: 600,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: widget.product['images']?.length ?? 1,
                              itemBuilder: (context, index) {
                                final imageUrl =
                                    widget.product['images'] != null &&
                                            widget.product['images'][index] !=
                                                null
                                        ? widget.product['images'][index]
                                        : '';
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ImageViewerScreen(
                                              images: List<String>.from(
                                                widget.product['images'],
                                              ),
                                              initialPage: index,
                                            ),
                                      ),
                                    );
                                  },
                                  child:
                                      imageUrl.isNotEmpty
                                          ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                color: Colors.grey.shade300,
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                          : Container(
                                            color: Colors.grey.shade300,
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                              ),
                                            ),
                                          ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: widget.product['images']?.length ?? 1,
                              effect: ExpandingDotsEffect(
                                dotHeight: 8,
                                dotWidth: 8,
                                expansionFactor: 3,
                                spacing: 6,
                                dotColor: Colors.grey.shade400,
                                activeDotColor: Colors.brown.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Positioned(
                            top: 16,
                            left: 16,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_outlined,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                          Positioned.fill(
                            top: 70,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                'Product Details',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isFavorite = !isFavorite;

                                    /// for calling the add to favorite
                                    if (isFavorite == true) {
                                      _addFavorite();
                                    }
                                  });
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.product['brand_name'] ?? "Product",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const Spacer(),
                            const Icon(Icons.star, color: Colors.amber),
                            Gap(5),
                            Text(
                              widget.product['rating'] != null &&
                                      widget.product['rating']
                                          .toString()
                                          .isNotEmpty
                                  ? widget.product['rating'].toString()
                                  : "4.5",
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.product['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.product['description'] ??
                              'No description available',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              backgroundColor: Colors.white,
                              isScrollControlled: true,
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          "Product Description",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          widget.product['description'] ??
                                              'No description available.',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text(
                            "Read more",
                            style: TextStyle(color: Colors.brown),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Conditional Size Section
                        if (sizes.isNotEmpty) ...[
                          Text(
                            "Select Size",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            children:
                                sizes
                                    .map(
                                      (size) => _buildChip(
                                        size,
                                        selectedSize == size,
                                        () {
                                          setState(() {
                                            selectedSize = size;
                                          });
                                        },
                                      ),
                                    )
                                    .toList(),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Conditional Color Section
                        if (colors.isNotEmpty) ...[
                          Text(
                            "Select Color",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            children:
                                colors
                                    .map(
                                      (color) => _buildChip(
                                        color,
                                        selectedColor == color,
                                        () {
                                          setState(() {
                                            selectedColor = color;
                                          });
                                        },
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Price\n₹${widget.product['price'] ?? '0.00'}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Add to cart functionality here
                      _addToCart();
                    },
                    icon: const Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      "Add to Cart",
                      style: GoogleFonts.inter(
                        color: AppColors.background,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F4E37),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

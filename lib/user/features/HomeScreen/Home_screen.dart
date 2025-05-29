import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:zenzo/constants/AppColor.dart';

import '../../../api_connection/api_connection.dart';
import '../../userPrefrences/current_user.dart';
import '../product_details/product_details.dart';
import '../user_address/user_address.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
  String? userEmail;
  int hours = 2;
  int minutes = 12;
  int seconds = 56;

  String selectedTab = "All";
  String selectedCategory = "";

  // Search controller
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  List<Address> addresses = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    searchController.addListener(_onSearchChanged);
    _loadUserData();
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
      _filterProducts();
    });
  }

  Future<void> _loadUserData() async {
    await _currentUser.getUserInfo();
    userEmail = _currentUser.user?.userEmail;
    if (userEmail != null) {
      await fetchAddresses(userEmail!);
    }
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(Api.get_Productdata));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('API Response: $data');

        if (data != null && data['success'] == true && data['products'] != null) {
          setState(() {
            products = List.from(data['products']);
            filteredProducts = List.from(products);
            isLoading = false;
          });
          _filterProducts();
        } else {
          setState(() {
            errorMessage = 'Invalid data format or no products found';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
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

  void _filterProducts() {
    List<dynamic> tempProducts = List.from(products);

    // Debug: Print all products with their details
    print('=== ALL PRODUCTS DEBUG ===');
    for (int i = 0; i < products.length; i++) {
      var product = products[i];
      print('Product $i:');
      print('  Title: ${product['title']}');
      print('  Category: ${product['category']}');
      print('  SubCategory: ${product['subcategory']}');
      print('  Brand: ${product['brand_name']}');
      print('  ---');
    }

    // Apply search filter first
    if (searchQuery.isNotEmpty) {
      tempProducts = tempProducts.where((product) {
        String productName = (product['title'] ?? '').toString().toLowerCase();
        String brandName = (product['brand_name'] ?? '').toString().toLowerCase();
        String category = (product['category'] ?? '').toString().toLowerCase();
        String subCategory = (product['subcategory'] ?? '').toString().toLowerCase();

        return productName.contains(searchQuery) ||
            brandName.contains(searchQuery) ||
            category.contains(searchQuery) ||
            subCategory.contains(searchQuery);
      }).toList();
    }

    // Apply category filter (Fixed - exact matching)
    if (selectedCategory.isNotEmpty) {
      tempProducts = tempProducts.where((product) {
        String productCategory = (product['category'] ?? '').toString().toLowerCase();
        String productSubcategory = (product['subcategory'] ?? '').toString().toLowerCase();
        String productTitle = (product['title'] ?? '').toString().toLowerCase();
        String categoryLower = selectedCategory.toLowerCase();

        // Check if the product belongs to the selected category
        return productCategory.contains(categoryLower) ||
            productSubcategory.contains(categoryLower) ||
            productTitle.contains(categoryLower);
      }).toList();
    }

    // Apply tab filter (Fixed Logic - More Precise)
    if (selectedTab != "All") {
      tempProducts = tempProducts.where((product) {
        String category = (product['category'] ?? '').toString().toLowerCase();
        String title = (product['title'] ?? '').toString().toLowerCase();
        String subcategory = (product['subcategory'] ?? '').toString().toLowerCase();
        String brandName = (product['brand_name'] ?? '').toString().toLowerCase();

        // Combine all searchable fields
        String allFields = '$category $title $subcategory $brandName'.toLowerCase();

        switch (selectedTab.toLowerCase()) {
          case "newest":
          // You can implement newest logic here based on your date field
          // For now, showing all products
            return true;

          case "popular":
          // You can implement popular logic here based on your rating/sales field
          // For now, showing all products
            return true;

          case "men":
          // More precise matching for men's products
            return category.contains('men') ||
                category.contains('man') ||
                category.contains('male') ||
                category.contains('men') ||
                (!category.contains('women')&&!category.contains('kids'));

          case "women":
          // More precise matching for women's products
            return category.contains('women') ||
                category.contains('woman') ||
                category.contains('female') ||
                category.contains('girl') ||
                category.contains('women') ||
                (category.contains('women') && !category.contains('men')&&!category.contains('kids'));

          case "kids":
          // More precise matching for kids products
            return allFields.contains('kids') ||
                allFields.contains('kid') ||
                allFields.contains('child') ||
                allFields.contains('children') ||
                allFields.contains('boy') ||
                allFields.contains('girl') ||
                category.contains('kids') ||
                (category.contains('women') && !category.contains('men'));

          default:
            return true;
        }
      }).toList();
    }

    setState(() {
      filteredProducts = tempProducts;
    });

    // Enhanced Debug print
    print('=== FILTERING DEBUG ===');
    print('Selected Tab: $selectedTab');
    print('Selected Category: $selectedCategory');
    print('Search Query: $searchQuery');
    print('Total products: ${products.length}');
    print('Filtered products: ${filteredProducts.length}');

    // Print filtered products details
    print('=== FILTERED PRODUCTS ===');
    for (int i = 0; i < filteredProducts.length; i++) {
      var product = filteredProducts[i];
      print('Filtered Product $i:');
      print('  Title: ${product['title']}');
      print('  Category: ${product['category']}');
      print('  SubCategory: ${product['subcategory']}');
      print('  Brand: ${product['brand_name']}');
      print('  ---');
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = selectedCategory == category ? "" : category;
      _filterProducts();
    });
  }

  void _onTabSelected(String tab) {
    setState(() {
      selectedTab = tab;
      _filterProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildLocationBar(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildPromotionBanner(),
                const SizedBox(height: 16),
                _buildIndicatorDots(),
                const SizedBox(height: 24),
                _buildCategorySection(),
                const SizedBox(height: 24),
                _buildFlashSaleSection(),
                isLoading
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : _buildProductsGrid(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.brown.shade600, size: 20),
            const SizedBox(width: 4),
            const Text("New York, USA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
        CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          radius: 18,
          child: const Icon(CupertinoIcons.bell_fill, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                hintText: "Search products, brands, categories...",
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    searchController.clear();
                  },
                )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: Colors.brown.shade600,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPromotionBanner() {
    return Container(
      height: 189,
      decoration: BoxDecoration(
        color: const Color(0xFFEFE5D5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New Collection", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Discount 50% for\nthe first transaction", style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text("Shop Now", style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Image.network(
                "https://images.unsplash.com/photo-1581044777550-4cfa60707c03",
                fit: BoxFit.cover,
                height: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: index == 2 ? Colors.brown.shade600 : Colors.grey.shade300,
        ),
      )),
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      {"icon": null, "name": "T-Shirt", "svgIcon": 'assets/images/t-shirt-6-svgrepo-com.svg'},
      {"icon": null, "name": "Pant", "svgIcon": 'assets/images/pants-svgrepo-com.svg'},
      {"icon": null, "name": "Dress", "svgIcon": 'assets/images/dress-1-svgrepo-com.svg'},
      {"icon": null, "name": "Jacket", "svgIcon": 'assets/images/jacket-svgrepo-com.svg'},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Category", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedCategory = "";
                  _filterProducts();
                });
              },
              child: Text("See All", style: TextStyle(color: Colors.grey.shade700)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: categories.map((category) {
            String categoryName = category["name"] as String;
            bool isSelected = selectedCategory == categoryName;

            return GestureDetector(
              onTap: () => _onCategorySelected(categoryName),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.brown.shade600 : Colors.brown.shade50,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.brown.shade800, width: 2) : null,
                    ),
                    child: SvgPicture.asset(
                      category["svgIcon"] as String,
                      width: 30,
                      height: 30,
                      colorFilter: ColorFilter.mode(
                          isSelected ? Colors.white : Colors.brown.shade700,
                          BlendMode.srcIn
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      categoryName,
                      style: TextStyle(
                          color: isSelected ? Colors.brown.shade800 : Colors.grey.shade800,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500
                      )
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFlashSaleSection() {
    final tabs = ["All", "Newest", "Popular", "Men", "Women", "Kids"];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Flash Sale", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Text("Closing in : ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                _buildTimeBox(hours.toString().padLeft(2, '0')),
                const Text(" : "),
                _buildTimeBox(minutes.toString().padLeft(2, '0')),
                const Text(" : "),
                _buildTimeBox(seconds.toString().padLeft(2, '0')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tabs.length,
            itemBuilder: (context, index) {
              final isSelected = tabs[index] == selectedTab;
              return GestureDetector(
                onTap: () => _onTabSelected(tabs[index]),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.brown.shade600 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? Colors.brown.shade600 : Colors.grey.shade300),
                  ),
                  child: Center(
                      child: Text(
                          tabs[index],
                          style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500
                          )
                      )
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTimeBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildProductsGrid() {
    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty || selectedCategory.isNotEmpty || selectedTab != "All"
                  ? 'No products found for "${selectedTab}" category\nTry adjusting your filters'
                  : 'No products available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (searchQuery.isNotEmpty || selectedCategory.isNotEmpty || selectedTab != "All")
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  'Found ${filteredProducts.length} products${selectedTab != "All" ? ' in $selectedTab' : ''}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (searchQuery.isNotEmpty || selectedCategory.isNotEmpty || selectedTab != "All")
                  TextButton(
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                        selectedCategory = "";
                        selectedTab = "All";
                        _filterProducts();
                      });
                    },
                    child: Text(
                      'Clear Filters',
                      style: TextStyle(color: Colors.brown.shade600),
                    ),
                  ),
              ],
            ),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(product: product),
                  ),
                );
              },
              child: _buildProductCard(product),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    String imageUrl = '';
    if (product['images'] != null && product['images'] is List && product['images'].isNotEmpty) {
      imageUrl = product['images'][0];
    }
    print('Product Images: ${product['images']}');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.fitHeight,
                )
                    : Container(
                  height: 180,
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.image_not_supported, size: 40)),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite_border, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['brand_name'] ?? 'No name',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGray),
                ),
                Text(
                  product['title'] ?? 'No name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹ ${product['price'] ?? '0'}',
                  style: TextStyle(color: Colors.brown.shade600, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
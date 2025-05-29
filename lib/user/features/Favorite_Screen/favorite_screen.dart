import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:zenzo/api_connection/api_connection.dart';
import 'package:zenzo/constants/AppColor.dart';
import 'package:zenzo/user/features/Favorite_Screen/models/favorite_models.dart';
import '../../userPrefrences/current_user.dart';
import '../Cart_Screen/models/cart_model.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final CurrentUser _currentUser = Get.put(CurrentUser());
  String? userEmail;
  List<CartItems> favoriteItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _currentUser.getUserInfo();
    userEmail = _currentUser.user?.userEmail;
    if (userEmail != null) {
      await fetchFavoriteDetails();
    }
  }

  Future<void> fetchFavoriteDetails() async {
    final url = Uri.parse(Api.get_favorite);
    if (userEmail == null) return;

    try {
      setState(() => isLoading = true);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': userEmail}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Response data: $data");

        if (data['success']) {
          final List<CartItems> loadedItems =
          (data['favorite'] as List).map((item) {
            final images = item['images'];
            String imageUrl = '';
            if (images is List && images.isNotEmpty) {
              imageUrl = images.first.toString();
            } else if (images is String) {
              imageUrl = images;
            }

            return CartItems(
              name: item['title'] ?? 'Unknown',
              brand: item['brand_name'] ?? 'Unknown',
              size: (item['selected_size'] ?? 'M').toString(),
              price:
              double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0,
              image: imageUrl,
              productId: int.tryParse(item['product_id'].toString()) ?? 0,
              quantity: 1,
            );
          }).toList();

          setState(() {
            favoriteItems = loadedItems;
          });
        } else {
          Get.snackbar(
            'Error',
            data['message']?.toString() ?? 'Failed to fetch favorites',
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load favorites (status: ${response.statusCode})',
        );
      }
    } catch (e) {
      print('Exception: $e');
      Get.snackbar('Error', 'An error occurred while fetching favorites');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> removeFromFavorite(int productId) async {
    final url = Uri.parse(Api.remove_favorite);
    if (userEmail == null) {
      print("User email is null");
      Get.snackbar('Error', 'User email is null');
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': userEmail, 'product_id': productId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response data: $data');

        if (data != null && data['success'] != null) {
          if (data['success']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Item removed from favorites',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.green,
              ),
            );
            await fetchFavoriteDetails();
          } else {
            final message =
                data['message']?.toString() ?? 'Failed to remove item';
            Get.snackbar('Error', message);
          }
        } else {
          Get.snackbar('Error', 'Invalid response data');
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to remove item (status code: ${response.statusCode})',
        );
      }
    } catch (e) {
      print('Exception: $e');
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Gap(50),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Favorite',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchFavoriteDetails,
                color: AppColors.primary,
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
                    : favoriteItems.isEmpty
                    ? const Center(
                  child: Text(
                    'Your favorites are empty',
                    style: TextStyle(fontSize: 18),
                  ),
                )
                    : ListView.separated(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: favoriteItems.length,
                  separatorBuilder: (context, index) =>
                  const Divider(),
                  itemBuilder: (context, index) {
                    final item = favoriteItems[index];
                    return CartItemWidget(
                      item: item,
                      onRemove: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text('Delete'),
                            content: const Text(
                                'Are you sure you want to delete?'),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('No'),
                                onPressed: () =>
                                    Navigator.of(context).pop(),
                              ),
                              CupertinoDialogAction(
                                child: const Text('Yes'),
                                isDestructiveAction: true,
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await removeFromFavorite(
                                      item.productId);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItems item;
  final VoidCallback onRemove;

  const CartItemWidget({Key? key, required this.item, required this.onRemove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: item.image.isNotEmpty
                ? Image.network(
              item.image,
              fit: BoxFit.fitHeight,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image, size: 40),
            )
                : const Icon(Icons.image, size: 40),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.brand,
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

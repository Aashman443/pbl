import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageViewerScreen extends StatelessWidget {
  final List<String> images;
  final int initialPage;

  ImageViewerScreen({required this.images, this.initialPage = 0});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(initialPage: initialPage);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return ZoomableImage(imageUrl: images[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ZoomableImage extends StatefulWidget {
  final String imageUrl;

  const ZoomableImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final position = _doubleTapDetails!.localPosition;
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    } else {
      _controller.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _controller,
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.8,
        maxScale: 4.0,
        child: Center(
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.broken_image, color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}

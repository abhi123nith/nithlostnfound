import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class FullscreenImageViewer extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2671), // Deep blue color
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D2671), Color(0xFFC33764)], // Deep blue to dark magenta
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius:BorderRadius.circular(20)
            ),
            child: CarouselSlider(
              options: CarouselOptions(
                initialPage: initialIndex,
                height: MediaQuery.of(context).size.height * 0.8, // Adjust height as needed
                viewportFraction: 1.0, 
                autoPlay: false,
                enlargeCenterPage: false,
                enableInfiniteScroll: false,
              ),
              items: imageUrls.map<Widget>((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain, 
                          width: MediaQuery.of(context).size.width, 
                          height: MediaQuery.of(context).size.height * 0.8, 
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

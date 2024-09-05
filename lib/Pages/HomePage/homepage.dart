import 'package:flutter/material.dart';
import 'package:nithlostnfound/Pages/AppDrawer/appdrawer.dart';
import 'package:nithlostnfound/Pages/FoundPage/found_page.dart';
import 'package:nithlostnfound/Pages/LostPage/lost_page.dart';
import 'package:nithlostnfound/Pages/UploadPage/upload_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Lost and Found',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            Container(
              margin: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 232, 61, 61), // Vibrant Yellow
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                ),
                onPressed: () => _showUploadDialog(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'New Item',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 16, color: Colors.white),
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(
                text: 'Lost Items',
              ),
              Tab(text: 'Found Items'),
            ],
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(color: Colors.deepOrange.shade500
                // gradient: LinearGradient(
                //   colors: [
                //     Color(0xFF8E2DE2), // Deep Purple
                //     Color(0xFFFF9966), // Orange
                //   ],
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                // ),
                ),
          ),
        ),
        drawer: const AppDrawer(),
        body: const TabBarView(
          children: [
            LostPage(),
            FoundPage(),
          ],
        ),
      ),
    );
  }

 void _showUploadDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Rounded corners for the dialog
        ),
        title: const Text(
          'Select Item Type',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Title text color
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Is this item a lost item or a found item?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // Content text color
              ),
            ),
            const SizedBox(height: 20), // Space between content and buttons
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // Rounded corners for the card
              ),
              color: Colors.white.withOpacity(0.8), // Card background color
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.remove_circle, color: Color(0xFF1D2671)), // Deep blue color
                    title: const Text(
                      'Lost Item',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2671), // Deep blue color
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UploadItemPage(isLostItem: true),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.add_circle, color: Color(0xFFC33764)), // Dark magenta color
                    title: const Text(
                      'Found Item',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC33764), // Dark magenta color
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UploadItemPage(isLostItem: false),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Close',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 95, 105, 191), // Deep blue background color
      );
    },
  );
}

}

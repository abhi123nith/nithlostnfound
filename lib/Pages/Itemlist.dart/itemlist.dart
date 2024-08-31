import 'package:flutter/material.dart';
import 'package:nithlostnfound/Models/lost_item_model.dart';

class ItemList extends StatelessWidget {
  final List<LostItem> items;

  const ItemList({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            leading: item.imageUrls != null && item.imageUrls!.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(item.imageUrls![0]),
                    backgroundColor: Colors.grey[200],
                  )
                : CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.white),
                  ),
            title: Text(item.userName ?? 'Unknown'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Item Type: ${item.itemType ?? 'Unknown'}'),
                Text('Location: ${item.location ?? 'Unknown'}'),
                Text('Description: ${item.description ?? 'No Description'}'),
                if (item.imageUrls != null && item.imageUrls!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.network(
                      item.imageUrls![0],
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

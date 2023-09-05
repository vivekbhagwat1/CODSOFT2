import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quoteoftheday/provider/favorite_provider.dart';

class favoritePage extends StatelessWidget {
  const favoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoriteProvider>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Favorites'),
        ),
        body: ListView.builder(
            itemCount: provider.quote.length,
            itemBuilder: (context, index) {
              final quot = provider.quote[index];
              return ListTile(
                title: Text(quot),
                trailing: IconButton(
                  onPressed: () {
                    provider.toggleFavorite(quot);
                  },
                  icon: provider.isExist(quot)
                      ? const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 0, 0, 0),
                        )
                      : const Icon(Icons.delete),
                ),
              );
            }));
  }
}

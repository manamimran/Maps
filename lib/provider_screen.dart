import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maps/another_screen.dart';
import 'package:maps/provider.dart';
import 'package:provider/provider.dart';

class ProviderScreen extends StatefulWidget {
  @override
  State<ProviderScreen> createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderClass>(
      builder: (context, provider, child) {
        var fav = provider.favlist;
        print(fav);

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AnotherScreen(),
                ),
              );
            },
            child: Icon(Icons.next_plan),
          ),
          appBar: AppBar(
            title: Text('Favourites ${fav.length}'),
          ),
          body: ListView.builder(
            itemCount: 40,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Movies ${index}'),
                trailing: GestureDetector(
                  onTap: () {
                    if (!fav.contains(index)) {
                     context.read<ProviderClass>().addToFav(index);
                    } else {
                      context.read<ProviderClass>().removeFav(index);
                    }
                  },
                  child: Icon(
                    Icons.favorite,
                    color: fav.contains(index) ? Colors.red : Colors.grey,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
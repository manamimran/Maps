import 'package:flutter/material.dart';
import 'package:maps/provider.dart';
import 'package:provider/provider.dart';

class AnotherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderClass>(
        builder: (context, provider, child) {
      var fav = provider.favlist;
      print(fav);

    return Scaffold(
      appBar: AppBar(
        title: Text('Favourite List'),
      ),
      body: ListView.builder(
          itemCount: fav.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text("Favourite movies ${fav[index]}"),
              trailing: TextButton(
                onPressed: () {
                  context.read<ProviderClass>().removeFav(fav[index]);
                },
                child: Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            );
          }),
    );
        },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:maps/Home.dart';
import 'package:maps/provider.dart';
import 'package:maps/provider_screen.dart';
import 'package:provider/provider.dart';

void main() {
  // runApp(const MyApp());
  runApp(ChangeNotifierProvider(create: (_)=> ProviderClass(), child: const MyApp(),));   //This is a callback function that creates an instance of ProviderAdd
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ProviderScreen(),
    );
  }
}


import 'package:flutter/material.dart';

import 'list_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'limited_characters_diary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ListPage(),
    );
  }
}

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:sizer/sizer.dart';

import 'list_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    required this.isar,
    super.key,
  });

  final Isar isar;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          title: 'limited_characters_diary',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const ListPage(),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_cloud_datastore_viewer/widgets/header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import './widgets/filters.dart';
import './widgets/entity_list.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: Header(),
        body: EntityListWidget(),
      ),
    );
  }
}

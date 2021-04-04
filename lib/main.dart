import 'package:flutter/material.dart';
import 'package:flutter_cloud_datastore_viewer/screens/entities/list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(title: const Text('test')),
      body: EntityDatatable(),
    ));
  }
}

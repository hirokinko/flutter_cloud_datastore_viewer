import 'package:flutter/material.dart';
import 'package:flutter_cloud_datastore_viewer/models/connection.dart';
import 'package:flutter_cloud_datastore_viewer/screens/entities/list.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => ConnectionModel(),
        )
      ],
      child: MaterialApp(
          title: 'Flutter Cloud Datastore Viewer',
          initialRoute: '/entities/list',
          routes: {
            '/entities/list': (context) => EntityList(),
          }),
    );
  }
}

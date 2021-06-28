import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './controllers/connections_controller.dart';
import './widgets/connection_list.dart';
import './widgets/header.dart';

import './widgets/entity_list.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends HookWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: Header(),
        body: EntityListWidget(),
        drawer: ConnectionListDrawer(),
        onDrawerChanged: (isOpened) {
          if (isOpened) {
            context.read(connectionController).onLoadConnectionList();
          }
        },
      ),
    );
  }
}

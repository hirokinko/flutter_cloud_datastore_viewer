import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/connections_controller.dart';
import '../models/connection.dart';

final _connections = <CloudDatastoreConnection>[];

class ConnectionListDrawer extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  '接続一覧',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              )
            ] +
            this._createConnectionList(context),
      ),
    );
  }

  List<Widget> _createConnectionList(BuildContext context) {
    // TODO replace to state
    return _connections
        .map(
          (c) => ListTile(
            leading: Icon(Icons.storage_outlined), // TODO CloudDatastore icon
            title: Text('${c.projectId}(${c.rootUrl})'),
            onTap: () async {
              await context.read(connectionController).onSelectConnection(c);
              Navigator.pop(context);
            },
            onLongPress: () {
              // TODO show menu for connection
            },
          ),
        )
        .toList(growable: false);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/connections_controller.dart';
import '../models/connection.dart';
import '../widgets/connection_edit_dialog.dart';

class ConnectionListDrawer extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final connections = useProvider(connectionListStateProvider).state;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  'コネクション一覧',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.add_circle),
                title: Text('コネクションの追加'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // context.read(editingConnectionStateProvider).state = null;
                      return ConnectionEditFormDialog();
                    },
                  ).then((value) {
                    Navigator.pop(context);
                  });
                },
              )
            ] +
            this._createConnectionList(context, connections),
      ),
    );
  }

  List<Widget> _createConnectionList(
      BuildContext context, List<CloudDatastoreConnection> connections) {
    // TODO replace to state
    return connections
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

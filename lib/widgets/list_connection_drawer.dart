import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/connections_controller.dart';
import '../models/connection.dart';
import 'edit_connection_dialog.dart';

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
                onTap: () async {
                  context.read(editingConnectionStateProvider).state = null;
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConnectionEditFormDialog(null);
                    },
                  );
                  Navigator.pop(context);
                },
              ),
            ] +
            this._createConnectionList(context, connections),
      ),
    );
  }

  List<Widget> _createConnectionList(
    BuildContext context,
    List<CloudDatastoreConnection> connections,
  ) {
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
              showMenuForConnection(context, c);
            },
          ),
        )
        .toList(growable: false);
  }

  void showMenuForConnection(
    BuildContext context,
    CloudDatastoreConnection connection,
  ) async {
    final selected = await showMenu<String?>(
      context: context,
      position: RelativeRect.fill,
      items: [
        PopupMenuItem(
          value: 'EDIT',
          child: Text('編集'),
        ),
        PopupMenuItem(
          value: 'DELETE',
          child: Text('削除'),
        ),
      ],
    );
    if (selected == null || selected.isEmpty) return;
    switch (selected) {
      case 'DELETE':
        await context.read(connectionController).onDeleteConnection(connection);
        final newConnectionList =
            context.read(connectionListStateProvider).state;
        if (newConnectionList.where((c) => c == connection).isEmpty) {
          showDidDeleteConnectionDialog(context);
        }
        break;
      case 'EDIT':
        context.read(editingConnectionStateProvider).state = connection;
        await showDialog(
          context: context,
          builder: (BuildContext context) =>
              ConnectionEditFormDialog(connection),
        );
        break;
    }
  }

  void showDidDeleteConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('コネクションを削除しました'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

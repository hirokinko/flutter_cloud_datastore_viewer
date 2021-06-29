import 'package:flutter/material.dart';
import 'package:flutter_cloud_datastore_viewer/controllers/connections_controller.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';

import '../models/connection.dart';

final editingConnectionStateProvider =
    StateProvider.autoDispose<CloudDatastoreConnection?>((ref) => null);

class ConnectionEditFormDialog extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final projectIdEditingController = useTextEditingController(text: '');
    final keyFilePathEditingController = useTextEditingController(text: '');
    final rootUrlEditingController =
        useTextEditingController(text: DEFAULT_ROOT_URL);

    final connection = useProvider(editingConnectionStateProvider).state;

    return SimpleDialog(
      title: Text('コネクションの追加'),
      children: <Widget>[
        ListTile(
          title: TextFormField(
            controller: projectIdEditingController,
            decoration: InputDecoration(
              labelText: 'プロジェクトID',
              errorText: connection != null && connection.projectId.isEmpty
                  ? 'プロジェクトIDを入力してください'
                  : null,
            ),
          ),
        ),
        ListTile(
          // TODO ファイルチューザーを使う
          title: TextFormField(
            controller: keyFilePathEditingController,
            decoration: InputDecoration(
              labelText: 'キーファイルのパス',
              errorText: connection != null &&
                      !connection.isLocalEmulatorConnection &&
                      !connection.isValidKeyFilePath
                  ? 'キーファイルがありません'
                  : null,
            ),
          ),
        ),
        ListTile(
          title: TextFormField(
            controller: rootUrlEditingController,
            decoration: InputDecoration(
              labelText: 'DatastoreのルートURL',
              hintText: 'エミュレーターに接続するときはエミュレーターのホストとポートを指定してください',
            ),
          ),
        ),
        ListTile(
            title: Column(
          children: [
            ElevatedButton(
                onPressed: () async {
                  final newConnection = CloudDatastoreConnection(
                    keyFilePathEditingController.text.isNotEmpty
                        ? keyFilePathEditingController.text
                        : null,
                    projectIdEditingController.text,
                    rootUrl: rootUrlEditingController.text,
                  );
                  context.read(editingConnectionStateProvider).state =
                      newConnection;

                  if (!newConnection.isValid) return;
                  context
                      .read(connectionController)
                      .onCreateConnection(newConnection);
                  await showDidAddNewConnectionDialog(context);
                  Navigator.pop(context);
                },
                child: Text('追加')),
          ],
        ))
      ],
    );
  }

  Future<void> showDidAddNewConnectionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('コネクションを追加しました'),
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

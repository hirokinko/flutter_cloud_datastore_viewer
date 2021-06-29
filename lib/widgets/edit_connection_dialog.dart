import 'package:flutter/material.dart';
import 'package:flutter_cloud_datastore_viewer/controllers/connections_controller.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';

import '../models/connection.dart';

final editingConnectionStateProvider =
    StateProvider<CloudDatastoreConnection?>((ref) => null);

class ConnectionEditFormDialog extends HookWidget {
  final CloudDatastoreConnection? _editingConnection;

  ConnectionEditFormDialog(this._editingConnection);

  @override
  Widget build(BuildContext context) {
    final connection = useProvider(editingConnectionStateProvider).state;
    final projectIdEditingController = useTextEditingController(
      text: connection?.projectId ?? '',
    );
    final keyFilePathEditingController = useTextEditingController(
      text: connection?.keyFilePath ?? '',
    );
    final rootUrlEditingController = useTextEditingController(
      text: connection?.rootUrl ?? DEFAULT_ROOT_URL,
    );

    return SimpleDialog(
      title: Text('コネクションの${this._actionLabel}'),
      children: <Widget>[
        ListTile(
          title: TextFormField(
            controller: projectIdEditingController,
            decoration: InputDecoration(
              labelText: 'プロジェクトID',
              errorText: this._onProjectIdIsEmpty(connection),
            ),
          ),
        ),
        ListTile(
          // TODO ファイルチューザーを使う
          title: TextFormField(
            controller: keyFilePathEditingController,
            decoration: InputDecoration(
              labelText: 'キーファイルのパス',
              errorText: this._onKeyFileNotFound(connection),
            ),
          ),
        ),
        ListTile(
          title: TextFormField(
            controller: rootUrlEditingController,
            decoration: InputDecoration(
              labelText: 'DatastoreのルートURL',
              hintText: 'エミュレーターに接続するときはエミュレーターのホストとポートを指定してください',
              errorText: this._onRootUrlRegExpPatternNotMatched(connection),
            ),
          ),
        ),
        ListTile(
            title: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await this._onPressedAddButton(
                  context,
                  keyFilePathEditingController.text,
                  projectIdEditingController.text,
                  rootUrlEditingController.text,
                );
              },
              child: Text(this._actionLabel),
            ),
          ],
        ))
      ],
    );
  }

  Future<void> showDidAddOrUpdateConnectionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text('コネクションを${this._actionLabel}しました'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _onProjectIdIsEmpty(CloudDatastoreConnection? connection) {
    return connection != null && connection.projectId.isEmpty
        ? 'プロジェクトIDを入力してください'
        : null;
  }

  String? _onKeyFileNotFound(CloudDatastoreConnection? connection) {
    return connection != null &&
            !connection.isLocalEmulatorConnection &&
            !connection.isValidKeyFilePath
        ? 'キーファイルがありません'
        : null;
  }

  String? _onRootUrlRegExpPatternNotMatched(
      CloudDatastoreConnection? connection) {
    return connection != null && !connection.isRootUrlPatternMatched
        ? 'ルートURLは `http[s]://<ドメイン>[:ポート番号]/` で入力してください'
        : null;
  }

  Future<void> _onPressedAddButton(
    BuildContext context,
    String keyFilePath,
    String projectId,
    String rootUrl,
  ) async {
    final newConnection = CloudDatastoreConnection(
      keyFilePath.isNotEmpty ? keyFilePath : null,
      projectId,
      rootUrl: rootUrl,
    );
    context.read(editingConnectionStateProvider).state = newConnection;

    if (!newConnection.isValid) return;
    if (this._editingConnection == null) {
      context.read(connectionController).onCreateConnection(newConnection);
    } else {
      context.read(connectionController).onUpdateConnection(
            this._editingConnection!,
            newConnection,
          );
    }
    await showDidAddOrUpdateConnectionDialog(context);
    Navigator.pop(context);
  }

  String get _actionLabel => this._editingConnection == null ? '追加' : '更新';
}

import 'package:riverpod/riverpod.dart';

import '../data_access_objects/clouddatastore_dao.dart';
import '../data_access_objects/connections_dao.dart';
import '../models/connection.dart';

final connectionDaoProvider = Provider((ref) => ConnectionDao());
final connectionController = Provider((ref) => ConnectionController(ref.read));

class ConnectionController {
  final Reader read;

  ConnectionController(this.read);

  Future<void> onLoadConnectionList() async {
    final connections =
        await this.read(connectionDaoProvider).getCloudDatastoreConnections();
    this.read(connectionListStateProvider).state = connections;
  }

  Future<void> onSelectConnection(CloudDatastoreConnection connection) async {
    this.read(currentConnectionStateProvider).state = connection;
    this.read(currentShowingStateProvider).state = CurrentShowing(null, null);
    await this._updateDatastoreMetadataState();
  }

  Future<void> onCreateConnection(
      CloudDatastoreConnection newConnection) async {
    // TODO OrderedSetにするか？
    final connectionSet =
        (await this.read(connectionDaoProvider).getCloudDatastoreConnections())
            .toSet();
    connectionSet.add(newConnection);
    final connectionList = connectionSet.toList(growable: false);
    connectionList.sort(
      (CloudDatastoreConnection a, CloudDatastoreConnection b) =>
          a.projectId.compareTo(b.projectId),
    );
    await this
        .read(connectionDaoProvider)
        .putCloudDatastoreConnectionsToPref(connectionList);
    await this._updateDatastoreMetadataState();
  }

  Future<void> onDeleteConnection(CloudDatastoreConnection connection) async {
    final dao = this.read(connectionDaoProvider);
    final connections = await dao.getCloudDatastoreConnections();
    await dao.putCloudDatastoreConnectionsToPref(
      connections.where((c) => c != connection).toList(growable: false),
    );
    if (this.read(currentConnectionStateProvider).state == connection) {
      this.read(currentConnectionStateProvider).state = null;
    }
    this.read(connectionListStateProvider).state =
        await dao.getCloudDatastoreConnections();
    await this._updateDatastoreMetadataState();
  }

  Future<void> onUpdateConnection(
    CloudDatastoreConnection currentConnection,
    CloudDatastoreConnection newConnection,
  ) async {
    final dao = this.read(connectionDaoProvider);
    final connections = await dao.getCloudDatastoreConnections();
    final replacedConnections = connections.fold(
      <CloudDatastoreConnection>[],
      (List<CloudDatastoreConnection> acc, CloudDatastoreConnection c) {
        if (c == currentConnection) {
          acc.add(newConnection);
        } else {
          acc.add(c);
        }
        return acc;
      },
    );
    await dao.putCloudDatastoreConnectionsToPref(replacedConnections);
    this.read(connectionListStateProvider).state = replacedConnections;
    this.read(currentConnectionStateProvider).state = newConnection;
    await this._updateDatastoreMetadataState();
  }

  Future<void> _updateDatastoreMetadataState() async {
    final dao = await this.read(datastoreDaoProvider);
    if (dao == null) return;
    final metadata = await dao.getMetadata(null);
    this.read(metadataStateProvider).state = metadata;
  }
}

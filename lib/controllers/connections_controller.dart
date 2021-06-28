import 'package:riverpod/riverpod.dart';

import '../data_access_objects/clouddatastore_dao.dart';
import '../data_access_objects/connections_dao.dart';
import '../models/connection.dart';

final connectionDaoProvider = Provider((ref) => ConnectionDao());
final connectionController = Provider((ref) => ConnectionController(ref.read));

class ConnectionController {
  final Reader read;

  ConnectionController(this.read);

  // TODO onLoadConnectionList
  Future<void> onSelectConnection(CloudDatastoreConnection connection) async {
    this.read(currentConnectionStateProvider).state = connection;
    this.read(currentShowingStateProvider).state = CurrentShowing(null, null);

    final dao = await this.read(datastoreDaoProvider);
    if (dao == null) return;
    final metadata = await dao.getMetadata(null);
    this.read(metadataStateProvider).state = metadata;
  }
  // TODO onCreateConnection
  // TODO onDeleteConnection
  // TODO onUpdateConnection
}

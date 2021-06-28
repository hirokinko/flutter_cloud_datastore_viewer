import 'package:flutter_cloud_datastore_viewer/controllers/entities_controller.dart';
import 'package:riverpod/riverpod.dart';

import '../data_access_objects/connections_dao.dart';
import '../models/connection.dart';

final connectionDaoProvider = Provider((ref) => ConnectionDao());
final connectionController = Provider((ref) => ConnectionController(ref.read));

class ConnectionController {
  final Reader read;

  ConnectionController(this.read);

  // TODO onLoadConnectionList
  void onSelectConnection(CloudDatastoreConnection connection) {
    this.read(currentConnectionStateProvider).state = connection;
    this.read(currentShowingStateProvider).state = CurrentShowing(null, null);
  }
  // TODO onCreateConnection
  // TODO onDeleteConnection
  // TODO onUpdateConnection
}

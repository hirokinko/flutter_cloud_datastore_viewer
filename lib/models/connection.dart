import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_cloud_datastore_viewer/util/datastore.dart';

class ConnectionModel {
  DatastoreClient client = DatastoreClient(
      auth.clientViaApiKey(''), 'test-project',
      rootUrl: 'http://0.0.0.0:8081/');
}

import 'package:flutter_test/flutter_test.dart';

import 'package:googleapis_auth/auth_io.dart' as auth;
import '../lib/util/datastore.dart';

void main() {
  final httpClient = auth.clientViaApiKey('');
  final projectId = 'test-project';
  final rootUrl = 'http://0.0.0.0:8081/';
  final client = DatastoreClient(httpClient, projectId, rootUrl: rootUrl);
  test('test getNamespaces()', () async {
    var namespaces = await client.getNamespaces();
    print(namespaces[0] == null);
    print(namespaces[1] == 'development');
  });

  for (var namespace in [null, 'development']) {
    test('test getKinds($namespace)', () async {
      var kinds = await client.getKinds(namespace: namespace ?? '');
      for (var kind in kinds) {
        print(kind);
      }
    });
  }

  test('test getIndexedProperties', () async {
    await client.getKindIndexedProperties('User');
  });

  test('test runQuery', () async {
    var result = await client.runQuery('User');
    // if (result != null) {
    //   result.forEach((element) {
    //     print(element);
    //   });
    // }
    result.entities.forEach((element) {
      print(element);
    });
    result.properties.forEach((element) {
      print(element.name);
      print(element.type);
      print(element.indexable);
    });
  });

  test('test getEntity', () async {
    Key key = Key(projectId, 'User', 5634161670881280);
    var entity = await client.getEntity(key);
    entity?.propertyValuesMapEntries?.forEach((element) {
      print(element.value.get());
      print(element.value.runtimeType);
    });
  });
}

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meta/meta.dart';

import '../models/connection.dart';
import '../models/entities.dart';
import '../patched_datastore/v1.dart';
import '../repositories/clouddatastore_repository.dart';

const DEFAULT_LIMIT = 50;
const DEFAULT_ENTITY_LIST = EntityList([], DEFAULT_LIMIT, null, null, null);

final currentConnectionStateProvider = StateProvider(
  (ref) => CloudDatastoreConnection(
    '',
    'test-project',
    rootUrl: 'http://localhost:8081/',
  ),
);
final currentShowingStateProvider =
    StateProvider((ref) => CurrentShowing('development', 'User'));
final entityListStateProvider =
    StateProvider.autoDispose((ref) => DEFAULT_ENTITY_LIST);
// TODO 初期状態とConnectionを変えた時の対応
final metadataStateProvider =
    StateProvider((ref) => CloudDatastoreMetadata([null, 'development'], []));
final repositoryProvider = Provider((ref) {
  final currentConnection = ref.watch(currentConnectionStateProvider).state;
  final client = auth.clientViaApiKey(currentConnection.keyFilePath);
  final datastoreApi = DatastoreApi(client, rootUrl: currentConnection.rootUrl);
  return CloudDatastoreRepostiry(datastoreApi, currentConnection.projectId);
});
final entitiesControllerProvider =
    Provider.autoDispose((ref) => EntitiesController(ref.read));

@immutable
class EntitiesController {
  final Reader read;

  EntitiesController(this.read);

  Future<void> onChangeCurrentShowingNamespace(String? namespace) async {
    final newMetadata =
        await this.read(repositoryProvider).getMetadata(namespace);
    this.read(metadataStateProvider).state = newMetadata;
    if (!newMetadata.namespaces.contains(namespace)) return;

    this.read(currentShowingStateProvider).state =
        CurrentShowing(namespace, null);
    // TODO notify to entityList(reload)
  }

  Future<void> onChangeCurrentShowingKind(String kind) async {
    final metadata = this.read(metadataStateProvider).state;
    if (!(metadata.kinds.contains(kind))) return;

    final previousShowing = this.read(currentShowingStateProvider).state;
    this.read(currentShowingStateProvider).state =
        CurrentShowing(previousShowing.namespace, kind);
    // TODO notify to entityList(reload)
    await this.read(entitiesControllerProvider).onLoadEntityList(null, null);
  }

  Future<void> onLoadEntityList(
    String? startCursor,
    String? previousPageStartCursor, {
    int limit = DEFAULT_LIMIT,
  }) async {
    final metadata = this.read(metadataStateProvider).state;
    final currentShowing = this.read(currentShowingStateProvider).state;
    if (!(metadata.namespaces.contains(currentShowing.namespace) &&
        metadata.kinds.contains(currentShowing.kind))) {
      this.read(entityListStateProvider).state = DEFAULT_ENTITY_LIST;
      return;
    }

    final newEntityList = await this.read(repositoryProvider).find(
          currentShowing.kind!,
          currentShowing.namespace,
          startCursor,
          previousPageStartCursor,
        );
    this.read(entityListStateProvider).state = newEntityList;
  }
}

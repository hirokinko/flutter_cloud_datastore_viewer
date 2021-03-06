import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meta/meta.dart';

import '../models/connection.dart';
import '../models/entities.dart';
import '../models/filters.dart' as filters;
import '../data_access_objects/clouddatastore_dao.dart';

final entitiesControllerProvider =
    Provider.autoDispose((ref) => EntitiesController(ref.read));

@immutable
class EntitiesController {
  final Reader read;

  EntitiesController(this.read);

  Future<void> onChangeCurrentShowingNamespace(String? namespace) async {
    final dao = await this.read(datastoreDaoProvider);
    if (dao == null) {
      return;
    }

    final newMetadata = await dao.getMetadata(namespace);
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
    final dao = await this.read(datastoreDaoProvider);
    if (dao == null) return;

    final metadata = this.read(metadataStateProvider).state;
    final currentShowing = this.read(currentShowingStateProvider).state;
    if (!(metadata.namespaces.contains(currentShowing.namespace) &&
        metadata.kinds.contains(currentShowing.kind))) {
      this.read(entityListStateProvider).state = DEFAULT_ENTITY_LIST;
      return;
    }
    final filter = this.read(filters.filterStateProvider).state;
    final order = this.read(sortOrderStateProvider).state;

    final newEntityList = await dao.find(
      currentShowing.kind!,
      currentShowing.namespace,
      startCursor,
      previousPageStartCursor,
      filter,
      order,
    );
    this.read(entityListStateProvider).state = newEntityList;
    final newSelectableProperties =
        (currentShowing.kind == filter.kind && newEntityList.entities.isEmpty)
            ? filter.selectableProperties
            : this._createNewSelectableProperties(newEntityList.entities);

    this.read(filters.filterStateProvider).state = filters.Filter(
      currentShowing.kind,
      filter.selectedProperty,
      newSelectableProperties,
      filter.filterType,
      filter.selectableFilterTypes,
      filter.filterValue,
    );
  }

  List<filters.Property> _createNewSelectableProperties(
    List<Entity?> entities,
  ) {
    final List<filters.Property> newProperties = entities.fold(
      <filters.Property>{},
      (Set<filters.Property> acc, Entity? value) {
        final selectables = (value?.getInnerPropertyEntries(null, true) ?? [])
            .map((
              MapEntry<String, Type> entry,
            ) =>
                filters.Property(entry.key, entry.value))
            .toSet();

        acc.addAll(selectables);
        return acc;
      },
    ).toList(growable: false);
    newProperties.sort((a, b) => a.name.compareTo(b.name));
    return newProperties;
  }

  void onChangedSortOrder(String propertyName, bool ascending) {
    final currentFilter = this.read(filters.filterStateProvider).state;
    if (propertyName != currentFilter.selectedProperty?.name) {
      return;
    }
    this.read(sortOrderStateProvider).state = SortOrder(
      propertyName,
      ascending: ascending,
    );
  }
}

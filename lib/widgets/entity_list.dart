import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/entities_controller.dart';
import '../models/entities.dart' as entities;
import '../models/filters.dart' as filters;

class EntityListWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final entityList = useProvider(entityListStateProvider).state;
    // TODO 後で見た目を整える
    if (entityList.entities.isEmpty) {
      return Column(
        children: [],
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: createEntityDataTable(context, entityList),
          ),
        ],
      );
    }
  }
}

DataTable createEntityDataTable(
    BuildContext context, entities.EntityList entityList) {
  final indexedProperties = entityList.entities.fold(
    <filters.Property>{},
    (
      Set<filters.Property> acc,
      entities.Entity? cur,
    ) {
      acc.addAll(cur
              ?.getInnerPropertyEntries(null, false)
              .where((p) => !p.key.startsWith('__key__.kind'))
              .map((e) => filters.Property(e.key, e.value)) ??
          <filters.Property>[]);
      return acc;
    },
  ).toList(growable: false);
  final rows = entityList.entities
      .where((e) => e != null)
      .map((e) => createDataRow(indexedProperties.map((p) => p.name), e!))
      .toList(growable: false);

  return DataTable(
    columns: createDataColumns(indexedProperties),
    rows: rows,
  );
}

List<DataColumn> createDataColumns(Iterable<filters.Property> properties) {
  return properties
      .map((filters.Property p) => DataColumn(label: Text(p.name)))
      .toList(growable: false);
}

DataRow createDataRow(Iterable<String> propertyNames, entities.Entity entity) {
  final cells = <DataCell>[
    DataCell(
      Text(entity.key?.name ?? '<NULL>'),
    ),
    DataCell(
      Text(entity.key?.id?.toString() ?? '<NULL>'),
    ),
  ];

  cells.addAll(propertyNames.where((p) => !p.startsWith('__key__')).map(
        (String propertyName) => DataCell(
          Text(propertyName),
        ),
      ));
  return DataRow(cells: cells);
}

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
    return Column(
      children: [
        // Expanded(
        //   child: createEntityDataTable(context, entityList),
        // ),
      ],
    );
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
              ?.getIndexedInnerPropertyEntries(null)
              .map((e) => filters.Property(e.key, e.value)) ??
          <filters.Property>[]);
      return acc;
    },
  ).toList(growable: false);
  indexedProperties.sort();

  return DataTable(
    columns: createDataColumns(indexedProperties),
    rows: [
      DataRow(cells: [
        DataCell.empty,
      ]),
    ],
  );
}

List<DataColumn> createDataColumns(Iterable<filters.Property> properties) {
  return properties
      .map((filters.Property p) => DataColumn(label: Text(p.name)))
      .toList(growable: false);
}

// List<DataRow> createDataRow(
//     Iterable<String> propertyNames, entities.Entity entity) {
//   propertyNames.map(
//     (String propertyName) => DataCell(
//       Text(
//         entity.properties.firstWhere((entities.Property p) => p.name == propertyName)?.
//       ),
//     ),
//   );
// }

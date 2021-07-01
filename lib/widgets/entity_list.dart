import 'package:flutter/material.dart';
import 'package:flutter_cloud_datastore_viewer/controllers/filter_controller.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/entities.dart' as entities;
import '../models/filters.dart' as filters;
import 'filters.dart' as filterWidget;

// TODO text decoration
const NULL_TEXT = const Text('<NULL>');

class EntityListWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final entityList = useProvider(entities.entityListStateProvider).state;
    final filterState = useProvider(filterStateProvider).state;
    // TODO 後で見た目を整える
    if (entityList.entities.isEmpty) {
      return Column(
        children: [],
      );
    } else {
      return ListView(
        padding: const EdgeInsets.all(4),
        children: [
          ExpansionTile(
            title: Text('フィルター'),
            children: [],
            trailing: IconButton(
              icon: const Icon(Icons.add_outlined),
              onPressed: (filterState.filterValue == null)
                  ? () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return filterWidget.FilterFormWidget();
                        },
                      );
                    }
                  : null,
            ),
          ),
          createEntityDataTable(context, entityList),
        ],
      );
    }
  }
}

class TempTable {
  final Set<String> columnNames;
  final List<Map<String, DataCell>> tempRowMapList;

  TempTable(this.columnNames, this.tempRowMapList);
}

class _DataSource extends DataTableSource {
  final BuildContext context;
  final List<DataRow> rows;

  _DataSource(this.context, this.rows);

  @override
  DataRow? getRow(int index) {
    return this.rows[index];
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => this.rows.length;

  @override
  int get selectedRowCount => 0;
}

Widget createEntityDataTable(
    BuildContext context, entities.EntityList entityList) {
  final tempTable = entityList.entities.fold(
    TempTable({}, []),
    (TempTable acc, entities.Entity? e) {
      if (e != null) {
        final tempRowMap = createTempRowMap(e);
        acc.columnNames.addAll(tempRowMap.keys);
        acc.tempRowMapList.add(tempRowMap);
      }
      return acc;
    },
  );

  final columnNames = tempTable.columnNames.toList(growable: false);
  columnNames.sort();

  final rows = tempTable.tempRowMapList.map((Map<String, DataCell> tempRowMap) {
    return DataRow(
      cells: columnNames
          .map((String name) => tempRowMap[name] ?? DataCell(NULL_TEXT))
          .toList(growable: false),
    );
  }).toList(growable: false);

  return PaginatedDataTable(
    rowsPerPage: entityList.entities.length,
    columns: columnNames
        .map((String c) => DataColumn(label: Text(c)))
        .toList(growable: false),
    source: _DataSource(context, rows),
  );
}

List<DataColumn> createDataColumns(Iterable<filters.Property> properties) {
  return properties
      .map((filters.Property p) => DataColumn(label: Text(p.name)))
      .toList(growable: false);
}

Map<String, DataCell> createTempRowMap(entities.Entity entity) {
  return entity.properties.fold(
    {'__key__': createKeyDataCell(entity.key)},
    (Map<String, DataCell> acc, entities.Property cur) {
      acc[cur.name] = createDataCell(cur);
      return acc;
    },
  );
}

DataCell createDataCell(entities.Property property) {
  if (property is entities.SingleProperty && property.value != null) {
    // TODO Entity型
    switch (property.type) {
      case int:
      case double:
        return createNumberSinglePropertyDataCell(property);
      case String:
        return createStringSinglePropertyDataCell(property);
      case DateTime:
        return createDateTimeSinglePropertyDataCell(property);
      case entities.Key:
        return createKeyDataCell(property.value);
      default:
        return DataCell(Text(property.name));
    }
  } else {
    return DataCell(Text(property.name));
  }
}

DataCell createKeyDataCell(entities.Key? key) {
  if (key?.kind != null && key?.id != null) {
    return DataCell(Text('${key?.kind}(id=${key?.id})'));
  } else if (key?.kind != null && key?.name != null) {
    return DataCell(Text('${key?.kind}(name=${key?.name})'));
  } else if (key?.kind != null && key?.id == null && key?.name == null) {
    return DataCell(Text('${key?.kind}(<NULL>)'));
  } else {
    return DataCell(NULL_TEXT);
  }
}

DataCell createNumberSinglePropertyDataCell(entities.SingleProperty property) {
  return DataCell(Text(property.value.toString()));
}

DataCell createStringSinglePropertyDataCell(
  entities.SingleProperty property,
) {
  return DataCell(Text(property.value));
}

DataCell createDateTimeSinglePropertyDataCell(
  entities.SingleProperty property,
) {
  return DataCell(Text((property.value as DateTime).toIso8601String()));
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cloud_datastore_viewer/models/connection.dart';
import 'package:flutter_cloud_datastore_viewer/patched_datastore/v1.dart'
    as v1Api;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordered_set/ordered_set.dart';
import 'package:styled_text/styled_text.dart';

final connectionProvider = Provider((ref) => ConnectionModel());

final entitiesProvider = FutureProvider((ref) async {
  final connection = ref.read(connectionProvider);

  return connection.runQuery();
});

class EntityDatatable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      final result = watch(entitiesProvider);
      final connection = watch(connectionProvider);

      if (result.data == null || result.data!.value == null) {
        return Center(child: CircularProgressIndicator());
      }
      final model = result.data!.value!;
      final columns = this._createColumns(model.columns, connection, context);
      final rows = model.entities
          .where((e) => e != null)
          .map((e) => this._createRow(model.columns, e!))
          .toList(growable: false);

      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Expanded(
              child: Container(
                  padding: EdgeInsets.all(5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(columns: columns, rows: rows),
                  )))
        ],
      );
    });
  }

  List<DataColumn> _createColumns(OrderedSet<ColumnModel> columns,
      ConnectionModel connection, BuildContext context) {
    return columns.map((column) {
      final textColor = column.sortable ? Colors.blue : Colors.black;
      final fontWeight = column.sortable ? FontWeight.bold : FontWeight.normal;
      final sortDirectionIcon =
          connection.sortDirection == SortDirection.ASCENDING
              ? Icons.arrow_drop_up
              : Icons.arrow_drop_down;
      final columnNameText =
          '<text_style>${column.name}</text_style>${column.name == connection.sortKey ? " <dir_icon/>" : ""}';

      return DataColumn(
        label: StyledText(
            textAlign: TextAlign.left,
            text: columnNameText,
            styles: {
              'text_style': TextStyle(color: textColor, fontWeight: fontWeight),
              'dir_icon': IconStyle(sortDirectionIcon, size: 32.0),
            }),
        numeric: false,
        onSort: (columnIndex, _) {
          final sortColumn = columns.toList(growable: false)[columnIndex];
          connection.sortKey = sortColumn.name;
          connection.sortDirection = (connection.sortDirection != null &&
                  connection.sortDirection == SortDirection.ASCENDING)
              ? SortDirection.DESCENDING
              : SortDirection.ASCENDING;
          context.refresh(entitiesProvider);
        },
      );
    }).toList(growable: false);
  }

  DataRow _createRow(OrderedSet<ColumnModel> columns, v1Api.Entity entity) {
    final cells = <DataCell>[DataCell(Text(entity.key!.toJson().toString()))] +
        columns
            .where((e) => e.name != '__key__')
            .map((column) => DataCell(
                Text(entity.properties![column.name]!.toJson().toString())))
            .toList(growable: false);
    return DataRow(cells: cells);
  }
}

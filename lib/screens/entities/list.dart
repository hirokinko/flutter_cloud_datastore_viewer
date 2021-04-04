import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cloud_datastore_viewer/models/connection.dart';
import 'package:flutter_cloud_datastore_viewer/patched_datastore/v1.dart'
    as v1Api;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordered_set/ordered_set.dart';

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
      if (result.data == null || result.data!.value == null) {
        return Center(child: CircularProgressIndicator());
      }
      final model = result.data!.value!;
      final columns = this._createColumns(model.columns);
      final rows = model.entities
          .where((e) => e != null)
          .map((e) => this._createRow(model.columns, e!))
          .toList();
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

  List<DataColumn> _createColumns(OrderedSet<String> columns) {
    return columns
        .map((column) => DataColumn(label: Text(column), numeric: false))
        .toList();
  }

  DataRow _createRow(OrderedSet<String> columns, v1Api.Entity entity) {
    final cells = columns
        .map((c) => DataCell(Text(entity.properties![c]!.toJson().toString())))
        .toList();
    return DataRow(cells: cells);
  }
}

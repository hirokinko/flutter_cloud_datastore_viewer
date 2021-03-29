import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cloud_datastore_viewer/models/connection.dart';
import 'package:flutter_cloud_datastore_viewer/util/datastore.dart';
import 'package:provider/provider.dart';

class EntityList extends StatelessWidget {
  Widget build(BuildContext context) {
    var client = context.read<ConnectionModel>().client;
    return Scaffold(
      appBar: AppBar(
        title: Text('Entity List'),
      ),
      body: FutureBuilder<Entities>(
        future: client.runQuery('User', namespace: 'development'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: dataBody(snapshot.data as Entities),
                  ),
                )
              ],
            );
          }
          return Center();
        },
      ),
    );
  }

  SingleChildScrollView dataBody(Entities entities) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
          columns: _createColumns(entities.properties),
          rows: entities.entities.map((entity) => _createRow(entity)).toList()),
    );
  }

  List<DataColumn> _createColumns(Iterable<Property> properties) {
    var columns = [
      DataColumn(label: Text('Key'), numeric: false, tooltip: 'Key')
    ];
    columns.addAll(properties
        .map((p) => DataColumn(
            label: Text(p.name),
            numeric: (p.type is int) || (p.type is double),
            tooltip: p.name))
        .toList());
    return columns;
  }

  DataRow _createRow(Entity entity) {
    var rowCells = [
      DataCell(Text('Key( ${entity.key?.kind}, ${entity.key?.id} )'))
    ];
    var valueCells = entity.propertyValuesMapEntries
            ?.map((entry) => _createDataCell(entry))
            .toList() ??
        <DataCell>[];
    rowCells.addAll(valueCells);

    return DataRow(cells: rowCells);
  }

  DataCell _createDataCell(MapEntry<String, PropertyValue> entry) {
    return DataCell(Text(entry.value.get().toString()));
  }
}

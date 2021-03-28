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
          columns: entities.properties
              .map((e) => DataColumn(
                  label: Text(e.name),
                  numeric: (e.type is int) || (e.type is double),
                  tooltip: e.name))
              .toList(),
          rows: entities.entities.map((entity) => _createRow(entity)).toList()),
    );
  }

  DataRow _createRow(Entity entity) {
    return DataRow(
        cells: entity.propertyValuesMapEntries
                ?.map((entry) => _createDataCell(entry))
                .toList() ??
            <DataCell>[]);
  }

  DataCell _createDataCell(MapEntry<String, PropertyValue> entry) {
    return DataCell(Text(entry.value.get().toString()));
  }
}

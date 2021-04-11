import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cloud_datastore_viewer/models/connection.dart';
import 'package:flutter_cloud_datastore_viewer/patched_datastore/v1.dart'
    as v1Api;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ordered_set/ordered_set.dart';
import 'package:styled_text/styled_text.dart';
import 'dart:core' as core;

final connectionProvider = Provider((ref) => ConnectionModel());

final entitiesProvider = FutureProvider((ref) async {
  final connection = ref.read(connectionProvider);

  return connection.runQuery();
});

class EntityListScreen extends StatelessWidget {
  @core.override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      final result = watch(entitiesProvider);
      final connection = watch(connectionProvider);

      if (result.data == null || result.data!.value == null) {
        return Center(child: CircularProgressIndicator());
      }

      final model = result.data!.value;

      return Column(children: [
        Flexible(
          child: FilterForm(model!.columns, connection),
          flex: 5,
          fit: FlexFit.loose,
        ),
        Flexible(
          child: EntityDatatable(model, connection),
          flex: 15,
          fit: FlexFit.loose,
        ),
      ]);
    });
  }
}

class EntityDatatable extends StatelessWidget {
  final EntitiesDatatableModel _model;
  final ConnectionModel _connection;

  EntityDatatable(EntitiesDatatableModel model, ConnectionModel connection)
      : _model = model,
        _connection = connection;

  @core.override
  Widget build(BuildContext context) {
    final columns = this._createColumns(_model.columns, _connection, context);
    final rows = _model.entities
        .where((e) => e != null)
        .map((e) => this._createRow(_model.columns, e!))
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
  }

  core.List<DataColumn> _createColumns(OrderedSet<ColumnModel> columns,
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

enum FilterOperator {
  UNSPECIFIED,
  LT,
  LTE,
  GT,
  GTE,
  EQ,
}

extension FilterOperatorExtension on FilterOperator {
  core.String get displayValue {
    switch (this) {
      case FilterOperator.UNSPECIFIED:
        return '';
      case FilterOperator.LT:
        return '<';
      case FilterOperator.LTE:
        return '<=';
      case FilterOperator.GT:
        return '>';
      case FilterOperator.GTE:
        return '>=';
      case FilterOperator.EQ:
        return '==';
    }
  }

  core.String get value {
    switch (this) {
      case FilterOperator.UNSPECIFIED:
        return 'OPERATOR_UNSPECIFIED';
      case FilterOperator.LT:
        return 'LESS_THAN';
      case FilterOperator.LTE:
        return 'LESS_THAN_OR_EQUAL';
      case FilterOperator.GT:
        return 'GREATER_THAN';
      case FilterOperator.GTE:
        return 'GREATER_THAN_OR_EQUAL';
      case FilterOperator.EQ:
        return 'EQUAL';
    }
  }
}

class FilterForm extends StatefulWidget {
  final OrderedSet<ColumnModel> _columns;
  final ConnectionModel _connection;

  FilterForm(OrderedSet<ColumnModel> columns, ConnectionModel connection)
      : _columns = columns,
        _connection = connection;

  @core.override
  State<StatefulWidget> createState() => FilterFormState(_columns, _connection);
}

class FilterFormState extends State<FilterForm> {
  final _formKey = GlobalKey<FormState>();
  final OrderedSet<ColumnModel> _columns;
  final ConnectionModel _connection;
  final TextEditingController _textValueController = TextEditingController();
  ColumnModel? _selectedField;
  FilterOperator _selectedOperator = FilterOperator.UNSPECIFIED;
  core.bool? _boolValueForQuery;

  FilterFormState(OrderedSet<ColumnModel> columns, ConnectionModel connection)
      : _columns = columns,
        _connection = connection,
        _selectedField = connection.propertyFilter != null
            ? columns.firstWhere(
                (c) => connection.propertyFilter!.property!.name == c.name)
            : null,
        _selectedOperator = connection.propertyFilter != null
            ? FilterOperator.values
                .firstWhere((v) => v.value == connection.propertyFilter!.op)
            : FilterOperator.UNSPECIFIED,
        _boolValueForQuery = connection.propertyFilter != null &&
                connection.propertyFilter!.value!.booleanValue != null
            ? connection.propertyFilter!.value!.booleanValue
            : null;

  static core.String _displayStringForOption(ColumnModel c) => c.name;

  @core.override
  void dispose() {
    this._textValueController.dispose();
    super.dispose();
  }

  @core.override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'フィルター: ',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 3.0, 5.0, 1.0),
                    child: Autocomplete<ColumnModel>(
                      displayStringForOption: _displayStringForOption,
                      optionsBuilder: (TextEditingValue t) => t.text.isEmpty
                          ? _columns.where((c) => c.sortable)
                          : _columns.where((c) =>
                              c.sortable &&
                              c.name
                                  .toLowerCase()
                                  .contains(t.text.toLowerCase())),
                      onSelected: (ColumnModel c) {
                        setState(() {
                          _selectedField = c;
                        });
                      },
                      fieldViewBuilder: (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        textEditingController.text =
                            _selectedField != null ? _selectedField!.name : '';
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 3.0, 5.0, 1.0),
                    child: DropdownButtonFormField<FilterOperator>(
                      value: _selectedOperator,
                      items: _selectedField?.type == core.bool
                          ? <DropdownMenuItem<FilterOperator>>[
                              DropdownMenuItem<FilterOperator>(
                                child: Text(
                                  FilterOperator.UNSPECIFIED.displayValue,
                                ),
                                value: FilterOperator.UNSPECIFIED,
                              ),
                              DropdownMenuItem<FilterOperator>(
                                child: Text(FilterOperator.EQ.displayValue),
                                value: FilterOperator.EQ,
                              ),
                            ]
                          : FilterOperator.values
                              .map((v) => DropdownMenuItem<FilterOperator>(
                                  child: Text(v.displayValue), value: v))
                              .toList(),
                      onChanged: (FilterOperator? v) {
                        setState(() {
                          _selectedOperator =
                              (v != null) ? v : FilterOperator.UNSPECIFIED;
                        });
                      },
                      validator: (v) =>
                          (v == null || v == FilterOperator.UNSPECIFIED)
                              ? '条件演算子を選択してください'
                              : null,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 3.0, 5.0, 1.0),
                    child: _buildValueFieldForm(_selectedField?.type),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          _connection.propertyFilter = v1Api.PropertyFilter()
                            ..property = (v1Api.PropertyReference()
                              ..name = this._selectedField?.name)
                            ..op = (_selectedOperator.value)
                            ..value = this._buildFilterValue();

                          context.refresh(entitiesProvider);
                        },
                        child: Text('フィルター実行'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _connection.propertyFilter = null;
                          context.refresh(entitiesProvider);
                        },
                        child: Text('フィルター条件クリア'),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget? _buildValueFieldForm(core.Type? t) {
    switch (t) {
      case core.int:
      case core.double:
      case core.String:
        return TextFormField(
          validator: this._getTextFormValidator(t),
          controller: this._textValueController,
        );
      case core.bool:
        return DropdownButtonFormField(
          value: this._boolValueForQuery,
          items: <DropdownMenuItem<core.bool>>[
            DropdownMenuItem<core.bool>(child: Text('true'), value: true),
            DropdownMenuItem<core.bool>(child: Text('false'), value: false)
          ],
          onChanged: (core.bool? value) {
            setState(() {
              _boolValueForQuery = value;
            });
          },
        );
      default:
        return Text('Unimplemented');
    }
  }

  FormFieldValidator<core.String> _getTextFormValidator(core.Type? t) {
    switch (t) {
      case core.int:
        return (core.String? v) =>
            v == null || v.isEmpty || core.int.tryParse(v) == null
                ? '整数値を入力してください'
                : null;
      case core.double:
        return (core.String? v) =>
            v == null || v.isEmpty || core.double.tryParse(v) == null
                ? '実数値を入力してください'
                : null;
      default:
        return (core.String? v) =>
            v == null || v.isEmpty ? '文字列を入力してください' : null;
    }
  }

  v1Api.Value _buildFilterValue() {
    switch (_selectedField?.type) {
      case core.int:
        return v1Api.Value()..integerValue = this._textValueController.text;

      case core.String:
        return v1Api.Value()..stringValue = this._textValueController.text;

      case core.double:
        return v1Api.Value()
          ..doubleValue = core.double.tryParse(this._textValueController.text);

      case core.bool:
        return v1Api.Value()..booleanValue = this._boolValueForQuery;

      default:
        return v1Api.Value()..nullValue = null;
    }
  }
}

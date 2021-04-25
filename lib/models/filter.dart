import 'package:flutter_cloud_datastore_viewer/models/property.dart';
import 'package:flutter_cloud_datastore_viewer/patched_datastore/v1.dart'
    as v1Api;
import 'package:meta/meta.dart';

enum Operator {
  UNSPECIFIED,
  LT,
  LTE,
  GT,
  GTE,
  EQ,
}

extension OperatorExtension on Operator {
  String get display {
    switch (this) {
      case Operator.UNSPECIFIED:
        return '';
      case Operator.LT:
        return '<';
      case Operator.LTE:
        return '<=';
      case Operator.GT:
        return '>';
      case Operator.GTE:
        return '>=';
      case Operator.EQ:
        return '==';
    }
  }

  String get value {
    switch (this) {
      case Operator.UNSPECIFIED:
        return 'OPERATOR_UNSPECIFIED';
      case Operator.LT:
        return 'LESS_THAN';
      case Operator.LTE:
        return 'LESS_THAN_OR_EQUAL';
      case Operator.GT:
        return 'GREATER_THAN';
      case Operator.GTE:
        return 'GREATER_THAN_OR_EQUAL';
      case Operator.EQ:
        return 'EQUAL';
    }
  }
}

@immutable
class Filter<T> {
  final Property? selectedProperty;
  final Operator op;
  final T? value;

  const Filter(this.selectedProperty, this.op, this.value);

  v1Api.PropertyFilter? toPropertyFilter() {
    if (this.selectedProperty == null ||
        this.op == Operator.UNSPECIFIED ||
        this.value == null) {
      return null;
    }
    final filter = v1Api.PropertyFilter()
      ..property =
          (v1Api.PropertyReference()..name = this.selectedProperty!.name)
      ..op = (this.op.value);

    switch (this.selectedProperty!.type) {
      case String:
        filter..value = (v1Api.Value()..stringValue = (this.value as String));
        break;
      case int:
        filter
          ..value =
              (v1Api.Value()..integerValue = (this.value as int).toString());
        break;
      case double:
        filter..value = (v1Api.Value()..doubleValue = (this.value as double));
        break;
      case bool:
        filter..value = (v1Api.Value()..booleanValue = (this.value as bool));
        break;
      default:
        filter..value = null;
    }
    return filter;
  }

  int get hashCode =>
      ((17 * 31 + this.selectedProperty.hashCode) * 31 + this.op.hashCode) *
          31 +
      this.value.hashCode;

  bool operator ==(Object other) =>
      other is Filter &&
      this.selectedProperty == other.selectedProperty &&
      this.op == other.op &&
      this.value == other.value;
}

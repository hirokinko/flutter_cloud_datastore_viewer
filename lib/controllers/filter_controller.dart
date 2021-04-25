import 'package:flutter/material.dart';
import 'package:flutter_cloud_datastore_viewer/models/property.dart';
import 'package:flutter_cloud_datastore_viewer/models/filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filterStateProvider = StateProvider.autoDispose((ref) => FilterState(
      propertySelectorValues,
      UNSPECIFIED_OP_SELECTOR,
    ));

final filterControllerProvider =
    Provider.autoDispose((ref) => FilterController(ref.read));

const BOOLEAN_OP_SELECTOR = [Operator.UNSPECIFIED, Operator.EQ];
const UNSPECIFIED_OP_SELECTOR = [Operator.UNSPECIFIED];

final propertySelectorValues = <Property>[
  Property('stringValue', true, String),
  Property('integerValue', true, int),
  Property('doubleValue', true, double),
  Property('blobValue', false, String),
  Property('booleanValue', true, bool),
];

@immutable
class FilterState<T> extends Filter<T> {
  final List<Property> propertySelector;
  final List<Operator> opSelector;

  const FilterState(
    this.propertySelector,
    this.opSelector, {
    Property? selectedProperty,
    Operator op = Operator.UNSPECIFIED,
    T? value,
  }) : super(selectedProperty, op, value);

  void initState() {}

  void dispose() {}
}

class FilterController {
  final Reader read;

  FilterController(this.read);

  void dispose() {}

  void onChangeProperty(Property? prop) {
    final currentState = this.read(filterStateProvider).state;
    Property? newProperty =
        currentState.propertySelector.any((p) => p == prop) ? prop : null;
    late List<Operator> opSelector;
    if (newProperty == null) {
      opSelector = UNSPECIFIED_OP_SELECTOR;
    } else {
      opSelector =
          newProperty.type == bool ? BOOLEAN_OP_SELECTOR : Operator.values;
    }

    this.read(filterStateProvider).state = FilterState(
      currentState.propertySelector,
      opSelector,
      selectedProperty: newProperty,
      op: Operator.UNSPECIFIED,
    );
  }

  void onChangeOperator(Operator? newOp) {
    final currentState = this.read(filterStateProvider).state;
    if (newOp == null || !currentState.opSelector.contains(newOp)) return;
    this.read(filterStateProvider).state = FilterState(
      currentState.propertySelector,
      currentState.opSelector,
      selectedProperty: currentState.selectedProperty,
      op: newOp,
      value: currentState.value,
    );
  }

  void onSubmit(String? newValue) {
    final currentState = this.read(filterStateProvider).state;
    final setValue = this._validateValue(currentState, newValue);
    this.read(filterStateProvider).state = FilterState(
      currentState.propertySelector,
      currentState.opSelector,
      selectedProperty: currentState.selectedProperty,
      op: currentState.op,
      value: setValue,
    );
  }

  void onResetFilter() {
    final currentState = this.read(filterStateProvider).state;
    this.read(filterStateProvider).state = FilterState(
      currentState.propertySelector,
      UNSPECIFIED_OP_SELECTOR,
      selectedProperty: null,
      op: Operator.UNSPECIFIED,
      value: null,
    );
  }

  Iterable<Property> getPropertySelector(TextEditingValue t) {
    return (t.text.isEmpty)
        ? this
            .read(filterStateProvider)
            .state
            .propertySelector
            .where((p) => p.indexed)
        : this.read(filterStateProvider).state.propertySelector.where((p) =>
            p.indexed && p.name.toLowerCase().contains(t.text.toLowerCase()));
  }

  dynamic _validateValue<T>(FilterState currentState, String? value) {
    if (currentState.selectedProperty == null)
      throw Exception('プロパティを選択してください');

    if (currentState.op == Operator.UNSPECIFIED)
      throw Exception('演算子を選択してください');

    if (value == null) throw Exception('値を入力してください');

    switch (currentState.selectedProperty!.type) {
      case bool:
        if (value.toLowerCase() != 'true' && value.toLowerCase() != 'false')
          throw Exception(
            '値は true または false のどちらかである必要があります',
          );
        return value.toLowerCase() == 'true' ? true : false;
      case int:
        try {
          return int.parse(value);
        } catch (e) {
          throw Exception('値は整数である必要があります');
        }
      case double:
        try {
          return double.parse(value);
        } catch (e) {
          throw Exception('値は実数である必要があります');
        }
      case String:
        if (value.isEmpty)
          throw Exception('値を入力してください');
        else {
          return value;
        }
      default:
        throw Exception('正しい値を入力してください');
    }
  }
}

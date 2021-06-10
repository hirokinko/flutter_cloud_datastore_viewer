import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum FilterType {
  UNSPECIFIED,
  EQUALS,
  RANGE,
}

@immutable
class Property extends Equatable {
  final String name;
  final Type type;

  Property(this.name, this.type);

  List<Object> get props => [this.name, this.type];

  String toString() {
    return '${this.name}[${this.type}]';
  }
}

@immutable
class FilterTypeSelector extends Equatable {
  final List<FilterType> selectableFilterType;
  final String? error;

  FilterTypeSelector(this.selectableFilterType, this.error);

  List<Object?> get props => [this.selectableFilterType, this.error];
}

mixin FilterValue {
  List<String> validate();
}

@immutable
class EqualsFilterValue extends Equatable with FilterValue {
  final String? value;
  final Type? type;

  EqualsFilterValue(this.value, this.type);

  @override
  List<String> validate() {
    throw UnimplementedError();
  }

  @override
  List<Object?> get props => [this.value, this.type];
}

@immutable
class RangeFilterValue extends Equatable with FilterValue {
  final String? maxValue;
  final String? minValue;
  final bool containsMaxValue;
  final bool containsMinValue;

  RangeFilterValue(this.maxValue, this.minValue,
      {this.containsMaxValue = false, this.containsMinValue = false});

  @override
  List<String> validate() {
    throw UnimplementedError();
  }

  @override
  List<Object?> get props => [
        this.maxValue,
        this.minValue,
        this.containsMaxValue,
        this.containsMinValue,
      ];
}

@immutable
class Filter {
  final Property? selectedProperty;
  final List<Property> selectableProperties;
  final String? selectedPropertyError;
  final FilterType filterType;
  final FilterTypeSelector filterTypeSelector;
  final FilterValue? filterValue;

  Filter(
    this.selectedProperty,
    this.selectableProperties,
    this.selectedPropertyError,
    this.filterType,
    this.filterTypeSelector,
    this.filterValue,
  );

  String? validateSelectedProperty(Property? prop) {
    if (prop == null) {
      return "プロパティを選択してください";
    } else if (!this.selectableProperties.contains(prop)) {
      return "$propは存在しません";
    } else {
      return null;
    }
  }
}

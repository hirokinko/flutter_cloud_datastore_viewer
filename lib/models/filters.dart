import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

const FILTER_UNSELECTABLE = [FilterType.UNSPECIFIED];
const EQUALS_FILTER_ONLY = [FilterType.UNSPECIFIED, FilterType.EQUALS];
const AVAILABLE_ALL_FILTERS = [
  FilterType.UNSPECIFIED,
  FilterType.EQUALS,
  FilterType.RANGE,
];

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

mixin FilterValue {
  List<String> validate(Property prop);
}

@immutable
class EqualsFilterValue extends Equatable with FilterValue {
  final String? value;

  EqualsFilterValue(this.value);

  @override
  List<String> validate(Property prop) {
    if (this.value == null) {
      return ["値を入力してください"];
    }

    switch (prop.type) {
      case bool:
        return this._validateBooleanValue(prop);
      case String:
        return this._validateStringValue(prop);
      case int:
        return this._validateIntegerValue(prop);
      case double:
        return this._validateDoubleValue(prop);
      default:
        throw UnimplementedError();
    }
  }

  @override
  List<Object?> get props => [this.value];

  List<String> _validateBooleanValue(Property prop) {
    final String lowerValue = this.value!.toLowerCase();
    return lowerValue == 'true' || lowerValue == 'false'
        ? []
        : ["$propは'true'または'false'でないといけません"];
  }

  List<String> _validateStringValue(Property prop) {
    return this.value != '' ? [] : ["値を入力してください"];
  }

  List<String> _validateIntegerValue(Property prop) {
    return int.tryParse(this.value!) != null ? [] : ["入力値は整数でないといけません"];
  }

  List<String> _validateDoubleValue(Property prop) {
    return double.tryParse(this.value!) != null ? [] : ["入力値は実数でないといけません"];
  }
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
  List<String> validate(Property prop) {
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
  final List<FilterType> selectableFilterTypes;
  final String? selectedFilterTypeError;
  final FilterValue? filterValue;
  final List<String> filterValueErrors;

  Filter(
    this.selectedProperty,
    this.selectableProperties,
    this.selectedPropertyError,
    this.filterType,
    this.selectableFilterTypes,
    this.selectedFilterTypeError,
    this.filterValue,
    this.filterValueErrors,
  );

  String? validateSelectedProperty(Property? prop) {
    return prop == null ? "プロパティを選択してください" : null;
  }

  List<FilterType> getSelectableFilterTypes(Property? prop) {
    if (prop == null) {
      return FILTER_UNSELECTABLE;
    } else if (prop.type == bool) {
      return EQUALS_FILTER_ONLY;
    } else {
      return AVAILABLE_ALL_FILTERS;
    }
  }

  String? validateSelectedFilterType(FilterType filterType) {
    return filterType == FilterType.UNSPECIFIED ? "フィルタータイプを選択してください" : null;
  }

  FilterValue? generateDefaultFilterValue(FilterType filterType) {
    switch (filterType) {
      case FilterType.UNSPECIFIED:
        return null;
      case FilterType.EQUALS:
        return EqualsFilterValue(null);
      case FilterType.RANGE:
        return RangeFilterValue(null, null);
    }
  }
}

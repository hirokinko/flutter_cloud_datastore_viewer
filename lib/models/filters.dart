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

abstract class FilterValue extends Equatable {}

@immutable
class EqualsFilterValue extends FilterValue {
  final Type type;
  final String? value;
  final String? error;

  EqualsFilterValue(this.type, this.value, this.error);

  @override
  List<Object?> get props => [this.type, this.value, this.error];
}

class _Validators {
  static String? validateBooleanValue(
    String inputValue, {
    String label: "入力値",
  }) {
    final String lowerValue = inputValue.toLowerCase();
    return lowerValue == 'true' || lowerValue == 'false'
        ? null
        : "$labelは'true'または'false'でないといけません";
  }

  static String? validateStringValue(String inputValue, {String label: ''}) {
    return inputValue.isNotEmpty ? null : "$label値を入力してください";
  }

  static String? validateIntegerValue(
    String inputValue, {
    String label: '',
  }) {
    return int.tryParse(inputValue) != null ? null : "$label整数値を入力してください";
  }

  static String? validateDoubleValue(
    String inputValue, {
    String label: '',
  }) {
    return double.tryParse(inputValue) != null ? null : "$label実数値を入力してください";
  }

  static String? validateIntegerRangeValues(
    String? maxValue,
    String? minValue,
  ) {
    return maxValue != null &&
            minValue != null &&
            int.tryParse(maxValue) != null &&
            int.tryParse(minValue) != null &&
            int.parse(maxValue) < int.parse(minValue)
        ? "最大値には最小値より大きい整数値を入力してください"
        : null;
  }

  static String? validateDoubleRangeValues(String? maxValue, String? minValue) {
    return maxValue != null &&
            minValue != null &&
            double.tryParse(maxValue) != null &&
            double.tryParse(minValue) != null &&
            double.parse(maxValue) < double.parse(minValue)
        ? "最大値には最小値より大きい実数値を入力してください"
        : null;
  }
}

RangeFilterValue createIntegerRangeFilterValue(
  String? maxValue,
  String? minValue,
  bool containsMaxValue,
  bool containsMinValue,
) {
  late final String? formError;
  late final String? maxValueError;
  late final String? minValueError;

  maxValueError = (maxValue != null && maxValue.isNotEmpty)
      ? _Validators.validateIntegerValue(maxValue, label: "最大値には")
      : null;
  minValueError = (minValue != null && minValue.isNotEmpty)
      ? _Validators.validateIntegerValue(minValue, label: "最小値には")
      : null;
  formError = _Validators.validateIntegerRangeValues(maxValue, minValue);
  return RangeFilterValue(
    maxValue,
    minValue,
    containsMaxValue,
    containsMinValue,
    formError,
    maxValueError,
    minValueError,
  );
}

RangeFilterValue createDoubleRangeFilterValue(
  String? maxValue,
  String? minValue,
  bool containsMaxValue,
  bool containsMinValue,
) {
  late final String? formError;
  late final String? maxValueError;
  late final String? minValueError;

  maxValueError = (maxValue != null && maxValue.isNotEmpty)
      ? _Validators.validateDoubleValue(maxValue, label: "最大値には")
      : null;
  minValueError = (minValue != null && minValue.isNotEmpty)
      ? _Validators.validateDoubleValue(minValue, label: "最小値には")
      : null;
  formError = _Validators.validateDoubleRangeValues(maxValue, minValue);
  return RangeFilterValue(
    maxValue,
    minValue,
    containsMaxValue,
    containsMinValue,
    formError,
    maxValueError,
    minValueError,
  );
}

EqualsFilterValue createEqualsFilterValue(Property property, String? value) {
  if (value == null) {
    return EqualsFilterValue(property.type, value, "値を入力してください");
  }
  late final String? error;
  switch (property.type) {
    case bool:
      error = _Validators.validateBooleanValue(value);
      break;
    case String:
      error = _Validators.validateStringValue(value);
      break;
    case int:
      error = _Validators.validateIntegerValue(value);
      break;
    case double:
      error = _Validators.validateDoubleValue(value);
      break;
    default:
      error = null;
  }
  return EqualsFilterValue(property.type, value, error);
}

@immutable
class RangeFilterValue extends FilterValue {
  final String? maxValue;
  final String? minValue;
  final bool containsMaxValue;
  final bool containsMinValue;
  final String? formError;
  final String? maxValueError;
  final String? minValueError;

  RangeFilterValue(
    this.maxValue,
    this.minValue,
    this.containsMaxValue,
    this.containsMinValue,
    this.formError,
    this.maxValueError,
    this.minValueError,
  );

  @override
  List<Object?> get props => [
        this.maxValue,
        this.minValue,
        this.containsMaxValue,
        this.containsMinValue,
        this.formError,
        this.maxValueError,
        this.minValueError,
      ];
}

RangeFilterValue createRangeFilterValue(
  Property property,
  String? maxValue,
  String? minValue,
  bool containsMaxValue,
  bool containsMinValue,
) {
  late final String? formError;

  if (property.type == bool) {
    formError = "真理値型のプロパティに範囲フィルターは使用できません";
  } else if ((maxValue == null || maxValue.isEmpty) &&
      (minValue == null || minValue.isEmpty)) {
    formError = "最大値または最小値に値を入力してください";
  } else {
    formError = null;
  }

  switch (property.type) {
    case int:
      return createIntegerRangeFilterValue(
        maxValue,
        minValue,
        containsMaxValue,
        containsMinValue,
      );
    case double:
      return createDoubleRangeFilterValue(
        maxValue,
        minValue,
        containsMaxValue,
        containsMinValue,
      );
  }

  return RangeFilterValue(
    maxValue,
    minValue,
    containsMaxValue,
    containsMinValue,
    formError,
    null,
    null,
  );
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

  Filter(
    this.selectedProperty,
    this.selectableProperties,
    this.selectedPropertyError,
    this.filterType,
    this.selectableFilterTypes,
    this.selectedFilterTypeError,
    this.filterValue,
  );

  String? validateSelectedProperty(Property? prop) {
    print(prop);
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
        return EqualsFilterValue(Null, null, null);
      case FilterType.RANGE:
        return RangeFilterValue(null, null, false, false, null, null, null);
    }
  }

  List<Property> getSuggestedProperties(String propertyName) {
    return this.selectableProperties.where((Property property) {
      return property.name.toLowerCase().contains(propertyName.toLowerCase());
    }).toList(growable: false);
  }
}

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

  EqualsFilterValue(this.type, this.value);

  @override
  List<Object?> get props => [this.type, this.value];

  String? get error {
    if (this.value == null || this.value!.isEmpty) {
      return "値を入力してください";
    }
    switch (this.type) {
      case String:
        return null;
      case bool:
        return this.value!.toLowerCase() == 'true' ||
                this.value!.toLowerCase() == 'false'
            ? null
            : "'true'または'false'を入力してください";
      case int:
        return int.tryParse(this.value!) != null ? null : "整数値を入力してください";
      case double:
        return double.tryParse(this.value!) != null ? null : "実数値を入力してください";
      default:
        throw UnimplementedError();
    }
  }
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
  Type type,
  String? maxValue,
  String? minValue,
  bool containsMaxValue,
  bool containsMinValue,
) {
  late final String? formError;

  formError = _Validators.validateIntegerRangeValues(maxValue, minValue);
  return RangeFilterValue(
    type,
    maxValue,
    minValue,
    containsMaxValue,
    containsMinValue,
  );
}

RangeFilterValue createDoubleRangeFilterValue(
  Type type,
  String? maxValue,
  String? minValue,
  bool containsMaxValue,
  bool containsMinValue,
) {
  late final String? formError;

  formError = _Validators.validateDoubleRangeValues(maxValue, minValue);
  return RangeFilterValue(
    type,
    maxValue,
    minValue,
    containsMaxValue,
    containsMinValue,
  );
}

EqualsFilterValue createEqualsFilterValue(Property property, String? value) {
  if (value == null) {
    return EqualsFilterValue(property.type, value);
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
  return EqualsFilterValue(property.type, value);
}

@immutable
class RangeFilterValue extends FilterValue {
  final Type type;
  final String? maxValue;
  final String? minValue;
  final bool containsMaxValue;
  final bool containsMinValue;

  RangeFilterValue(
    this.type,
    this.maxValue,
    this.minValue,
    this.containsMaxValue,
    this.containsMinValue,
  );

  @override
  List<Object?> get props => [
        this.type,
        this.maxValue,
        this.minValue,
        this.containsMaxValue,
        this.containsMinValue,
      ];

  String? get maxValueError {
    if (this.maxValue == null || this.maxValue!.isEmpty) {
      return null;
    }
    switch (this.type) {
      case bool:
      case String:
        return null;
      case int:
        return int.tryParse(this.maxValue!) != null ? null : "整数値を入力してください";
      case double:
        return double.tryParse(this.maxValue!) != null ? null : "実数値を入力してください";
      default:
        throw UnimplementedError();
    }
  }

  String? get minValueError {
    if (this.minValue == null || this.minValue!.isEmpty) {
      return null;
    }
    switch (this.type) {
      case bool:
      case String:
        return null;
      case int:
        return int.tryParse(this.minValue!) != null ? null : "整数値を入力してください";
      case double:
        return double.tryParse(this.minValue!) != null ? null : "実数値を入力してください";
      default:
        throw UnimplementedError();
    }
  }

  String? get formError {
    if (this.type == bool) {
      return "真理値型のプロパティに範囲フィルターは使用できません";
    } else if ((this.maxValue == null || this.maxValue!.isEmpty) &&
        (this.minValue == null || this.minValue!.isEmpty)) {
      return "最大値または最小値に値を入力してください";
    } else if (this.type == int &&
        this.maxValue != null &&
        int.tryParse(this.maxValue!) != null &&
        this.minValue != null &&
        int.tryParse(this.minValue!) != null &&
        int.parse(this.maxValue!) < int.parse(this.minValue!)) {
      return "最大値には最小値より大きい整数値を入力してください";
    } else if (this.type == double &&
        this.maxValue != null &&
        double.tryParse(this.maxValue!) != null &&
        this.minValue != null &&
        double.tryParse(this.minValue!) != null &&
        double.parse(this.maxValue!) < double.parse(this.minValue!)) {
      return "最大値には最小値より大きい実数値を入力してください";
    } else {
      return null;
    }
  }
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
        property.type,
        maxValue,
        minValue,
        containsMaxValue,
        containsMinValue,
      );
    case double:
      return createDoubleRangeFilterValue(
        property.type,
        maxValue,
        minValue,
        containsMaxValue,
        containsMinValue,
      );
  }

  return RangeFilterValue(
    property.type,
    maxValue,
    minValue,
    containsMaxValue,
    containsMinValue,
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
        return EqualsFilterValue(Null, null);
      case FilterType.RANGE:
        return RangeFilterValue(
          Null,
          null,
          null,
          false,
          false,
        );
    }
  }

  List<Property> getSuggestedProperties(String propertyName) {
    return this.selectableProperties.where((Property property) {
      return property.name.toLowerCase().contains(propertyName.toLowerCase());
    }).toList(growable: false);
  }
}

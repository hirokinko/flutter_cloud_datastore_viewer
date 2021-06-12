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
  Set<String> validate(Property prop);

  Set<String> _validateBooleanValue(
    String inputValue, {
    String label: "入力値",
  }) {
    final String lowerValue = inputValue.toLowerCase();
    return lowerValue == 'true' || lowerValue == 'false'
        ? {}
        : {"$labelは'true'または'false'でないといけません"};
  }

  Set<String> _validateStringValue(String inputValue) {
    return inputValue != '' ? {} : {"値を入力してください"};
  }

  Set<String> _validateIntegerValue(
    String inputValue, {
    String label: "入力値",
  }) {
    return int.tryParse(inputValue) != null
        ? {}
        : {
            "$labelは整数でないといけません",
          };
  }

  Set<String> _validateDoubleValue(
    String inputValue, {
    String label: "入力値",
  }) {
    return double.tryParse(inputValue) != null
        ? {}
        : {
            "$labelは実数でないといけません",
          };
  }
}

@immutable
class EqualsFilterValue extends Equatable with FilterValue {
  final String? value;

  EqualsFilterValue(this.value);

  @override
  Set<String> validate(Property prop) {
    if (this.value == null) {
      return {"値を入力してください"};
    }

    switch (prop.type) {
      case bool:
        return this._validateBooleanValue(this.value!);
      case String:
        return this._validateStringValue(this.value!);
      case int:
        return this._validateIntegerValue(this.value!);
      case double:
        return this._validateDoubleValue(this.value!);
      default:
        throw UnimplementedError();
    }
  }

  @override
  List<Object?> get props => [this.value];
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
  Set<String> validate(Property prop) {
    final errors = <String>{};
    if (prop.type == bool) {
      errors.add("真理値型のプロパティに範囲フィルターは使用できません");
    }
    if ((this.maxValue == null || this.maxValue == '') &&
        (this.minValue == null || this.minValue == '')) {
      errors.add("最大値または最小値に値を入力してください");
      return errors;
    }
    switch (prop.type) {
      case int:
        errors.addAll(this._validateIntegerValues());
        break;
      case double:
        errors.addAll(this._validateDoubleValues());
        break;
    }
    return errors;
  }

  @override
  List<Object?> get props => [
        this.maxValue,
        this.minValue,
        this.containsMaxValue,
        this.containsMinValue,
      ];

  Set<String> _validateIntegerValues() {
    final errors = <String>{};
    if (this.maxValue != null && this.maxValue!.isNotEmpty) {
      errors.addAll(this._validateIntegerValue(this.maxValue!, label: "最大値"));
    }
    if (this.minValue != null && this.minValue!.isNotEmpty) {
      errors.addAll(this._validateIntegerValue(this.minValue!, label: "最小値"));
    }
    if (this.maxValue != null &&
        this.minValue != null &&
        int.tryParse(maxValue!) != null &&
        int.tryParse(minValue!) != null &&
        int.parse(this.maxValue!) < int.parse(this.minValue!)) {
      errors.add("最大値は最小値以上でないといけません");
    }
    return errors;
  }

  Set<String> _validateDoubleValues() {
    final errors = <String>{};
    if (this.maxValue != null && this.maxValue!.isNotEmpty) {
      errors.addAll(this._validateDoubleValue(this.maxValue!, label: "最大値"));
    }
    if (this.minValue != null && this.minValue!.isNotEmpty) {
      errors.addAll(this._validateDoubleValue(this.minValue!, label: "最小値"));
    }
    if (this.maxValue != null &&
        this.minValue != null &&
        double.tryParse(maxValue!) != null &&
        double.tryParse(minValue!) != null &&
        double.parse(this.maxValue!) < double.parse(this.minValue!)) {
      errors.add("最大値は最小値以上でないといけません");
    }
    return errors;
  }
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
  final Set<String> filterValueErrors;

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

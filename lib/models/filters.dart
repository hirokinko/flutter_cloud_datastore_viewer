import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

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

final defaultEqualsFilterValue = EqualsFilterValue(Null, null);
final defaultRangeFilterValue = RangeFilterValue(
  Null,
  null,
  null,
  false,
  false,
);

final filterStateProvider = StateProvider((ref) {
  return Filter(
    null,
    null,
    <Property>[],
    FilterType.UNSPECIFIED,
    FILTER_UNSELECTABLE,
    null,
  );
});

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

abstract class FilterValue extends Equatable {
  bool get isValid;

  String? toExpression(String? propertyName);
}

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

  @override
  bool get isValid => this.error == null;

  @override
  String? toExpression(String? propertyName) {
    return propertyName != null && this.value != null
        ? '$propertyName ＝ ${this.value}'
        : null;
  }
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
    } else if (this._isBothValueEmpty) {
      return "最大値または最小値に値を入力してください";
    } else if (this._isMaxValueLesserThanMinValueInt) {
      return "最大値には最小値より大きい整数値を入力してください";
    } else if (this._isMaxValueLesserThanMinValueDouble) {
      return "最大値には最小値より大きい実数値を入力してください";
    } else {
      return null;
    }
  }

  bool get _isBothValueEmpty =>
      (this.maxValue == null || this.maxValue!.isEmpty) &&
      (this.minValue == null || this.minValue!.isEmpty);

  bool get _isMaxValueLesserThanMinValueInt {
    return this.type == int &&
        this.maxValue != null &&
        this.minValue != null &&
        int.tryParse(this.maxValue!) != null &&
        int.tryParse(this.minValue!) != null &&
        int.parse(this.maxValue!) < int.parse(this.minValue!);
  }

  bool get _isMaxValueLesserThanMinValueDouble =>
      this.type == double &&
      this.maxValue != null &&
      this.minValue != null &&
      double.tryParse(this.maxValue!) != null &&
      double.tryParse(this.minValue!) != null &&
      double.parse(this.maxValue!) < double.parse(this.minValue!);

  @override
  bool get isValid =>
      this.maxValueError == null &&
      this.minValueError == null &&
      this.formError == null;

  @override
  String? toExpression(String? propertyName) {
    late final String minExpression;
    late final String maxExpression;
    if (propertyName == null ||
        (this.minValue == null && this.maxValue == null)) {
      return null;
    }
    if (this.minValue != null) {
      minExpression =
          this.containsMinValue ? '${this.minValue} ≦' : '${this.minValue} ＜';
    } else {
      minExpression = '';
    }
    if (this.maxValue != null) {
      maxExpression =
          this.containsMaxValue ? '≦ ${this.maxValue}' : '＜ ${this.maxValue}';
    } else {
      maxExpression = '';
    }
    return '$minExpression $propertyName $maxExpression'.trim();
  }
}

@immutable
class Filter extends Equatable {
  final String? kind;
  final Property? selectedProperty;
  final List<Property> selectableProperties;
  final FilterType filterType;
  final List<FilterType> selectableFilterTypes;
  final FilterValue? filterValue;

  Filter(
    this.kind,
    this.selectedProperty,
    this.selectableProperties,
    this.filterType,
    this.selectableFilterTypes,
    this.filterValue,
  );

  List<FilterType> getSelectableFilterTypes(Property? prop) {
    if (prop == null) {
      return FILTER_UNSELECTABLE;
    } else if (prop.type == bool) {
      return EQUALS_FILTER_ONLY;
    } else {
      return AVAILABLE_ALL_FILTERS;
    }
  }

  List<Property> getSuggestedProperties(String propertyName) {
    return this.selectableProperties.where((Property property) {
      return property.name.toLowerCase().contains(propertyName.toLowerCase());
    }).toList(growable: false);
  }

  String? get selectedPropertyError =>
      this.selectedProperty == null ? "プロパティを選択してください" : null;

  String? get selectedFilterTypeError =>
      this.selectedProperty != null && this.filterType == FilterType.UNSPECIFIED
          ? "フィルタータイプを選択してください"
          : null;

  @override
  List<Object?> get props => [
        this.selectedProperty,
        this.selectableProperties,
        this.filterType,
        this.selectableFilterTypes,
        this.filterValue,
      ];

  bool get isValid =>
      this.selectedPropertyError == null &&
      this.selectedFilterTypeError == null &&
      (this.filterValue?.isValid ?? true);

  String? get expression =>
      this.filterValue?.toExpression(this.selectedProperty?.name);
}

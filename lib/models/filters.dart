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
class PropertySelector extends Equatable {
  final List<Property> selectableProps;
  final String? error;

  PropertySelector(this.selectableProps, this.error);

  List<Object> get props => [this.selectableProps, this.error ?? '<null>'];
}

@immutable
class FilterTypeSelector extends Equatable {
  final List<FilterType> selectableFilterType;
  final String? error;

  FilterTypeSelector(this.selectableFilterType, this.error);

  List<Object> get props => [this.selectableFilterType, this.error ?? '<null>'];
}

@immutable
class Filter {
  final Property? selectedProperty;
  final PropertySelector? propertySelector;
  final FilterType filterType;
  final FilterTypeSelector filterTypeSelector;

  Filter(
    this.selectedProperty,
    this.propertySelector,
    this.filterType,
    this.filterTypeSelector,
  );
}

import 'package:meta/meta.dart';

@immutable
class Property implements Comparable<Property> {
  final String name;
  final bool indexed;
  final Type type;

  const Property(this.name, this.indexed, this.type);

  @override
  int compareTo(other) => this.name.compareTo(other.name);

  @override
  int get hashCode =>
      ((17 * 31 + this.name.hashCode) * 31 + this.indexed.hashCode) * 31 +
      this.type.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Property &&
      this.name == other.name &&
      this.indexed == other.indexed &&
      this.type == other.type;
}

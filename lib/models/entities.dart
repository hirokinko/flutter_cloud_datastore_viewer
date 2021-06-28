import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

const DEFAULT_LIMIT = 50;
const DUMMY_EMPTY_KEY = const Key('', null, '', null, null, []);
const DEFAULT_ENTITY_LIST = EntityList([], DEFAULT_LIMIT, null, null, null);

final entityListStateProvider =
    StateProvider.autoDispose((ref) => DEFAULT_ENTITY_LIST);

@immutable
abstract class Property<T> extends Equatable with Comparable<dynamic> {
  final String name;
  final Type type;
  final bool indexed;

  Property(this.name, this.type, this.indexed);

  List<MapEntry<String, Type>> get propertyEntries;

  @override
  int compareTo(other) {
    return this.name.compareTo(name);
  }
}

@immutable
class SingleProperty<T> extends Property<T> {
  final T? value;

  SingleProperty(String name, Type type, bool indexed, this.value)
      : super(
          name,
          type,
          indexed,
        );

  @override
  List<Object?> get props => [this.name, this.type, this.indexed, this.value];

  @override
  List<MapEntry<String, Type>> get propertyEntries {
    switch (this.type) {
      case Entity:
        return this.value == null
            ? <MapEntry<String, Type>>[]
            : (this.value as Entity).getInnerPropertyEntries(this.name, false);
      case Key:
        return DUMMY_EMPTY_KEY.getIndexedInnerPropertyEntries(this.name);
      default:
        return [MapEntry<String, Type>(this.name, this.type)];
    }
  }
}

@immutable
class ListProperty<T> extends Property<T> {
  final List<T?> values;

  ListProperty(String name, Type type, bool indexed, this.values)
      : super(
          name,
          type,
          indexed,
        );

  @override
  List<Object?> get props => [this.name, this.type, this.indexed, this.values];

  @override
  List<MapEntry<String, Type>> get propertyEntries {
    final nonNullValues = this.values.where((v) => v != null);
    switch (this.type) {
      case Entity:
        return nonNullValues.isEmpty
            ? <MapEntry<String, Type>>[]
            : (nonNullValues.first as Entity)
                .getInnerPropertyEntries(this.name, false);
      case Key:
        return DUMMY_EMPTY_KEY.getIndexedInnerPropertyEntries(this.name);
      default:
        return [MapEntry<String, Type>(this.name, this.type)];
    }
  }
}

@immutable
class Key extends Equatable {
  final String projectId;
  final String? namespaceId;
  final String kind;
  final int? id;
  final String? name;
  final List<Key> ancestors;

  const Key(
    this.projectId,
    this.namespaceId,
    this.kind,
    this.id,
    this.name,
    this.ancestors,
  );

  @override
  List<Object?> get props => [
        this.projectId,
        this.namespaceId,
        this.kind,
        this.id,
        this.name,
        this.ancestors,
      ];

  List<MapEntry<String, Type>> getIndexedInnerPropertyEntries(
    String? parentName,
  ) {
    final parentTag =
        parentName != null && parentName.isNotEmpty ? '$parentName.' : '';
    return [
      MapEntry<String, Type>('${parentTag}kind', String),
      MapEntry<String, Type>('${parentTag}name', String),
      MapEntry<String, Type>('${parentTag}id', int),
    ];
  }
}

@immutable
class Entity extends Equatable {
  final Key? key;
  final List<Property> properties;

  Entity(this.key, this.properties);

  @override
  List<Object?> get props => [this.key, this.properties];

  List<MapEntry<String, Type>> getInnerPropertyEntries(
    String? parentName,
    bool indexedOnly,
  ) {
    final allPropertyEntries =
        this.key?.getIndexedInnerPropertyEntries('__key__') ??
            <MapEntry<String, Type>>[];
    final parentTag =
        parentName != null && parentName.isNotEmpty ? '$parentName.' : '';

    final folded = this
        .properties
        .where((p) => !indexedOnly || (indexedOnly && p.indexed))
        .fold(
      <MapEntry<String, Type>>[],
      (
        List<MapEntry<String, Type>> acc,
        Property cur,
      ) {
        final propertyEntries = cur.propertyEntries;
        acc.addAll(
          propertyEntries.map(
            (MapEntry<String, Type> e) => MapEntry<String, Type>(
              '$parentTag${e.key}',
              e.value,
            ),
          ),
        );
        return acc;
      },
    );
    allPropertyEntries.addAll(folded);
    return allPropertyEntries;
  }
}

@immutable
class EntityList extends Equatable {
  final List<Entity?> entities;
  final int limit;
  final String? startCursor;
  final String? endCursor;
  final String? previousPageStartCursor;

  const EntityList(
    this.entities,
    this.limit,
    this.startCursor,
    this.endCursor,
    this.previousPageStartCursor,
  );

  @override
  List<Object?> get props => [
        this.entities,
        this.limit,
        this.startCursor,
        this.endCursor,
        this.previousPageStartCursor,
      ];

  String? get isInvalidLimit => this.limit < 0 ? "件数は正の整数を入力してください" : null;
}

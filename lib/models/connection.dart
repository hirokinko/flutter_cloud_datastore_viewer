import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

mixin Connection {}

@immutable
class CloudDatastoreConnection extends Equatable with Connection {
  final String keyFilePath;
  final String rootUrl;
  final String projectId;

  const CloudDatastoreConnection(
    this.keyFilePath,
    this.projectId, {
    this.rootUrl: 'https://datastore.googleapis.com/',
  });

  @override
  List<Object?> get props => [this.keyFilePath, this.rootUrl, this.projectId];

  static CloudDatastoreConnection fromJson(Map<String, String> json) {
    return CloudDatastoreConnection(
      json['keyFilePath']!,
      json['projectId']!,
      rootUrl: json['rootUrl'] ?? 'https://datastore.googleapis.com/',
    );
  }

  String toJson() {
    return jsonEncode({
      'keyFilePath': this.keyFilePath,
      'projectId': this.projectId,
      'rootUrl': this.rootUrl,
    });
  }
}

@immutable
class CurrentShowing extends Equatable {
  final String? namespace;
  final String? kind;

  CurrentShowing(this.namespace, this.kind);

  @override
  List<Object?> get props => [this.namespace, this.kind];

  static CurrentShowing fromJson(Map<String, String> json) {
    return CurrentShowing(json['namespace'], json['kind']);
  }

  String toJson() {
    return jsonEncode({
      'namespace': this.namespace,
      'kind': this.kind,
    });
  }
}

@immutable
class CloudDatastoreMetadata extends Equatable {
  final List<String?> namespaces;
  final List<String> kinds;

  const CloudDatastoreMetadata(this.namespaces, this.kinds);

  @override
  List<Object?> get props => [this.namespaces, this.kinds];
}

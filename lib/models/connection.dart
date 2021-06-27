import 'package:equatable/equatable.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_cloud_datastore_viewer/patched_datastore/v1.dart'
    as v1Api;
import 'package:ordered_set/ordered_set.dart';
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
}

@immutable
class CurrentShowing extends Equatable {
  final String? namespace;
  final String? kind;

  CurrentShowing(this.namespace, this.kind);

  @override
  List<Object?> get props => [this.namespace, this.kind];
}

@immutable
class CloudDatastoreMetadata extends Equatable {
  final List<String?> namespaces;
  final List<String> kinds;

  const CloudDatastoreMetadata(this.namespaces, this.kinds);

  @override
  List<Object?> get props => [this.namespaces, this.kinds];
}

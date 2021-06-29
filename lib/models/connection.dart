import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

const DEFAULT_ROOT_URL = 'https://datastore.googleapis.com/';

final connectionListStateProvider =
    StateProvider<List<CloudDatastoreConnection>>((ref) => []);
final currentConnectionStateProvider = StateProvider<CloudDatastoreConnection?>(
  (ref) => null,
);
final currentShowingStateProvider =
    StateProvider((ref) => CurrentShowing(null, null));
final metadataStateProvider =
    StateProvider((ref) => CloudDatastoreMetadata([], []));
final rootUrlPattern =
    RegExp('^https?:\/\/[a-zA-Z][a-zA-Z0-9\.]*[a-zA-Z](\:[0-9]+)?\/\$');

mixin Connection {}

@immutable
class CloudDatastoreConnection extends Equatable with Connection {
  final String? keyFilePath;
  final String rootUrl;
  final String projectId;

  const CloudDatastoreConnection(
    this.keyFilePath,
    this.projectId, {
    this.rootUrl: DEFAULT_ROOT_URL,
  });

  @override
  List<Object?> get props => [this.keyFilePath, this.rootUrl, this.projectId];

  static CloudDatastoreConnection fromJson(Map<String, dynamic> json) {
    return CloudDatastoreConnection(
      json['keyFilePath'],
      json['projectId']!,
      rootUrl: json['rootUrl'] ?? DEFAULT_ROOT_URL,
    );
  }

  String toJson() {
    return jsonEncode({
      'keyFilePath': this.keyFilePath,
      'projectId': this.projectId,
      'rootUrl': this.rootUrl,
    });
  }

  bool get isValid {
    return this.projectId.isNotEmpty &&
        (isValidKeyFilePath || isLocalEmulatorConnection) &&
        isRootUrlPatternMatched;
  }

  bool get isValidKeyFilePath =>
      this.rootUrl == DEFAULT_ROOT_URL &&
      this.keyFilePath != null &&
      new File(this.keyFilePath!).existsSync();

  // TODO ping to emulator host
  bool get isLocalEmulatorConnection => this.rootUrl != DEFAULT_ROOT_URL;

  bool get isRootUrlPatternMatched => rootUrlPattern.hasMatch(this.rootUrl);
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

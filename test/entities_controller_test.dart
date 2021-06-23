import 'package:flutter_cloud_datastore_viewer/controllers/entities_controller.dart';
import 'package:flutter_cloud_datastore_viewer/models/connection.dart';
import 'package:flutter_cloud_datastore_viewer/models/entities.dart';
import 'package:flutter_cloud_datastore_viewer/repositories/clouddatastore_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'entities_controller_test.mocks.dart';

@GenerateMocks([CloudDatastoreRepostiry])
main() {
  late ProviderContainer container;
  final mockedRepositry = MockCloudDatastoreRepostiry();

  setUp(() => {
        container = ProviderContainer(
          overrides: [
            repositoryProvider.overrideWithProvider(
              Provider((ref) => mockedRepositry),
            ),
          ],
        )
      });

  tearDown(() => {
        reset(mockedRepositry),
      });

  group('onChangeCurrentShowingNamespace', () {
    <String?>[null, 'development'].forEach((String? namespace) {
      final expected = CurrentShowing(namespace, null);
      test(
        'gives $namespace to EntitiesController.onChangeCurrentShowingNamespace, state returns $expected',
        () async {
          when(mockedRepositry.getMetadata(namespace)).thenAnswer(
            (_) async => CloudDatastoreMetadata(
              [null, 'development'],
              ['Spam', 'Ham', 'Egg'],
            ),
          );
          await container
              .read(entitiesControllerProvider)
              .onChangeCurrentShowingNamespace(namespace);
          final actual = container.read(currentShowingStateProvider).state;
          expect(actual, expected);
          expect(
            container.read(metadataStateProvider).state,
            CloudDatastoreMetadata(
              [null, 'development'],
              ['Spam', 'Ham', 'Egg'],
            ),
          );
          verify(mockedRepositry.getMetadata(namespace)).called(1);
        },
      );
    });

    test(
      'If "spam" not in namespaces and gives it to EntitiesController.onChangeCurrentShowingNamespace, state returns current',
      () async {
        when(mockedRepositry.getMetadata('spam')).thenAnswer(
            (_) async => CloudDatastoreMetadata([null, 'development'], []));
        container.read(metadataStateProvider).state =
            CloudDatastoreMetadata([null, 'development'], []);
        await container
            .read(entitiesControllerProvider)
            .onChangeCurrentShowingNamespace('spam');

        final actual = container.read(currentShowingStateProvider).state;
        expect(actual, CurrentShowing(null, null));
        expect(container.read(metadataStateProvider).state,
            CloudDatastoreMetadata([null, 'development'], []));
        verify(mockedRepositry.getMetadata('spam')).called(1);
      },
    );
  });

  group('onChangeCurrentShowingKind', () {
    <MapEntry<String, String?>>[
      MapEntry<String, String?>('Ham', 'Ham'),
      MapEntry<String, String?>('SpanishInquisition', null),
    ].forEach((MapEntry<String, String?> entry) {
      test(
        'When gives ${entry.key} to onChangeCurrentShowingKind, then returns ${entry.value}',
        () async {
          container.read(metadataStateProvider).state = CloudDatastoreMetadata(
            [null, 'development'],
            ['Spam', 'Ham', 'Egg'],
          );
          container.read(currentShowingStateProvider).state = CurrentShowing(
            'development',
            null,
          );
          final expected = CurrentShowing('development', entry.value);
          await container
              .read(entitiesControllerProvider)
              .onChangeCurrentShowingKind(entry.key);
          final actual = container.read(currentShowingStateProvider).state;
          expect(actual, expected);
        },
      );
    });
  });

  group('onLoadEntityList', () {
    test('Query to no exists namespace', () async {
      when(mockedRepositry.find('Spam', 'spam', 'Eric', 'Terry', limit: 50))
          .thenAnswer((_) async => DEFAULT_ENTITY_LIST);

      container.read(metadataStateProvider).state = CloudDatastoreMetadata(
        [null, 'development'],
        ['Spam', 'Ham', 'Egg'],
      );
      container.read(currentShowingStateProvider).state =
          CurrentShowing('spam', 'Spam');

      await container
          .read(entitiesControllerProvider)
          .onLoadEntityList('Eric', 'Terry');

      expect(
        container.read(entityListStateProvider).state,
        DEFAULT_ENTITY_LIST,
      );

      verifyNever(mockedRepositry.find(
        'Spam',
        'spam',
        'Eric',
        'Terry',
        limit: 50,
      ));
    });

    test('Query to no exists kind', () async {
      when(mockedRepositry.find(
              'SpanishInquisition', 'development', 'Eric', 'Terry',
              limit: 50))
          .thenAnswer((_) async => DEFAULT_ENTITY_LIST);

      container.read(metadataStateProvider).state = CloudDatastoreMetadata(
        [null, 'development'],
        ['Spam', 'Ham', 'Egg'],
      );
      container.read(currentShowingStateProvider).state =
          CurrentShowing('development', 'SpanishInquisition');

      await container
          .read(entitiesControllerProvider)
          .onLoadEntityList('Eric', 'Terry');

      expect(
        container.read(entityListStateProvider).state,
        DEFAULT_ENTITY_LIST,
      );

      verifyNever(mockedRepositry.find(
        'SpanishInquisition',
        'development',
        'Eric',
        'Terry',
        limit: 50,
      ));
    });

    test('Query to null kind', () async {
      when(mockedRepositry.find(
        null,
        null,
        'Eric',
        'Terry',
        limit: 50,
      )).thenAnswer((_) async => DEFAULT_ENTITY_LIST);

      container.read(metadataStateProvider).state = CloudDatastoreMetadata(
        [null, 'development'],
        ['Spam', 'Ham', 'Egg'],
      );
      container.read(currentShowingStateProvider).state =
          CurrentShowing(null, null);

      await container
          .read(entitiesControllerProvider)
          .onLoadEntityList('Eric', 'Terry');

      expect(
        container.read(entityListStateProvider).state,
        DEFAULT_ENTITY_LIST,
      );

      verifyNever(mockedRepositry.find(
        null,
        null,
        'Eric',
        'Terry',
        limit: 50,
      ));
    });

    test('Got entities', () async {
      when(mockedRepositry.find(
        'Spam',
        null,
        'Eric',
        'Terry',
        limit: 50,
      )).thenAnswer((_) async => EntityList([], 50, 'Eric', 'Graham', 'Terry'));

      container.read(metadataStateProvider).state = CloudDatastoreMetadata(
        [null, 'development'],
        ['Spam', 'Ham', 'Egg'],
      );
      container.read(currentShowingStateProvider).state =
          CurrentShowing(null, 'Spam');

      await container
          .read(entitiesControllerProvider)
          .onLoadEntityList('Eric', 'Terry');

      expect(
        container.read(entityListStateProvider).state,
        EntityList([], 50, 'Eric', 'Graham', 'Terry'),
      );

      verify(mockedRepositry.find(
        'Spam',
        null,
        'Eric',
        'Terry',
        limit: 50,
      )).called(1);
    });
  });
}

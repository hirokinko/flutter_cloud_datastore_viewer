import 'package:flutter_cloud_datastore_viewer/patched_datastore/v1.dart'
    as datastore_api;
import 'package:flutter_cloud_datastore_viewer/repositories/clouddatastore_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'clouddatastore_repository_test.mocks.dart';
import 'fixtures/clouddatastore_repository_fixtures.dart';

@GenerateMocks([datastore_api.DatastoreApi, datastore_api.ProjectsResource])
void main() {
  toValueTestFixtures.asMap().forEach((index, fixture) {
    test(
        'ケース $index\n'
        'CloudDatastoreUtils.toValue() に ${fixture.type}と ${fixture.value} を渡した時、\n'
        '${fixture.expectedValue} が返る', () {
      final actual = CloudDatastoreUtils.toValue(fixture.type, fixture.value);
      expect(actual.toJson(), fixture.expectedValue);
    });
  });

  toPropertyFilterFixtures.asMap().forEach((index, fixture) {
    test(
        'ケース $index\n'
        'CloudDatastoreUtils.toPropertyFilter() に ${fixture.name}, ${fixture.op}, ${fixture.type}, ${fixture.value} を渡した時\n'
        '${fixture.expectedPropertyFilter} が返る', () {
      final actual = CloudDatastoreUtils.toPropertyFilter(
        fixture.name,
        fixture.op,
        fixture.type,
        fixture.value,
      );
      expect(actual.toJson(), fixture.expectedPropertyFilter);
    });
  });

  toRangeFilterFixtures.asMap().forEach((index, fixture) {
    test(
      'ケース $index\n'
      'CloudDatastoreUtils.toRangeFilter() に ${fixture.name}, ${fixture.type}, '
      '${fixture.maxValue}, ${fixture.minValue}, '
      ' ${fixture.containsMax}, ${fixture.containsMin} を渡した時\n'
      '${fixture.expectedPropertyFilter} が返る',
      () {
        final actual = CloudDatastoreUtils.toRangeFilter(
          fixture.name,
          fixture.type,
          fixture.maxValue,
          fixture.minValue,
          containsMaxValue: fixture.containsMax,
          containsMinValue: fixture.containsMin,
        );
        expect(actual.toJson(), fixture.expectedPropertyFilter);
      },
    );
  });

  test('CloudDatastoreRepository.namespaces', () async {
    final datastoreApi = MockDatastoreApi();
    final mockedProjectResouce = MockProjectsResource();
    final projectId = 'test-project';
    final repository = CloudDatastoreRepostiry(datastoreApi, projectId);

    when(datastoreApi.projects).thenReturn(mockedProjectResouce);
    when(
      mockedProjectResouce.runQuery(
        any,
        any,
      ),
    ).thenAnswer(
      (_) async => namespacesRunQueryResponse,
    );
    expect(await repository.namespaces(), [null, 'development']);
    verify(mockedProjectResouce.runQuery(any, any)).called(1);
  });

  test('CloudDatastoreRepository.kinds', () async {
    final datastoreApi = MockDatastoreApi();
    final mockedProjectResouce = MockProjectsResource();
    final projectId = 'test-project';
    final repository = CloudDatastoreRepostiry(datastoreApi, projectId);

    when(datastoreApi.projects).thenReturn(mockedProjectResouce);
    when(
      mockedProjectResouce.runQuery(any, any),
    ).thenAnswer(
      (_) async => kindRunQueryResponse,
    );
    expect(await repository.kinds(null), ['Spam', 'Ham', 'Egg']);
  });
}

import 'package:flutter_cloud_datastore_viewer/models/filters.dart';
import 'package:flutter_cloud_datastore_viewer/patched_datastore/v1.dart'
    as datastore_api;
import 'package:flutter_cloud_datastore_viewer/data_access_objects/clouddatastore_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'clouddatastore_dao_test.mocks.dart';
import 'fixtures/clouddatastore_dao_fixtures.dart';

@GenerateMocks([datastore_api.DatastoreApi, datastore_api.ProjectsResource])
void main() {
  test('CloudDatastoreDao.namespaces', () async {
    final datastoreApi = MockDatastoreApi();
    final mockedProjectResouce = MockProjectsResource();
    final projectId = 'test-project';
    final dao = CloudDatastoreDao(datastoreApi, projectId);

    when(datastoreApi.projects).thenReturn(mockedProjectResouce);
    when(
      mockedProjectResouce.runQuery(
        any,
        any,
      ),
    ).thenAnswer((_) async => namespacesRunQueryResponse);
    expect(await dao.namespaces(), [null, 'development']);
    verify(mockedProjectResouce.runQuery(any, any)).called(1);
  });

  test('CloudDatastoreDao.kinds', () async {
    final datastoreApi = MockDatastoreApi();
    final mockedProjectResouce = MockProjectsResource();
    final projectId = 'test-project';
    final dao = CloudDatastoreDao(datastoreApi, projectId);

    when(datastoreApi.projects).thenReturn(mockedProjectResouce);
    when(
      mockedProjectResouce.runQuery(any, any),
    ).thenAnswer((_) async => kindRunQueryResponse);
    expect(await dao.kinds(null), ['Spam', 'Ham', 'Egg']);
  });

  test('CloudDatastoreDao.find', () async {
    final datastoreApi = MockDatastoreApi();
    final mockedProjectResource = MockProjectsResource();
    final projectId = 'test-project';
    final dao = CloudDatastoreDao(datastoreApi, projectId);

    when(datastoreApi.projects).thenReturn(mockedProjectResource);
    when(
      mockedProjectResource.runQuery(any, any),
    ).thenAnswer(
      (_) async => findRunQueryResponse,
    );

    final result = await dao.find(
      'Profile',
      'development',
      null,
      null,
      null,
      null,
    );
    result.entities.forEach((entity) {
      entity?.properties.forEach((property) {
        print(property);
      });
    });
    // TODO assertion
  });

  toPropertyFilterFixtures.asMap().forEach((index, fixture) {
    test(
        'CloudDatastoreDao.toFilter(${fixture.name}, ${fixture.type}, ${fixture.value}) == ${fixture.expectedPropertyFilter}',
        () {
      final datastoreApi = MockDatastoreApi();
      final projectId = 'test-project';
      final dao = CloudDatastoreDao(datastoreApi, projectId);
      final actual = dao.toFilter(fixture.name, fixture.type, fixture.value);
      expect(actual.toJson(), fixture.expectedPropertyFilter);
    });
  });

  toValueTestFixtures.asMap().forEach((index, fixture) {
    test(
        'CloudDatastoreDao.toDatastoreValue(${fixture.type}, ${fixture.value}) == ${fixture.expectedValue}',
        () {
      final datastoreApi = MockDatastoreApi();
      final projectId = 'test-project';
      final dao = CloudDatastoreDao(datastoreApi, projectId);
      final actual = dao.toDatastoreValue(fixture.type, fixture.value);
      expect(actual.toJson(), fixture.expectedValue);
    });
  });

  toRangeFilterFixtures.asMap().forEach((index, fixture) {
    test(
      'CloudDatastoreDao.toCompositeFilter('
      '${fixture.name}, ${fixture.type},'
      'RangeFilterValue(${fixture.type}, ${fixture.maxValue}, ${fixture.minValue}, ${fixture.containsMax}, ${fixture.containsMin}'
      ') == ${fixture.expectedPropertyFilter}',
      () {
        final datastoreApi = MockDatastoreApi();
        final projectId = 'test-project';
        final dao = CloudDatastoreDao(datastoreApi, projectId);
        final actual = dao.toCompositeFilter(
          fixture.name,
          fixture.type,
          RangeFilterValue(
            fixture.type,
            fixture.maxValue,
            fixture.minValue,
            fixture.containsMax,
            fixture.containsMin,
          ),
        );
        expect(actual.toJson(), fixture.expectedPropertyFilter);
      },
    );
  });
}

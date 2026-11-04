import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/task.dart';
import 'package:my_app/task_api_client.dart';

/// Mock HTTP client for fast, deterministic client tests (Section 15)
class MockHttpClient implements HttpClientWrapper {
  Map<String, dynamic>? cannedResponse;
  String? recordedUrl;
  Map<String, String>? recordedHeaders;

  @override
  Future<Map<String, dynamic>> get(String url, {Map<String, String>? headers}) async {
    recordedUrl = url;
    recordedHeaders = headers;
    return cannedResponse ?? {'statusCode': 200, 'body': []};
  }
}

void main() {
  group('Mocked API Client tests (Section 15)', () {
    late MockHttpClient mockClient;
    late TaskApiClient apiClient;

    setUp(() {
      mockClient = MockHttpClient();
      apiClient = TaskApiClient(client: mockClient);
    });

    test('parses tasks from mocked successful response', () async {
      mockClient.cannedResponse = {
        'statusCode': 200,
        'body': [
          {'id': 'task-101', 'title': 'Write unit tests', 'completed': false},
          {'id': 'task-102', 'title': 'Verify mock contracts', 'completed': true},
        ],
      };

      final tasks = await apiClient.fetchTasks('fake-test-token-xyz');

      // What this catches:
      // - Correct authorization header generation
      // - Client URL construction
      // - JSON parsing and conversion into Task model objects
      // - Fast execution without network latency or DB setup
      expect(mockClient.recordedUrl, 'http://localhost:3000/api/v1/tasks');
      expect(mockClient.recordedHeaders?['Authorization'], 'Bearer fake-test-token-xyz');
      expect(tasks.length, 2);
      expect(tasks[0].id, 'task-101');
      expect(tasks[0].title, 'Write unit tests');
      expect(tasks[1].completed, true);
    });

    test('throws FormatException on 401 Unauthorized', () async {
      mockClient.cannedResponse = {
        'statusCode': 401,
        'body': {'error': 'Unauthorized'},
      };

      // What this catches:
      // - Client-side handling of unauthorized response codes
      // What this CANNOT catch:
      // - Actual JWT validation errors, DB connection errors, or backend routing bugs
      expect(
        () => apiClient.fetchTasks('expired-token'),
        throwsFormatException,
      );
    });
  });
}

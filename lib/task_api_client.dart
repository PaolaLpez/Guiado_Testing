import 'dart:convert';
import 'task.dart';

/// Interface for HTTP requests enabling clean unit testing with mocks.
abstract class HttpClientWrapper {
  Future<Map<String, dynamic>> get(String url, {Map<String, String>? headers});
}

/// Task API Client demonstrating unit testing with mocks (Section 15).
class TaskApiClient {
  final HttpClientWrapper client;
  final String baseUrl;

  TaskApiClient({
    required this.client,
    this.baseUrl = 'http://localhost:3000/api/v1',
  });

  /// Fetches tasks for authenticated user.
  Future<List<Task>> fetchTasks(String token) async {
    final response = await client.get(
      '$baseUrl/tasks',
      headers: {'Authorization': 'Bearer $token'},
    );

    final int statusCode = response['statusCode'] as int? ?? 200;
    if (statusCode == 200) {
      final dynamic body = response['body'];
      final List<dynamic> list = body is List
          ? body
          : jsonDecode(body as String) as List<dynamic>;

      return list
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (statusCode == 401) {
      throw const FormatException('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Server error: $statusCode');
    }
  }
}

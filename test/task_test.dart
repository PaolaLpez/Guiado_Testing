import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/task.dart';

void main() {
  group('Task model unit tests (Section 4)', () {
    test('parses a valid task', () {
      final task = Task.fromJson({'id': 'task-1', 'title': 'Plan tests'});
      expect(task.id, 'task-1');
      expect(task.title, 'Plan tests');
      expect(task.completed, false);
    });

    test('rejects an empty title', () {
      expect(
        () => Task.fromJson({'id': 'task-1', 'title': ' '}),
        throwsFormatException,
      );
    });

    // Practice exercise (Section 4): Missing ID
    test('rejects a missing ID', () {
      expect(
        () => Task.fromJson({'title': 'Plan tests'}),
        throwsFormatException,
      );
    });

    test('rejects a non-string ID', () {
      expect(
        () => Task.fromJson({'id': 12345, 'title': 'Plan tests'}),
        throwsFormatException,
      );
    });

    // Practice exercise (Section 4): Valid title at maximum allowed length (120 characters)
    test('accepts a valid title at the maximum allowed length of 120 characters', () {
      final maxTitle = 'a' * 120;
      final task = Task.fromJson({'id': 'task-max', 'title': maxTitle});
      expect(task.id, 'task-max');
      expect(task.title, maxTitle);
      expect(task.title.length, 120);
    });

    test('serializes to JSON correctly', () {
      const task = Task(id: 'task-3', title: 'Buy milk', completed: true);
      final json = task.toJson();
      expect(json, {
        'id': 'task-3',
        'title': 'Buy milk',
        'completed': true,
      });
    });
  });
}

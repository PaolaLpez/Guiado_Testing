import 'package:flutter/material.dart';

/// Shows tasks or the current loading, empty, or error state.
class TaskListPanel extends StatelessWidget {
  /// Creates a task list panel.
  const TaskListPanel({
    super.key,
    required this.loading,
    required this.tasks,
    this.errorMessage,
    this.onRetry,
    this.onToggleComplete,
  });

  /// Whether tasks are being loaded.
  final bool loading;

  /// Task titles to display.
  final List<String> tasks;

  /// Optional safe error message.
  final String? errorMessage;

  /// Callback when retry button is tapped (Practice exercise Section 5).
  final VoidCallback? onRetry;

  /// Optional callback for task action.
  final ValueChanged<int>? onToggleComplete;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                key: const Key('retry-button'),
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks yet.'));
    }
    return Material(
      child: ListView(
        children: [
          for (int i = 0; i < tasks.length; i++)
            ListTile(
              key: Key('task-item-$i'),
              title: Text(tasks[i]),
              trailing: IconButton(
                key: Key('complete-task-button-$i'),
                tooltip: 'Complete Task',
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => onToggleComplete?.call(i),
              ),
            ),
        ],
      ),
    );
  }
}

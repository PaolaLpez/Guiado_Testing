import 'package:flutter/material.dart';
import 'task.dart';
import 'task_list_panel.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAuthenticated = false;
  String _userEmail = '';

  void _login(String email) {
    setState(() {
      _isAuthenticated = true;
      _userEmail = email;
    });
  }

  void _logout() {
    setState(() {
      _isAuthenticated = false;
      _userEmail = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return LoginScreen(onLogin: _login);
    }
    return TaskHomeScreen(userEmail: _userEmail, onLogout: _logout);
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});

  final ValueChanged<String> onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _handleSubmit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email.');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters.');
      return;
    }

    setState(() => _errorMessage = null);
    widget.onLogin(email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.task_alt, size: 64, color: Colors.indigo),
                const SizedBox(height: 16),
                const Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                TextField(
                  key: const Key('email-field'),
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('password-field'),
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  key: const Key('login-button'),
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskHomeScreen extends StatefulWidget {
  const TaskHomeScreen({
    super.key,
    required this.userEmail,
    required this.onLogout,
  });

  final String userEmail;
  final VoidCallback onLogout;

  @override
  State<TaskHomeScreen> createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends State<TaskHomeScreen> {
  final List<Task> _tasks = [];
  bool _loading = false;
  String? _errorMessage;

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    String? dialogError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    key: const Key('task-title-field'),
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      errorText: dialogError,
                    ),
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  key: const Key('save-task-button'),
                  onPressed: () {
                    final rawTitle = titleController.text;
                    final trimmed = rawTitle.trim();
                    if (trimmed.isEmpty) {
                      setDialogState(() {
                        dialogError = 'Enter a valid title.';
                      });
                      return;
                    }
                    if (trimmed.length > 120) {
                      setDialogState(() {
                        dialogError = 'Title must be 120 characters or fewer.';
                      });
                      return;
                    }

                    setState(() {
                      _tasks.add(Task(
                        id: 'task-${DateTime.now().millisecondsSinceEpoch}',
                        title: trimmed,
                      ));
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      final current = _tasks[index];
      _tasks[index] = current.copyWith(completed: !current.completed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            key: const Key('logout-button'),
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? TaskListPanel(
              loading: _loading,
              tasks: const [],
              errorMessage: _errorMessage,
              onRetry: () {
                setState(() => _errorMessage = null);
              },
            )
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.completed ? Colors.grey : Colors.black87,
                    ),
                  ),
                  subtitle: Text(task.completed ? 'Completed' : 'Pending'),
                  trailing: IconButton(
                    key: index == 0
                        ? const Key('complete-task-button')
                        : Key('complete-task-button-$index'),
                    tooltip: 'Mark Complete',
                    icon: Icon(
                      task.completed
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: task.completed ? Colors.green : null,
                    ),
                    onPressed: () => _toggleTaskCompletion(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add-task-button'),
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';

// No BLoC, no DI — keeps it crash-proof even if the DI setup itself is what failed.
class BlockedScreen extends StatelessWidget {
  final List<String> issues;

  const BlockedScreen({super.key, required this.issues});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.security,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "This app can't run here",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Text(
                      "We detected something unusual about this device.\n"
                      "To keep your data safe, Task Manager only runs on standard devices.\n"
                      "If you think this is a mistake, please contact support.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (issues.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Text(
                      'Detected issues:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: issues
                          .map((i) => Chip(
                                label: Text(
                                  i,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.red.shade100,
                                side: BorderSide(color: Colors.red.shade200),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

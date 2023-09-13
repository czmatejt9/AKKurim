import 'package:flutter/material.dart';

class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              const Text('Coming soon!'),
              TextButton(
                  onPressed: () => throw Exception(),
                  child: Text('Throw test exception')),
            ],
          ),
        ),
      ),
    );
  }
}

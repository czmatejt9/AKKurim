import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:get_storage/get_storage.dart';

class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: const MyStopWatch(),
        ),
      ),
    );
  }
}

class MyStopWatch extends StatefulWidget {
  const MyStopWatch({super.key});

  @override
  State<MyStopWatch> createState() => _MyStopWatchState();
}

class _MyStopWatchState extends State<MyStopWatch> {
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;
  String elapsedTime = '00:00.00';
  List<String> measurements = [];
  Map<String, String> dragged = {'dragged1': '', 'dragged2': ''};

  void startTimer() {
    stopwatch.start();
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (true) {
        setState(() {
          String millis = (stopwatch.elapsed.inMilliseconds % 1000)
              .toString()
              .padLeft(3, '0')
              .substring(0, 2);
          elapsedTime =
              '${stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}.$millis';
        });
      }
    });
  }

  void stopTimer() {
    setState(() {
      stopwatch.stop();
      timer.cancel();
      measurements.add(athleticRound(stopwatch));
    });
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      stopwatch.reset();
      elapsedTime = '00:00.00';
      measurements = [];
      dragged = {'dragged1': '', 'dragged2': ''};
    });
  }

  void takeMeasurement() {
    setState(() {
      measurements.add(athleticRound(stopwatch));
    });
  }

  String athleticRound(Stopwatch stopwatch) {
    // round to 1 decimal place because hand measurements are not that precise (by adding 100ms and then removing the last digits)
    Duration time = stopwatch.elapsed + const Duration(milliseconds: 100);
    String millis =
        (time.inMilliseconds % 1000).toString().padLeft(3, '0').substring(0, 1);
    return '${time.inMinutes.toString().padLeft(2, '0')}:${(time.inSeconds % 60).toString().padLeft(2, '0')}.$millis';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          elapsedTime,
          style: const TextStyle(fontSize: 30),
        ),
        const SizedBox(height: 20),
        Expanded(
            child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                childAspectRatio: 2.2,
                children: [
              ...measurements.map((measurement) => Draggable<String>(
                    data: measurement,
                    feedback: Card(
                      elevation: 10,
                      color: dragged.values.contains(measurement)
                          ? Colors.grey
                          : Colors.green,
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(measurement),
                      )),
                    ),
                    childWhenDragging: Card(
                      elevation: 10,
                      color: Colors.orange,
                      child: Center(child: Text(measurement)),
                    ),
                    child: Card(
                      elevation: 10,
                      color: !dragged.values.contains(measurement)
                          ? Colors.green
                          : Colors.grey,
                      child: Center(child: Text(measurement)),
                    ),
                  )),
            ])),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DragTarget<String>(onAccept: (value) {
              setState(() {
                dragged['dragged1'] = value;
              });
            }, builder: (context, candidates, rejects) {
              return Card(
                elevation: 10,
                color: candidates.isEmpty
                    ? dragged['dragged1'] == ''
                        ? Colors.grey
                        : Colors.green
                    : Colors.orange,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 150, minHeight: 100),
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text(dragged['dragged1'] ?? ''))),
                ),
              );
            }),
            const SizedBox(width: 20),
            DragTarget<String>(onAccept: (value) {
              setState(() {
                dragged['dragged2'] = value;
              });
            }, builder: (context, candidates, rejects) {
              return Card(
                elevation: 10,
                color: candidates.isEmpty
                    ? dragged['dragged2'] == ''
                        ? Colors.grey
                        : Colors.green
                    : Colors.orange,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 150, minHeight: 100),
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text(dragged['dragged2'] ?? ''))),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: IconButton(
                  onPressed: stopwatch.isRunning ? takeMeasurement : resetTimer,
                  icon: stopwatch.isRunning
                      ? const Icon(Icons.add, size: 40)
                      : const Icon(Icons.stop, size: 40)),
            ),
            const SizedBox(width: 20),
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: IconButton(
                onPressed: stopwatch.isRunning ? stopTimer : startTimer,
                icon: stopwatch.isRunning
                    ? const Icon(Icons.pause, size: 40)
                    : const Icon(Icons.play_arrow, size: 40),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

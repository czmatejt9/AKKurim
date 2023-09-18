import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ak_kurim/models/measurement.dart';
import 'package:ak_kurim/models/training.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ak_kurim/services/helpers.dart';

class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = Provider.of<DatabaseService>(context);

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              const Text('Přidat měření k tréninku',
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              for (Training training in db.nextWeekTrainings)
                Card(
                    elevation: 10,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                      title: Text(db.getGroupNameFromID(training.groupID)),
                      subtitle: Text(
                          '${Helper().getCzechDayAndDate(training.timestamp.toDate())} ${training.hourAndMinute}'),
                      trailing: IconButton(
                        onPressed: () {
                          // TODO ask for confirmation and other stuff
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyStopWatch(
                                        measurement:
                                            db.createMeasurementFromTraining(
                                                training,
                                                true,
                                                'Testovací měření',
                                                '60 m'),
                                      )));
                        },
                        icon: Icon(Icons.add,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    )),
            ],
          )),
    );
  }
}

class MyStopWatch extends StatefulWidget {
  final Measurement measurement;
  const MyStopWatch({required this.measurement, super.key});

  @override
  State<MyStopWatch> createState() => _MyStopWatchState();
}

class _MyStopWatchState extends State<MyStopWatch> {
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;
  String elapsedTime = '00:00.00';
  List<String> measurements = [];

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
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Opravdu chcete resetovat stopky?'),
              content: const Text(
                  'Pokud resetujete stopky, nepřiřařezené mezičasy budou ztraceny.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      stopTimer();
                      setState(() {
                        stopwatch.reset();
                        elapsedTime = '00:00.00';
                        measurements = [];
                      });
                    },
                    child: const Text('Resetovat')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Zrušit')),
              ],
            ));
  }

  void takeMeasurement() {
    setState(() {
      measurements.add(athleticRound(stopwatch));
    });
  }

  String athleticRound(Stopwatch stopwatch) {
    // round to 1 decimal place because hand measurements are not that precise (by adding 99ms and then removing the last digits)
    Duration time = stopwatch.elapsed + const Duration(milliseconds: 99);
    String millis =
        (time.inMilliseconds % 1000).toString().padLeft(3, '0').substring(0, 1);
    return '${time.inMinutes.toString().padLeft(2, '0')}:${(time.inSeconds % 60).toString().padLeft(2, '0')}.$millis';
  }

// TODO add saving to db
  @override
  Widget build(BuildContext context) {
    final DatabaseService db = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.measurement.name} - ${widget.measurement.discipline}'),
      ),
      body: Column(
        children: [
          Text(
            elapsedTime,
            style: const TextStyle(fontSize: 30),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 1,
            child: GridView.count(
                crossAxisCount: 2,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  ...measurements.map((measurement) => GestureDetector(
                        onDoubleTap: () {
                          setState(() {
                            measurements.remove(measurement);
                            // do some animation maybe? TODO (maybe), also is this necessary?
                          });
                        },
                        child: Draggable<String>(
                          data: measurement,
                          feedback: Card(
                            elevation: 10,
                            color: widget.measurement.measurements.values
                                    .contains(measurement)
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
                            color: !widget.measurement.measurements.values
                                    .contains(measurement)
                                ? Colors.green
                                : Colors.grey,
                            child: Center(child: Text(measurement)),
                          ),
                        ),
                      )),
                ]),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 3,
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: widget.measurement.measurements.keys.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    elevation: 10,
                    child: ListTile(
                      // add border to the list tile
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                      title: Text(db.getMemberfullNameFromID(widget
                          .measurement.measurements.keys
                          .elementAt(index))),
                      trailing: GestureDetector(
                        onDoubleTap: () {
                          setState(() {
                            widget.measurement.measurements[widget
                                .measurement.measurements.keys
                                .elementAt(index)] = '';
                          });
                        },
                        child: DragTarget<String>(
                          onAccept: (data) {
                            setState(() {
                              widget.measurement.measurements[widget
                                  .measurement.measurements.keys
                                  .elementAt(index)] = data;
                            });
                          },
                          builder: (context, candidateData, rejectedData) =>
                              DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(12),
                            color: Theme.of(context).colorScheme.secondary,
                            strokeWidth: 2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 90,
                                height: 40,
                                color: candidateData.isEmpty
                                    ? Colors.transparent
                                    : Colors.orange,
                                child: Center(
                                  child: Text(
                                    '${widget.measurement.measurements.values.elementAt(index)} ',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: IconButton(
                  onPressed: stopwatch.isRunning ? stopTimer : resetTimer,
                  icon: stopwatch.isRunning
                      ? const Icon(Icons.pause, size: 40)
                      : const Icon(Icons.stop, size: 40),
                ),
              ),
              const SizedBox(width: 20),
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: IconButton(
                    onPressed:
                        stopwatch.isRunning ? takeMeasurement : startTimer,
                    icon: stopwatch.isRunning
                        ? const Icon(Icons.add, size: 40)
                        : const Icon(Icons.play_arrow, size: 40)),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

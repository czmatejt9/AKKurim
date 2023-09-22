import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ak_kurim/models/measurement.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ak_kurim/services/helpers.dart';

class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = Provider.of<DatabaseService>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              const Text('Přidat měření k tréninku',
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              if (db.isUpdating)
                const Center(child: CircularProgressIndicator())
              else if (db.nextWeekTrainings.isEmpty)
                const Center(
                  child:
                      Text('V příštím týdnu nejsou naplánované žádné tréninky'),
                ),
              for (int i = 0; i < db.nextWeekTrainings.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    elevation: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Text(
                              '${db.getGroupNameFromID(db.nextWeekTrainings[i].groupID)} - ${Helper().getCzechDayAndDate(db.nextWeekTrainings[i].timestamp.toDate())}',
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              const Text('Disciplína:',
                                  style: TextStyle(fontSize: 18),
                                  textAlign: TextAlign.center),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(
                                      text: db.measurementsScreenData[
                                          'discipline']![i]),
                                  onChanged: (value) {
                                    db.measurementsScreenData['discipline']![
                                        i] = value;
                                    //db.refresh();
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Název disciplíny',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              const Text('Název:',
                                  style: TextStyle(fontSize: 18),
                                  textAlign: TextAlign.center),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(
                                      text: db
                                          .measurementsScreenData['name']![i]),
                                  onChanged: (value) {
                                    db.measurementsScreenData['name']![i] =
                                        value;
                                    //db.refresh();
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Název měření',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              const Text('Typ:',
                                  style: TextStyle(fontSize: 18),
                                  textAlign: TextAlign.center),
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text('Běh'),
                                  value: true,
                                  groupValue:
                                      db.measurementsScreenData['isRun']![i],
                                  onChanged: (bool? value) {
                                    db.measurementsScreenData['isRun']![i] =
                                        true;
                                    db.refresh();
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text('Technika'),
                                  value: false,
                                  groupValue:
                                      db.measurementsScreenData['isRun']![i],
                                  onChanged: (bool? value) {
                                    db.measurementsScreenData['isRun']![i] =
                                        false;
                                    db.refresh();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              if (db.measurementsScreenData['isRun']![i])
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text('Použít stopky?'),
                                    value: db.measurementsScreenData[
                                        'useStopwatch']![i],
                                    onChanged: (value) {
                                      db.measurementsScreenData[
                                          'useStopwatch']![i] = value!;
                                      db.refresh();
                                    },
                                  ),
                                ),
                              if (!db.measurementsScreenData['isRun']![i])
                                const Spacer(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    foregroundColor: Colors.black),
                                onPressed: () {
                                  if (db.measurementsScreenData['name']![i] ==
                                          '' ||
                                      db.measurementsScreenData['discipline']![
                                              i] ==
                                          '') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Color(0xFFE57373),
                                        content: Text(
                                          'Název a disciplína musí být vyplněny!',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (db.measurementsScreenData[
                                          'useStopwatch']![i] &&
                                      db.measurementsScreenData['isRun']![i]) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyStopWatch(
                                          measurement:
                                              db.createMeasurementFromTraining(
                                            db.nextWeekTrainings[i],
                                            db.measurementsScreenData['isRun']![
                                                i],
                                            db.measurementsScreenData['name']![
                                                i],
                                            db.measurementsScreenData[
                                                'discipline']![i],
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    // TODO create measurement without stopwatch for writing down the results
                                  }
                                },
                                child: const Text('Vytvořit měření'),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              const Divider(),
              Row(
                children: [
                  const Expanded(
                    child: Text('Vytvořit vlastní měření',
                        style: TextStyle(fontSize: 20)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyCustomMeasurement(),
                        ),
                      );
                    },
                    child: const Text('Vytvořit'),
                  ),
                ],
              ),
              const Divider(),
              const Text('Přehled měření', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              for (Measurement measurement in db.measurements)
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade300,
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            width: 1,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            Helper().getDayMonthYear(
                              measurement.createdAt!.toDate(),
                            ),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade500,
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              width: 1,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${measurement.name} - ${measurement.discipline}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShowMeasurement(
                                          measurement: measurement),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.remove_red_eye)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
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
  final bool create = true;
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;
  String elapsedTime = '00:00.00';
  List<String> measurements = [];

  void updateTime() {
    setState(() {
      String millis = (stopwatch.elapsed.inMilliseconds % 1000)
          .toString()
          .padLeft(3, '0')
          .substring(0, 2);
      elapsedTime =
          '${stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}.$millis';
    });
  }

  void startTimer() {
    stopwatch.start();
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      updateTime();
    });
  }

  void stopTimer() {
    setState(() {
      stopwatch.stop();
      timer.cancel();
      measurements.add(athleticRound(stopwatch));

      updateTime();
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

    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Opravdu chcete odejít?'),
                  content: const Text('Pokud odejdete, měření nebude uloženo!'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Odejít')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Zrušit')),
                  ],
                ));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          automaticallyImplyLeading: false,
          title: Text(
              '${widget.measurement.name} - ${widget.measurement.discipline}'),
          actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.black),
                onPressed: () {
                  create
                      ? db.createMeasurement(widget.measurement)
                      : db.updateMeasurement(widget.measurement);
                  Navigator.pop(context);
                  // show snackbar

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF81C784),
                      content: Text(
                        'Měření bylo úspěšně uloženo',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
                child: const Text('Uložit')),
          ],
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
                            width: 2,
                            color: Theme.of(context).colorScheme.secondary,
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
                              color: widget.measurement.measurements.values
                                          .elementAt(index) ==
                                      ''
                                  ? Theme.of(context).colorScheme.outline
                                  : Colors.green,
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class MyCustomMeasurement extends StatelessWidget {
  const MyCustomMeasurement({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// TODO show measurement, maybe edit it
class ShowMeasurement extends StatelessWidget {
  final Measurement measurement;
  const ShowMeasurement({super.key, required this.measurement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${measurement.name} - ${measurement.discipline}'),
        actions: [
          IconButton(
              onPressed: () {
                // TODO edit measurement
              },
              icon: const Icon(Icons.edit)),
        ],
      ),
    );
  }
}

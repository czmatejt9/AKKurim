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

                                  // dissmiss keyboard
                                  FocusScope.of(context).unfocus();
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditMeasurement(
                                          create: true,
                                          measurement:
                                              db.createMeasurementFromTraining(
                                                  db.nextWeekTrainings[i],
                                                  db.measurementsScreenData[
                                                      'isRun']![i],
                                                  db.measurementsScreenData[
                                                      'name']![i],
                                                  db.measurementsScreenData[
                                                      'discipline']![i]),
                                        ),
                                      ),
                                    );
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
              const Text('Přehled proběhlých měření',
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              if (db.measurements.isEmpty)
                const Center(
                  child: Text('Žádná měření nebyla nalezena'),
                ),
              for (Measurement measurement in db.measurements)
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      style: BorderStyle.none,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  elevation: 10,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      // use card color for the background
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          width: 1,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Center(
                          child: Text(
                            Helper().getDayMonthYear(
                                measurement.createdAt!.toDate()),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Center(
                              child: Text(
                                '${measurement.name} - ${measurement.discipline}',
                                style: const TextStyle(fontSize: 18),
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ShowMeasurement(measurement: measurement),
                                ),
                              );
                            },
                            icon: const Icon(Icons.remove_red_eye)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyStopWatch extends StatefulWidget {
  final Measurement measurement;
  final bool create;
  const MyStopWatch({required this.measurement, this.create = true, super.key});

  @override
  State<MyStopWatch> createState() => _MyStopWatchState();
}

class _MyStopWatchState extends State<MyStopWatch> {
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;
  String elapsedTime = '00:00.00';
  List<String> measurements = [];

  void updateTime(Duration elapsed) {
    setState(() {
      String millis = (elapsed.inMilliseconds % 1000)
          .toString()
          .padLeft(3, '0')
          .substring(0, 2);
      elapsedTime =
          '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}.$millis';
    });
  }

  void startTimer() {
    stopwatch.start();
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      updateTime(stopwatch.elapsed);
    });
  }

  void stopTimer() {
    setState(() {
      stopwatch.stop();
      timer.cancel();
      measurements.add(athleticRound(stopwatch));

      Duration elapsed = stopwatch.elapsed + const Duration(milliseconds: 9);
      updateTime(elapsed);
    });
  }

  void resetTimer() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Opravdu chcete resetovat stopky?'),
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
                  widget.create
                      ? db.createMeasurement(widget.measurement)
                      : db.updateMeasurement(widget.measurement);
                  Navigator.pop(context);
                  // show snackbar

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF81C784),
                      content: Text(
                        widget.create
                            ? 'Měření bylo úspěšně vytvořeno'
                            : 'Měření bylo úspěšně upraveno',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
                child: const Text('Uložit')),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: Column(
          children: [
            Text(
              elapsedTime,
              style: const TextStyle(fontSize: 30),
            ),
            const Divider(),
            Expanded(
              flex: 1,
              child: Scrollbar(
                child: GridView.count(
                    // TODO change to listview (only one row)
                    padding: const EdgeInsets.only(bottom: 16),
                    crossAxisCount: 1,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    controller: ScrollController(keepScrollOffset: false),
                    children: [
                      ...measurements.map((measurement) => GestureDetector(
                            onDoubleTap: () {
                              setState(() {
                                measurements.remove(measurement);
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
            ),
            const Divider(),
            Expanded(
              flex: 5,
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
            const Divider(),
            const SizedBox(height: 10),
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

// class for editing measurement or creating new one without stopwatch
class EditMeasurement extends StatelessWidget {
  final bool create;
  final Measurement measurement;
  final double textFieldHeight = 40;
  const EditMeasurement(
      {super.key, required this.create, required this.measurement});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = Provider.of<DatabaseService>(context);
    return Scaffold(
        appBar: AppBar(
          leading: null,
          automaticallyImplyLeading: false,
          title: Text('${measurement.name} - ${measurement.discipline}'),
          actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.black),
                onPressed: () {
                  create
                      ? db.createMeasurement(measurement)
                      : db.updateMeasurement(measurement);
                  Navigator.pop(context);
                  // show snackbar

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF81C784),
                      content: Text(
                        create
                            ? 'Měření bylo úspěšně vytvořeno'
                            : 'Měření bylo úspěšně upraveno',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
                child: const Text('Uložit')),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: measurement.measurements.keys.length,
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
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    title: Text(
                      db.getMemberfullNameFromID(
                          measurement.measurements.keys.elementAt(index)),
                    ),
                    trailing: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: 90, maxHeight: textFieldHeight),
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        color:
                            measurement.measurements.values.elementAt(index) ==
                                    ''
                                ? Theme.of(context).colorScheme.outline
                                : Colors.green,
                        strokeWidth: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 90,
                            height: textFieldHeight,
                            color: Colors.transparent,
                            child: Center(
                              child: TextField(
                                textAlign: TextAlign.center,
                                controller: TextEditingController(
                                    text: measurement.measurements.values
                                        .elementAt(index)
                                        .toString()),
                                onChanged: (value) {
                                  measurement.measurements[measurement
                                      .measurements.keys
                                      .elementAt(index)] = value;
                                  //db.refresh();
                                },
                                decoration: InputDecoration(
                                  hintText: 'Výkon',
                                  border: InputBorder.none,
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  contentPadding: EdgeInsets.only(
                                      bottom: textFieldHeight / 2 -
                                          textFieldHeight / 5.8),
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
        ));
  }
}

class MyCustomMeasurement extends StatelessWidget {
  const MyCustomMeasurement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Vlastní měření'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Bude k dispozici v budoucnu ve verzi 1.6.2"),
        ));
  }
}

class ShowMeasurement extends StatelessWidget {
  final Measurement measurement;
  const ShowMeasurement({super.key, required this.measurement});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${measurement.name} - ${measurement.discipline}'),
        actions: [
          IconButton(
              onPressed: () {
                if (measurement.isRun) {
                  // ask if they want to use stopwatch
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('Otevřít se stopkami?'),
                            content: const Text(
                                'Toto měření můžete otevřít v módu se stopkami nebo bez.'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditMeasurement(
                                          create: false,
                                          measurement: measurement,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Bez stopek')),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyStopWatch(
                                          measurement: measurement,
                                          create: false,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Se stopkami')),
                            ],
                          ));
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMeasurement(
                        create: false,
                        measurement: measurement,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.edit)),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('Opravdu chcete smazat měření?'),
                        content: const Text(
                            'Pokud smažete měření, nebude možné jej obnovit.'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                db.deleteMeasurement(measurement);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                // show snackbar

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Color(0xFFE57373),
                                    content: Text(
                                      'Měření bylo úspěšně smazáno',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Smazat')),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Zrušit')),
                        ],
                      ));
            },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  'Autor: ${db.getTrainerFullNameFromID(measurement.authorId)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Text(
                  'Datum: ${Helper().getDayMonthYear(measurement.createdAt!.toDate())}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text('Výkony:',
                style: TextStyle(fontSize: 20), textAlign: TextAlign.left),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: measurement.measurements.keys.length,
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
                      title: Text(db.getMemberfullNameFromID(
                          measurement.measurements.keys.elementAt(index))),
                      trailing: Text(measurement.measurements.values
                          .elementAt(index)
                          .toString()),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

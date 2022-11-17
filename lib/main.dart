import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:ffi/ffi.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:sprintf/sprintf.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(350, 500);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = title;
    appWindow.show();
  });
}

const title = "シャットダウンタイマー";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const FluentApp(
      debugShowCheckedModeBanner: false,
      title: title,
      home: MyHomePage(title: "$title Home Page"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(height: double.infinity, child: MinimizeWindowButton()),
        SizedBox(height: double.infinity, child: MaximizeWindowButton()),
        SizedBox(height: double.infinity, child: CloseWindowButton()),
      ],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int topIndex = 0;

  IconData toggleButtonIcon = FluentIcons.play_solid;

  bool isPause = false;
  late Timer timer;

  int timerSecond = 10;

  int currentSecond = 10;
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return NavigationView(
      appBar: NavigationAppBar(
          title: const Text(title),
          height: 40,
          automaticallyImplyLeading: false,
          actions: MoveWindow(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [Spacer(), WindowButtons()]),
          )),
      pane: NavigationPane(
        selected: topIndex,
        onChanged: (index) => setState(() => topIndex = index),
        displayMode: PaneDisplayMode.auto,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.alarm_clock),
            title: const Text("シャットダウンタイマー"),
            body: ScaffoldPage.scrollable(
              children: [
                Card(
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          SizedBox(
                              width: 200,
                              height: 200,
                              child: ProgressRing(
                                value: getPercent(timerSecond, currentSecond),
                                strokeWidth: 15,
                              )),
                          Text(
                            covertSecond(currentSecond),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 40),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 30,
                              width: 30,
                              child: FilledButton(
                                  onPressed: toggleTimer,
                                  style: ButtonStyle(
                                      shape: ButtonState.all(
                                          RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ))),
                                  child: Icon(
                                    toggleButtonIcon,
                                    size: 14,
                                    color: Colors.white,
                                  )),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              height: 30,
                              width: 30,
                              child: IconButton(
                                  icon: const Icon(
                                    FluentIcons.reset,
                                    size: 14,
                                  ),
                                  onPressed: !(currentSecond < timerSecond)
                                      ? null
                                      : resetTimer),
                            ),
                          ],
                        ))
                  ]),
                )
              ],
            ),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.update_restore),
            title: const Text("BIOS"),
            body: ScaffoldPage.scrollable(
              children: [
                Card(
                    child: Column(
                  children: [
                    FilledButton(
                      onPressed: goToBIOS,
                      child: const Text("実行"),
                    )
                  ],
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  String covertSecond(int s) {
    double hour = s / 3600;
    double second = s % 3600;
    double minute = second / 60;
    second = second % 60;

    return sprintf("%02.0f:%02.0f:%02.0f", [hour, minute, second]);
  }

  double getPercent(set, current) {
    double percent = current / set * 100;

    return percent;
  }

  void goToBIOS() {}

  void pauseTimer() {
    setState(() {
      toggleButtonIcon = FluentIcons.play_solid;
      isPause = false;

      timer.cancel();
    });
  }

  void reboot() {}

  void resetTimer() {
    setState(() {
      toggleButtonIcon = FluentIcons.play_solid;
      isPause = false;

      timer.cancel();
      currentSecond = timerSecond;
    });
  }

  void shutdown() {}

  void startTimer() {
    toggleButtonIcon = FluentIcons.pause;
    isPause = true;

    timer = Timer.periodic(const Duration(seconds: 1), ((Timer timer) {
      setState(() {
        currentSecond--;
        if (currentSecond < 0) {
          resetTimer();
          Process.run("shutdown.exe", ["/s", "/hybrid", "/t", "0"]);
        }
      });
    }));
  }

  void toggleTimer() {
    if (isPause == false) {
      startTimer();
    } else {
      pauseTimer();
    }
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
}

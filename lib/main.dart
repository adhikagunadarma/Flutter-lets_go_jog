import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/services.dart';

void main() {
  final timerService = TimerService();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(TimerServiceProvider(
      service: timerService,
      child: MyApp(),
    ));
  });
}

class TimerService extends ChangeNotifier {
  Stopwatch _watch;
  Timer _timer;

  Widget flareAnimation = FlareActor("assets/animations/Let's go Jog!.flr",alignment: Alignment.center, fit: BoxFit.contain, animation: "idle");

  String messageLog;

  Duration get currentDuration => _currentDuration;
  Duration _currentDuration = Duration.zero;

  bool firstTime = true;

  TimerService() {
    _watch = Stopwatch();
  }

  void _onTick(Timer timer) {
    _currentDuration =
        new Duration(milliseconds: _watch.elapsed.inMilliseconds);

    if (_currentDuration.inMilliseconds <= 450) {
      this.flareAnimation = FlareActor("assets/animations/Let's go Jog!.flr",alignment: Alignment.center, fit: BoxFit.contain, animation: "start");
    }
    if (_currentDuration.inMilliseconds > 450) {
      this.flareAnimation = FlareActor("assets/animations/Let's go Jog!.flr",alignment: Alignment.center,fit: BoxFit.contain,animation: "jogging");
    }

    notifyListeners();
  }

  void start() {
    if (_timer != null) return;
    this.messageLog = null;
    _currentDuration = Duration.zero;
    firstTime = false;

    _timer = Timer.periodic(Duration(milliseconds: 1), _onTick);
    _watch.start();

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _watch.stop();
    _currentDuration = _watch.elapsed;

    if (currentDuration.inSeconds <= 10) {
      messageLog = "Are you even trying?";
    }
    if (currentDuration.inSeconds > 10) {
      messageLog = "This is getting hot!";
    }
    if (currentDuration.inSeconds > 60) {
      messageLog = "You're a damn freak!!";
    }
    _watch.reset();
    this.flareAnimation = FlareActor("assets/animations/Let's go Jog!.flr",alignment: Alignment.center, fit: BoxFit.contain, animation: "stop");
    notifyListeners();
  }

  static TimerService of(BuildContext context) {
    var provider = context.inheritFromWidgetOfExactType(TimerServiceProvider)
        as TimerServiceProvider;
    return provider.service;
  }
}

class TimerServiceProvider extends InheritedWidget {
  const TimerServiceProvider({Key key, this.service, Widget child})
      : super(key: key, child: child);

  final TimerService service;

  @override
  bool updateShouldNotify(TimerServiceProvider old) => service != old.service;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String status;
  @override
  Widget build(BuildContext context) {
    var timerService = TimerService.of(context);

    return Scaffold(
      persistentFooterButtons: <Widget>[
        Text("Background designed by Katemangostar / Freepik",style: TextStyle(fontSize: 7.0))
      ],
      body: Center(
        child: AnimatedBuilder(
          animation: timerService,
          builder: (context, child) {
            return Container(
              width : MediaQuery.of(context).size.width,
              height : MediaQuery.of(context).size.height,
              decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/background.jpg"),fit: BoxFit.fill)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  timerService.firstTime
                      ? new Container(height: 25.0, child: Text("Hold to start jog!",textScaleFactor: 1.0,style: TextStyle(fontSize: 20.0)))
                      : timerService.messageLog != null
                          ? new Container(height: 25.0, child: Text(timerService.messageLog,textScaleFactor: 1.0,style: TextStyle(fontSize: 20.0)))
                          : new Container(height: 25.0),
                  timerService.currentDuration.inSeconds >= 1
                      ? new Container(height: 25.0,child: Text("Jog time : " +timerService.currentDuration.inSeconds.toString() +" seconds",textScaleFactor: 1.0,style: TextStyle(fontSize: 10.0)))
                      : new Container(height: 25.0),
                  GestureDetector(
                    onLongPress: timerService.start,
                    onLongPressUp: timerService.stop,
                    child: Container(height: MediaQuery.of(context).size.height / 2,width: 100.0,child: timerService.flareAnimation),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


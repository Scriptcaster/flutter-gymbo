import 'package:bench_more/models/day.dart';
import 'package:bench_more/models/exercise.dart';
import 'package:bench_more/models/round.dart';
import 'package:bench_more/models/week.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../db/db_provider.dart';
import '../scopedmodel/program.dart';
import '../gradient_background.dart';
import '../models/hero_id.dart';
import '../models/program.dart';
import '../models/choice_card.dart';
import '../utils/color_utils.dart';
import '../utils/datetime_utils.dart';
import '../utils/subscriber_series.dart';
import '../utils/subscriber_chart.dart';
import '../utils/task_card.dart';
import '../utils/add_category.dart';
import '../page/privacy_policy.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  HeroId _generateHeroIds(Program program) {
    return HeroId(
      codePointId: 'code_point_id_${program.id}',
      progressId: 'progress_id_${program.id}',
      titleId: 'title_id_${program.id}',
      remainingTaskId: 'remaining_program_id_${program.id}',
    );
  }

  String currentDay(BuildContext context) {
    return DateTimeUtils.currentDay;
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  PageController _pageController;
  int _currentPageIndex = 0;

  final List<SubscriberSeries> data = [];

  refreshVolumes() async {
    var getPreviousExerciseVolume = await DBProvider.db.getAllWeeks();
    print(getPreviousExerciseVolume);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
    refreshVolumes();
    print('hey!');
  }


  // @override
  // Widget build(BuildContext context) {
  //   return Expanded(
  //     child: FutureBuilder<List<Week>>(
  //       future: DBProvider.db.getAllWeeks(),
  //       builder: (BuildContext context, AsyncSnapshot<List<Week>> snapshot) {
  //         if (snapshot.hasData) {
  //           return ListView.builder(itemCount: snapshot.data.length, itemBuilder: (BuildContext context, int index) {
  //             print(snapshot.data);
              
  //           });
  //         } else {
  //           return Center(child: CircularProgressIndicator());
  //         }
  //       }
  //     )
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<WeekListModel>(
        builder: (BuildContext context, Widget child, WeekListModel model) {
      var _isLoading = model.isLoading;
      var _programs = model.programs;
      var _weeks = model.weeks;
      var backgroundColor =
          _programs.isEmpty || _programs.length == _currentPageIndex
              ? Colors.blueGrey
              : ColorUtils.getColorFrom(id: _programs[_currentPageIndex].color);

      _programs.forEach((element) {
        // print(element.toJson());
      });
      var _db = DBProvider.db;
      List<Round> _myweeks = [];
      // List<Day> get days => _days.toList();

      void loadTodos() async {
        _myweeks = await _db.getAllRoundsAll();
        // print(_myweeks.length);
        _myweeks.forEach((element) {
          print(element.weight);
        });
      }

      loadTodos();

      if (!_isLoading) {
        // move the animation value towards upperbound only when loading is complete
        _controller.forward();
      }
      return GradientBackground(
        color: backgroundColor,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(widget.title),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            actions: [
              PopupMenuButton<Choice>(
                onSelected: (choice) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          PrivacyPolicyScreen()));
                },
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 1.0,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : FadeTransition(
                  opacity: _animation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          // height: 16.0,

                          child: SubscriberChart(
                        // data: data,

                        data: [
                          SubscriberSeries(
                            year: 'NOV',
                            subscribers: _weeks.length,
                            barColor:
                                charts.ColorUtil.fromDartColor(Colors.blue),
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
        ),
      );
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

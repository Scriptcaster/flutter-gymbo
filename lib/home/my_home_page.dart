import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../db/db_provider.dart';
import '../scopedmodel/program.dart';
import '../gradient_background.dart';
import '../models/hero_id.dart';
import '../models/program.dart';
import '../models/exercise.dart';
import '../models/choice_card.dart';
import '../utils/color_utils.dart';
import '../utils/datetime_utils.dart';
import 'subscriber_series.dart';
import 'subscriber_chart.dart';
import 'task_card.dart';
import 'add_category.dart';
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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  PageController _pageController;
  int _currentPageIndex = 0;
  var _db = DBProvider.db;
  List<SubscriberSeries> data = [];

  refreshVolumes() async {
    var getPreviousExerciseVolume = await DBProvider.db.getAllWeeks();
    print(getPreviousExerciseVolume);
  }

  void loadChart() async {
    data = await _db.getChartData();
  }

  // void uodateChart() {
  //   data = model.exercises();
  // }

  @override
  void initState() {
    super.initState();
    loadChart();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
    refreshVolumes();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<WeekListModel>(builder: (BuildContext context, Widget child, WeekListModel model) {
      var _isLoading = model.isLoading;
      var _programs = model.programs;
      var _weeks = model.weeks;
      // var _exercises = model.exercises;
      var newData = model.getChart();
      // print(newData);
      var backgroundColor = _programs.isEmpty || _programs.length == _currentPageIndex? Colors.blueGrey : ColorUtils.getColorFrom(id: _programs[_currentPageIndex].color);
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
                  builder: (BuildContext context) => PrivacyPolicyScreen()));
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
                        margin: EdgeInsets.only(top: 0.0, left: 30.0, right: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // ShadowImage(),
                            Container(
                              // margin: EdgeInsets.only(top: 22.0),
                              child: Text(
                                '${widget.currentDay(context)}',
                                style: Theme.of(context).textTheme.headline.copyWith(color: Colors.white),
                              ),
                            ),
                            Text('${DateTimeUtils.currentDate} ${DateTimeUtils.currentMonth}', style: Theme.of(context).textTheme.title.copyWith(color: Colors.white.withOpacity(0.7))),
                            Container(height: 16.0),
                            Text('You have ${_weeks.where((week) => week.isCompleted == 0).length} programs to complete', style: Theme.of(context).textTheme.body1.copyWith(color: Colors.white.withOpacity(0.7))),
                            Container(

                      


                              child: SubscriberChart(data: newData)







                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        key: _backdropKey,
                        flex: 1,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification is ScrollEndNotification) {
                              print("ScrollNotification = ${_pageController.page}");
                              var currentPage = _pageController.page.round().toInt();
                              if (_currentPageIndex != currentPage) {
                                setState(() => _currentPageIndex = currentPage);
                              }
                            }
                          },
                          child: PageView.builder(
                            controller: _pageController,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == _programs.length) {
                                return AddPageCard(
                                  color: Colors.blueGrey,
                                );
                              } else {
                                return TaskCard(
                                  backdropKey: _backdropKey,
                                  color: ColorUtils.getColorFrom(
                                  id: _programs[index].color),
                                  getHeroIds: widget._generateHeroIds,
                                  getTaskCompletionPercent: model.getTaskCompletionPercent,
                                  getTotalTodos: model.getTotalTodosFrom,
                                  program: _programs[index],
                                );
                              }
                            },
                            itemCount: _programs.length + 1,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 32.0),
                      ),
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

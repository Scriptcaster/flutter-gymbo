import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scopedmodel/week_list_model.dart';
import '../task_progress_indicator.dart';
import '../component/week_badge.dart';
import '../models/hero_id_model.dart';
import '../models/program_model.dart';
import '../utils/color_utils.dart';
import '../page/program_add.dart';
import '../page/program_edit.dart';

import 'week.dart';
import '../db/db_provider.dart';
import '../models/week_model.dart';

class DetailScreen extends StatefulWidget {
  final String taskId;
  final HeroId heroIds;

  DetailScreen({
    @required this.taskId,
    @required this.heroIds,
  });

  @override
  State<StatefulWidget> createState() {
    return _DetailScreenState();
  }
}

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _animation;
  TextEditingController _weekNameController = TextEditingController();
  var previousWeekId;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween<Offset>(begin: Offset(0, 1.0), end: Offset(0.0, 0.0)).animate(_controller);
  }

  // getContainer(bool isCompleted, {Widget child}) {
  //   if (isCompleted) {
  //     return Container(
  //       padding: EdgeInsets.only(left: 22.0, right: 22.0),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.centerLeft,
  //           end: Alignment.centerRight,
  //           stops: [0.4, 0.6, 1],
  //           colors: <Color>[
  //             Colors.grey.shade100,
  //             Colors.grey.shade50,
  //             Colors.white,
  //           ],
  //         ),
  //       ),
  //       child: child,
  //     );
  //   } else {
  //     return Container(
  //       padding: EdgeInsets.only(left: 22.0, right: 22.0),
  //       child: child,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return ScopedModelDescendant<WeekListModel>(
      builder: (BuildContext context, Widget child, WeekListModel model) {
        Program _program;
        try {
         _program = model.programs.firstWhere((week) => week.id == widget.taskId);
        } catch (e) {
          return Container(
            color: Colors.white,
          );
        }
        var _weeks = model.weeks.where((week) => week.program == widget.taskId).toList();
        var _hero = widget.heroIds;
        var _color = ColorUtils.getColorFrom(id: _program.color);
        var _icon = IconData(_program.codePoint, fontFamily: 'MaterialIcons');
        return Theme(
          data: ThemeData(primarySwatch: _color),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black26),
              brightness: Brightness.light,
              backgroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(Icons.edit),
                  color: _color,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTaskScreen(
                          taskId: _program.id,
                          taskName: _program.name,
                          icon: _icon,
                          color: _color,
                        ),
                      ),
                    );
                  },
                ),
                SimpleAlertDialog(
                  color: _color,
                  onActionPressed: () => model.removeProgram(_program),
                ),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
              child: Column(children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 36.0, vertical: 0.0),
                  height: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TodoBadge(
                        color: _color,
                        codePoint: _program.codePoint,
                        id: _hero.codePointId,
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 4.0),
                        child: Hero(
                          tag: _hero.remainingTaskId,
                          child: Text(
                            "${model.getTotalTodosFrom(_program)} Weeks",
                            style: Theme.of(context)
                              .textTheme
                              .body1
                              .copyWith(color: Colors.grey[500]),
                          ),
                        ),
                      ),
                      Container(
                        child: Hero(
                          tag: 'title_hero_unused',//_hero.titleId,
                          child: Text(_program.name,
                              style: Theme.of(context)
                                .textTheme
                                .title
                                .copyWith(color: Colors.black54)),
                        ),
                      ),
                      Spacer(),
                      Hero(
                        tag: _hero.progressId,
                        child: TaskProgressIndicator(
                          color: _color,
                          progress: model.getTaskCompletionPercent(_program),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        _weeks.sort((a, b) => b.seq.compareTo(a.seq));
                        if (index == _weeks.length) { return SizedBox(height: 56); }
                        var week = _weeks[index];
                        previousWeekId = week.id;
                        return Dismissible(
                          key: UniqueKey(),
                          background: Container(color: Colors.red),
                          confirmDismiss: (DismissDirection direction) async {
                          final bool res = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: const Text("Are you sure you wish to delete this item?"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: const Text("DELETE"),
                                    onPressed: () {
                                      model.removeWeek(week);
                                      Navigator.of(context).pop(true);
                                    }
                                  ),
                                  FlatButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("CANCEL"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: ListTile(
                          onTap: () {
                            print(week.id);
                            print(week.name);
                            print(_program.id);
                            Navigator.push(context,
                              MaterialPageRoute(
                                builder: (context) => WeekLocal(id: week.id, name: week.name, programId: _program.id ),
                              ),
                            );
                          },
                          // onTap: () => model.updateTodo(week.copy(
                          //     isCompleted: week.isCompleted == 1 ? 0 : 1)),
                          // contentPadding: EdgeInsets.symmetric(
                          //     horizontal: 0, vertical: 8.0),
                          // leading: Checkbox(
                          //     onChanged: (value) => model.updateTodo(
                          //         week.copy(isCompleted: value ? 1 : 0)),
                          //     value: week.isCompleted == 1 ? true : false),
                          // trailing: IconButton(
                          //   icon: Icon(Icons.delete_outline),
                          //   onPressed: () => model.removeTodo(week),
                          // ),
                          trailing: Text(week.seq.toString()),
                            title: Text(
                              week.name,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                // color: week.isCompleted == 1
                                //     ? _color
                                //     : Colors.black54,
                                // decoration: week.isCompleted == 1
                                //     ? TextDecoration.lineThrough
                                //     : TextDecoration.none,
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: _weeks.length + 1,
                    ),
                  ),
                ),
              ]),
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'fab_new_program',
              onPressed: () {
                 showDialog(context: context, builder: (BuildContext context) {
                  _weekNameController.text = "Week ${model.getTotalTodosFrom(_program) + 1}";
                  return AlertDialog(
                    title: Text("New Week"),
                    content: TextField(
                      style: new TextStyle(fontSize: 20.0, color: Colors.blue),
                      keyboardType: TextInputType.text,
                      controller: _weekNameController,
                      onSubmitted: (value) {
                        _weekNameController.text = value;
                      }
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text("Save"),
                         onPressed: () {
                          if (_weekNameController.text.isEmpty) {
                            final snackBar = SnackBar(
                              content: Text('Ummm... It seems that you are trying to add an invisible program which is not allowed in this realm.'),
                              backgroundColor: _color,
                            );
                            Scaffold.of(context).showSnackBar(snackBar);
                            // _scaffoldKey.currentState.showSnackBar(snackBar);
                          } else {
                            model.addWeek(previousWeekId, _program.id,  Week(
                              _weekNameController.text, 
                              program: _program.id, 
                              // seq: model.weeks.last.seq + 1,
                            ));
                            Navigator.pop(context);
                          }
                        },
                      )
                    ],
                  );
                });
                // Navigator.push(context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //       AddTodoScreen(taskId: widget.taskId, heroIds: _hero),
                //   ),
                // );
              },
              tooltip: 'New Week',
              backgroundColor: _color,
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

typedef void Callback();

class SimpleAlertDialog extends StatelessWidget {
  final Color color;
  final Callback onActionPressed;

  SimpleAlertDialog({
    @required this.color,
    @required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: color,
      icon: Icon(Icons.delete),
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete this card?'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'This is a one way street! Deleting this will remove all the program assigned in this card.'),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Delete'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onActionPressed();
                  },
                ),
                FlatButton(
                  child: Text('Cancel'),
                  textColor: Colors.grey,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

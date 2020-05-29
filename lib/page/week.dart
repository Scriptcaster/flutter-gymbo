import 'package:bench_more/component/week_badge.dart';
import 'package:bench_more/models/week.dart';
import 'package:bench_more/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/day.dart';
import '../db/db_provider.dart';
import 'day.dart';

import '../models/hero_id.dart';

import '../task_progress_indicator.dart';

class WeekLocal extends StatefulWidget {
  WeekLocal({ this.id, this.name, this.date, this.programId, this.taskId, this.heroIds, this.color });
  final String id;
  final String name;
  final int date;
  final String programId;

  final String taskId;
  final HeroId heroIds;
  final Color color;


  // var _color = ColorUtils.getColorFrom(id: _program.color);
   
  @override
  _WeekLocalState createState() => _WeekLocalState();
}

class _WeekLocalState extends State<WeekLocal> {
  TextEditingController _newNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black26),
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        // title: Text(widget.name, style: new TextStyle(fontSize: 20.0, color: Colors.blue)),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.add),
        //     onPressed: () {
        //       showDialog(context: context, builder: (BuildContext context) {
        //         return AlertDialog(
        //           title: Text("New Day"),
        //           content: TextField(
        //             style: new TextStyle(fontSize: 20.0, color: Colors.blue),
        //             keyboardType: TextInputType.text,
        //             controller: _newNameController,
        //             onSubmitted: (value) => _newNameController.text = value,  
        //           ),
        //           actions: <Widget>[
        //             FlatButton(child: Text("Close"),
        //               onPressed: () => Navigator.of(context).pop(),
        //             ),
        //             FlatButton(child: Text("Save"),
        //               onPressed: () async {
        //                 await DBProvider.db.addDay( Day( dayName: _newNameController.text, target: 'Target', weekId: widget.id, programId: widget.programId ));
        //                 setState(() {});
        //                 Navigator.of(context).pop();
        //                 _newNameController.clear();
        //               },
        //             )
        //           ],
        //         );
        //       });
        //     },
        //   )
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
        child: Column(children: [
          Container(margin: EdgeInsets.symmetric(horizontal: 36.0, vertical: 0.0), height: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // TodoBadge(color: _color, codePoint: _program.codePoint, id: _hero.codePointId),
                Spacer(flex: 1),
                Container(margin: EdgeInsets.only(bottom: 4.0),
                  // child: Hero(tag: _hero.remainingTaskId,
                    child: Text(DateFormat('MMM d').format(DateTime.fromMillisecondsSinceEpoch(widget.date)).toString()
                      // "${model.getTotalTodosFrom(_program)} Weeks",
                      // style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[500]),
                    ),
                  // ),
                ),
                Container(          
                  child: Text(
                    widget.name, style: Theme.of(context).textTheme.title.copyWith(color: Colors.black54)
                  ),
                ),
                Spacer(),
                Hero(tag: widget.heroIds.progressId,
                  child: TaskProgressIndicator(
                    color: widget.color,
                    progress: 54,
                  ),
                )
              ]
            )
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: FutureBuilder<List<Day>>(
                future: DBProvider.db.getAllDays(widget.id),
                builder: (BuildContext context, AsyncSnapshot<List<Day>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(itemCount: snapshot.data.length, itemBuilder: (BuildContext context, int index) {
                      Day day = snapshot.data[index];
                      return Dismissible(
                        key: UniqueKey(),
                        background: Container(color: Colors.red),
                        onDismissed: (direction) => DBProvider.db.removeDay(day), 
                        child: ListTile(
                          leading: Checkbox(
                            onChanged: (value) {
                              setState(() {
                                DBProvider.db.updateDay( day.copy(isCompleted: value ? 1 : 0) );
                              });
                            },
                            value: day.isCompleted == 1 ? true : false
                          ),
                          title: Text(day.dayName.toString()),
                          subtitle: Text(day.target.toString()),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () async {
                            setState(() {});
                            await Navigator.push( context, MaterialPageRoute(
                              builder: (context) => DayLocal(id: day.id, dayName: day.dayName, target: day.target, weekId: day.weekId, programId: day.programId),
                            ));
                          }
                        )
                      );
                    });
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }
              )
            )
          )
        ])
      )
    );
  }
}
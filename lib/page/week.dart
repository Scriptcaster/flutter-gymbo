import 'package:bench_more/models/week.dart';
import 'package:flutter/material.dart';
import '../models/day.dart';
import '../db/db_provider.dart';
import 'day.dart';

class WeekLocal extends StatefulWidget {
  WeekLocal({ this.id, this.name, this.programId });
  final String id;
  final String name;
  final String programId;
  @override
  _WeekLocalState createState() => _WeekLocalState();
}

class _WeekLocalState extends State<WeekLocal> {
  TextEditingController _newNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(context: context, builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("New Day"),
                  content: TextField(
                    style: new TextStyle(fontSize: 20.0, color: Colors.blue),
                    keyboardType: TextInputType.text,
                    controller: _newNameController,
                    onSubmitted: (value) => _newNameController.text = value,  
                  ),
                  actions: <Widget>[
                    FlatButton(child: Text("Close"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    FlatButton(child: Text("Save"),
                      onPressed: () async {
                        await DBProvider.db.addDay( Day( dayName: _newNameController.text, target: 'Target', weekId: widget.id, programId: widget.programId ));
                        setState(() {});
                        Navigator.of(context).pop();
                        _newNameController.clear();
                      },
                    )
                  ],
                );
              });
            },
          )
        ],
      ),
      body: FutureBuilder<List<Day>>(
        future: DBProvider.db.getAllDays(widget.id),
        builder: (BuildContext context, AsyncSnapshot<List<Day>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(itemCount: snapshot.data.length, itemBuilder: (BuildContext context, int index) {
              Day day = snapshot.data[index];
              print('FutureBuilder');
              return Dismissible(
                key: UniqueKey(),
                background: Container(color: Colors.red),
                onDismissed: (direction) => DBProvider.db.removeDay(day), 
                child: ListTile(
                  // leading: Text(day.id.toString()),
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
                  // trailing: Text(item.weekId.toString()),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () async {
                    setState(() {});
                    await Navigator.push( context, MaterialPageRoute(
                      builder: (context) => DayLocal(id: day.id, dayName: day.dayName, target: day.target, weekId: day.weekId, programId: day.programId),
                    ));
                   
                  },
                ),
              );
            });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
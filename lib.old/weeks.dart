import 'package:flutter/material.dart';
import 'models/day.dart';
import 'services/database.dart';
import 'days.dart';

class WeekLocal extends StatefulWidget {
  WeekLocal({ this.id });
  final int id;
  @override
  _WeekLocalState createState() => _WeekLocalState();
}

class _WeekLocalState extends State<WeekLocal> {
  TextEditingController _newNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( 'Week ' + widget.id.toString()),
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
                    onSubmitted: (value) {
                      _newNameController.text = value;
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
                      onPressed: () async {
                        await DBProvider.db.newDay( Day( dayName: _newNameController.text, target: 'Target', weekId: widget.id ));
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
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Day item = snapshot.data[index];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    DBProvider.db.deleteDay(item.id);
                  },
                  child: ListTile(
                    leading: Text(item.id.toString()),
                    title: Text(item.dayName.toString()),
                    subtitle: Text(item.target.toString()),
                    trailing: Text(item.weekId.toString()),
                     onTap: () async {
                      await Navigator.push( context, MaterialPageRoute(
                        builder: (context) => DayLocal(id: item.id, dayName: item.dayName, target: item.target, weekId: item.weekId),
                      ));
                      setState(() {});
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
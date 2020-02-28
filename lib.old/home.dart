import 'dart:convert';
import 'package:flutter/material.dart';
import 'services/database.dart';
import 'models/week.dart';
import 'weeks.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key); //update this to include the uid in the constructor
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController taskTitleInputController;
  TextEditingController taskDescripInputController;
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: Padding(
        //   padding: EdgeInsets.only(left: 0),
        //   child: IconButton(
        //     icon: Icon(Icons.clear),
        //     // onPressed: () {
        //     //   FirebaseAuth.instance.signOut().then((result) => Navigator.pushReplacementNamed(context, "/login")).catchError((err) => print(err));
        //     // },
        //   ),
        // ),
        title: Text('Weeks'),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.add),
        //     // onPressed: () async {
        //     // },
        //   )
        // ],
      ),

     body: 
      FutureBuilder<List<Week>>(
        future: DBProvider.db.getAllWeeks(),
        builder: (BuildContext context, AsyncSnapshot<List<Week>> snapshot) {
          if (snapshot.hasData) {

            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Week item = snapshot.data[index];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    DBProvider.db.deleteWeek(item.id);
                  },
                  child: ListTile(
                    title: Text(item.name.toString()),
                    // leading: Text(item.id.toString()),
                    trailing: Text(item.id.toString()),
                    onTap: () async {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeekLocal(id: item.id),
                        ),
                      );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await DBProvider.db.newWeek( Week( name: "Week" ),);
          setState(() {});
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
  
}
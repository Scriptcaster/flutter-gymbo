import 'package:flutter/material.dart';
import '../db/db_provider.dart';
import '../models/exercise.dart';
import '../models/round.dart';

class RenderRounds extends StatefulWidget {
  final Object id;
  final Exercise exercise;
  final VoidCallback parentUpdater;
  RenderRounds(this.id, this.exercise, {this.parentUpdater});
  @override
  _RenderRoundsState createState() => _RenderRoundsState(
    this.parentUpdater
  );
}
class _RenderRoundsState extends State<RenderRounds> { _RenderRoundsState( this.parentUpdater );
  List<Color> colors = [Colors.blue, Colors.white, Colors.white];
  List<bool> _selected = [true, false, false];
  final VoidCallback parentUpdater;
  _updateCurrentVolume(_round, subtract) async {
    setState(() {
      if (subtract) {
        if (_selected[0]) {
        _round.weight -= 5;
        } else if (_selected[1]) {
          _round.round -= 1;
        } else if(_selected[2]) {
          _round.rep -= 1;
        }
      } else {
         if (_selected[0]) {
        _round.weight += 5;
        } else if (_selected[1]) {
          _round.round += 1;
        } else if(_selected[2]) {
          _round.rep += 1;
        }
      }
      widget.exercise.currentVolume = 0;
      widget.exercise.round.forEach((i) {
        widget.exercise.currentVolume += i.weight*i.round*i.rep;
      });
    });
    // await DBProvider.db.updateRound(Round(id: _round.id, weight: _round.weight, round: _round.round, rep: _round.rep, exerciseId: widget.exercise.dayId));
    // await DBProvider.db.updateExercise(Exercise( id: widget.exercise.id, name: widget.exercise.name, bestVolume: widget.exercise.bestVolume, previousVolume: widget.exercise.previousVolume, currentVolume: widget.exercise.currentVolume, dayId: widget.id ));
    widget.parentUpdater();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
    children: widget.exercise.round.map((_round) => 
      Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Row(
          children: <Widget>[
              Expanded(
                child: new SizedBox(height: 18.0, width: 24.0,
                  child: new IconButton(
                    padding: new EdgeInsets.all(0.0),
                    icon: new Icon(Icons.remove, size: 18.0),
                    onPressed: () {
                      _updateCurrentVolume(_round, true);
                    }
                  )
                ),
              ),
              FlatButton(color: colors[0],
                onPressed: () async {
                  _selected = [false, false, false];
                  setState(() {
                    colors = [Colors.white, Colors.white, Colors.white];
                    colors[0] = Colors.blue;
                    _selected[0] = true;
                  });
                },
                child: Text(_round.weight.toString())
              ),
              FlatButton(color: colors[1],
              onPressed: () {
                _selected = [false, false, false];
                setState(() {
                  colors = [Colors.white, Colors.white, Colors.white];
                  colors[1] = Colors.blue;
                  _selected[1] = true;
                });
              },
              child: Text(_round.round.toString())),
              FlatButton(color: colors[2],
                onPressed: () {
                  _selected = [false, false, false];
                  setState(() {
                    colors = [Colors.white, Colors.white, Colors.white];
                    colors[2] = Colors.blue;
                    _selected[2] = true;
                  });
                },
                child: Text(_round.rep.toString())
              ),
              Expanded(
                child: new SizedBox(height: 18.0, width: 24.0,
                  child: new IconButton(
                    padding: new EdgeInsets.all(0.0),
                    icon: new Icon(Icons.add, size: 18.0),
                    onPressed: () {    
                      _updateCurrentVolume(_round, false);
                    }
                  )
                )
              )
            ]
          )
        )
      ).toList()
    );          
  }  
}
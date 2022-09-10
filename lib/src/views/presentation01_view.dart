import 'package:flutter/material.dart';
  import 'package:jaipi/src/views/presentation02_view.dart';

import 'home_view.dart';

class Presentation01View extends StatelessWidget {
  static const routeName = 'presentation01';

  const Presentation01View({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            child: _Image(),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 50),
            child: Text("Disfruta de unos \nricos tacos", 
            style: TextStyle(
              color: Color.fromARGB(255, 4, 64, 167),
              fontSize: 18,
            ), 
            textAlign: TextAlign.center,
            ),
          ),
          Container(
            height: 10,
            child: Image(image: AssetImage('assets/images/presentation_progress_bar_01.PNG'), 
            alignment: Alignment.center,
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Container(
                child: RaisedButton(
                  textColor: Colors.white,
                  child: Text('Siguiente'),
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 90),
                  color: Color.fromARGB(255, 5, 58, 150),
                  onPressed: (){
                    Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context)=>Presentation02View())
                    );
                  }
                ),
              )
              ],
            ),
          ),
          Container(
            child: Column(
              children: [Container(
                child: FlatButton(
                  textColor: Color.fromARGB(255, 5, 58, 150),
                  child: Text("Saltar"),
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 90),              
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=>HomeView())
                    );
                  },
                ),
              )],
            ),
          )
        ],
      )
    );
  }
}

_Image(){
  return Padding(
    padding: const EdgeInsets.all(0.5),
    child: Container(
      height: 370.0,
      width: 300.0,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(150.0),
          bottomRight: Radius.circular(150.0)
        ),
        boxShadow: [BoxShadow(
          color: Colors.grey[850].withOpacity(0.29),
          offset: const Offset(-10.0, 10.0),
          blurRadius: 10.0,
          spreadRadius: 10.0
        )],
        image: const DecorationImage(
          image: AssetImage('assets/images/tacos.jpg'),
          fit: BoxFit.cover
        )
      ),
    ),
  );
}

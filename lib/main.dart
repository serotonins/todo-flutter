import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'I dont wanna do 한글도 써주나요'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool? _checkBoxValue1 = false;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }

  // void _addtodo() {
  //
  // }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times gg: ',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  activeColor: Colors.deepPurple[50], // 체크됐을 때 체크박스의 컬러
                  checkColor: Colors.blue, // 체크표시의 컬러
                  value: _checkBoxValue1, // 체크박스의 값
                  onChanged: (value) {
                    setState(() {
                      _checkBoxValue1 = value;
                    });
                  },
                ),
                // TextField(
                //   style: TextStyle(fontSize: 32, color: Colors.red),
                //   textAlign: TextAlign.center,
                //   decoration: InputDecoration(hintText: '입력 오네가이'),
                //   onChanged: (String todotext) {
                //     setState(() {
                //
                //     });
                //   },
                // )
              ]
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

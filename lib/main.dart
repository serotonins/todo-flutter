import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '일정을 정리해 봅시다.'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class TodoType {
  bool isDone = false; // 완료했는지
  String title; // 할일 이름

  TodoType(this.title);
}

class _MyHomePageState extends State<MyHomePage> {
  bool? _checkBoxValue1 = false;
  var _cTodo = '시작일 순';
  final _todoListItem = <TodoType>[];
  var _todoController = TextEditingController(); // 입력받은 투두 문자열을 조작하는 컨트롤러래

  void _addTodo(TodoType todo) {
    setState(() {
      _todoListItem.add(todo);
      _todoController.text = '';
    });
  }
  
  void _deleteTodo(TodoType todo) {
    setState(() {
      _todoListItem.remove(todo);
    });
  }
  
  void _donecheckTodo(TodoType todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _changetodo(bool ma) {
    setState(() {
      if (ma == true) {_cTodo = '마감일 순';}
      else {_cTodo = '시작일 순';};
    });
  }

  @override
  void dispose() {
    _todoController.dispose(); // 컨트롤러 종료시 해제해주는 코드래
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView(
                children: _todoListItem.map((todo) => _buildTodoListWidget(todo)).toList(),
              )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  activeColor: Colors.indigo, // 활성화 시 Thumb(콩알) 컬러
                  activeTrackColor: Colors.blueAccent[100], // 활성화 시 스위치 바탕 컬러
                  inactiveThumbColor: Colors.green, // 비활성화 시 콩알 컬러
                  inactiveTrackColor: Colors.white, // 비활성화 시 스위치 바탕색
                  // trackColor: MaterialStateProperty.all(Colors.yellow), // 활성화건 비활성화건 무조건 스위치 바탕색은 이것(바뀌게 하고 싶으면 쓰지마)
                  // thumbColor: MaterialStateProperty.all(Colors.green), // 활성화했건 비활성화했건 무조건 Thumb 컬러는 이것(바뀌게 하고 싶으면 쓰지마)
                  value: _checkBoxValue1!, // 스위치 값
                  onChanged: (value) {
                    setState(() {
                      _checkBoxValue1 = value;
                      _changetodo(value!);
                    });
                  },
                ),
                Text(
                  _cTodo,
                )
              ]
            )
          ],
        ),
      ),
      floatingActionButton: multipleFloatingButton(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget? multipleFloatingButton() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      visible: true,
      curve: Curves.bounceIn,
      // shape: CircleBorder(),
      backgroundColor: Colors.indigo[100],
      children: [
        SpeedDialChild(
          child: const Icon(Icons.settings_sharp, color: Colors.indigo,),
          shape: CircleBorder(),
          backgroundColor: Colors.indigo[100],
          label: "설정",
          labelBackgroundColor: Colors.indigo[50],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
            fontSize: 13.0
          ),
          onTap: () {}
        ),
        SpeedDialChild(
          child: const Icon(Icons.add, color: Colors.indigo,),
          shape: CircleBorder(),
          backgroundColor: Colors.indigo[100],
          label: "할 일 추가",
          labelBackgroundColor: Colors.indigo[50],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
            fontSize: 13.0
          ),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("할 일이... 또 생겼니..? 힘내라...", style: TextStyle(fontSize: 15),),
                    content: TextField(
                      controller: _todoController,
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          _addTodo(TodoType(_todoController.text));
                          Navigator.pop(context);
                        },
                        child: Text('추가', style: TextStyle(color: Colors.indigo),),
                      )
                    ],
                  );
                }
            );
          },
        )
      ],
    );
  }

  Widget _buildTodoListWidget(TodoType todo) {
    return ListTile(
      onTap: () => _donecheckTodo(todo),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => _deleteTodo(todo),
      ),
      title:
        Row(
          children: [
            Checkbox(
              activeColor: Colors.black45,
              checkColor: Colors.white,
              value: todo.isDone,
              onChanged: (value) {
                setState(() {
                  todo.isDone = value!;
                });
              }
            ),
            Text(
              todo.title,
              style: todo.isDone?
                  TextStyle(
                    decoration: TextDecoration.lineThrough,
                    fontStyle: FontStyle.italic,
                  ) : null, // 완료 전이면 취소선 안 긋고 아무 짓 안 한다는 표시
            )
          ]
        )
    );
  }
}

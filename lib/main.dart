import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';
// import 'screen/addTodoScreen.dart';

// 필요 1
void main() {
  runApp(const MyApp());
}

// 필요 2
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

// 필요 3
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class TodoType {
  bool isDone = false; // 완료했는지
  String title; // 할일 이름
  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now();

  TodoType(this.title, this.startDate, this.endDate);
}

class _MyHomePageState extends State<MyHomePage> {
  bool? _checkBoxValue1 = false;
  var _cTodo = '시작일 순';
  final _todoListItem = <TodoType>[];
  var _todoController = TextEditingController(); // 입력받은 투두 문자열을 조작하는 컨트롤러래
  var _dateTimeEditingController = TextEditingController(); // 날짜 받아오는 컨트롤러도 하나 만들어줌
  DateTime _selectedDate = DateTime.now();

  void _addTodo(TodoType todo) { // 리스트에 투두 아이템 하나 추가
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

  void _editTodo(TodoType todo, TodoType changed) {
    setState(() {
      todo.title = changed.title;
      todo.startDate = changed.startDate;
      todo.endDate = changed.endDate;

      _todoController.text = '';
    });
  }

  void _donecheckTodo(TodoType todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  void _changetodo(bool ma) {
    setState(() {
      if (ma == true) {_cTodo = '마감일 기준';}
      else {_cTodo = '시작일 기준';};
    });
  }

  // 날짜, 시간 연달아 선택해서 _selectedDate에 넣어주는 함수
  Future jdatePicker(jdate) async {
    _selectedDate = jdate;

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: jdate,
      firstDate: jdate,
      lastDate: DateTime(2999),
    );
    if (picked != null) { setState(() {
      _selectedDate = picked;
    });}

    TimeOfDay? tpicked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (tpicked != null && _selectedDate != null) {
      setState(() {
        _selectedDate = _selectedDate.add(Duration(hours: tpicked.hour, minutes: tpicked.minute));
      });
    }
  }

  // todo 추가하는 alert dialog
  Future<dynamic> showStatefulDialogBuilder(BuildContext context) async {
    DateTime _startDate = DateTime.now();
    DateTime _endDate = DateTime.now();

    await showDialog<void>(
        context: context,
        builder: (_) {
          return AlertDialog(
              title: Text("할 일이 또 있나요?", style: TextStyle(fontSize: 15),),
              content: StatefulBuilder(
                  builder: (__, StateSetter setState) {
                    return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _todoController,
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await jdatePicker(DateTime.now());
                                  setState(() {
                                    _startDate = _selectedDate;
                                    _endDate = _startDate;
                                  });
                                },
                                child: Text(DateFormat('yyyy/MM/dd HH:mm').format(_startDate)),
                              ),
                              Text(" 부터  "),
                              TextButton(
                                onPressed: () async {
                                  await jdatePicker(_startDate);
                                  setState(() {
                                    _endDate = _selectedDate;
                                  });
                                },
                                child: Text(DateFormat('yyyy/MM/dd HH:mm').format(_endDate)),
                              ),
                              Text(" 까지"),
                            ],
                          )
                        ]
                    );
                  }
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    _addTodo(TodoType(_todoController.text, _startDate, _endDate));
                    Navigator.pop(context);
                  },
                  child: Text('추가', style: TextStyle(color: Colors.indigo),),
                )
              ]
          );
        }
    );
  }

  // todo 변경하는 alert dialog !
  Future<dynamic> showEditStatefulDialogBuilder(BuildContext context, TodoType todo) async {
    DateTime _startDate = todo.startDate!;
    DateTime _endDate = todo.endDate!;
    _todoController.text = todo.title;

    await showDialog<void>(
        context: context,
        builder: (_) {
          return AlertDialog(
            // title: Text("할 일이 또 있나요?", style: TextStyle(fontSize: 15),),
              content: StatefulBuilder(
                  builder: (__, StateSetter setState) {
                    return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _todoController,
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await jdatePicker(DateTime.now());
                                  setState(() {
                                    _startDate = _selectedDate;
                                    _endDate = _startDate;
                                  });
                                },
                                child: Text(DateFormat('yyyy/MM/dd HH:mm').format(_startDate)),
                              ),
                              Text(" 부터  "),
                              TextButton(
                                onPressed: () async {
                                  await jdatePicker(_startDate);
                                  setState(() {
                                    _endDate = _selectedDate;
                                  });
                                },
                                child: Text(DateFormat('yyyy/MM/dd HH:mm').format(_endDate)),
                              ),
                              Text(" 까지"),
                            ],
                          )
                        ]
                    );
                  }
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    _editTodo(todo, TodoType(_todoController.text, _startDate, _endDate));
                    Navigator.pop(context);
                  },
                  child: Text('수정', style: TextStyle(color: Colors.indigo),),
                )
              ]
          );
        }
    );
  }

  @override
  void dispose() {
    _todoController.dispose(); // widget이 dispose될 때 컨트롤러도 같이 해줘라
    _dateTimeEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(

          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: <Widget>[],
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
              ),
              // Text(DateFormat('yyyy/MM/dd \nHH:mm').format(DateTime.now())) // 관찰용
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {showStatefulDialogBuilder(context);},
          tooltip: '추가',
          child: const Icon(Icons.add),
        )
      // multipleFloatingButton(), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // multiplefloatingbutton
  // Widget? multipleFloatingButton() {
  //   return SpeedDial(
  //     animatedIcon: AnimatedIcons.menu_close,
  //     visible: true,
  //     curve: Curves.bounceIn,
  //     // shape: CircleBorder(),
  //     backgroundColor: Colors.indigo[100],
  //     children: [
  //       SpeedDialChild(
  //         child: const Icon(Icons.settings_sharp, color: Colors.indigo,),
  //         shape: CircleBorder(),
  //         backgroundColor: Colors.indigo[100],
  //         label: "설정",
  //         labelBackgroundColor: Colors.indigo[50],
  //         labelStyle: const TextStyle(
  //           fontWeight: FontWeight.w500,
  //           color: Colors.black54,
  //           fontSize: 13.0
  //         ),
  //         onTap: () {}
  //       ),
  //       SpeedDialChild(
  //         child: const Icon(Icons.add, color: Colors.indigo,),
  //         shape: CircleBorder(),
  //         backgroundColor: Colors.indigo[100],
  //         label: "할 일 추가",
  //         labelBackgroundColor: Colors.indigo[50],
  //         labelStyle: const TextStyle(
  //           fontWeight: FontWeight.w500,
  //           color: Colors.black54,
  //           fontSize: 13.0
  //         ),
  //         onTap: () {
  //           showStatefulDialogBuilder(context);
  //         },
  //       )
  //     ],
  //   );
  // }

  // 투두 리스트 그려주는 위젯
  Widget _buildTodoListWidget(TodoType todo) {
    return ListTile(
        onTap: () => _donecheckTodo(todo),
        trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton( // 끝쪽(오른쪽)에, 왼쪽에 두고싶으면 leading 파라미터에 주기
                icon: Icon(Icons.edit),
                onPressed: () => showEditStatefulDialogBuilder(context, todo),
              ),
              IconButton( // 끝쪽(오른쪽)에, 왼쪽에 두고싶으면 leading 파라미터에 주기
                icon: Icon(Icons.delete),
                onPressed: () => _deleteTodo(todo),
              ),
            ]
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
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children : [
                    Text(
                      todo.title,
                      style: todo.isDone?
                      TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontStyle: FontStyle.italic,
                      ) : null, // 완료 전이면 취소선 안 긋고 아무 짓 안 한다는 표시
                    ),
                    Text(
                        DateFormat('yyyy/MM/dd HH:mm').format(todo.startDate!)
                            + ' 부터  '
                            + DateFormat('yyyy/MM/dd HH:mm').format(todo.endDate!)
                            + ' 까지 '
                        ,
                        style: (todo.endDate!.compareTo(DateTime.now()) == 1)?
                        TextStyle(fontSize: 12, color: Colors.black45)
                            : TextStyle(fontSize: 12, color: Colors.red[200])
                    ),
                  ]
              )
            ]
        )
    );
  }
}
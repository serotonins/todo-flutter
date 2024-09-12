import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
      title: 'Priority Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Priority Planner'),
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

  @override
  void initState() {
    super.initState();
    _loadTodos(); // 앱 시작 시 Todos 로드
  }

  void _addTodo(TodoType todo) { // 리스트에 투두 아이템 하나 추가
    setState(() {
      _todoListItem.add(todo);
      _todoController.text = '';
      _changeSortMethodExecute(_checkBoxValue1!);
    });
  }

  void _deleteTodo(TodoType todo) {
    setState(() {
      _todoListItem.remove(todo);
      _saveTodos();
    });
  }

  void _editTodo(TodoType todo, TodoType changed) {
    setState(() {
      todo.title = changed.title;
      todo.startDate = changed.startDate;
      todo.endDate = changed.endDate;

      _todoController.text = '';
      _changeSortMethodExecute(_checkBoxValue1!);

      _saveTodos();
    });
  }

  void _donecheckTodo(TodoType todo) {
    setState(() {
      todo.isDone = !todo.isDone;
      _saveTodos();
    });
  }

  void _changeSortMethod(bool ma) {
    setState(() {
      if (ma == true) {_cTodo = '마감일 기준';}
      else {_cTodo = '시작일 기준';}
      _changeSortMethodExecute(ma);
    });
  }

  void _changeSortMethodExecute(bool ma) {
    setState(() {
      if (ma == true) { _todoListItem.sort((x, y) => x.endDate!.compareTo(y.endDate!)); }
      else { _todoListItem.sort((x, y) => x.startDate!.compareTo(y.startDate!)); }
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
    });

      TimeOfDay? tpicked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (tpicked != null && _selectedDate != null) {
        setState(() {
          _selectedDate = _selectedDate.add(Duration(hours: tpicked.hour, minutes: tpicked.minute));
        });
      }
    }
  }

  // 저장하는 함수
  Future<void> _saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> todos = _todoListItem.map((todo) => json.encode({
      'title': todo.title,
      'startDate': todo.startDate?.toIso8601String() ?? '',
      'endDate': todo.endDate?.toIso8601String() ?? '',
      'isDone': todo.isDone,
    })).toList();
    await prefs.setStringList('todos', todos);
  }

  // 불러오는 함수
  Future<void> _loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? todos = prefs.getStringList('todos');
    if (todos != null) {
      setState(() {
        _todoListItem.clear();
        for (String todo in todos) {
          Map<String, dynamic> todoData = json.decode(todo);
          _todoListItem.add(TodoType(
            todoData['title'],
            DateTime.parse(todoData['startDate']),
            DateTime.parse(todoData['endDate']),
          )..isDone = todoData['isDone']);
        }
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
              title: Text("작업 추가하기", style: TextStyle(fontSize: 15),),
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
                                child: //Text(DateFormat('yyyy/MM/dd HH:mm').format(_startDate)),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('yyyy/MM/dd').format(_startDate),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        DateFormat('HH:mm').format(_startDate),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                              ),
                              Text(" 부터  "),
                              TextButton(
                                onPressed: () async {
                                  await jdatePicker(_startDate);
                                  setState(() {
                                    _endDate = _selectedDate;
                                  });
                                },
                                child: //Text(DateFormat('yyyy/MM/dd HH:mm').format(_endDate)),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('yyyy/MM/dd').format(_endDate),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        DateFormat('HH:mm').format(_endDate),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
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
                    _saveTodos();
                    Navigator.pop(context);
                  },
                  child: Text('추가', style: TextStyle(color: Colors.indigo),),
                )
              ]
          );
        }
    );
  }

  // Future<dynamic> showEditStatefulDialogBuilder(BuildContext context, TodoType todo) async {
  //   DateTime _startDate = todo.startDate!;
  //   DateTime _endDate = todo.endDate!;
  //   _todoController.text = todo.title;
  //
  //   await showDialog<void>(
  //     context: context,
  //     builder: (_) {
  //       return AlertDialog(
  //         content: Container(
  //           width: double.maxFinite, // 너비를 최대화
  //           constraints: BoxConstraints(maxHeight: 300), // 최대 높이 설정
  //           child: StatefulBuilder(
  //             builder: (__, StateSetter setState) {
  //               return SingleChildScrollView( // 스크롤 가능하게 감싸기
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     TextField(
  //                       controller: _todoController,
  //                       maxLines: null, // 여러 줄 입력 가능
  //                       decoration: InputDecoration(
  //                         hintText: '할 일을 입력하세요',
  //                         counterText: '', // 길이 카운터 숨기기
  //                       ),
  //                     ),
  //                     Row(
  //                       children: [
  //                         TextButton(
  //                           onPressed: () async {
  //                             await jdatePicker(DateTime.now());
  //                             setState(() {
  //                               _startDate = _selectedDate;
  //                               _endDate = _startDate;
  //                             });
  //                           },
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 DateFormat('yyyy/MM/dd').format(_startDate),
  //                                 overflow: TextOverflow.ellipsis,
  //                                 maxLines: 1,
  //                               ),
  //                               Text(
  //                                 DateFormat('HH:mm').format(_startDate),
  //                                 overflow: TextOverflow.ellipsis,
  //                                 maxLines: 1,
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         Text(" 부터  "),
  //                         TextButton(
  //                           onPressed: () async {
  //                             await jdatePicker(_startDate);
  //                             setState(() {
  //                               _endDate = _selectedDate;
  //                             });
  //                           },
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(
  //                                 DateFormat('yyyy/MM/dd').format(_endDate),
  //                                 overflow: TextOverflow.ellipsis,
  //                                 maxLines: 1,
  //                               ),
  //                               Text(
  //                                 DateFormat('HH:mm').format(_endDate),
  //                                 overflow: TextOverflow.ellipsis,
  //                                 maxLines: 1,
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         Text(" 까지"),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               _editTodo(todo, TodoType(_todoController.text, _startDate, _endDate));
  //               _todoController.clear();
  //               Navigator.pop(context);
  //             },
  //             child: Text('수정', style: TextStyle(color: Colors.indigo)),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  Future<dynamic> showEditStatefulDialogBuilder(BuildContext context, TodoType todo) async {
    DateTime _startDate = todo.startDate!;
    DateTime _endDate = todo.endDate!;
    _todoController.text = todo.title;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            _todoController.clear(); // 텍스트 내용 비우기
            return Future.value(true); // 다이얼로그 닫기
          },
          child: AlertDialog(
            content: Container(
              width: double.maxFinite, // 너비를 최대화
              constraints: BoxConstraints(maxHeight: 300), // 최대 높이 설정
              child: StatefulBuilder(
                builder: (__, StateSetter setState) {
                  return SingleChildScrollView( // 스크롤 가능하게 감싸기
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _todoController,
                          maxLines: null, // 여러 줄 입력 가능
                          decoration: InputDecoration(
                            hintText: '할 일을 입력하세요',
                            counterText: '', // 길이 카운터 숨기기
                          ),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('yyyy/MM/dd').format(_startDate),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    DateFormat('HH:mm').format(_startDate),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            Text(" 부터  "),
                            TextButton(
                              onPressed: () async {
                                await jdatePicker(_startDate);
                                setState(() {
                                  _endDate = _selectedDate;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('yyyy/MM/dd').format(_endDate),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    DateFormat('HH:mm').format(_endDate),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            Text(" 까지"),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _editTodo(todo, TodoType(_todoController.text, _startDate, _endDate));
                  _todoController.clear(); // 텍스트 내용 비우기
                  Navigator.pop(context);
                },
                child: Text('수정', style: TextStyle(color: Colors.indigo)),
              ),
            ],
          ),
        );
      },
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
                          _changeSortMethod(value!);
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

  Widget _buildTodoListWidget(TodoType todo) {
    return ListTile(
      onTap: () => _donecheckTodo(todo),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => showEditStatefulDialogBuilder(context, todo),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteTodo(todo),
          ),
        ],
      ),
      title: Row(
        children: [
          Checkbox(
            activeColor: Colors.black45,
            checkColor: Colors.white,
            value: todo.isDone,
            onChanged: (value) {
              setState(() {
                todo.isDone = value!;
              });
            },
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isSpaceLimited = constraints.maxWidth < MediaQuery.of(context).size.width * 0.55;
                // double screenWidth = MediaQuery.of(context).size.width;
                // bool isSpaceLimited = constraints.maxWidth < screenWidth * 0.3;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            todo.title,
                            style: todo.isDone
                                ? TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontStyle: FontStyle.italic,
                            )
                                : null,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          child: Text(
                            _formatDateFrom(todo.startDate!, isShort: isSpaceLimited),
                            style: (todo.endDate!.compareTo(DateTime.now()) == 1)
                                ? TextStyle(fontSize: 12, color: Colors.black45)
                                : TextStyle(fontSize: 12, color: Colors.red[200]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _formatDateTo(todo.endDate!, isShort: isSpaceLimited),
                            style: (todo.endDate!.compareTo(DateTime.now()) == 1)
                                ? TextStyle(fontSize: 12, color: Colors.black45)
                                : TextStyle(fontSize: 12, color: Colors.red[200]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// 날짜 포맷팅 함수
  String _formatDateFrom(DateTime date, {bool isShort = false}) {
    if (isShort) {
      return DateFormat('MM/dd HH:mm').format(date) + ' ~'; // 연도를 두 자리로
    } else {
      return DateFormat('yyyy/MM/dd HH:mm').format(date) + '부터'; // 기본 포맷
    }
  }

  String _formatDateTo(DateTime date, {bool isShort = false}) {
    if (isShort) {
      return DateFormat('MM/dd HH:mm').format(date); // 연도를 두 자리로
    } else {
      return DateFormat('yyyy/MM/dd HH:mm').format(date) + '까지'; // 기본 포맷
    }
  }

}

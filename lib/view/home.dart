import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'insert_todo_list.dart';
import 'update_todo_list.dart';

class TodoItem {
  TodoItem({required this.todo, required this.date, this.imageIndex = 0});

  String todo;
  DateTime date;
  int imageIndex;
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<TodoItem> _todoList = <TodoItem>[];

  static const Color _background = Color(0xFFFFF8FC);
  static const List<Color> _cardColors = <Color>[
    Color(0xFFFFF0B9),
    Color(0xFFFFC7D8),
    Color(0xFFCDE8FF),
  ];

  Future<void> _insert() async {
    final TodoItem? item = await Navigator.push<TodoItem>(
      context,
      MaterialPageRoute(builder: (_) => const InsertTodoList()),
    );
    if (item != null) setState(() => _todoList.add(item));
  }

  Future<void> _update(TodoItem item) async {
    final TodoItem? updated = await Navigator.push<TodoItem>(
      context,
      MaterialPageRoute(builder: (_) => UpdateTodoList(todoItem: item)),
    );
    if (updated != null) {
      setState(() => _todoList[_todoList.indexOf(item)] = updated);
    }
  }

  void _delete(TodoItem item) {
    setState(() => _todoList.remove(item));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('할 일이 삭제되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        centerTitle: true,
        title: const Text('Todo List 검색'),
        actions: [IconButton(onPressed: _insert, icon: const Icon(Icons.add))],
      ),
      body: _todoList.isEmpty
          ? const Center(child: Text('등록된 할 일이 없습니다.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                final TodoItem item = _todoList[index];
                return Slidable(
                  key: ValueKey(item),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) => _delete(item),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: '삭제',
                      ),
                    ],
                  ),
                  child: Card(
                    color: _cardColors[index % _cardColors.length],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => _update(item),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            _TodoImage(index: item.imageIndex, size: 54),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1} / ${item.todo}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDateTime(item.date),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _TodoImage extends StatelessWidget {
  const _TodoImage({required this.index, this.size = 72});

  final int index;
  final double size;

  @override
  Widget build(BuildContext context) {
    const List<Color> colors = <Color>[
      Color(0xFFFFE27A),
      Color(0xFFFFAFC8),
      Color(0xFFB9D9FF),
    ];
    const List<IconData> icons = <IconData>[
      Icons.edit_note,
      Icons.access_time,
      Icons.check_circle_outline,
    ];
    return Container(
      width: size,
      height: size,
      color: colors[index % colors.length],
      child: Icon(icons[index % icons.length], size: size * .58),
    );
  }
}

String _formatDate(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String _formatDateTime(DateTime value) {
  final String hour = value.hour.toString().padLeft(2, '0');
  final String minute = value.minute.toString().padLeft(2, '0');
  final String second = value.second.toString().padLeft(2, '0');
  return '${_formatDate(value)} $hour:$minute:$second';
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;

import 'insert_todo_list.dart';
import 'update_todo_list.dart';

class TodoItem {
  TodoItem({required this.todo, required this.date, this.imageIndex = 0});

  String todo;
  DateTime date;
  int imageIndex;
}

class TodoImage {
  const TodoImage({required this.seq, required this.bytes});

  final int seq;
  final Uint8List bytes;
}

class ImageRepository {
  ImageRepository._();

  static const String _baseUrl = 'http://192.168.20.55:8000';
  static List<TodoImage>? _cache;

  static Future<List<TodoImage>> fetchImages({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) {
      return _cache!;
    }

    final http.Response response = await http.get(Uri.parse('$_baseUrl/image'));
    if (response.statusCode != 200) {
      throw Exception('이미지를 불러오지 못했습니다. (${response.statusCode})');
    }

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    if (body['result'] != 'OK') {
      throw Exception('이미지를 불러오지 못했습니다.');
    }

    final List<dynamic> images = body['images'] as List<dynamic>? ?? [];
    _cache = [
      for (final dynamic item in images)
        TodoImage(
          seq: item['seq'] as int,
          bytes: base64Decode(item['image'] as String),
        ),
    ];
    return _cache!;
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<TodoItem> _todoList = <TodoItem>[];
  List<TodoImage> _images = <TodoImage>[];

  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const Color _background = Color(0xFFFFF8FC);
  static const List<Color> _cardColors = <Color>[
    Color(0xFFFFF0B9),
    Color(0xFFFFC7D8),
    Color(0xFFCDE8FF),
  ];

  List<TodoItem> get _filteredTodoList {
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _todoList;
    return _todoList
        .where((item) => item.todo.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  Future<void> _loadImages() async {
    try {
      final List<TodoImage> images = await ImageRepository.fetchImages();
      if (!mounted) return;
      setState(() => _images = images);
    } catch (e) {
      debugPrint('이미지 로드 실패: $e');
    }
  }

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
        leading: _isSearching
            ? IconButton(
                onPressed: _stopSearch,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '할 일을 검색하세요',
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : const Text('Todo List 검색'),
        actions: [
          if (_isSearching && _searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              icon: const Icon(Icons.clear),
            )
          else if (!_isSearching)
            IconButton(onPressed: _startSearch, icon: const Icon(Icons.search)),
          IconButton(onPressed: _insert, icon: const Icon(Icons.add)),
        ],
      ),
      body: _filteredTodoList.isEmpty
          ? Center(
              child: Text(
                _searchQuery.isEmpty ? '등록된 할 일이 없습니다.' : '검색 결과가 없습니다.',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
              itemCount: _filteredTodoList.length,
              itemBuilder: (context, index) {
                final TodoItem item = _filteredTodoList[index];
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
                            _TodoImage(
                              images: _images,
                              index: item.imageIndex,
                              size: 54,
                            ),
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
  const _TodoImage({required this.images, required this.index, this.size = 72});

  final List<TodoImage> images;
  final int index;
  final double size;

  @override
  Widget build(BuildContext context) {
    const List<Color> colors = <Color>[
      Color(0xFFFFE27A),
      Color(0xFFFFAFC8),
      Color(0xFFB9D9FF),
    ];
    final Color background = colors[index % colors.length];

    if (images.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: background,
        child: Icon(Icons.image_outlined, size: size * .58),
      );
    }

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: background),
      child: Image.memory(
        images[index % images.length].bytes,
        fit: BoxFit.cover,
      ),
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

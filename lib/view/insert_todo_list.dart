import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class InsertTodoList extends StatefulWidget {
  const InsertTodoList({super.key});

  @override
  State<InsertTodoList> createState() => _InsertTodoListState();
}

class _InsertTodoListState extends State<InsertTodoList> {
  final TextEditingController _controller = TextEditingController();
  int _imageIndex = 0;
  late final Future<List<TodoImage>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _imagesFuture = ImageRepository.fetchImages();
  }

  void _save() {
    final String value = _controller.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('할 일을 입력하세요.')));
      return;
    }
    Navigator.pop(
      context,
      TodoItem(todo: value, date: DateTime.now(), imageIndex: _imageIndex),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8FC),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left),
        ),
        centerTitle: true,
        title: const Text('Add View'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
        child: Column(
          children: [
            FutureBuilder<List<TodoImage>>(
              future: _imagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    width: 190,
                    height: 260,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final List<TodoImage> images = snapshot.data ?? [];
                if (snapshot.hasError || images.isEmpty) {
                  return const SizedBox(
                    width: 190,
                    height: 260,
                    child: Center(child: Text('이미지를 불러오지 못했습니다.')),
                  );
                }
                if (_imageIndex >= images.length) {
                  _imageIndex = images.length - 1;
                }
                return _PickerView(
                  selectedIndex: _imageIndex,
                  images: images,
                  onChanged: (value) => setState(() => _imageIndex = value),
                );
              },
            ),
            const SizedBox(height: 44),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                enabledBorder: UnderlineInputBorder(),
                hintText: '목록을 입력하세요',
              ),
            ),
            const SizedBox(height: 34),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerView extends StatelessWidget {
  const _PickerView({
    required this.selectedIndex,
    required this.images,
    required this.onChanged,
  });

  final int selectedIndex;
  final List<TodoImage> images;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 190,
          height: 160,
          color: const Color(0xFFB9D9FF),
          child: Image.memory(
            images[selectedIndex].bytes,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(
          height: 92,
          width: 190,
          child: CupertinoPicker(
            itemExtent: 42,
            scrollController: FixedExtentScrollController(
              initialItem: selectedIndex,
            ),
            onSelectedItemChanged: onChanged,
            children: [
              for (final TodoImage image in images)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.memory(image.bytes, fit: BoxFit.contain),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

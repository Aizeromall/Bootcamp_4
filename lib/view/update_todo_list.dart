import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class UpdateTodoList extends StatefulWidget {
  const UpdateTodoList({required this.todoItem, super.key});

  final TodoItem todoItem;

  @override
  State<UpdateTodoList> createState() => _UpdateTodoListState();
}

class _UpdateTodoListState extends State<UpdateTodoList> {
  late final TextEditingController _controller;
  late int _imageIndex;

  static const List<IconData> _icons = <IconData>[
    Icons.edit_note,
    Icons.access_time,
    Icons.check_circle_outline,
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.todoItem.todo);
    _imageIndex = widget.todoItem.imageIndex;
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
      TodoItem(
        todo: value,
        date: widget.todoItem.date,
        imageIndex: _imageIndex,
      ),
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
        title: const Text('Update View'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
        child: Column(
          children: [
            _PickerView(
              selectedIndex: _imageIndex,
              icons: _icons,
              onChanged: (value) => setState(() => _imageIndex = value),
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
    required this.icons,
    required this.onChanged,
  });

  final int selectedIndex;
  final List<IconData> icons;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 190,
          height: 160,
          color: const Color(0xFFB9D9FF),
          child: Icon(icons[selectedIndex], size: 74),
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
            children: [for (final IconData icon in icons) Icon(icon, size: 28)],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notepad_clone/note_provider.dart';
import 'package:flutter/services.dart';

class SaveIntent extends Intent {
  const SaveIntent();
}

class OpenIntent extends Intent {
  const OpenIntent();
}

class NewIntent extends Intent {
  const NewIntent();
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NoteProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NotepadHome(),
      ),
    ),
  );
}

class NotepadHome extends StatefulWidget {
  const NotepadHome({super.key});

  @override
  State<NotepadHome> createState() => _NotepadHomeState();
}

class _NotepadHomeState extends State<NotepadHome> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final note = context.watch<NoteProvider>();

    if (_controller.text != note.content) {
      _controller.text = note.content;
    }

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const SaveIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyO):
            const OpenIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
            const NewIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SaveIntent: CallbackAction<SaveIntent>(
            onInvoke: (intent) => note.saveFile(),
          ),
          OpenIntent: CallbackAction<OpenIntent>(
            onInvoke: (intent) => note.openFile(),
          ),
          NewIntent: CallbackAction<NewIntent>(
            onInvoke: (intent) => note.newFile(),
          ),
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("${note.fileName}${note.isDirty ? " *" : ""} - Flutter 메모장"),
            actions: [
              IconButton(
                icon: const Icon(Icons.note_add),
                onPressed: () => note.newFile(),
              ),
              IconButton(
                icon: const Icon(Icons.file_open),
                onPressed: () => note.openFile(),
              ),
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () => note.saveFile(),
              ),
            ],
          ),
          body: TextField(
            controller: _controller,
            maxLines: null,
            expands: true,
            onChanged: (value) => note.updateContent(value),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
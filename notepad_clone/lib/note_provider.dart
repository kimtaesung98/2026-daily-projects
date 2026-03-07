import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class NoteProvider extends ChangeNotifier {
  String _content = "";
  String? _filePath;
  bool _isDirty = false;

  String get content => _content;
  String? get filePath => _filePath;
  bool get isDirty => _isDirty;
  String get fileName => _filePath != null ? _filePath!.split(Platform.pathSeparator).last : "제목 없음";

  void updateContent(String newContent) {
    if (_content != newContent) {
      _content = newContent;
      _isDirty = true;
      notifyListeners();
    }
  }

  // [열기] 로직
  Future<void> openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md', 'dart', 'json'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final file = File(path);
      final content = await file.readAsString();
      
      _content = content;
      _filePath = path;
      _isDirty = false;
      notifyListeners();
    }
  }

  // [저장] 로직 (덮어쓰기 또는 새 이름으로 저장)
  Future<void> saveFile({bool saveAs = false}) async {
    String? targetPath = _filePath;

    // 경로가 없거나 '새 이름으로 저장'인 경우 다이얼로그 호출
    if (saveAs || targetPath == null) {
      targetPath = await FilePicker.platform.saveFile(
        dialogTitle: '파일 저장',
        fileName: _filePath != null ? fileName : 'note.txt',
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );
    }

    if (targetPath != null) {
      final file = File(targetPath);
      await file.writeAsString(_content);
      
      _filePath = targetPath;
      _isDirty = false;
      notifyListeners();
    }
  }

  // [새로 만들기] 로직
  void newFile() {
    _content = "";
    _filePath = null;
    _isDirty = false;
    notifyListeners();
  }
}
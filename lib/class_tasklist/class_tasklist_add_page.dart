import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'class_tasklist_add_view.dart';
import 'package:file_picker/file_picker.dart';
import '../services/cloudinary_service.dart';
import 'package:uuid/uuid.dart';
import '../widgets/show_message.dart';

class ClassTaskListAddPage extends StatefulWidget {
  final String role;
  final String classCode;
  final String className;
  final String email;
  final Map<String, dynamic>? existingTask;

  const ClassTaskListAddPage({
    super.key,
    required this.role,
    required this.classCode,
    required this.className,
    required this.email,
    this.existingTask,
  });

  @override
  State<ClassTaskListAddPage> createState() => _ClassTaskListAddPageState();
}

class _ClassTaskListAddPageState extends State<ClassTaskListAddPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final ShowMessage _showMessage = ShowMessage();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _taskNameController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = TimeOfDay.now();
  DateTime _closeDate = DateTime.now();
  TimeOfDay _closeTime = TimeOfDay.now();
  String _taskName = '';
  PlatformFile? _selectedFile;
  bool _isLoading = false;
  List<String> _selectedMembers = [];
  List<Map<String, dynamic>> _availableMembers = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _initializeTaskData(widget.existingTask!);
    }
    _fetchAvailableMembers();
  }

  void _initializeTaskData(Map<String, dynamic> taskData) {
    _taskNameController.text = taskData['taskName'];
    _descriptionController.text = taskData['description'];
    _dueDate = taskData['taskDeadline'].toDate();
    _dueTime = TimeOfDay.fromDateTime(taskData['taskDeadline'].toDate());
    _closeDate = taskData['taskCloseDeadline'].toDate();
    _closeTime = TimeOfDay.fromDateTime(taskData['taskCloseDeadline'].toDate());
    _selectedMembers = List<String>.from(taskData['taskMembers']);
  }

  Future<void> _fetchAvailableMembers() async {
    try {
      final members = await _firebaseService.getNonTaskMembers(
        classCode: widget.classCode,
        taskId: '',
      );
      setState(() {
        _availableMembers = members;
      });
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal mengambil data anggota: $e');
      }
    }
  }

  void _handleMembersChanged(List<String> members) {
    setState(() {
      if (members.contains('Pilih Semua')) {
        _selectedMembers = _getAvailableMembers();
      } else {
        _selectedMembers = members;
      }
    });
  }

  void _handleTaskNameSaved(String taskName) {
    setState(() {
      _taskName = taskName;
    });
  }

  List<String> _getAvailableMembers() {
    return _availableMembers
        .map((member) =>
            '${member['username']}\n${member['role']}\n${member['email']}')
        .toList();
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
        if (_closeDate.isBefore(picked)) {
          _closeDate = picked;
        }
      });
    }
  }

  Future<void> _handleTimeChanged() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null && picked != _dueTime) {
      if (_closeDate.year == _dueDate.year &&
          _closeDate.month == _dueDate.month &&
          _closeDate.day == _dueDate.day) {
        final newDueMinutes = picked.hour * 60 + picked.minute;
        final closeMinutes = _closeTime.hour * 60 + _closeTime.minute;

        if (newDueMinutes >= closeMinutes) {
          setState(() {
            _dueTime = picked;
            _closeTime = picked;
          });
          return;
        }
      }

      setState(() {
        _dueTime = picked;
      });
    }
  }

  Future<void> _showCloseDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _closeDate,
      firstDate: _dueDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _closeDate) {
      setState(() {
        _closeDate = picked;
      });
    }
  }

  Future<void> _handleCloseTimeChanged() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _closeTime,
    );
    if (picked != null && picked != _closeTime) {
      if (_closeDate.year == _dueDate.year &&
          _closeDate.month == _dueDate.month &&
          _closeDate.day == _dueDate.day) {
        final closeMinutes = picked.hour * 60 + picked.minute;
        final dueMinutes = _dueTime.hour * 60 + _dueTime.minute;

        if (closeMinutes < dueMinutes) {
          if (mounted) {
            _showMessage.showMessage(
                context, 'Waktu tutup tidak boleh kurang dari tenggat waktu');
          }
          return;
        }
      }

      setState(() {
        _closeTime = picked;
      });
    }
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'jpg',
          'jpeg',
          'png',
          'zip'
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
        if (mounted) {
          _showMessage.showMessage(context, 'File berhasil dipilih');
        }
      } else {
        if (mounted) {
          _showMessage.showMessage(context, 'Pemilihan file dibatalkan');
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal memilih file: $e');
      }
    }
  }

  Future<String?> _uploadToCloudinary() async {
    if (_selectedFile == null) return null;

    try {
      return await _cloudinaryService.uploadFile(
        file: _selectedFile!,
        folder: '${widget.classCode}/task/$_taskName/soal',
      );
    } catch (e) {
      if (mounted) {
        _showMessage.showMessage(context, 'Gagal mengunggah file: $e');
      }
      return null;
    }
  }

  String _generateTaskId() {
    final uuid = const Uuid().v4();
    return '${widget.classCode}-${uuid.substring(0, 8)}';
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final DateTime deadline = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    ).toLocal();

    final DateTime closeDeadline = DateTime(
      _closeDate.year,
      _closeDate.month,
      _closeDate.day,
      _closeTime.hour,
      _closeTime.minute,
    ).toLocal();

    if (closeDeadline.isBefore(deadline)) {
      if (mounted) {
        _showMessage.showMessage(
            context, 'Waktu tutup tidak boleh kurang dari tenggat waktu');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _formKey.currentState!.save();

      String? fileUrl;
      if (_selectedFile != null) {
        if (mounted) {
          _showMessage.showMessage(context, 'Mengunggah file...');
        }
        fileUrl = await _uploadToCloudinary();
        if (fileUrl == null) {
          throw Exception('Gagal mengunggah file');
        }
      }

      List<String> memberEmails = [];
      for (String member in _selectedMembers) {
        String email = member.split('\n')[2];
        memberEmails.add(email);
      }
      _selectedMembers = memberEmails;

      if (widget.existingTask != null) {
        await _firebaseService.updateTask(
          taskId: widget.existingTask!['id'],
          classCode: widget.classCode,
          taskName: _taskName,
          taskDeadline: deadline,
          taskCloseDeadline: closeDeadline,
          description: _descriptionController.text,
          attachmentTaskUrl: fileUrl,
          taskMembers: _selectedMembers,
        );
        if (mounted) {
          _showMessage.showMessage(context, 'Tugas berhasil diperbarui');
          Navigator.pop(context, 'updateTask');
        }
      } else {
        final taskExists = await _firebaseService.checkTaskNameExists(
            classCode: widget.classCode, taskName: _taskName);

        if (taskExists) {
          if (mounted) {
            _showMessage.showMessage(context, 'Nama tugas sudah digunakan');
          }
          return;
        }

        final taskId = _generateTaskId();

        await _firebaseService.addTaskToClass(
          taskId: taskId,
          classCode: widget.classCode,
          taskName: _taskName,
          description: _descriptionController.text,
          taskDeadline: deadline,
          taskCloseDeadline: closeDeadline,
          teacherEmail: widget.role == 'Guru' ? widget.email : '',
          attachmentTaskUrl: fileUrl,
          taskMembers: _selectedMembers,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
          _showMessage.showMessage(context, 'Tugas berhasil ditambahkan');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showMessage.showMessage(context, 'Gagal menambahkan tugas: $e');
      }
    }
  }

  String? _validateTaskName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Mohon isi nama tugas';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mohon isi deskripsi tugas';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ClassTaskListAddView(
      className: widget.className,
      formKey: _formKey,
      taskNameController: _taskNameController,
      descriptionController: _descriptionController,
      dueDate: _dueDate,
      dueTime: _dueTime,
      closeDate: _closeDate,
      closeTime: _closeTime,
      onTaskNameSaved: _handleTaskNameSaved,
      onDatePressed: _showDatePicker,
      onTimeChanged: _handleTimeChanged,
      onCloseDatePressed: _showCloseDatePicker,
      onCloseTimeChanged: _handleCloseTimeChanged,
      onSave: _handleSave,
      taskNameValidator: _validateTaskName,
      descriptionValidator: _validateDescription,
      selectedFileName: _selectedFile?.name,
      onSelectFile: _selectFile,
      isLoading: _isLoading,
      selectedMembers: _selectedMembers,
      onMembersChanged: _handleMembersChanged,
      availableMembers: _getAvailableMembers(),
      existingTask: widget.existingTask,
    );
  }
}

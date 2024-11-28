import 'package:flutter/material.dart';

class AddTaskDialog extends StatelessWidget {
  final String className;
  final GlobalKey<FormState> formKey;
  final TextEditingController descriptionController;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final Function(String) onTaskNameSaved;
  final VoidCallback onDatePressed;
  final VoidCallback onTimeChanged;
  final VoidCallback onSave;

  const AddTaskDialog({
    super.key,
    required this.className,
    required this.formKey,
    required this.descriptionController,
    required this.dueDate,
    required this.dueTime,
    required this.onTaskNameSaved,
    required this.onDatePressed,
    required this.onTimeChanged,
    required this.onSave,
  });

  Widget _buildTaskNameField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Nama Tugas'),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Mohon isi nama tugas' : null,
      onSaved: (value) => onTaskNameSaved(value!),
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tanggal Jatuh Tempo:',
                  style: TextStyle(fontSize: 16)),
              Text(_formatDate(dueDate),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: onDatePressed,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tambah Tugas Baru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 16.0),
                _buildTaskNameField(),
                const SizedBox(height: 16.0),
                _buildDatePicker(),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Waktu Jatuh Tempo:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            dueTime.format(context),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: onTimeChanged,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Tugas',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon isi deskripsi tugas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onSave,
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

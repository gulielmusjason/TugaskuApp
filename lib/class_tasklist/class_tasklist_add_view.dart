import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class ClassTaskListAddView extends StatelessWidget {
  final String className;
  final GlobalKey<FormState> formKey;
  final TextEditingController taskNameController;
  final TextEditingController descriptionController;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final Function(String) onTaskNameSaved;
  final VoidCallback onDatePressed;
  final VoidCallback onTimeChanged;
  final VoidCallback onSave;
  final FormFieldValidator<String>? taskNameValidator;
  final FormFieldValidator<String>? descriptionValidator;
  final String? selectedFileName;
  final VoidCallback onSelectFile;
  final DateTime closeDate;
  final TimeOfDay closeTime;
  final VoidCallback onCloseDatePressed;
  final VoidCallback onCloseTimeChanged;
  final bool isLoading;
  final List<String> selectedMembers;
  final Function(List<String>) onMembersChanged;
  final List<Map<String, dynamic>> availableMembers;
  final Map<String, dynamic>? existingTask;

  const ClassTaskListAddView({
    super.key,
    required this.className,
    required this.formKey,
    required this.taskNameController,
    required this.descriptionController,
    required this.dueDate,
    required this.dueTime,
    required this.onTaskNameSaved,
    required this.onDatePressed,
    required this.onTimeChanged,
    required this.onSave,
    required this.taskNameValidator,
    required this.descriptionValidator,
    this.selectedFileName,
    required this.onSelectFile,
    required this.closeDate,
    required this.closeTime,
    required this.onCloseDatePressed,
    required this.onCloseTimeChanged,
    this.isLoading = false,
    required this.selectedMembers,
    required this.onMembersChanged,
    required this.availableMembers,
    required this.existingTask,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(existingTask != null ? 'Edit Tugas' : 'Tambah Tugas Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskNameField(),
              const SizedBox(height: 16.0),
              _buildMembersDropdown(),
              const SizedBox(height: 16.0),
              _buildDateTimePicker(context, 'Tenggat Waktu:', dueDate, dueTime,
                  onDatePressed, onTimeChanged),
              const SizedBox(height: 16.0),
              _buildDateTimePicker(context, 'Waktu Tutup:', closeDate,
                  closeTime, onCloseDatePressed, onCloseTimeChanged),
              const SizedBox(height: 16.0),
              _buildDescriptionField(),
              const SizedBox(height: 16.0),
              _buildFileUpload(context),
              const SizedBox(height: 24.0),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskNameField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Nama Tugas'),
      validator: taskNameValidator,
      onSaved: (value) => onTaskNameSaved(value!),
      controller: taskNameController,
    );
  }

  Widget _buildMembersDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Anggota:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownSearch<String>.multiSelection(
          items: (filter, infiniteScrollProps) => Future.value([
            'Pilih Semua',
            ...availableMembers
                .map((member) => '${member['username']} (${member['email']})')
          ]),
          popupProps: PopupPropsMultiSelection.menu(
            showSearchBox: true,
            searchFieldProps: const TextFieldProps(
              decoration: InputDecoration(
                hintText: "Cari anggota",
              ),
            ),
          ),
          selectedItems: selectedMembers.map((email) {
            final username = _getUsernameFromEmail(email);
            return username != null ? '$username ($email)' : email;
          }).toList(),
          onChanged: (selectedUsernames) {
            if (selectedUsernames.contains('Pilih Semua')) {
              final allEmails = availableMembers
                  .where((member) => member['username'] != 'Pilih Semua')
                  .map((member) => member['email'])
                  .whereType<String>()
                  .toList();
              onMembersChanged(allEmails);
            } else {
              final selectedEmails = selectedUsernames
                  .map((usernameWithEmail) {
                    final username = usernameWithEmail.split(' (')[0];
                    return _getEmailFromUsername(username);
                  })
                  .whereType<String>()
                  .toList();
              onMembersChanged(selectedEmails);
            }
          },
          dropdownBuilder: (context, selectedItems) {
            if (selectedItems.isEmpty) {
              return const Text("Pilih anggota");
            }
            return Text(selectedItems.join(', '));
          },
        ),
      ],
    );
  }

  Widget _buildDateTimePicker(
    BuildContext context,
    String label,
    DateTime date,
    TimeOfDay time,
    VoidCallback onDatePressed,
    VoidCallback onTimePressed,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: onDatePressed,
                  child: Row(
                    children: [
                      Text(
                        _formatDate(date),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.calendar_month),
                    ],
                  ),
                ),
              ),
              Container(
                height: 24,
                width: 1,
                color: Colors.grey,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              InkWell(
                onTap: onTimePressed,
                child: Row(
                  children: [
                    Text(
                      time.format(context),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: descriptionController,
      decoration: const InputDecoration(
        labelText: 'Deskripsi Tugas',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      validator: descriptionValidator,
    );
  }

  Widget _buildFileUpload(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lampiran File:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                selectedFileName ?? 'Belum ada file dipilih',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            ElevatedButton.icon(
              onPressed: onSelectFile,
              icon: const Icon(Icons.attach_file, color: Colors.white),
              label: const Text('Pilih File'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: isLoading ? null : onSave,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }

  String? _getEmailFromUsername(String username) {
    final member = availableMembers.firstWhere(
      (member) => member['username'] == username,
      orElse: () => <String, dynamic>{},
    );
    return member['email'] as String?;
  }

  String? _getUsernameFromEmail(String email) {
    final member = availableMembers.firstWhere(
      (member) => member['email'] == email,
      orElse: () => <String, dynamic>{},
    );
    return member['username'] as String?;
  }
}

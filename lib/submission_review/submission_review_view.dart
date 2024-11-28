import 'package:flutter/material.dart';

class SubmissionReviewView extends StatelessWidget {
  final String className;
  final Map<String, dynamic> taskDetails;
  final List<Map<String, dynamic>> submittedMembers;
  final List<Map<String, dynamic>> notSubmittedMembers;
  final Future<void> Function() onDeleteTask;
  final String Function(DateTime) formatDateTime;
  final Future<void> Function(String) onDownloadFile;
  final void Function(Map<String, dynamic>) onTapSubmittedMember;
  final VoidCallback onEditTask;
  final Future<void> Function() onRefresh;

  const SubmissionReviewView({
    super.key,
    required this.className,
    required this.taskDetails,
    required this.submittedMembers,
    required this.notSubmittedMembers,
    required this.onDeleteTask,
    required this.formatDateTime,
    required this.onDownloadFile,
    required this.onTapSubmittedMember,
    required this.onEditTask,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTaskHeader(context),
              const SizedBox(height: 16),
              _buildSubmittedSection(context),
              const SizedBox(height: 16),
              _buildNotSubmittedSection(context),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      title: Text(
        'Pengumpulan Tugas',
        style: theme.appBarTheme.titleTextStyle,
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: theme.primaryColor),
          onSelected: (value) => _handleMenuSelection(value, context),
          itemBuilder: (context) => _buildMenuItems(context),
        ),
      ],
    );
  }

  void _handleMenuSelection(String value, BuildContext context) {
    if (value == 'delete') {
      _showDeleteConfirmation(context);
    } else if (value == 'edit') {
      onEditTask();
    }
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    final theme = Theme.of(context);
    return [
      PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit_outlined, color: theme.primaryColor),
            SizedBox(width: 12),
            Text('Edit Tugas', style: theme.textTheme.labelLarge),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 12),
            Text('Hapus Tugas', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ];
  }

  Future<void> _showDeleteConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Konfirmasi Hapus Tugas',
          style: theme.textTheme.titleLarge,
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus tugas ini?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: theme.textTheme.labelLarge,
            ),
          ),
          ElevatedButton(
            onPressed: onDeleteTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Hapus',
              style: theme.textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskHeader(BuildContext context) {
    final theme = Theme.of(context);
    final attachmentUrl = taskDetails['attachmentTaskUrl'];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              taskDetails['taskName'],
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              icon: Icons.access_time,
              text:
                  'Jatuh tempo: ${formatDateTime(taskDetails['taskDeadline'].toDate())}',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.lock_clock,
              text:
                  'Tutup pada: ${formatDateTime(taskDetails['taskCloseDeadline'].toDate())}',
              theme: theme,
            ),
            if (attachmentUrl != null && attachmentUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.attachment,
                text: 'File Tugas',
                theme: theme,
                trailing: TextButton.icon(
                  onPressed: () => onDownloadFile(attachmentUrl),
                  icon: Icon(Icons.download, color: theme.primaryColor),
                  label: Text(
                    'Unduh',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(thickness: 1),
            ),
            Text(
              'Deskripsi Tugas:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              taskDetails['description'] ?? 'Tidak ada deskripsi',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required ThemeData theme,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? const Color(0xFFEFEBE9)
            : const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.brightness == Brightness.light
              ? Colors.brown.withAlpha((0.2 * 255).round())
              : Colors.white24,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildSubmittedSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 12),
                Text(
                  'Sudah Mengumpulkan',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: submittedMembers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final member = submittedMembers[index];
                final bool isGraded = member['gradedAt'] != null;

                return InkWell(
                  onTap: () => onTapSubmittedMember(member),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            member['username'],
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (isGraded)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[700],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Sudah Dinilai',
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      formatDateTime(member['submittedAt'].toDate()),
                      style: theme.textTheme.bodyMedium,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[700],
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotSubmittedSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_rounded, color: theme.colorScheme.error),
                const SizedBox(width: 12),
                Text(
                  'Belum Mengumpulkan',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notSubmittedMembers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final member = notSubmittedMembers[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  title: Text(
                    member['username'],
                    style: theme.textTheme.titleMedium,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.error,
                    child: Icon(Icons.close, color: theme.colorScheme.onError),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubmissionView extends StatelessWidget {
  final Map<String, dynamic> task;
  final String Function(Timestamp?) formatDateTime;
  final String selectedFileName;
  final VoidCallback onSelectFile;
  final VoidCallback onSave;
  final Future<void> Function() onRefresh;
  final VoidCallback onCancel;
  final VoidCallback onBack;
  final bool isSubmitting;
  final bool isCancelling;
  final Future<void> Function(String) onDownloadFile;

  const SubmissionView({
    super.key,
    required this.task,
    required this.formatDateTime,
    required this.selectedFileName,
    required this.onSelectFile,
    required this.onSave,
    required this.onRefresh,
    required this.onCancel,
    required this.onBack,
    required this.isSubmitting,
    required this.isCancelling,
    required this.onDownloadFile,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        onBack();
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTugasContent(context),
                const SizedBox(height: 16),
                _buildFileUpload(context),
                const SizedBox(height: 24),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
      ),
      title: const Text('Pengumpulan Tugas'),
    );
  }

  Widget _buildTugasContent(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task['taskName'],
          style: TextStyle(
            fontSize: theme.textTheme.headlineSmall?.fontSize,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          task['className'],
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.access_time,
                size: 16, color: theme.colorScheme.secondary),
            const SizedBox(width: 4),
            Text(
              'Jatuh Tempo: ${formatDateTime(task['taskDeadline'])}',
              style: TextStyle(
                fontSize: theme.textTheme.bodyMedium?.fontSize,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.lock_clock, size: 16, color: Colors.red),
            const SizedBox(width: 4),
            Text(
              'Tutup pada: ${formatDateTime(task['taskCloseDeadline'])}',
              style: TextStyle(
                fontSize: theme.textTheme.bodyMedium?.fontSize,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (task['submission']['submittedAt'] != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
              const SizedBox(width: 4),
              Text(
                'Dikumpulkan: ${formatDateTime(task['submission']['submittedAt'])}',
                style: TextStyle(
                  fontSize: theme.textTheme.bodyMedium?.fontSize,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Deskripsi:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          task['description'] ?? 'Tidak ada deskripsi',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'File Tugas:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        if (task['attachmentTaskUrl'] != null)
          InkWell(
            onTap: () => onDownloadFile(task['attachmentTaskUrl']),
            child: Row(
              children: [
                const Icon(Icons.description, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Lihat File Tugas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFileUpload(BuildContext context) {
    final theme = Theme.of(context);
    final isTaskClosed = task['taskCloseDeadline'] != null &&
        Timestamp.now().compareTo(task['taskCloseDeadline']) > 0;
    final hasSubmitted = task['submission']['submittedAt'] != null;

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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: task['submission']['attachmentUrl'] != null
                    ? InkWell(
                        onTap: () =>
                            onDownloadFile(task['submission']['attachmentUrl']),
                        child: Row(
                          children: [
                            Icon(Icons.description,
                                size: 20, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Lihat File Jawaban',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          Icon(Icons.insert_drive_file,
                              size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedFileName,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: (isTaskClosed || hasSubmitted) ? null : onSelectFile,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.upload_file,
                    size: 18, color: Colors.white),
                label: const Text('Upload'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final now = Timestamp.now();
    final isTaskClosed = task['taskCloseDeadline'] != null &&
        now.compareTo(task['taskCloseDeadline']) > 0;
    final isTaskDeadlinePassed =
        task['taskDeadline'] != null && now.compareTo(task['taskDeadline']) > 0;
    final hasSubmitted = task['submission']['submittedAt'] != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (hasSubmitted) ...[
          ElevatedButton(
            onPressed: isTaskClosed || isCancelling ? null : onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: isCancelling
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Batal Submit'),
          ),
          const SizedBox(width: 8),
        ],
        ElevatedButton(
          onPressed: (isTaskClosed || hasSubmitted || isSubmitting)
              ? null
              : isTaskDeadlinePassed
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Pengumpulan tugas telah melewati batas waktu'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      onSave();
                    }
                  : onSave,
          child: isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubmissionEvaluationView extends StatelessWidget {
  final Map<String, dynamic> submission;
  final String Function(Timestamp?) formatDateTime;
  final Future<void> Function(String) onDownloadFile;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onBack;
  final bool isSaving;
  final TextEditingController scoreController;
  final TextEditingController feedbackController;
  final Future<void> Function() onRefresh;

  const SubmissionEvaluationView({
    super.key,
    required this.submission,
    required this.formatDateTime,
    required this.onDownloadFile,
    required this.onSave,
    required this.onCancel,
    required this.onBack,
    required this.isSaving,
    required this.scoreController,
    required this.feedbackController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Evaluasi Tugas'),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSubmissionInfo(context),
              const SizedBox(height: 24),
              _buildEvaluationForm(context),
              const SizedBox(height: 24),
              _buildActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionInfo(BuildContext context) {
    final theme = Theme.of(context);
    final bool isEvaluated = submission['score'] != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Informasi Pengumpulan',
                    style: TextStyle(
                      fontSize: theme.textTheme.titleLarge?.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isEvaluated) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sudah Dinilai',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              'Nama Siswa:',
              submission['username'] ?? '-',
            ),
            _buildInfoRow(
              context,
              'Waktu Pengumpulan:',
              formatDateTime(submission['submittedAt']),
            ),
            const SizedBox(height: 16),
            if (submission['attachmentUrl'] != null)
              _buildAttachmentSection(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File Jawaban:',
          style: TextStyle(
            fontSize: theme.textTheme.titleMedium?.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => onDownloadFile(submission['attachmentUrl']),
          child: Row(
            children: [
              Icon(Icons.description, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Lihat File Jawaban',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildEvaluationForm(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Penilaian',
              style: TextStyle(
                fontSize: theme.textTheme.titleLarge?.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nilai (0-100)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              controller: scoreController,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Catatan/Feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              controller: feedbackController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (submission['gradedAt'] != null) ...[
          ElevatedButton(
            onPressed: isSaving ? null : onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Batalkan Penilaian'),
          ),
          const SizedBox(width: 8),
        ],
        ElevatedButton(
          onPressed: isSaving ? null : onSave,
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(submission['score'] != null
                  ? 'Perbarui Nilai'
                  : 'Simpan Penilaian'),
        ),
      ],
    );
  }
}

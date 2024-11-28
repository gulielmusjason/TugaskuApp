import 'package:flutter/material.dart';

class AddClassPage extends StatelessWidget {
  final TextEditingController addClassController;
  final List<String> classAvailableIcons;
  final ValueChanged<String?> addClassOnChanged;
  final String addClassSelectedIcon;
  final bool addClassIsLoading;
  final VoidCallback addClassOnAddPressed;
  final VoidCallback addClassOnCancelPressed;
  final Function(String) validateClassName;

  const AddClassPage({
    super.key,
    required this.addClassController,
    required this.classAvailableIcons,
    required this.addClassOnChanged,
    required this.addClassSelectedIcon,
    required this.addClassIsLoading,
    required this.addClassOnAddPressed,
    required this.addClassOnCancelPressed,
    required this.validateClassName,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kelas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Nama Kelas',
                  errorStyle: TextStyle(color: Colors.red),
                ),
                controller: addClassController,
                validator: (value) {
                  return validateClassName(value ?? '');
                },
              ),
              const SizedBox(height: 20),
              const Text('Pilih Ikon:'),
              SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  value: addClassSelectedIcon,
                  items: classAvailableIcons
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(_getIcon(value),
                              color: Theme.of(context).primaryColor, size: 30),
                          const SizedBox(width: 10),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: addClassOnChanged,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: addClassOnCancelPressed,
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: addClassIsLoading
                        ? null
                        : () {
                            if (formKey.currentState?.validate() ?? false) {
                              addClassOnAddPressed();
                            }
                          },
                    child: addClassIsLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _getIcon(String iconName) {
  final IconData iconData = switch (iconName) {
    'class_' => Icons.class_,
    'calculate' => Icons.calculate,
    'book' => Icons.book,
    'science' => Icons.science,
    'public' => Icons.public,
    'language' => Icons.language,
    'sports_soccer' => Icons.sports_soccer,
    'music_note' => Icons.music_note,
    'palette' => Icons.palette,
    'computer' => Icons.computer,
    _ => Icons.class_
  };

  return iconData;
}

class JoinClassDialog extends StatelessWidget {
  final Function(String) onJoin;
  final Function(String) validateClasscode;
  final VoidCallback onJoinCancelPressed;

  const JoinClassDialog({
    super.key,
    required this.onJoin,
    required this.validateClasscode,
    required this.onJoinCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    String kodeKelas = '';
    final formKey = GlobalKey<FormState>();

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Gabung Kelas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Masukkan Kode Kelas',
                  errorStyle: TextStyle(color: Colors.red),
                ),
                onChanged: (value) {
                  kodeKelas = value;
                },
                validator: (value) {
                  return validateClasscode(value ?? '');
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: onJoinCancelPressed,
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        await onJoin(kodeKelas);
                      }
                    },
                    child: const Text('Gabung'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

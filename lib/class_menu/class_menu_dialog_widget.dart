import 'package:flutter/material.dart';

class AddClassPage extends StatefulWidget {
  final TextEditingController addClassController;
  final List<String> classAvailableIcons;
  final ValueChanged<String?> addClassOnChanged;
  final String addClassSelectedIcon;
  final Future<bool> Function() addClassOnAddPressed;

  final Function(String) validateClassName;

  const AddClassPage({
    super.key,
    required this.addClassController,
    required this.classAvailableIcons,
    required this.addClassOnChanged,
    required this.addClassSelectedIcon,
    required this.addClassOnAddPressed,
    required this.validateClassName,
  });

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
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
                controller: widget.addClassController,
                validator: (value) {
                  return widget.validateClassName(value ?? '');
                },
              ),
              const SizedBox(height: 20),
              const Text('Pilih Ikon:'),
              SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  value: widget.addClassSelectedIcon,
                  items: widget.classAvailableIcons
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
                  onChanged: widget.addClassOnChanged,
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });
                            if (formKey.currentState?.validate() ?? false) {
                              final success =
                                  await widget.addClassOnAddPressed();
                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Kelas berhasil dibuat'),
                                  ),
                                );
                              }
                            }

                            setState(() {
                              isLoading = false;
                            });
                          },
                    child: isLoading
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

class JoinClassDialog extends StatefulWidget {
  final Future<bool> Function(String) onJoin;
  final Function(String) validateClasscode;

  const JoinClassDialog({
    super.key,
    required this.onJoin,
    required this.validateClasscode,
  });

  @override
  State<JoinClassDialog> createState() => _JoinClassDialogState();
}

class _JoinClassDialogState extends State<JoinClassDialog> {
  String kodeKelas = '';
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                  setState(() {
                    kodeKelas = value;
                  });
                },
                validator: (value) {
                  return widget.validateClasscode(value ?? '');
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (formKey.currentState?.validate() ?? false) {
                              setState(() {
                                isLoading = true;
                              });

                              final navigator = Navigator.of(context);
                              final success = await widget.onJoin(kodeKelas);
                              if (success) {
                                navigator.pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Berhasil bergabung ke kelas'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Kode kelas tidak ditemukan'),
                                  ),
                                );
                              }
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Gabung'),
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

import 'package:flutter/material.dart';

class AddClassPage extends StatelessWidget {
  final TextEditingController addClassController;
  final List<String> classAvailableIcons;
  final ValueChanged<String?> addClassOnChanged;
  final String addClassSelectedIcon;
  final bool addClassIsLoading;
  final VoidCallback addClassOnAddPressed;

  const AddClassPage({
    super.key,
    required this.addClassController,
    required this.classAvailableIcons,
    required this.addClassOnChanged,
    required this.addClassSelectedIcon,
    required this.addClassIsLoading,
    required this.addClassOnAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kelas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: 'Nama Kelas'),
              controller: addClassController,
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: addClassIsLoading ? null : addClassOnAddPressed,
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

class JoinClassDialog {
  final Function(String) onJoin;

  JoinClassDialog({required this.onJoin});

  void show(BuildContext context) {
    String kodeKelas = '';
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Gabung Kelas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration:
                        const InputDecoration(hintText: 'Masukkan Kode Kelas'),
                    onChanged: (value) {
                      kodeKelas = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                await onJoin(kodeKelas);
                                kodeKelas = '';
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Gabung'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

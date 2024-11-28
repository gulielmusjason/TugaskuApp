import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class MemberListAddView extends StatelessWidget {
  final List<String> selectedMembers;
  final Function(List<String>) onMembersChanged;
  final List<String> items;
  final VoidCallback onCancel;
  final VoidCallback onAdd;

  const MemberListAddView({
    super.key,
    required this.selectedMembers,
    required this.onMembersChanged,
    required this.items,
    required this.onCancel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tambah Anggota Baru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownSearch<String>.multiSelection(
              items: (filter, infiniteScrollProps) => Future.value(items),
              popupProps: PopupPropsMultiSelection.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Cari berdasarkan username atau email",
                  ),
                ),
              ),
              selectedItems: selectedMembers,
              onChanged: onMembersChanged,
              dropdownBuilder: (context, selectedItems) {
                if (selectedItems.isEmpty) {
                  return const Text("Pilih anggota");
                }
                return Text(selectedItems
                    .map((item) => item.split('\n')[0])
                    .join(', '));
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: onCancel,
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAdd,
                  child: const Text('Tambah'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

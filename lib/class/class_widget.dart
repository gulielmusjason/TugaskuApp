import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class AddNewMember extends StatefulWidget {
  final VoidCallback onAdd;

  final Function(String, String) addMemberToFirestore;
  final List<Map<String, dynamic>> members;
  final String? selectedMember;
  final Function(String?) onMemberSelected;

  const AddNewMember({
    super.key,
    required this.onAdd,
    required this.addMemberToFirestore,
    required this.members,
    required this.selectedMember,
    required this.onMemberSelected,
  });

  @override
  State<AddNewMember> createState() => _AddNewMemberState();
}

class _AddNewMemberState extends State<AddNewMember> {
  List<String> selectedMembers = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Anggota Baru'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownSearch<String>.multiSelection(
            items: (filter, infiniteScrollProps) => Future.value(widget.members
                .map((member) => '${member['email']} (${member['role']})')
                .toList()),
            popupProps: PopupPropsMultiSelection.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Cari berdasarkan email",
                ),
              ),
            ),
            selectedItems: selectedMembers,
            onChanged: (List<String> items) {
              setState(() {
                selectedMembers = items;
              });
              widget.onMemberSelected(
                  selectedMembers.isNotEmpty ? selectedMembers.first : null);
            },
            dropdownBuilder: (context, selectedItems) {
              return Text(selectedItems.join(', '));
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Batal'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: () {
            for (var member in selectedMembers) {
              var memberData = widget.members.firstWhere(
                (m) => '${m['email']} (${m['role']})' == member,
                orElse: () => <String, dynamic>{},
              );
              if (memberData.isNotEmpty) {
                widget.addMemberToFirestore(
                    memberData['email'], memberData['role']);
              }
            }
            Navigator.of(context).pop();
          },
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}

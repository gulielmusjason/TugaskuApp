import 'package:flutter/material.dart';
import 'class_memberlist_add_page.dart';

class MemberListView extends StatelessWidget {
  final String role;
  final String classCode;
  final String className;
  final List<Map<String, dynamic>> members;
  final Function(String) deleteMember;

  const MemberListView({
    super.key,
    required this.role,
    required this.classCode,
    required this.className,
    required this.members,
    required this.deleteMember,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: _buildMemberList(),
        ),
        if (role == 'Guru') _buildFloatingActionButton(context),
      ],
    );
  }

  Widget _buildMemberList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        final theme = Theme.of(context);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(11),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: theme.primaryColor,
                child: Text(
                  member['username'][0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                member['username'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.primaryColor.withAlpha(51),
                      ),
                    ),
                    child: Text(
                      member['role'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        member['email'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing:
                  role == 'Guru' ? _buildPopupMenu(member['email']) : null,
              onTap: () {},
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupMenu(String email) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'delete') {
          deleteMember(email);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Hapus Anggota'),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        heroTag: 'AddMemberButton',
        onPressed: () async {
          if (context.mounted) {
            _showAddNewMemberDialog(context);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddNewMemberDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MemberListAddPage(classCode: classCode),
    );
  }
}

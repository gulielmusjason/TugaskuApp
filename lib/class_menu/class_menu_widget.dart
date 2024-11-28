import 'package:flutter/material.dart';

class ClassMenuCard extends StatelessWidget {
  final String classIconName;
  final String className;
  final VoidCallback onTap;

  const ClassMenuCard({
    super.key,
    required this.classIconName,
    required this.className,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: ListTile(
          leading: Icon(_getIcon(classIconName),
              color: Theme.of(context).primaryColor, size: 30),
          title:
              Text(className, style: Theme.of(context).textTheme.titleMedium),
          trailing: const Icon(Icons.arrow_forward_ios, size: 15),
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

// custom_widgets.dart
import 'package:flutter/material.dart';



Widget buildTopDivider() {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 600),
    child: const Divider(
      color: Color(0xFFE7E7E7),
      thickness: 1,
      height: 0.5,
    ),
  );
}

Widget buildDivider() {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 600),
    child: const Divider(
      color: Color(0xFFE7E7E7),
      thickness: 0.1,
      height: 0.1,
    ),
  );
}

Widget buildAddBox({
  required String label,
  required int count,
  required int max,
  required VoidCallback onAdd,
}) {
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF000000)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('$count/$max', style: const TextStyle(fontSize: 12)),
            ),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(Icons.add, size: 12),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildEditableBox({
  required String text,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  return Column(
    children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Color(0xFF3D3D3D),
                  ),
                ),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 12,
                  icon: const Icon(Icons.more_vert, size: 20),
                  color: const Color(0xFFE9EFF0),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    else if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('수정하기')),
                    PopupMenuItem(value: 'delete', child: Text('삭제하기')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      buildDivider(),
    ],
  );
}

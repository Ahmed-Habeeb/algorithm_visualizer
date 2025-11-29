import 'package:flutter/material.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/utils/adaptive_layout.dart';
import '../../data/structures/binary_search_tree.dart';
import '../../data/structures/linked_list_ds.dart';
import '../../data/structures/queue_ds.dart';
import '../../data/structures/stack_ds.dart';
import '../../domain/interfaces/data_structure.dart';

class DSListPage extends StatelessWidget {
  DSListPage({super.key});

  final List<DataStructure> _structures = [
    StackDS(),
    QueueDS(),
    LinkedListDS(),
    BinarySearchTree(),
  ];

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = AdaptiveLayout.getGridCrossAxisCount(
      context,
      mobileCols: 1,
      tabletCols: 2,
      desktopCols: 2,
    );
    final spacing = AdaptiveLayout.getSpacing(context);
    final padding = AdaptiveLayout.getAdaptivePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Structures'),
        centerTitle: AdaptiveLayout.isDesktop(context),
      ),
      body: ConstrainedContent(
        maxWidth: 1200,
        child: GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: AdaptiveLayout.isMobile(context) ? 2.0 : 1.8,
          ),
          itemCount: _structures.length,
          itemBuilder: (context, index) {
            final structure = _structures[index].info;
            return _StructureCard(
              name: structure.name,
              description: structure.description,
              category: structure.category,
              operations: structure.operations,
              onTap: () => Navigator.pushNamed(
                context,
                Routes.dataStructuresVisualizer,
                arguments: structure.id,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StructureCard extends StatelessWidget {
  final String name;
  final String description;
  final String category;
  final List<String> operations;
  final VoidCallback onTap;

  const _StructureCard({
    required this.name,
    required this.description,
    required this.category,
    required this.operations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLinear = category == 'linear';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isLinear ? Icons.view_list : Icons.account_tree,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isLinear ? Colors.blue : Colors.purple).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isLinear ? 'Linear' : 'Non-Linear',
                      style: TextStyle(
                        fontSize: 10,
                        color: isLinear ? Colors.blue : Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: operations.take(4).map((op) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      op,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.primaryColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

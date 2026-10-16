import 'package:flutter/material.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';

class SearchHistorySection extends StatelessWidget {
  final List<String> history;
  final Function(String) onSearch;
  final Function(String) onRemove;
  final VoidCallback onClearAll;

  const SearchHistorySection({
    super.key,
    required this.history,
    required this.onSearch,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: AppTheme.textLight.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text('No recent searches', style: TextStyle(color: AppTheme.textLight, fontSize: 16)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Searches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: onClearAll,
                child: const Text('Clear All', style: TextStyle(color: AppTheme.primary, fontSize: 13)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final term = history[index];
              return ListTile(
                leading: const Icon(Icons.history_rounded, color: AppTheme.textLight),
                title: Text(term, style: const TextStyle(fontSize: 15)),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.textLight),
                  onPressed: () => onRemove(term),
                ),
                onTap: () => onSearch(term),
              );
            },
          ),
        ),
      ],
    );
  }
}

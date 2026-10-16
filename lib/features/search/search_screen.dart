import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saris_cosmo_center/core/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:saris_cosmo_center/features/search/widgets/search_history_section.dart';
import 'package:saris_cosmo_center/features/search/widgets/search_results_section.dart';
import 'package:saris_cosmo_center/features/search/controllers/search_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AppSearchController _searchApiCtrl = Get.put(AppSearchController());
  String _query = '';
  List<String> _history = [];
  Timer? _debounce;
  static const String _historyKey = 'search_history';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList(_historyKey) ?? [];
    });
  }

  Future<void> _saveQueryToHistory(String query) async {
    final term = query.trim();
    if (term.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> currentHistory = prefs.getStringList(_historyKey) ?? [];
    
    // Remove if already exists to move it to the top
    currentHistory.remove(term);
    currentHistory.insert(0, term);
    
    // Keep only top 10
    if (currentHistory.length > 10) {
      currentHistory = currentHistory.sublist(0, 10);
    }

    await prefs.setStringList(_historyKey, currentHistory);
    setState(() {
      _history = currentHistory;
    });
  }

  Future<void> _removeFromHistory(String term) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentHistory = prefs.getStringList(_historyKey) ?? [];
    currentHistory.remove(term);
    await prefs.setStringList(_historyKey, currentHistory);
    setState(() {
      _history = currentHistory;
    });
  }

  Future<void> _clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    setState(() {
      _history = [];
    });
  }

  void _onSearchSubmit(String val) {
    _saveQueryToHistory(val);
    _focusNode.unfocus();
    _searchApiCtrl.performSearch(val);
  }

  void _onHistoryItemTap(String term) {
    _searchController.text = term;
    setState(() {
      _query = term;
    });
    _saveQueryToHistory(term); // Move to top
    _focusNode.unfocus();
    _searchApiCtrl.performSearch(term);
  }

  void _onSearchChanged(String val) {
    setState(() {
      _query = val;
    });
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchApiCtrl.performSearch(val);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0.5,
          title: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmit,
            decoration: InputDecoration(
              hintText: 'Search products, courses, services...',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              filled: false,
              hintStyle: TextStyle(color: AppTheme.textLight.withValues(alpha: 0.7), fontSize: 14),
            ),
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            if (_query.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppTheme.textLight),
                onPressed: () {
                  _searchController.clear();
                  _searchApiCtrl.clearSearch();
                  setState(() {
                    _query = '';
                  });
                  _focusNode.requestFocus();
                },
              ),
          ],
        ),
        body: _query.isEmpty
            ? SearchHistorySection(
                history: _history,
                onSearch: _onHistoryItemTap,
                onRemove: _removeFromHistory,
                onClearAll: _clearAllHistory,
              )
            : Obx(() {
                if (_searchApiCtrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }
                if (_searchApiCtrl.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            _searchApiCtrl.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.textMedium, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _searchApiCtrl.performSearch(_query),
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    ),
                  );
                }
                return SearchResultsSection(
                  products: _searchApiCtrl.products,
                  courses: _searchApiCtrl.courses,
                  services: _searchApiCtrl.services,
                );
              }),
      ),
    );
  }
}

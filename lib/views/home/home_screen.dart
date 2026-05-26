import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intricue_app/utils/my_print.dart';

import '../../blocs/recruiter/recruiter_bloc.dart';
import '../../blocs/recruiter/recruiter_events.dart';
import '../../blocs/recruiter/recruiter_state.dart';

// 🔥 Replace with your actual base URL (Firebase Hosting URL or localhost)
const String kBaseUrl = 'https://intricue-3804f.web.app/profile';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Load first page on mount
    context.read<RecruiterBloc>().add(FetchAllRecruiters());

    // Pagination — load more when near bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final bloc = context.read<RecruiterBloc>();

        if (!bloc.state.isLoading && bloc.state.hasMore) {
          bloc.add(FetchMoreRecruiters());
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // we handle dismiss manually
      builder: (_) => BlocProvider.value(
        value: context.read<RecruiterBloc>(),
        child: const _AddRecruiterDialog(),
      ),
    ).then((_) {
      final bloc = context.read<RecruiterBloc>();

      if (bloc.state.searchQuery.isNotEmpty) {
        bloc.add(SearchRecruiters(bloc.state.searchQuery));
      } else {
        bloc.add(FetchAllRecruiters());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 50,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search recruiters...",
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),

            onChanged: (value) {
              MyPrint.printOnConsole("search $value");
              setState(() {
                
              });

              _debounce?.cancel();

              _debounce = Timer(const Duration(milliseconds: 500), () {
                if (value.trim().isEmpty) {
                  context.read<RecruiterBloc>().add(FetchAllRecruiters());
                } else {
                  context.read<RecruiterBloc>().add(
                    SearchRecruiters(value.trim()),
                  );
                }
              });
            },
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();

                context.read<RecruiterBloc>().add(FetchAllRecruiters());
                setState(() {
                  
                });
              },
            ),
          // IconButton(
          //   icon: const Icon(Icons.add),
          //   tooltip: "Add Recruiter",
          //   onPressed: _openAddDialog,
          // ),
        ],
      ),
      body: BlocBuilder<RecruiterBloc, RecruiterState>(
        builder: (context, state) {
          if (state.isLoading && state.recruiters.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.recruiters.isEmpty) {
            return Center(
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state.recruiters.isEmpty) {
            return const Center(child: Text("No recruiters yet. Add one!"));
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.recruiters.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Pagination loader at bottom
              if (index == state.recruiters.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final recruiter = state.recruiters[index];
              final docId = recruiter['id'] as String? ?? '';
              final name = recruiter['name'] as String? ?? 'Unknown';
              final company = recruiter['recent_company'] as String? ?? '';
              final role = recruiter['recent_role'] as String? ?? '';
              final link = '$kBaseUrl?id=$docId';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Name + company
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (company.isNotEmpty)
                        Text(
                          '$role • $company',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),

                      const SizedBox(height: 12),

                      /// Copyable link row
                      _LinkRow(link: link),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.person_add),
        label: const Text("Add Recruiter"),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Copyable link row with copy + close
// ────────────────────────────────────────────────
class _LinkRow extends StatefulWidget {
  final String link;
  const _LinkRow({required this.link});

  @override
  State<_LinkRow> createState() => _LinkRowState();
}

class _LinkRowState extends State<_LinkRow> {
  bool _copied = false;
  bool _dismissed = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.link));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          /// Link text
          Expanded(
            child: Text(
              widget.link,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          /// Copy button
          IconButton(
            icon: Icon(
              _copied ? Icons.check : Icons.copy,
              size: 18,
              color: _copied ? Colors.green : Colors.grey[700],
            ),
            tooltip: _copied ? "Copied!" : "Copy link",
            onPressed: _copy,
          ),

          /// Close / dismiss button (shows after copy)
          if (_copied)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              tooltip: "Dismiss",
              onPressed: () => setState(() => _dismissed = true),
            ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Add Recruiter Dialog
// ────────────────────────────────────────────────
class _AddRecruiterDialog extends StatefulWidget {
  const _AddRecruiterDialog();

  @override
  State<_AddRecruiterDialog> createState() => _AddRecruiterDialogState();
}

class _AddRecruiterDialogState extends State<_AddRecruiterDialog> {
  final _promptCtrl = TextEditingController();
  bool _hasContent = false;
  bool _linkReady = false;

  @override
  void initState() {
    super.initState();
    _promptCtrl.addListener(() {
      setState(() => _hasContent = _promptCtrl.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop(RecruiterState state) async {
    // If link is ready (saved), allow close freely
    if (_linkReady || state.savedDocId != null) return true;

    // If nothing typed, allow close freely
    if (!_hasContent && state.generatedData == null) return true;

    // Otherwise warn
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Discard changes?"),
        content: const Text(
          "You have unsaved data. If you close now, it will be lost.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Keep editing"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Discard", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecruiterBloc, RecruiterState>(
      listener: (context, state) {
        if (state.savedDocId != null) {
          setState(() => _linkReady = true);
        }
      },
      builder: (context, state) {
        final savedDocId = state.savedDocId;
        final link = savedDocId != null ? '$kBaseUrl?id=$savedDocId' : null;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final should = await _onWillPop(state);
            if (should && context.mounted) {
              context.read<RecruiterBloc>().add(ClearSavedDoc());
              Navigator.of(context).pop();
            }
          },
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Add Recruiter",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            final should = await _onWillPop(state);
                            if (should && context.mounted) {
                              context.read<RecruiterBloc>().add(
                                ClearSavedDoc(),
                              );
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Step 1: Input ──
                    if (link == null) ...[
                      TextField(
                        controller: _promptCtrl,
                        maxLines: 6,
                        enabled: !state.isLoading,
                        decoration: const InputDecoration(
                          hintText: "Paste LinkedIn profile text here...",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// Extract button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isLoading || !_hasContent
                              ? null
                              : () {
                                  context.read<RecruiterBloc>().add(
                                    GenerateContent(_promptCtrl.text),
                                  );
                                },
                          child: state.isLoading && state.generatedData == null
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Extract Profile"),
                        ),
                      ),

                      /// Error
                      if (state.error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          state.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],

                      /// Extracted data preview
                      if (state.generatedData != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        _PreviewRow("Name", state.generatedData!.name),
                        _PreviewRow("Email", state.generatedData!.email),
                        _PreviewRow("Headline", state.generatedData!.headline),
                        _PreviewRow(
                          "Company",
                          state.generatedData!.recentCompany,
                        ),
                        _PreviewRow("Role", state.generatedData!.recentRole),
                        _PreviewRow(
                          "Experience",
                          state.generatedData!.experienceYears,
                        ),
                        _PreviewRow(
                          "Skills",
                          state.generatedData!.skills?.join(", "),
                        ),

                        const SizedBox(height: 16),

                        /// Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: state.isSaving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("Save to Firestore"),
                            onPressed: state.isSaving
                                ? null
                                : () {
                                    context.read<RecruiterBloc>().add(
                                      SaveRecruiter(
                                        state.generatedData!.toJson(),
                                      ),
                                    );
                                  },
                          ),
                        ),
                      ],
                    ],

                    // ── Step 2: Link ready ──
                    if (link != null) ...[
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Recruiter saved! Share this link:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _LinkRow(link: link),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text("Close"),
                          onPressed: () {
                            context.read<RecruiterBloc>().add(ClearSavedDoc());
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────
// Small helper for preview rows
// ────────────────────────────────────────────────
class _PreviewRow extends StatelessWidget {
  final String label;
  final String? value;
  const _PreviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/presentation/providers/debug_provider.dart';
import 'package:manager_app/core/theme/app_colors.dart';

/// A persistent overlay that shows recent errors when debug mode is on.
///
/// Collapsed: single-line latest error with red accent.
/// Expanded: scrollable list of all errors with timestamps + details.
class DebugOverlay extends ConsumerStatefulWidget {
  const DebugOverlay({super.key});

  @override
  ConsumerState<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends ConsumerState<DebugOverlay> {
  bool _expanded = false;
  int? _expandedEntry;

  @override
  Widget build(BuildContext context) {
    final debug = ref.watch(debugProvider);

    if (!debug.debugMode || !debug.hasErrors) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.all(8),
            constraints: BoxConstraints(
              maxHeight: _expanded
                  ? MediaQuery.of(context).size.height * 0.45
                  : 52,
            ),
            decoration: BoxDecoration(
              color: const Color(0xEE1A1A2E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _expanded
                  ? _buildExpanded(debug)
                  : _buildCollapsed(debug),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsed(DebugNotifier debug) {
    final latest = debug.errors.first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.bug_report_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${latest.tag}: ${latest.message}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${debug.errors.length}',
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.expand_less_rounded,
              color: Colors.white38, size: 18),
        ],
      ),
    );
  }

  Widget _buildExpanded(DebugNotifier debug) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.bug_report_rounded,
                  color: AppColors.error, size: 18),
              const SizedBox(width: 8),
              Text(
                'Debug Log (${debug.errors.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _copyAllErrors(debug),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded, color: Colors.white60, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Copy All',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  debug.clearErrors();
                  setState(() => _expanded = false);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.expand_more_rounded,
                  color: Colors.white38, size: 18),
            ],
          ),
        ),

        // Error list
        Flexible(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            shrinkWrap: true,
            itemCount: debug.errors.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: Colors.white.withValues(alpha: 0.05),
            ),
            itemBuilder: (context, index) {
              final entry = debug.errors[index];
              final isExpanded = _expandedEntry == index;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _expandedEntry = isExpanded ? null : index;
                  });
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            entry.shortTimestamp,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry.tag,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.message,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isExpanded)
                            GestureDetector(
                              onTap: () => _copyEntry(entry),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(Icons.copy_rounded,
                                    color: Colors.white38, size: 14),
                              ),
                            ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: Colors.white24,
                            size: 16,
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 6),
                        if (entry.error != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              entry.error!,
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        if (entry.stackTrace != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              entry.stackTrace!,
                              style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.4),
                                fontSize: 9,
                                fontFamily: 'monospace',
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _copyEntry(DebugErrorEntry entry) {
    final buffer = StringBuffer()
      ..writeln('[${entry.shortTimestamp}] ${entry.tag}')
      ..writeln(entry.message);
    if (entry.error != null) buffer.writeln(entry.error);
    if (entry.stackTrace != null) buffer.writeln(entry.stackTrace);
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _copyAllErrors(DebugNotifier debug) {
    final buffer = StringBuffer();
    for (final entry in debug.errors) {
      buffer.writeln('═══ [${entry.shortTimestamp}] ${entry.tag} ═══');
      buffer.writeln(entry.message);
      if (entry.error != null) buffer.writeln(entry.error);
      if (entry.stackTrace != null) buffer.writeln(entry.stackTrace);
      buffer.writeln();
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${debug.errors.length} error(s) copied to clipboard'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}

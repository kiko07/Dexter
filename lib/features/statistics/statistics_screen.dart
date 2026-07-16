import 'dart:math' as math;

import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import 'statistics_provider.dart';

enum _BreakdownDimension { source, profile }

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  _BreakdownDimension _dimension = _BreakdownDimension.source;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(statisticsProvider);
    final notifier = ref.read(statisticsProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: notifier.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.statisticsSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: state.isLoading ? null : notifier.refresh,
                        tooltip: l10n.refresh,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.error != null && state.snapshot.totalRecords == 0)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _StatisticsError(
                    message: l10n.errorOccurred(state.error!),
                    onRetry: notifier.refresh,
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _RangeSelector(
                      value: state.range,
                      enabled: !state.isLoading,
                      onChanged: notifier.setRange,
                    ),
                  ),
                ),
                if (state.isLoading)
                  const SliverToBoxAdapter(
                    child: LinearProgressIndicator(minHeight: 2),
                  )
                else
                  const SliverToBoxAdapter(child: SizedBox(height: 2)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: SliverList.list(
                    children: [
                      _SummaryGrid(snapshot: state.snapshot),
                      const SizedBox(height: 16),
                      _TimelineSection(
                        points: state.snapshot.timeline,
                        range: state.range,
                      ),
                      const SizedBox(height: 16),
                      _BreakdownSection(
                        dimension: _dimension,
                        values: _dimension == _BreakdownDimension.source
                            ? state.snapshot.bySource
                            : state.snapshot.byProfile,
                        onDimensionChanged: (value) {
                          setState(() => _dimension = value);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  final StatisticsRange value;
  final bool enabled;
  final ValueChanged<StatisticsRange> onChanged;

  const _RangeSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DropdownButtonFormField<StatisticsRange>(
      initialValue: value,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.date_range_rounded),
        labelText: l10n.timeRange,
      ),
      items: [
        DropdownMenuItem(
          value: StatisticsRange.last7Days,
          child: Text(l10n.last7Days),
        ),
        DropdownMenuItem(
          value: StatisticsRange.last30Days,
          child: Text(l10n.last30Days),
        ),
        DropdownMenuItem(
          value: StatisticsRange.allTime,
          child: Text(l10n.allTime),
        ),
      ],
      onChanged: enabled
          ? (range) {
              if (range != null) onChanged(range);
            }
          : null,
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final StatisticsSnapshot snapshot;

  const _SummaryGrid({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final format = intl.NumberFormat.decimalPattern(locale);
    final cards = [
      (
        l10n.totalRecords.replaceAll(':', ''),
        snapshot.totalRecords,
        Icons.storage_rounded,
      ),
      (l10n.manualRecords, snapshot.manualRecords, Icons.edit_note_rounded),
      (l10n.indexedFiles, snapshot.indexedFiles, Icons.folder_copy_rounded),
      (l10n.profiles, snapshot.profiles, Icons.account_tree_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        final spacing = 12.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards)
              SizedBox(
                width: width,
                child: _SummaryCard(
                  label: card.$1,
                  value: format.format(card.$2),
                  icon: card.$3,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final List<TimelinePoint> points;
  final StatisticsRange range;

  const _TimelineSection({required this.points, required this.range});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final total = points.fold(0, (sum, point) => sum + point.count);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recordsOverTime,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  l10n.recordsCount(total),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (points.isEmpty)
              _EmptyChart(message: l10n.noStatisticsData)
            else
              _TimelineChart(points: points, range: range),
          ],
        ),
      ),
    );
  }
}

class _TimelineChart extends StatefulWidget {
  final List<TimelinePoint> points;
  final StatisticsRange range;

  const _TimelineChart({required this.points, required this.range});

  @override
  State<_TimelineChart> createState() => _TimelineChartState();
}

class _TimelineChartState extends State<_TimelineChart> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant _TimelineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndex != null && _selectedIndex! >= widget.points.length) {
      _selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = widget.range == StatisticsRange.allTime
        ? intl.DateFormat.yMMM(locale)
        : intl.DateFormat.MMMd(locale);
    final labels = [
      for (final point in widget.points) dateFormat.format(point.periodStart),
    ];
    final selected = _selectedIndex == null
        ? null
        : widget.points[_selectedIndex!];

    return Semantics(
      label:
          '${l10n.recordsOverTime}. '
          '${l10n.recordsCount(widget.points.fold(0, (sum, point) => sum + point.count))}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  const leftInset = 38.0;
                  const rightInset = 12.0;
                  final plotWidth = math.max(
                    1.0,
                    constraints.maxWidth - leftInset - rightInset,
                  );
                  final relative =
                      ((details.localPosition.dx - leftInset) / plotWidth)
                          .clamp(0.0, 1.0);
                  final index = (relative * (widget.points.length - 1)).round();
                  setState(() => _selectedIndex = index);
                },
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 220),
                  painter: _TimelinePainter(
                    points: widget.points,
                    labels: labels,
                    selectedIndex: _selectedIndex,
                    colorScheme: Theme.of(context).colorScheme,
                    textStyle: Theme.of(context).textTheme.bodySmall!,
                    textDirection: Directionality.of(context),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            selected == null
                ? '${labels.first} — ${labels.last}'
                : '${labels[_selectedIndex!]} · ${l10n.recordsCount(selected.count)}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final List<TimelinePoint> points;
  final List<String> labels;
  final int? selectedIndex;
  final ColorScheme colorScheme;
  final TextStyle textStyle;
  final TextDirection textDirection;

  const _TimelinePainter({
    required this.points,
    required this.labels,
    required this.selectedIndex,
    required this.colorScheme,
    required this.textStyle,
    required this.textDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 38.0;
    const right = 12.0;
    const top = 12.0;
    const bottom = 28.0;
    final width = size.width - left - right;
    final height = size.height - top - bottom;
    final maxValue = math.max(
      1,
      points.fold(0, (max, p) => math.max(max, p.count)),
    );
    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.55)
      ..strokeWidth = 1;

    for (var step = 0; step <= 2; step++) {
      final y = top + height * step / 2;
      canvas.drawLine(Offset(left, y), Offset(left + width, y), gridPaint);
      _paintText(
        canvas,
        '${(maxValue * (2 - step) / 2).round()}',
        Offset(0, y - 7),
        maxWidth: left - 6,
        align: TextAlign.end,
      );
    }

    final path = Path();
    final fillPath = Path();
    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? left + width / 2
          : left + width * i / (points.length - 1);
      final y = top + height * (1 - points[i].count / maxValue);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath
          ..moveTo(x, top + height)
          ..lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    final lastX = points.length == 1 ? left + width / 2 : left + width;
    fillPath
      ..lineTo(lastX, top + height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = colorScheme.primary.withValues(alpha: 0.12),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = colorScheme.primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final markerPaint = Paint()..color = colorScheme.primary;
    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? left + width / 2
          : left + width * i / (points.length - 1);
      final y = top + height * (1 - points[i].count / maxValue);
      if (i == selectedIndex) {
        canvas.drawLine(
          Offset(x, top),
          Offset(x, top + height),
          Paint()
            ..color = colorScheme.primary.withValues(alpha: 0.3)
            ..strokeWidth = 1,
        );
      }
      canvas.drawCircle(Offset(x, y), i == selectedIndex ? 5 : 3, markerPaint);
    }

    final labelIndexes = <int>{0, points.length ~/ 2, points.length - 1};
    for (final index in labelIndexes) {
      final x = points.length == 1
          ? left + width / 2
          : left + width * index / (points.length - 1);
      _paintText(
        canvas,
        labels[index],
        Offset(x - 38, top + height + 7),
        maxWidth: 76,
        align: TextAlign.center,
      );
    }
  }

  void _paintText(
    Canvas canvas,
    String value,
    Offset offset, {
    required double maxWidth,
    TextAlign align = TextAlign.start,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: textStyle.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      textDirection: textDirection,
      textAlign: align,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.textDirection != textDirection;
  }
}

class _BreakdownSection extends StatelessWidget {
  final _BreakdownDimension dimension;
  final List<CategoryStatistic> values;
  final ValueChanged<_BreakdownDimension> onDimensionChanged;

  const _BreakdownSection({
    required this.dimension,
    required this.values,
    required this.onDimensionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.breakdown,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.bySourceFile),
                  selected: dimension == _BreakdownDimension.source,
                  onSelected: (_) {
                    onDimensionChanged(_BreakdownDimension.source);
                  },
                ),
                ChoiceChip(
                  label: Text(l10n.byProfile),
                  selected: dimension == _BreakdownDimension.profile,
                  onSelected: (_) {
                    onDimensionChanged(_BreakdownDimension.profile);
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (values.isEmpty)
              _EmptyChart(message: l10n.noStatisticsData)
            else
              _HorizontalBars(values: values),
          ],
        ),
      ),
    );
  }
}

class _HorizontalBars extends StatelessWidget {
  final List<CategoryStatistic> values;

  const _HorizontalBars({required this.values});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final format = intl.NumberFormat.decimalPattern(locale);
    final maxValue = math.max(
      1,
      values.fold(0, (max, value) => math.max(max, value.count)),
    );

    return Column(
      children: [
        for (var index = 0; index < values.length; index++) ...[
          Semantics(
            label:
                '${values[index].label ?? l10n.manualSource}: ${l10n.recordsCount(values[index].count)}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        values[index].label ?? l10n.manualSource,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      format.format(values[index].count),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: values[index].count / maxValue,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.primary,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ],
            ),
          ),
          if (index != values.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String message;

  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _StatisticsError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _StatisticsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.query_stats_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.refresh),
            ),
          ],
        ),
      ),
    );
  }
}

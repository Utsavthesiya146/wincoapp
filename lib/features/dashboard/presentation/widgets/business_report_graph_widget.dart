import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/member_dashboard_model.dart';

class BusinessReportGraphWidget extends StatefulWidget {
  final BusinessReportChartData chartData;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const BusinessReportGraphWidget({
    super.key,
    required this.chartData,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  State<BusinessReportGraphWidget> createState() => _BusinessReportGraphWidgetState();
}

class _BusinessReportGraphWidgetState extends State<BusinessReportGraphWidget> {
  int? _selectedPointIndex;

  String _formatCurrency(double val) {
    if (val >= 10000000) {
      final cr = val / 10000000;
      return '₹${cr.toStringAsFixed(cr.truncateToDouble() == cr ? 0 : 2)} Cr';
    } else if (val >= 100000) {
      final lk = val / 100000;
      return '₹${lk.toStringAsFixed(lk.truncateToDouble() == lk ? 0 : 2)} L';
    } else if (val >= 1000) {
      final k = val / 1000;
      return '₹${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    return '₹${val.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final chart = widget.chartData;
    final hasData = chart.labels.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Title & Filter Switcher (Overflow-proof)
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBurgundy.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.show_chart_rounded,
                        color: AppColors.primaryBurgundy,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Business Performance',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Dual-series revenue analytics',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _buildFilterChips(),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Dual-Series Legend & Totals (Overflow-proof)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 0.8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF28A745),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Received',
                              style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              _formatCurrency(chart.totalReceived),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF28A745),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 24, width: 1, color: Colors.grey.shade300),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFCF2030),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Given',
                              style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              _formatCurrency(chart.totalGiven),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFCF2030),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Interactive Tooltip Callout if a point is tapped (Overflow-proof)
          if (_selectedPointIndex != null && _selectedPointIndex! < chart.labels.length) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBurgundy,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      chart.labels[_selectedPointIndex!],
                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Received: ${_formatCurrency(chart.receivedData[_selectedPointIndex!])}',
                      style: const TextStyle(color: Color(0xFF81C784), fontSize: 10.5, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Given: ${_formatCurrency(chart.givenData[_selectedPointIndex!])}',
                      style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 10.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 4. Custom Responsive Chart Canvas
          SizedBox(
            height: 180,
            width: double.infinity,
            child: hasData
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapUp: (details) {
                          _handleTap(details.localPosition, constraints.maxWidth, constraints.maxHeight);
                        },
                        child: CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: BusinessReportChartPainter(
                            labels: chart.labels,
                            givenData: chart.givenData,
                            receivedData: chart.receivedData,
                            selectedIndex: _selectedPointIndex,
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'No revenue records available for this filter period',
                      style: TextStyle(color: Colors.black45, fontSize: 12),
                    ),
                  ),
          ),
          const SizedBox(height: 6),

          // 5. Footer Hint
          Center(
            child: Text(
              'Tap any point to inspect timeline breakdown',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(Offset pos, double width, double height) {
    const leftPad = 48.0;
    const rightPad = 16.0;
    final chartWidth = width - leftPad - rightPad;
    final labels = widget.chartData.labels;
    if (labels.isEmpty) return;

    if (labels.length == 1) {
      setState(() {
        _selectedPointIndex = _selectedPointIndex == 0 ? null : 0;
      });
      return;
    }

    final stepX = chartWidth / (labels.length - 1);
    final touchX = pos.dx - leftPad;
    final index = (touchX / stepX).round().clamp(0, labels.length - 1);

    setState(() {
      _selectedPointIndex = _selectedPointIndex == index ? null : index;
    });
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': '15D', 'filter': '7'},
      {'label': '1M', 'filter': '30'},
      {'label': '6M', 'filter': '180'},
      {'label': '12M', 'filter': '365'},
      {'label': 'All', 'filter': 'all'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: filters.map((f) {
          final isSelected = widget.activeFilter == f['filter'] ||
              (f['filter'] == 'all' && (widget.activeFilter == 'Lifetime' || widget.activeFilter == 'all')) ||
              (f['filter'] == '180' && widget.activeFilter == '6M') ||
              (f['filter'] == '365' && widget.activeFilter == '12M') ||
              (f['filter'] == '7' && widget.activeFilter == '15D') ||
              (f['filter'] == '30' && widget.activeFilter == '1M');

          return Padding(
            padding: const EdgeInsets.only(left: 3),
            child: InkWell(
              onTap: () => widget.onFilterChanged(f['filter']!),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBurgundy : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBurgundy : Colors.grey.shade300,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BusinessReportChartPainter extends CustomPainter {
  final List<String> labels;
  final List<double> givenData;
  final List<double> receivedData;
  final int? selectedIndex;

  BusinessReportChartPainter({
    required this.labels,
    required this.givenData,
    required this.receivedData,
    this.selectedIndex,
  });

  String _formatAxisLabel(double val) {
    if (val >= 10000000) {
      final cr = val / 10000000;
      return '₹${cr.toStringAsFixed(cr.truncateToDouble() == cr ? 0 : 1)}Cr';
    } else if (val >= 100000) {
      final lk = val / 100000;
      return '₹${lk.toStringAsFixed(lk.truncateToDouble() == lk ? 0 : 1)}L';
    } else if (val >= 1000) {
      final k = val / 1000;
      return '₹${k.toStringAsFixed(0)}k';
    }
    return '₹${val.toStringAsFixed(0)}';
  }

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 48.0;
    const rightPad = 16.0;
    const topPad = 18.0;
    const bottomPad = 26.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    // 1. Calculate Maximum Y Value with headroom
    double maxVal = 0.0;
    for (final v in givenData) {
      if (v > maxVal) maxVal = v;
    }
    for (final v in receivedData) {
      if (v > maxVal) maxVal = v;
    }
    if (maxVal <= 0) maxVal = 100000.0;
    // Add 25% headroom
    maxVal = maxVal * 1.25;

    // 2. Draw Y-Axis Gridlines and Labels (3 divisions)
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const divisions = 3;
    for (int i = 0; i <= divisions; i++) {
      final yRatio = i / divisions;
      final yPos = topPad + chartHeight * (1.0 - yRatio);
      final labelVal = maxVal * yRatio;

      // Horizontal grid line
      canvas.drawLine(
        Offset(leftPad, yPos),
        Offset(size.width - rightPad, yPos),
        gridPaint,
      );

      // Y-axis label
      textPainter.text = TextSpan(
        text: _formatAxisLabel(labelVal),
        style: TextStyle(color: Colors.grey.shade500, fontSize: 9.0, fontWeight: FontWeight.w600),
      );
      textPainter.layout(maxWidth: leftPad - 4);
      textPainter.paint(
        canvas,
        Offset(leftPad - textPainter.width - 5, yPos - textPainter.height / 2),
      );
    }

    final n = labels.length;
    if (n == 0) return;

    // 3. Compute Coordinates
    final givenPoints = <Offset>[];
    final receivedPoints = <Offset>[];

    for (int i = 0; i < n; i++) {
      final x = n == 1 ? leftPad + chartWidth / 2 : leftPad + (chartWidth / (n - 1)) * i;

      final gVal = i < givenData.length ? givenData[i] : 0.0;
      final rVal = i < receivedData.length ? receivedData[i] : 0.0;

      final gY = topPad + chartHeight * (1.0 - (gVal / maxVal).clamp(0.0, 1.0));
      final rY = topPad + chartHeight * (1.0 - (rVal / maxVal).clamp(0.0, 1.0));

      givenPoints.add(Offset(x, gY));
      receivedPoints.add(Offset(x, rY));

      // Draw X-axis label
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: selectedIndex == i ? AppColors.primaryBurgundy : Colors.grey.shade700,
          fontSize: 9.5,
          fontWeight: selectedIndex == i ? FontWeight.bold : FontWeight.w600,
        ),
      );
      textPainter.layout(maxWidth: 55);
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - bottomPad + 6),
      );
    }

    // 4. Draw Received Series (Green) with smooth gradient fill
    _drawSeries(
      canvas: canvas,
      points: receivedPoints,
      strokeColor: const Color(0xFF28A745),
      gradientTopColor: const Color(0xFF28A745).withOpacity(0.22),
      gradientBottomColor: const Color(0xFF28A745).withOpacity(0.01),
      chartHeight: chartHeight,
      topPad: topPad,
      leftPad: leftPad,
      rightPad: rightPad,
      size: size,
      selectedIndex: selectedIndex,
    );

    // 5. Draw Given Series (Red/Burgundy) with smooth gradient fill
    _drawSeries(
      canvas: canvas,
      points: givenPoints,
      strokeColor: const Color(0xFFCF2030),
      gradientTopColor: const Color(0xFFCF2030).withOpacity(0.20),
      gradientBottomColor: const Color(0xFFCF2030).withOpacity(0.01),
      chartHeight: chartHeight,
      topPad: topPad,
      leftPad: leftPad,
      rightPad: rightPad,
      size: size,
      selectedIndex: selectedIndex,
    );
  }

  void _drawSeries({
    required Canvas canvas,
    required List<Offset> points,
    required Color strokeColor,
    required Color gradientTopColor,
    required Color gradientBottomColor,
    required double chartHeight,
    required double topPad,
    required double leftPad,
    required double rightPad,
    required Size size,
    required int? selectedIndex,
  }) {
    if (points.isEmpty) return;

    final linePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bottomY = topPad + chartHeight;

    if (points.length == 1) {
      // Single data point: draw a horizontal accent guide & filled point
      final pt = points.first;
      final guidePaint = Paint()
        ..color = strokeColor.withOpacity(0.3)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(leftPad, pt.dy), Offset(size.width - rightPad, pt.dy), guidePaint);

      final dotPaint = Paint()..color = strokeColor;
      final ringPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pt, 5.5, dotPaint);
      canvas.drawCircle(pt, 2.5, ringPaint);
      return;
    }

    // Build smooth cubic bezier path
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY1 = p0.dy;
      final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY2 = p1.dy;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
    }

    // Fill gradient under path
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, bottomY);
    fillPath.lineTo(points.first.dx, bottomY);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientTopColor, gradientBottomColor],
      ).createShader(Rect.fromLTWH(0, topPad, size.width, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw Data Point Dots
    final dotPaint = Paint()..color = strokeColor;
    final whiteRingPaint = Paint()..color = Colors.white;

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final isSel = selectedIndex == i;

      if (isSel) {
        // Highlighted halo
        final haloPaint = Paint()
          ..color = strokeColor.withOpacity(0.28)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pt, 7.5, haloPaint);
      }

      canvas.drawCircle(pt, isSel ? 5.0 : 3.8, dotPaint);
      canvas.drawCircle(pt, isSel ? 2.5 : 1.8, whiteRingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BusinessReportChartPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.givenData != givenData ||
        oldDelegate.receivedData != receivedData ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFormatters {
  AppFormatters._();

  static final NumberFormat _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrDecimalFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String formatINR(num amount, {bool showDecimals = false}) {
    if (showDecimals) {
      return _inrDecimalFormatter.format(amount);
    }
    return _inrFormatter.format(amount);
  }

  static String formatCompactINR(num amount) {
    if (amount >= 10000000) {
      final cr = amount / 10000000;
      return '₹${cr.toStringAsFixed(cr.truncateToDouble() == cr ? 0 : 2)} Cr';
    } else if (amount >= 100000) {
      final lakh = amount / 100000;
      return '₹${lakh.toStringAsFixed(lakh.truncateToDouble() == lakh ? 0 : 1)} Lakh';
    }
    return formatINR(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static Future<bool> launchPhoneNumber(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  static Future<bool> launchEmailAddress(String email, {String? subject, String? body}) async {
    final query = <String, String>{};
    if (subject != null) query['subject'] = subject;
    if (body != null) query['body'] = body;

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: query.isNotEmpty ? query : null,
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  static Future<bool> launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Unescapes common HTML entities (e.g. &amp;, &quot;, &#039;, &lt;, &gt;, &nbsp;)
  static String unescapeHtml(String? text) {
    if (text == null || text.isEmpty) return '';
    var s = text;
    s = s.replaceAll('&amp;', '&')
         .replaceAll('&quot;', '"')
         .replaceAll('&apos;', "'")
         .replaceAll('&#039;', "'")
         .replaceAll('&#39;', "'")
         .replaceAll('&lt;', '<')
         .replaceAll('&gt;', '>')
         .replaceAll('&nbsp;', ' ');

    // Numeric decimal entities &#123;
    s = s.replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
      final code = int.tryParse(m.group(1)!);
      return code != null ? String.fromCharCode(code) : m.group(0)!;
    });

    // Hex entities &#x1F600;
    s = s.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);', caseSensitive: false), (m) {
      final code = int.tryParse(m.group(1)!, radix: 16);
      return code != null ? String.fromCharCode(code) : m.group(0)!;
    });

    return s.trim();
  }
}


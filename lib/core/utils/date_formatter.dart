import 'package:intl/intl.dart';

abstract class DateFormatter {
  static DateTime? parseRfc2822(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      final format = DateFormat('EEE, dd MMM yyyy HH:mm:ss');
      final cleanedDate = dateString.replaceAll(' GMT', '').replaceAll(' UTC', '');
      return format.parse(cleanedDate, true).toLocal();
    } catch (e) {
      try {
        return DateTime.parse(dateString);
      } catch (_) {
        return null;
      }
    }
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  static String formatFull(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }
}

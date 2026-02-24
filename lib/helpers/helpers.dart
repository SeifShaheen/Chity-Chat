class Helpers {
  // Find item by ID in a list
  static T? findById<T>(List<T> list, String id) {
    try {
      return list.firstWhere((item) => item.toString() == id);
    } catch (e) {
      return null;
    }
  }

  // Find item by property value
  static T? findByProperty<T>(List<T> list, String property, dynamic value) {
    try {
      return list.firstWhere((item) {
        if (item is Map) {
          return item[property] == value;
        }
        return false;
      });
    } catch (e) {
      return null;
    }
  }

  // Check if list contains item
  static bool contains<T>(List<T> list, T item) {
    return list.contains(item);
  }

  // Format timestamp to readable string
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Format date to readable string
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Capitalize first letter of string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Check if string is null or empty
  static bool isNullOrEmpty(String? text) {
    return text == null || text.isEmpty;
  }

  // Safe string conversion
  static String safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }
}

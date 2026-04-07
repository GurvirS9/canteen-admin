class TimeUtils {
  /// Converts a given UTC DateTime to Indian Standard Time (IST - UTC+5:30).
  static DateTime toIST(DateTime utcTime) {
    return utcTime.toUtc().add(const Duration(hours: 5, minutes: 30));
  }
}


import 'wallet_summary.dart';

import 'announcement.dart';
import 'news_item.dart';

class HomeSummary {
  final String firstName;
  final WalletSummary walletSummary;
  final Announcement? announcement;
  final List<NewsItem> news;
  final int unreadNotificationCount;

  const HomeSummary({
    required this.firstName,
    required this.walletSummary,
    this.announcement,
    required this.news,
    required this.unreadNotificationCount,
  });

  factory HomeSummary.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>;
    final walletJson =
        json['walletSummary'] as Map<String, dynamic>;

    final announcementJson = json['announcement'];

    final newsJson = json['news'] as List<dynamic>? ?? [];

    return HomeSummary(
      firstName: userJson['firstName'] as String? ?? '',

      walletSummary: WalletSummary.fromJson(walletJson),

      announcement: announcementJson != null
          ? Announcement.fromJson(
              announcementJson as Map<String, dynamic>,
            )
          : null,

      news: newsJson
          .map(
            (item) => NewsItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),

      unreadNotificationCount:
          (json['unreadNotificationCount'] as num?)?.toInt() ?? 0,
    );
  }
}
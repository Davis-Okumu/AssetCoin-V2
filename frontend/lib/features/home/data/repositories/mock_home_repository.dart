
import '../../domain/announcement.dart';
import '../../domain/home_repository.dart';
import '../../domain/home_summary.dart';
import '../../domain/news_item.dart';
import '../../domain/wallet_summary.dart';

class MockHomeRepository implements HomeRepository {
  @override
  Future<HomeSummary> getHomeSummary() async {
    return HomeSummary(
      firstName: 'Davis',

      walletSummary: const WalletSummary(
        fiatBalance: 25000.00,
        tokenBalance: 1250.50,
        tokenValue: 18750.00,
        totalAssetValue: 43750.00,
        currency: 'KES',
      ),

      announcement: Announcement(
        id: 1,
        title: 'Welcome to Our Platform',
        content:
            'Explore asset tokenization and discover new investment opportunities.',
        imageUrl: null,
        publishedAt: DateTime.utc(2026, 10, 1),
        expiresAt: DateTime.utc(2026, 12, 31),
      ),

      news: [
        NewsItem(
          id: 1,
          title: 'Understanding Asset Tokenization',
          summary:
              'Learn how physical assets can be represented digitally through tokenization.',
          imageUrl: null,
          category: 'education',
          publishedAt: DateTime.utc(2026, 10, 1),
        ),
        NewsItem(
          id: 2,
          title: 'The Future of Digital Assets',
          summary:
              'Discover developments shaping the digital asset market.',
          imageUrl: null,
          category: 'market',
          publishedAt: DateTime.utc(2026, 9, 28),
        ),
      ],

      unreadNotificationCount: 3,
    );
  }
}
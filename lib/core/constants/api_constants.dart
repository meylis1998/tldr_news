abstract class ApiConstants {
  static const String baseUrl = 'https://tldr.tech';
  static const String apiUrl = '$baseUrl/api';

  // RSS Feed endpoints - Official TLDR API
  static String getRssFeedUrl(String newsletter) => '$apiUrl/rss/$newsletter';

  // Latest issue endpoint (redirects to dated URL)
  static String getLatestUrl(String newsletter) => '$apiUrl/latest/$newsletter';

  // Newsletter issue page
  static String getIssueUrl(String newsletter, String date) =>
      '$baseUrl/$newsletter/$date';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // "All" special category + 12 TLDR newsletters
  static const List<NewsletterCategory> newsletters = [
    NewsletterCategory(
      slug: 'all',
      name: 'All',
      description: 'All newsletters combined',
      subscribers: '7M+',
      emoji: '🌟',
      isAggregate: true,
    ),
    NewsletterCategory(
      slug: 'tech',
      name: 'Tech',
      description: 'Startups, Tech & Programming',
      subscribers: '1.6M+',
      emoji: '📱',
    ),
    NewsletterCategory(
      slug: 'ai',
      name: 'AI',
      description: 'AI, ML, Data Science',
      subscribers: '920K+',
      emoji: '🤖',
    ),
    NewsletterCategory(
      slug: 'webdev',
      name: 'Web Dev',
      description: 'Web Development',
      subscribers: '450K+',
      emoji: '🌐',
    ),
    NewsletterCategory(
      slug: 'infosec',
      name: 'InfoSec',
      description: 'Information Security',
      subscribers: '410K+',
      emoji: '🔒',
    ),
    NewsletterCategory(
      slug: 'devops',
      name: 'DevOps',
      description: 'DevOps & Cloud',
      subscribers: null,
      emoji: '⚙️',
    ),
    NewsletterCategory(
      slug: 'founders',
      name: 'Founders',
      description: 'Startup Founders',
      subscribers: null,
      emoji: '🚀',
    ),
    NewsletterCategory(
      slug: 'product',
      name: 'Product',
      description: 'Product Management',
      subscribers: null,
      emoji: '📦',
    ),
    NewsletterCategory(
      slug: 'design',
      name: 'Design',
      description: 'Design',
      subscribers: null,
      emoji: '🎨',
    ),
    NewsletterCategory(
      slug: 'marketing',
      name: 'Marketing',
      description: 'Marketing',
      subscribers: null,
      emoji: '📣',
    ),
    NewsletterCategory(
      slug: 'crypto',
      name: 'Crypto',
      description: 'Crypto & Web3',
      subscribers: null,
      emoji: '₿',
    ),
    NewsletterCategory(
      slug: 'fintech',
      name: 'Fintech',
      description: 'Financial Technology',
      subscribers: null,
      emoji: '💳',
    ),
    NewsletterCategory(
      slug: 'data',
      name: 'Data',
      description: 'Big Data & Data Engineering',
      subscribers: null,
      emoji: '📊',
    ),
  ];

  static List<String> get categorySlugs =>
      newsletters.where((n) => !n.isAggregate).map((n) => n.slug).toList();

  static NewsletterCategory? getCategory(String slug) {
    try {
      return newsletters.firstWhere((n) => n.slug == slug);
    } catch (_) {
      return null;
    }
  }
}

class NewsletterCategory {
  const NewsletterCategory({
    required this.slug,
    required this.name,
    required this.description,
    required this.emoji,
    this.subscribers,
    this.isAggregate = false,
  });

  final String slug;
  final String name;
  final String description;
  final String emoji;
  final String? subscribers;
  final bool isAggregate;
}

extension ApiConstantsX on ApiConstants {
  static List<NewsletterCategory> get feedNewsletters =>
      ApiConstants.newsletters.where((n) => !n.isAggregate).toList();
}

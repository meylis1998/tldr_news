import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tldr_news/core/di/injection.dart';
import 'package:tldr_news/core/theme/app_colors.dart';
import 'package:tldr_news/features/article_detail/presentation/widgets/article_content.dart';
import 'package:tldr_news/features/bookmarks/presentation/bloc/bookmarks_bloc.dart';
import 'package:tldr_news/features/feed/domain/entities/article.dart';
import 'package:tldr_news/features/feed/domain/usecases/get_article_by_id.dart';
import 'package:tldr_news/shared/widgets/error_widget.dart';
import 'package:tldr_news/shared/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleDetailPage extends StatefulWidget {
  const ArticleDetailPage({required this.articleId, super.key});

  final String articleId;

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  Article? _article;
  bool _isLoading = true;
  String? _error;
  bool _showWebView = false;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _loadArticle();
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {});
          },
        ),
      );
  }

  Future<void> _loadArticle() async {
    final getArticleById = getIt<GetArticleById>();
    final result = await getArticleById(widget.articleId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        result.fold(
          (failure) => _error = failure.message,
          (article) => _article = article,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: LoadingIndicator());
    }

    if (_error != null || _article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: _error ?? 'Article not found',
        ),
      );
    }

    final article = _article!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_showWebView ? 'Article' : 'TLDR'),
        actions: [
          if (_showWebView)
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: () => _openInBrowser(article.link),
            ),
          BlocBuilder<BookmarksBloc, BookmarksState>(
            builder: (context, state) {
              final isBookmarked = state.isBookmarked(article.id);
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: isBookmarked ? AppColors.primary : null,
                ),
                onPressed: () => _toggleBookmark(article, isBookmarked),
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareArticle(context, article),
            ),
          ),
        ],
      ),
      body: _showWebView ? _buildWebView(article) : _buildSummaryView(article),
    );
  }

  Widget _buildSummaryView(Article article) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArticleContent(article: article),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _webViewController.loadRequest(Uri.parse(article.link));
                setState(() => _showWebView = true);
              },
              icon: const Icon(Icons.article),
              label: const Text('Read Full Article'),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openInBrowser(article.link),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open in Browser'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView(Article article) {
    return Column(
      children: [
        const LinearProgressIndicator(
          backgroundColor: Colors.transparent,
        ),
        Expanded(
          child: WebViewWidget(controller: _webViewController),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _showWebView = false),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Summary'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _toggleBookmark(Article article, bool isBookmarked) {
    if (isBookmarked) {
      context.read<BookmarksBloc>().add(BookmarkRemoved(article.id));
    } else {
      context.read<BookmarksBloc>().add(BookmarkAdded(article));
    }
  }

  Future<void> _shareArticle(BuildContext context, Article article) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      '${article.title}\n\n${article.link}',
      subject: article.title,
      sharePositionOrigin: box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null,
    );
  }

  Future<void> _openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

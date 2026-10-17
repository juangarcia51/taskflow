import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'post.dart';
import 'posts_api.dart';
import 'tareas_remotas_provider.dart';

final postsApiProvider = Provider<PostsApi>((ref) {
  return PostsApi(ref.watch(httpClientProvider));
});

class PostsState {
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  PostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class PostsNotifier extends StateNotifier<PostsState> {
  final PostsApi _api;
  int _page = 1;
  static const int _limit = 15;

  PostsNotifier(this._api) : super(const PostsState()) {
    cargarInicial();
  }

  Future<void> cargarInicial() async {
    _page = 1;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _api.fetchPosts(page: _page, limit: _limit);
      state = state.copyWith(
        posts: items,
        isLoading: false,
        hasMore: items.length >= _limit,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> cargarSiguientePagina() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = _page + 1;
      final newItems = await _api.fetchPosts(page: nextPage, limit: _limit);
      _page = nextPage;
      state = state.copyWith(
        posts: [...state.posts, ...newItems],
        isLoadingMore: false,
        hasMore: newItems.length >= _limit,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  return PostsNotifier(ref.watch(postsApiProvider));
});

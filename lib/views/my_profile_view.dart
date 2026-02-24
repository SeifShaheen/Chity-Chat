import 'package:chity/constants/app_colors.dart';
import 'package:chity/services/profile_service.dart';
import 'package:chity/utils/error_handler.dart';
import 'package:chity/widgets/custom_button.dart';
import 'package:chity/widgets/custom_text_form_field.dart';
import 'package:chity/widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyProfileView extends StatefulWidget {
  const MyProfileView({super.key});
  static String id = 'MyProfileId';
  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  final TextEditingController _postController = TextEditingController();
  bool _isCreatingPost = false;
  bool _hasLoaded = false;
  Map<String, int> _stats = {'posts': 0, 'friends': 0};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      _loadStats();
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final username = ModalRoute.of(context)!.settings.arguments as String;
      final stats = await ProfileService.getUserStats(username);
      if (mounted) {
        setState(() {
          _stats = stats;
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, 'Failed to load stats: $e');
      }
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;

    setState(() {
      _isCreatingPost = true;
    });

    try {
      final username = ModalRoute.of(context)!.settings.arguments as String;
      await ProfileService.createPost(
        author: username,
        body: _postController.text.trim(),
      );

      _postController.clear();
      _loadStats(); // Refresh stats

      if (mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Post created successfully!');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, 'Failed to create post: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingPost = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('@$username'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(username),
              _buildStatsSection(),
              _buildCreatePostSection(),
              _buildPostsSection(username),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String username) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.surface,
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '@$username',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Posts', _stats['posts'] ?? 0),
          _buildStatItem('Friends', _stats['friends'] ?? 0),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCreatePostSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Post',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          CustomTextFormField(
            controller: _postController,
            hintText: 'What\'s on your mind?',
            maxLines: 3,
            textColor: AppColors.textPrimary,
            hintColor: AppColors.textSecondary,
            borderColor: AppColors.inputBorder,
            focusedBorderColor: AppColors.inputFocusedBorder,
            fillColor: AppColors.background,
            isFilled: true,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: _isCreatingPost ? 'Creating...' : 'Post',
            onPressed: _isCreatingPost ? null : _createPost,
            isLoading: _isCreatingPost,
            width: double.infinity,
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection(String username) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Posts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: ProfileService.getUserPosts(username),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget(message: 'Loading posts...');
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading posts: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              }

              final posts = snapshot.data ?? [];

              if (posts.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.post_add,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your first post above!',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildPostCard(post, username);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, String username) {
    final createdAt = (post['createdAt'] as Timestamp).toDate();
    final timeAgo = timeago.format(createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeletePostDialog(post['id']);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete Post'),
                      ],
                    ),
                  ),
                ],
                child: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post['body'] ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeletePostDialog(String postId) {
    ErrorHandler.showConfirmationDialog(
      context,
      title: 'Delete Post',
      message: 'Are you sure you want to delete this post?',
      onConfirm: () => _deletePost(postId),
    );
  }

  Future<void> _deletePost(String postId) async {
    try {
      await ProfileService.deletePost(postId);
      _loadStats(); // Refresh stats
      if (mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Post deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, 'Failed to delete post: $e');
      }
    }
  }
}

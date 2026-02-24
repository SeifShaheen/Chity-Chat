import 'package:chity/constants/app_colors.dart';
import 'package:chity/constants/app_strings.dart';
import 'package:chity/models/user_model.dart';
import 'package:chity/services/friend_service.dart';
import 'package:chity/services/profile_service.dart';
import 'package:chity/utils/error_handler.dart';
import 'package:chity/widgets/custom_button.dart';
import 'package:chity/widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});
  static String id = 'ProfileId';
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  UserModel? profileUser;
  UserModel? currentUser;
  bool isLoading = true;
  bool isProcessing = false;
  bool _hasLoaded = false;
  Map<String, int> stats = {'posts': 0, 'friends': 0};
  String?
      friendshipStatus; // 'friends', 'pending_sent', 'pending_received', 'none'

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      final profileUsername = args['username']!;
      final currentUsername = args['userUserName']!;

      final profile = await ProfileService.getUserProfile(profileUsername);
      final current = await ProfileService.getUserProfile(currentUsername);
      final userStats = await ProfileService.getUserStats(profileUsername);

      if (mounted) {
        setState(() {
          profileUser = profile;
          currentUser = current;
          stats = userStats;
          isLoading = false;
        });
        _checkFriendshipStatus();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ErrorHandler.showErrorSnackBar(context, 'Failed to load profile: $e');
      }
    }
  }

  Future<void> _checkFriendshipStatus() async {
    if (profileUser == null || currentUser == null) return;

    if (currentUser!.isFriendWith(profileUser!.username)) {
      setState(() {
        friendshipStatus = 'friends';
      });
    } else if (currentUser!.hasSentRequestTo(profileUser!.username)) {
      setState(() {
        friendshipStatus = 'pending_sent';
      });
    } else if (currentUser!.hasReceivedRequestFrom(profileUser!.username)) {
      setState(() {
        friendshipStatus = 'pending_received';
      });
    } else {
      setState(() {
        friendshipStatus = 'none';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: const Text(AppStrings.profile),
        ),
        body: const LoadingWidget(message: 'Loading profile...'),
      );
    }

    if (profileUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: const Text(AppStrings.profile),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'User not found',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: AppStrings.back,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('@${profileUser!.username}'),
        actions: [
          _buildActionButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(),
              _buildStatsSection(),
              _buildPostsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (friendshipStatus == null) return const SizedBox.shrink();

    switch (friendshipStatus!) {
      case 'friends':
        return IconButton(
          icon: const Icon(Icons.person_remove, color: AppColors.textPrimary),
          onPressed: _showUnfriendDialog,
        );
      case 'pending_sent':
        return IconButton(
          icon: const Icon(Icons.schedule, color: AppColors.warning),
          onPressed: _showCancelRequestDialog,
        );
      case 'pending_received':
        return IconButton(
          icon: const Icon(Icons.hourglass_bottom, color: Colors.white),
          onPressed: _showAcceptRequestDialog,
        );
      case 'none':
        return IconButton(
          icon: const Icon(Icons.person_add, color: AppColors.textPrimary),
          onPressed: _sendFriendRequest,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.surface,
            child: Text(
              profileUser!.name.isNotEmpty
                  ? profileUser!.name[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profileUser!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '@${profileUser!.username}',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profileUser!.email,
            style: const TextStyle(
              fontSize: 14,
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
          _buildStatItem('Posts', stats['posts'] ?? 0),
          _buildStatItem('Friends', stats['friends'] ?? 0),
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

  Widget _buildPostsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Posts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: ProfileService.getUserPosts(profileUser!.username),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget(message: 'No Posts for now');
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
                  return _buildPostCard(post);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
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
                  profileUser!.name.isNotEmpty
                      ? profileUser!.name[0].toUpperCase()
                      : 'U',
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
                      profileUser!.name,
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

  Future<void> _sendFriendRequest() async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      await FriendService.sendFriendRequest(
        fromUsername: currentUser!.username,
        toUsername: profileUser!.username,
      );

      setState(() {
        friendshipStatus = 'pending_sent';
        isProcessing = false;
      });

      ErrorHandler.showSuccessSnackBar(context, 'Friend request sent!');
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      ErrorHandler.showErrorSnackBar(
          context, 'Failed to send friend request: $e');
    }
  }

  void _showUnfriendDialog() {
    ErrorHandler.showConfirmationDialog(
      context,
      title: 'Unfriend',
      message: 'Are you sure you want to unfriend ${profileUser!.name}?',
      onConfirm: _unfriend,
    );
  }

  Future<void> _unfriend() async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      await FriendService.removeFriend(
        fromUsername: currentUser!.username,
        toUsername: profileUser!.username,
      );

      setState(() {
        friendshipStatus = 'none';
        isProcessing = false;
      });

      ErrorHandler.showSuccessSnackBar(context, 'Unfriended successfully');
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      ErrorHandler.showErrorSnackBar(context, 'Failed to unfriend: $e');
    }
  }

  void _showCancelRequestDialog() {
    ErrorHandler.showConfirmationDialog(
      context,
      title: 'Cancel Request',
      message: 'Are you sure you want to cancel the friend request?',
      onConfirm: _cancelFriendRequest,
    );
  }

  Future<void> _cancelFriendRequest() async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      await FriendService.declineFriendRequest(
        fromUsername: profileUser!.username,
        toUsername: currentUser!.username,
      );

      setState(() {
        friendshipStatus = 'none';
        isProcessing = false;
      });

      ErrorHandler.showSuccessSnackBar(context, 'Friend request cancelled');
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      ErrorHandler.showErrorSnackBar(context, 'Failed to cancel request: $e');
    }
  }

  void _showAcceptRequestDialog() {
    ErrorHandler.showConfirmationDialog(
      context,
      title: 'Accept Request',
      message: 'Accept friend request from ${profileUser!.name}?',
      onConfirm: _acceptFriendRequest,
    );
  }

  Future<void> _acceptFriendRequest() async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      await FriendService.acceptFriendRequest(
        fromUsername: profileUser!.username,
        toUsername: currentUser!.username,
      );

      setState(() {
        friendshipStatus = 'friends';
        isProcessing = false;
      });

      ErrorHandler.showSuccessSnackBar(context, 'Friend request accepted!');
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      ErrorHandler.showErrorSnackBar(context, 'Failed to accept request: $e');
    }
  }
}

import 'package:flutter/material.dart';
import '../theme.dart';
import 'feedback_screen.dart';
import 'thoughts_screen.dart';

class FeedbackThoughtsScreen extends StatefulWidget {
  const FeedbackThoughtsScreen({super.key});

  @override
  State<FeedbackThoughtsScreen> createState() =>
      _FeedbackThoughtsScreenState();
}

class _FeedbackThoughtsScreenState
    extends State<FeedbackThoughtsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Feedback & Thoughts',
            style: TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'Feedback'),
            Tab(text: 'Thoughts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FeedbackScreen(showAppBar: false),
          ThoughtsScreen(showAppBar: false),
        ],
      ),
    );
  }
}
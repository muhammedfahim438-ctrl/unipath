import 'package:flutter/material.dart';
import '../theme.dart';

const List<Map<String, dynamic>> _feedbackData = [
  {'name': 'John Doe', 'initials': 'J', 'date': '18 May 2024', 'rating': 5, 'text': 'Great support and helpful counselling session.', 'color': AppColors.primary},
  {'name': 'Rose Mary', 'initials': 'R', 'date': '17 May 2024', 'rating': 4, 'text': 'Good experience. Need more available slots.', 'color': AppColors.orange},
  {'name': 'David Smith', 'initials': 'D', 'date': '16 May 2024', 'rating': 5, 'text': 'Very supportive counsellors.', 'color': AppColors.blue},
];

const List<Map<String, dynamic>> _thoughtsData = [
  {'initials': 'A', 'time': '2 hours ago', 'text': 'I feel overwhelmed with the exam schedule. Need more support.', 'color': AppColors.green},
  {'initials': 'B', 'time': '5 hours ago', 'text': 'The counselling sessions have helped me a lot this semester!', 'color': AppColors.primary},
];

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDept = 'Computer Science';

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Feedback & Thoughts',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primaryLight)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDept,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 14),
                  items: ['Computer Science', 'IOT', 'Biology', 'Physics']
                      .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) { if (val != null) setState(() => _selectedDept = val); },
                ),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey,
            indicatorColor: AppColors.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            tabs: const [Tab(text: 'Feedback'), Tab(text: 'Thoughts')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _feedbackData.length,
                  itemBuilder: (context, index) {
                    final item = _feedbackData[index];
                    final color = item['color'] as Color;
                    final rating = item['rating'] as int;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                                child: Center(child: Text(item['initials'] as String,
                                    style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 17))),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(item['name'] as String,
                                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 14))),
                              Text(item['date'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                              color: i < rating ? const Color(0xFFFBBF24) : AppColors.grey.withOpacity(0.4),
                              size: 20,
                            )),
                          ),
                          const SizedBox(height: 8),
                          Text(item['text'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.4)),
                        ],
                      ),
                    );
                  },
                ),
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _thoughtsData.length,
                  itemBuilder: (context, index) {
                    final item = _thoughtsData[index];
                    final color = item['color'] as Color;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))]),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                            child: Center(child: Text(item['initials'] as String,
                                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 17))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Anonymous', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 13)),
                                    const Spacer(),
                                    Text(item['time'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(item['text'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 13, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Add Feedback'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

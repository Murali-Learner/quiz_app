import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/models/user_model.dart';
import 'package:quiz_app/providers/auth_provider.dart';

class LeadershipPage extends StatelessWidget {
  const LeadershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: authProvider.getLeaderboardStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading leaderboard'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final usersList = snapshot.data!;

            return ListView.builder(
              itemCount: usersList.length,
              itemBuilder: (context, index) {
                final user = usersList[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(
                    'Highest Score: ${user.highestScore}, Last Quiz: ${DateTime.fromMillisecondsSinceEpoch(user.lastQuizTime.millisecondsSinceEpoch)}',
                  ),
                  leading: CircleAvatar(child: Text('${index + 1}')),
                );
              },
            );
          } else {
            return const Center(child: Text('No users found'));
          }
        },
      ),
    );
  }
}

import 'package:eudkt/resources/colors.dart';
import 'package:eudkt/services/shared_preference.dart';
import 'package:eudkt/ui/widgets/admin_dashboard/post_card_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../state_management/community/community_cubit.dart';
import '../../state_management/theme/theme_cubit.dart';

class CommunitySection extends StatelessWidget {
  const CommunitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;
    context.read<CommunityCubit>().loadPosts(career: SharedPreferencesService.career);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: isDark ? dark : light,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 5)
          )
        ],


      ),
      child: BlocBuilder<CommunityCubit, CommunityState>(
        builder: (context, state) {
          if (state is CommunityLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is CommunityEmpty) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      height: 100,
                      image: AssetImage('assets/empty-box.png'),
                    ),
                    Text('No hay aportes disponibles.',
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
              ],
            ));
          } else if (state is CommunityError) {
            return Center(child: Text(state.message));
          } else if (state is CommunityLoaded) {
            final posts = state.posts;
            return ListView.builder(
              itemCount: posts.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SizedBox(
                  );
                }
                if (index == posts.length + 1) return SizedBox(height: 100);
                final post = posts[index - 1];
                return PostCardDashboard(
                  post: post,
                );
              },
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }
}
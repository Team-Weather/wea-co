import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:weaco/core/enum/router_path.dart';
import 'package:weaco/core/go_router/router_static.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/domain/user/model/user_profile.dart';
import 'package:weaco/presentation/common/component/cached_image_widget.dart';
import 'package:weaco/presentation/common/enum/exception_alert.dart';
import 'package:weaco/presentation/common/user_provider.dart';
import 'package:weaco/presentation/common/util/alert_util.dart';
import 'package:weaco/presentation/my_page/component/my_profile_widget.dart';
import 'package:weaco/presentation/my_page/view_model/my_page_view_model.dart';
import 'package:weaco/presentation/user_page/screen/component/feed_grid/feed_grid_empty_widget.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (context.read<UserProvider>().email == null) {
        context.read<MyPageViewModel>().clearMyPageViewModelState();
      } else {
        context.read<MyPageViewModel>().initializePageData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    MyPageViewModel myPageViewModel = context.watch<MyPageViewModel>();

    final UserProfile? profile = myPageViewModel.profile;
    final List<Feed> feedList = myPageViewModel.feedList;
    final bool isPageLoading = myPageViewModel.isPageLoading;

    return isPageLoading || profile == null
        ? Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(42),
              child: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                scrolledUnderElevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                    ),
                    onPressed: () {
                      RouterStatic.pushToAppSetting(context);
                    },
                  ),
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Column(
                children: [
                  MyProfileWidget(userProfile: profile),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Divider(),
                  ),
                  feedList.isEmpty
                      ? const FeedGridEmptyWidget()
                      : _buildFeedList(),
                ],
              ),
            ),
          );
  }

  bool _handleFeedScroll(UserScrollNotification notification) {
    MyPageViewModel myPageViewModel = context.read<MyPageViewModel>();

    if (notification.direction == ScrollDirection.reverse &&
        notification.metrics.maxScrollExtent * 0.85 <
            notification.metrics.pixels) {
      myPageViewModel.fetchFeed();
    }

    return false;
  }

  Widget _buildFeedList() {
    return NotificationListener<UserScrollNotification>(
      onNotification: _handleFeedScroll,
      child: Expanded(
        child: _buildFeedGridView(),
      ),
    );
  }

  Widget _buildFeedGridView() {
    MyPageViewModel myPageViewModel = context.read<MyPageViewModel>();

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: myPageViewModel.feedList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 3 / 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        crossAxisCount: 3,
      ),
      itemBuilder: (context, index) {
        return _buildFeedCard(myPageViewModel.feedList[index]);
      },
    );
  }

  Widget _buildFeedCard(Feed currentFeed) {
    MyPageViewModel myPageViewModel = context.read<MyPageViewModel>();

    return GestureDetector(
      onTap: () {
        RouterStatic.pushToOotdDetail(context, feed: currentFeed);
      },
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SizedBox(
              height: 240,
              width: double.maxFinite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: SizedBox(
                      height: 40,
                      width: 360,
                      child: Center(
                          child: Text(
                        '선택',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ),
                  ),
                  const Divider(),
                  Column(
                    children: [
                      SizedBox(
                        height: 50,
                        width: 360,
                        child: FilledButton(
                          onPressed: () {
                            context.push(RouterPath.ootdPost.path,
                                extra: currentFeed);
                            context.pop();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                          ),
                          child: const Text(
                            '수정',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        width: 360,
                        child: FilledButton(
                          onPressed: () {
                            AlertUtil.showAlert(
                              context: context,
                              exceptionAlert: ExceptionAlert.dialogTwoButton,
                              message: '삭제 하시겠습니까?',
                              onPressedLeft: () {
                                context.pop();
                              },
                              onPressedRight: () {
                                myPageViewModel
                                    .removeSelectedFeed(currentFeed.id!)
                                    .then((result) {
                                  AlertUtil.showAlert(
                                    context: context,
                                    exceptionAlert: ExceptionAlert.snackBar,
                                    message: '피드가 삭제 되었습니다.',
                                  );

                                  context.pop();
                                  context.pop();
                                });
                              },
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xffB2B2B2),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                          ),
                          child: const Text(
                            '삭제',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedImageWidget(currentFeed.thumbnailImagePath),
      ),
    );
  }
}

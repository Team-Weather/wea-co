import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:weaco/core/enum/season_code.dart';
import 'package:weaco/core/enum/weather_code.dart';
import 'package:weaco/core/go_router/router_static.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/presentation/common/component/cached_image_widget.dart';
import 'package:weaco/presentation/common/enum/exception_alert.dart';
import 'package:weaco/presentation/common/user_provider.dart';
import 'package:weaco/presentation/common/util/alert_util.dart';
import 'package:weaco/presentation/ootd_post/view_model/ootd_post_view_model.dart';

class OotdPostScreen extends StatefulWidget {
  final Feed? feed;

  const OotdPostScreen({super.key, this.feed});

  @override
  State<OotdPostScreen> createState() => _OotdPostScreenState();
}

class _OotdPostScreenState extends State<OotdPostScreen> {
  static const int maxLength = 300;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _contentTextController = TextEditingController();
  String _email = '';
  bool isClicked = false;
  bool _isScrolledUp = true;
  CroppedFile? _newCroppedFile;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    if (widget.feed != null) {
      _contentTextController.text = widget.feed!.description;
    }

    Future.microtask(() {
      _email = context.read<UserProvider>().email!;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OotdPostViewModel>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: _appBar(viewModel),
        body: viewModel.showSpinner
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 15, 22, 30),
                    child: Column(
                      children: [
                        widget.feed != null
                            ?
                            // 기존 피드 수정
                            CachedImageWidget(widget.feed!.imagePath)
                            :
                            // 새로운 피드 작성
                            Stack(
                                children: [
                                  _newCroppedFile ==
                                          null // 새 크롭 화면의 image null 검사
                                      ? viewModel.croppedImage ==
                                              null // viewModel image null 검사
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : Image.file(viewModel.croppedImage!)
                                      : Image.file(File(_newCroppedFile!.path)),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () async {
                                        await viewModel.getOriginImage();
                                        await cropImage(
                                            viewModel.originImage!.path);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.crop),
                                              Text('수정'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                _isScrolledUp = !_isScrolledUp;
                              });
                              _scrollTo();
                            },
                            icon: _isScrolledUp
                                ? const Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                    size: 50,
                                  )
                                : const Icon(
                                    Icons.keyboard_arrow_up_outlined,
                                    size: 50,
                                  ),
                          ),
                        ),
                        Column(
                          children: [
                            widget.feed != null
                                ? Row(
                                    children: [
                                      _tags(widget.feed!.location.city),
                                      _tags(SeasonCode.fromValue(
                                              widget.feed!.seasonCode)
                                          .description),
                                      _tags(
                                          '${widget.feed!.weather.temperature}°'),
                                      _tags(WeatherCode.fromValue(
                                              widget.feed!.weather.code)
                                          .description),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      _tags(viewModel
                                          .dailyLocationWeather!.location.city),
                                      _tags(SeasonCode.fromValue(viewModel
                                              .dailyLocationWeather!.seasonCode)
                                          .description),
                                      _tags(
                                          '${viewModel.weather!.temperature}°'),
                                      _tags(WeatherCode.fromValue(
                                              viewModel.weather!.code)
                                          .description),
                                    ],
                                  ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: _contentTextController,
                              maxLength: maxLength,
                              maxLines: 10,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                hintText: '어떤 코디를 하셨나요?',
                                hintStyle:
                                    const TextStyle(color: Color(0xFF979797)),
                                border: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).viewInsets.bottom,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _appBar(OotdPostViewModel viewModel) {
    return AppBar(
      title: const Text('피드글 쓰기'),
      centerTitle: true,
      leading: IconButton(
        onPressed: () async {
          if (widget.feed != null) {
            context.pop();
          } else {
            await viewModel.getOriginImage();
            await cropImage(viewModel.originImage!.path);
          }
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        TextButton(
          onPressed: viewModel.showSpinner
              ? null
              : () async {
                  if (widget.feed != null) {
                    await viewModel.editFeed(
                        widget.feed!, _contentTextController.text);
                  } else {
                    await viewModel.saveFeed(
                        _email, _contentTextController.text);
                  }

                  if (mounted) {
                    RouterStatic.goToDefault(context);
                  }
                },
          child: viewModel.showSpinner
              ? const Center(child: CircularProgressIndicator())
              : Text(
                  widget.feed != null ? '수정' : '저장',
                  style:
                      const TextStyle(color: Color(0xFFFC8800), fontSize: 18),
                ),
        ),
      ],
    );
  }

  Widget _tags(String name) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF0FF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Text(name),
      ),
    );
  }

  Future<void> cropImage(String sourcePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
      uiSettings: [
        AndroidUiSettings(
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true, // 비율 고정
        ),
        IOSUiSettings(
          title: '이미지 자르기',
          minimumAspectRatio: 1.0, // 비율 고정
          rotateButtonsHidden: true,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _newCroppedFile = croppedFile;
      });
    } else {
      if (mounted) {
        AlertUtil.showAlert(
            context: context,
            exceptionAlert: ExceptionAlert.dialogTwoButton,
            message: '지금 돌아가면 이미지 수정이 삭제됩니다.',
            rightButtonText: '삭제',
            onPressedRight: () {
              // 다이얼로그에서 '삭제' 를 눌렀을 경우
              RouterStatic.goToDefault(context);
            });
      }
    }
  }

  void _scrollListener() {
    if (_scrollController.offset <=
            _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      // 스크롤 위치가 상단에 도달하면 화살표를 위로 표시
      setState(() {
        _isScrolledUp = true;
      });
    } else if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // 스크롤 위치가 하단에 도달하면 화살표를 아래로 표시
      setState(() {
        _isScrolledUp = false;
      });
    }
  }

  void _scrollTo() {
    _scrollController.animateTo(
      _isScrolledUp
          ? _scrollController.position.minScrollExtent
          : _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}

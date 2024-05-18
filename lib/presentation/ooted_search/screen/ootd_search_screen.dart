import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:weaco/core/enum/season_code.dart';
import 'package:weaco/core/enum/temperature_code.dart';
import 'package:weaco/core/enum/weather_code.dart';
import 'package:weaco/core/go_router/router_static.dart';
import 'package:weaco/domain/feed/model/feed.dart';
import 'package:weaco/presentation/ooted_search/view_model/ootd_search_view_model.dart';

class OotdSearchScreen extends StatefulWidget {
  const OotdSearchScreen({super.key});

  @override
  State<OotdSearchScreen> createState() => _OotdSearchScreenState();
}

class _OotdSearchScreenState extends State<OotdSearchScreen> {
  final List<String> seasonItemList =
      List.generate(4, (index) => SeasonCode.fromValue(index + 1).description);

  final List<String> weatherItemList = [1, 2, 3, 4, 6, 7, 9, 10, 12].map((index) => WeatherCode.fromValue(index).description).toList();
  final List<String> temperatureItemList = List.generate(
      6, (index) => TemperatureCode.fromValue(index + 1).description);

  List<String?> selectedData = [null, null, null];

  @override
  Widget build(BuildContext context) {
    final OotdSearchViewModel ootdSearchViewModel =
        context.watch<OotdSearchViewModel>();

    final List<Feed> searchFeedList = ootdSearchViewModel.searchFeedList;

    final bool isPageLoading = ootdSearchViewModel.isPageLoading;

    return isPageLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        dropDownButton(
                            defaultText: '계절',
                            borderColor: const Color(0xFFF2C347),
                            items: seasonItemList,
                            width: 80,
                            selectedValueIndex: 0,
                            onChanged: (value) {
                              ootdSearchViewModel.fetchFeedWhenFilterChange(
                                seasonCodeValue:
                                    seasonItemList.indexOf(value ?? '') + 1,
                                weatherCodeValue: weatherItemList
                                        .indexOf(selectedData[1] ?? '') +
                                    1,
                                temperatureCodeValue: temperatureItemList
                                        .indexOf(selectedData[2] ?? '') +
                                    1,
                              );
                              setState(() {
                                selectedData[0] = value;
                              });
                            },
                            fontSize: 13),
                        dropDownButton(
                            defaultText: '날씨',
                            borderColor: const Color(0xFF4C8DE6),
                            items: weatherItemList,
                            width: 100,
                            selectedValueIndex: 1,
                            onChanged: (value) {
                              ootdSearchViewModel.fetchFeedWhenFilterChange(
                                seasonCodeValue: seasonItemList
                                        .indexOf(selectedData[0] ?? '') +
                                    1,
                                weatherCodeValue:
                                    weatherItemList.indexOf(value ?? '') + 1,
                                temperatureCodeValue: temperatureItemList
                                        .indexOf(selectedData[2] ?? '') +
                                    1,
                              );
                              setState(() {
                                selectedData[1] = value;
                              });
                            },
                            fontSize: 13),
                        dropDownButton(
                            defaultText: '온도',
                            borderColor: const Color(0xFFE2853F),
                            items: temperatureItemList,
                            width: 130,
                            selectedValueIndex: 2,
                            onChanged: (value) {
                              ootdSearchViewModel.fetchFeedWhenFilterChange(
                                seasonCodeValue: seasonItemList
                                        .indexOf(selectedData[0] ?? '') +
                                    1,
                                weatherCodeValue: weatherItemList
                                        .indexOf(selectedData[1] ?? '') +
                                    1,
                                temperatureCodeValue:
                                    temperatureItemList.indexOf(value ?? '') +
                                        1,
                              );
                              setState(() {
                                selectedData[2] = value;
                              });
                            },
                            fontSize: 12),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(),
                    ),
                    NotificationListener<UserScrollNotification>(
                      onNotification: (UserScrollNotification notification) {
                        if (notification.direction == ScrollDirection.reverse &&
                            notification.metrics.maxScrollExtent * 0.85 <
                                notification.metrics.pixels) {
                          ootdSearchViewModel.fetchFeedWhenScroll(
                            seasonCodeValue:
                                seasonItemList.indexOf(selectedData[0] ?? '') +
                                    1,
                            weatherCodeValue:
                                weatherItemList.indexOf(selectedData[1] ?? '') +
                                    1,
                            temperatureCodeValue: temperatureItemList
                                    .indexOf(selectedData[2] ?? '') +
                                1,
                          );
                        }

                        return false;
                      },
                      child: Expanded(
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: searchFeedList.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 3 / 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            crossAxisCount: 3,
                          ),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                RouterStatic.pushToOotdDetail(
                                  context,
                                  id: searchFeedList[index].id ?? '',
                                  imagePath: searchFeedList[index].imagePath,
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image(
                                  image: NetworkImage(
                                      searchFeedList[index].imagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }

  Widget dropDownButton(
      {required int selectedValueIndex,
      required String defaultText,
      required double fontSize,
      required List<String> items,
      required double width,
      required Color borderColor,
      required Function(String?) onChanged}) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Row(
          children: [
            Expanded(
              child: Text(
                defaultText,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        items: items
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ))
            .toList(),
        value: selectedData[selectedValueIndex],
        onChanged: (value) {
          onChanged(value);
        },
        buttonStyleData: ButtonStyleData(
          height: 40,
          width: width,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              width: 2,
              color: borderColor,
            ),
            color: Colors.white,
          ),
          elevation: 0,
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(
            color: Colors.black,
            Icons.keyboard_arrow_down_rounded,
          ),
          iconSize: 18,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: width - 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          offset: const Offset(18, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(30),
            thickness: MaterialStateProperty.all(2),
            thumbVisibility: MaterialStateProperty.all(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 35,
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        ),
      ),
    );
  }
}

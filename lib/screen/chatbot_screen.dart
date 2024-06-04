import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../api/weather_api.dart';
import '../models/checkbox_model.dart';
import '../models/conversation.dart';
import '../models/sentence_model.dart';
import 'package:mooddiary/widgets/chatbubble.dart';
import '../utils/ad_mob_helper.dart';

import '../utils/constant.dart';
import '../viewmodels/backgroud_image.dart';
import '../widgets/option_button.dart';

class ChatBotApp extends StatefulWidget {
  final DateTime selectedDate;

  const ChatBotApp({
    super.key,
    required this.selectedDate,
  });

  @override
  ChatBotAppState createState() => ChatBotAppState();
}

class ChatBotAppState extends State<ChatBotApp> {
  final List<Conversation> _conversations = [];
  Map<String, dynamic>? _jsonData;
  List<String> selectedOptions = []; // 선택한 옵션을 기록하는 리스트
  final ScrollController _scrollController = ScrollController();
  late Future<NativeAd> _adFuture;
  BackgroundImageViewModel viewModel = BackgroundImageViewModel();

  @override
  void initState() {
    super.initState();
    _loadConversationsFromJson();
    _adFuture=NativeAdManager(
      adUnitId: adUnitId,
      factoryId: 'adFactoryExample',
    ).createNativeAd();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _adFuture.then((ad) => ad.dispose());
    super.dispose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadConversationsFromJson() async {
    try {
      String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/buttonflow.json');
      _jsonData = json.decode(jsonString);
      _conversations.add(
          SentenceModel(id: 'q1', content: _jsonData!['q1'], isUser: false));
      _jsonData!['option'].forEach((option) {
        _conversations.add(CheckBoxModel(
            id: option['mood'],
            content: option['mood'],
            isChecked: false,
            next: option));
      });
      setState(() {});
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = widget.selectedDate;
    var weatherService = Provider.of<WeatherService>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  viewModel.getBackgroundImage(weatherService.weatherCondition ?? 'default')),
              fit: BoxFit.cover,
            ),
          ),
          child: AppBar(
            title: Text(DateFormat('yyyy / MM / dd').format(selectedDate)),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    viewModel.getBackgroundImage(weatherService.weatherCondition ?? 'default')),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: LayoutBuilder(builder: (context, constraints) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: _conversations.length + 1,
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if (index == _conversations.length) {
                        return Container(height: 200);
                      }
                      var conversation = _conversations[index];

                      if (conversation is SentenceModel) {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.03),
                          child: ChatBubble(
                            content: conversation.content,
                            isUser: conversation.isUser,
                          ),
                        );
                      } else if (_conversations[index] is CheckBoxModel &&
                          _conversations[index - 1] is SentenceModel) {
                        var buttons =
                        _conversations.whereType<CheckBoxModel>().toList();
                        scrollToBottom();
                        return Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.05),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: buttons.map((c) {
                                  return OptionButton(
                                    selectedDate: selectedDate,
                                    checkBoxModel: c,
                                    selectedOptions: selectedOptions,
                                    conversations: _conversations,
                                    onPressedCallback: () => setState(() {}),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              );
            }),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight, // 광고를 AppBar 아래에 배치
            child: FutureBuilder<NativeAd>(
              future: _adFuture,
              builder: (BuildContext context, AsyncSnapshot<NativeAd> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    color: Colors.transparent,
                    height: 45,
                    width: MediaQuery.of(context).size.width,
                    child: AdWidget(ad: snapshot.data!),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

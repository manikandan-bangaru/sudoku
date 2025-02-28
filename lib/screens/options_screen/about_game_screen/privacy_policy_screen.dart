import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../utils/game_colors.dart';
import '../../../utils/game_sizes.dart';
import '../../../utils/game_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  final String url;
  final String title;
  const PrivacyPolicyScreen({this.url = "https://magiban.in/policy.html",this.title = 'Privacy Policy'});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState(url: this.url, title: this.title);
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late WebViewController _controller;
  int progress = 0;
  String url;
  final String title;
  _PrivacyPolicyScreenState({required this.url, required this.title});
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              this.progress = progress;
            });
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${error.description}',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          },
          onNavigationRequest: (NavigationRequest request) async {
            // IT OPEN THE application in playStore
              if (await canLaunchUrl(Uri.parse(request.url))) {
                await launchUrl(Uri.parse(request.url), mode: LaunchMode.externalApplication);
              } else {
                throw "Could not launch $url";
              }
              return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.5,
          centerTitle: true,
          backgroundColor: GameColors.appBarBackground,
          title: Text(
            this.title,
            style: GameTextStyles.optionsScreenAppBarTitle
                .copyWith(fontSize: GameSizes.getWidth(0.045)),
          ),
          leading: const BackButton(),
        ),
        body: Visibility(
          visible: progress >= 100,
          replacement: LinearProgressIndicator(value: progress * 1.0),
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}

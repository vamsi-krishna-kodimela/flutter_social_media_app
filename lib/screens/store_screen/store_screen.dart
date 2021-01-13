import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:social_media/components/empty_state_component.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: OfflineBuilder(
            connectivityBuilder: (_, connectivity, child) {
              if (ConnectivityResult.none == connectivity)
                return Center(
                  child: EmptyStateComponent("You are offline."),
                );
              return child;
            },
            child: WebView(initialUrl: "http://ebeemart.com"),
          ),
        ),
      ],
    );
  }
}

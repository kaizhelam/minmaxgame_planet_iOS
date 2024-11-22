
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.backgroundColor, required this.url});

  final Color backgroundColor;
  final String url;

  @override
  State<StatefulWidget> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  double left = 0.0;
  double top = 0.0;
  int _selectedIndex = 0;
  bool _isBottomBarVisible = true;
  double bottomBarHeight = 50;
  bool _isLoading = true;
  String? _latestUrl;
  late InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _latestUrl = widget.url;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialIconPosition();
    });
  }

  void _setInitialIconPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? savedLeft = prefs.getDouble('left');
    double? savedTop = prefs.getDouble('top');

    setState(() {
      left = savedLeft ?? 0.0;
      top = savedTop ?? (MediaQuery.of(context).size.height - bottomBarHeight - 50) / 2;
    });
  }

  void _savePosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('left', left);
    await prefs.setDouble('top', top);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        if (_latestUrl != null) {
          _webViewController.loadUrl(urlRequest: URLRequest(url: WebUri(_latestUrl!)));
        }
      } else if (index == 1) {
        _webViewController.goBack();
      } else if (index == 2) {
        _webViewController.goForward();
      } else if (index == 3) {
        _webViewController.reload();
      }
    });
  }

  void _handleImageClick() {
    setState(() {
      _isBottomBarVisible = !_isBottomBarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxTopPosition = constraints.maxHeight - bottomBarHeight - 100;
            double maxLeftPosition = constraints.maxWidth - 50;
            if (left < 0) left = 0;
            if (top < 0) top = 0;
            if (left > maxLeftPosition) left = maxLeftPosition;
            if (top > maxTopPosition) top = maxTopPosition;

            return Stack(
              children: [
                // Adjust the web view height to fit above the bottom bar
                Positioned.fill(
                  bottom: _isBottomBarVisible ? bottomBarHeight : 0,
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(widget.url),
                      headers: {"User-Agent": "Mozilla/5.0"},
                    ),
                    onLoadStop: (controller, url) {
                      setState(() {
                        _isLoading = false;
                        _latestUrl = url?.toString();
                      });
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        _isLoading = true;
                      });
                    },
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onLoadError: (controller, url, code, message) {
                      print("Error loading page: $message");
                    },
                    androidOnPermissionRequest: (controller, origin, resources) async {
                      return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT,
                      );
                    },
                  ),
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                Positioned(
                  left: left,
                  top: top,
                  child: GestureDetector(
                    onTap: _handleImageClick,
                    onPanUpdate: (details) {
                      setState(() {
                        double newLeft = left + details.delta.dx;
                        double newTop = top + details.delta.dy;
                        if (newTop >= 0 && newTop <= maxTopPosition) {
                          if (newLeft >= 0 && newLeft <= maxLeftPosition) {
                            left = newLeft;
                            top = newTop;
                          }
                        }
                      });
                    },
                    onPanEnd: (_) => _savePosition(),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromRGBO(28, 40, 54, 1),
                          border: Border.all(
                            color: Colors.transparent,
                            width: 6,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/icon_home.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 00), 
                  bottom: _isBottomBarVisible ? 0 : -bottomBarHeight, 
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                      child: BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: Colors.black,
                        items: const <BottomNavigationBarItem>[
                          BottomNavigationBarItem(
                            icon: Center(child: Icon(Icons.home, size: 24)),
                            label: '',
                          ),
                          BottomNavigationBarItem(
                            icon: Center(child: Icon(Icons.arrow_back, size: 24)),
                            label: '',
                          ),
                          BottomNavigationBarItem(
                            icon: Center(child: Icon(Icons.arrow_forward, size: 24)),
                            label: '',
                          ),
                          BottomNavigationBarItem(
                            icon: Center(child: Icon(Icons.refresh, size: 24)),
                            label: '',
                          ),
                        ],
                        currentIndex: _selectedIndex,
                        selectedItemColor: Colors.white,
                        unselectedItemColor: Colors.white,
                        onTap: _onItemTapped,
                        showSelectedLabels: false,
                        showUnselectedLabels: false,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
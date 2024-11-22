import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minmaxgame_planet/gamewidget/menu_page.dart';
import 'package:minmaxgame_planet/webScreen/web_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    fetchIsOn();
    Timer(const Duration(seconds: 5), () {
      if (!isDataFetched) {
        setState(() {
          isOpen = false;
          isLoading = false;
        });
      }
    });
  }

    String url = '';
  bool isOpen = false;
  bool isDataFetched = false;
  bool isLoading = true;

  Future<void> fetchIsOn() async {
    try {
      final response = await http.get(
        Uri.parse('https://6703907dab8a8f892730a6d2.mockapi.io/api/v1/elementalmatch'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final bool apiIsOpen = data[0]['is_on'] ?? false;
          final String apiUrl = data[0]['url'] ?? '';
          if (apiIsOpen && await isValidUrl(apiUrl)) {
            setState(() {
              isOpen = true;
              url = apiUrl;
              isDataFetched = true;
              isLoading = false;
            });
          } else {
            setState(() {
              isOpen = false;
              isDataFetched = true;
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isOpen = false;
            isDataFetched = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isOpen = false;
          isDataFetched = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isOpen = false;
        isDataFetched = true;
        isLoading = false;
      });
    }
  }


  Future<bool> isValidUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: isLoading
            ? const Scaffold(
              backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        )
            : isOpen
            ? WebViewScreen(backgroundColor: Colors.black, url: url)
            : const MenuPage()
    );
  }
}
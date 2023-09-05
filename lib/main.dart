import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'package:page_transition/page_transition.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quoteoftheday/provider/favorite_provider.dart';
import 'package:quoteoftheday/screens/favorite.dart';
import 'package:share_plus/share_plus.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoriteProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: Color.fromARGB(255, 221, 128, 238),
        ),
        home: QuoteGenerator(),
      ),
    );
  }
}

class QuoteGenerator extends StatefulWidget {
  const QuoteGenerator({super.key});

  @override
  State<QuoteGenerator> createState() => _QuoteGeneratorState();
}

class _QuoteGeneratorState extends State<QuoteGenerator>
    with SingleTickerProviderStateMixin {
  final String quoteURL = "https://api.adviceslip.com/advice";
  String quote = ' ';

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    generate(); // Generate a quote when the app starts
    _animationController = AnimationController(
      duration: Duration(milliseconds: 50),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.2,
    )..addListener(() {
        setState(() {});
      });
  }

  generate() async {
    var res = await http.get(Uri.parse(quoteURL));
    var result = jsonDecode(res.body);
    print(result["slip"]["advice"]);
    setState(() {
      quote = result["slip"]["advice"];
    });
  }

  Future<void> generateQuote() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    var res = await http.get(Uri.parse(quoteURL));
    var result = jsonDecode(res.body);
    print(result["slip"]["advice"]);
    setState(() {
      quote = result["slip"]["advice"];
    });
    Navigator.of(context).pop();
  }

  shareText() {
    Share.share(quote);
  }

  bool isFinished = false;
  @override
  Widget build(BuildContext context) {
    double scale = 1 + _animationController.value;
    final provider = Provider.of<FavoriteProvider>(context);
    return Container(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 252, 248, 251),
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Center(
            child: Container(
              child: Text('Quote of the day'),
            ),
          ),
        ),
        body: LiquidPullToRefresh(
          onRefresh: generateQuote,
          color: Colors.deepPurple,
          height: 300,
          backgroundColor: Colors.deepPurple,
          animSpeedFactor: 2,
          showChildOpacityTransition: true,
          child: Padding(
            padding: const EdgeInsets.only(top: 45.0),
            child: Container(
              width: 500,
              height: 1000,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 34, 34, 34),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60.0),
                    topRight: Radius.circular(60.0)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: Container(
                        padding: EdgeInsets.only(left: 15),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 600.0,
                            maxHeight: 300.0,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              quote,
                              style: TextStyle(
                                  fontSize: 30.0, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTapDown: OnTapDown,
                            onTapUp: OnTapUp,
                            onTapCancel: OnTapCancel,
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                child: IconButton(
                                  color: Color.fromARGB(255, 246, 249, 252),
                                  iconSize: 40,
                                  onPressed: generateQuote,
                                  icon: Icon(Icons.refresh),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              provider.toggleFavorite(quote);
                            },
                            icon: provider.isExist(quote)
                                ? const Icon(Icons.favorite, color: Colors.red)
                                : const Icon(
                                    Icons.favorite_border,
                                    color: Colors.white,
                                  ),
                          ),
                          GestureDetector(
                            onTapDown: OnTapDown,
                            onTapUp: OnTapUp,
                            onTapCancel: OnTapCancel,
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                child: IconButton(
                                  color: Color.fromARGB(255, 237, 238, 239),
                                  iconSize: 40,
                                  onPressed: shareText,
                                  icon: Icon(Icons.share_rounded),
                                  //label: Text("SHARE")
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 25),
                      child: SwipeableButtonView(
                        buttonText: "Go to favorite",
                        buttonWidget: Container(
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey,
                          ),
                        ),
                        activeColor: Color(0xFF4D3C77),
                        isFinished: isFinished,
                        onWaitingProcess: () {
                          Future.delayed(Duration(seconds: 1), () {
                            setState(() {
                              isFinished = true;
                            });
                          });
                        },
                        onFinish: () async {
                          await Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: favoritePage()));
                          setState(() {
                            isFinished = false;
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            // ),
          ),
        ),
      ),
    );
  }

  OnTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  OnTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  OnTapCancel() {
    _animationController.reverse();
  }
}

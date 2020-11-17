import 'package:flutter/material.dart';
import 'package:social_media/screens/create_page_screen/create_page_screen.dart';
import '../../components/top_bar_option.dart';

import '../../constants.dart';

class PagesScreen extends StatefulWidget {
  @override
  _PagesScreenState createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen> {
  int currentOption = 0;

  void changeOption(val) {
    setState(() {
      currentOption = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pages", style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: kWhite,
            ),
            onPressed: () {
              //TODO:: Implement navigation to pages search screen
            },
          ),
        ],
        elevation: 0.0,
      ),
      backgroundColor: kPrimaryColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: kPrimaryColor,
            padding: EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TopBarOption(
                    isActive: currentOption == 0,
                    option: "Posts",
                    onPress: changeOption,
                    optionNum: 0,
                  ),
                  TopBarOption(
                    isActive: currentOption == 1,
                    option: "Liked",
                    onPress: changeOption,
                    optionNum: 1,
                  ),
                  TopBarOption(
                    isActive: currentOption == 2,
                    option: "Created",
                    onPress: changeOption,
                    optionNum: 2,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  color: kBGColor,
                ),
                child: Text("Hello World!"),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => CreatePageScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/entertainment_upload_screen/entertainment_upload_screen.dart';

class EntertainmentScreen extends StatefulWidget {
  @override
  _EntertainmentScreenState createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  var currentOption = 0;

  void changeOption(val) {
    setState(() {
      currentOption = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        title: Text("Entertainment"),
        elevation: 0.0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_)=>EntertainmentUploadScreen()));
        },
        child: Icon(Icons.add),
      ),
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
                  _TopBarOption(
                    isActive: currentOption == 0,
                    option: "All",
                    onPress: changeOption,
                    optionNum: 0,
                  ),
                  _TopBarOption(
                    isActive: currentOption == 1,
                    option: "Video",
                    onPress: changeOption,
                    optionNum: 1,
                  ),
                  _TopBarOption(
                    isActive: currentOption == 2,
                    option: "Audio",
                    onPress: changeOption,
                    optionNum: 2,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(

              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                color: kBGColor,
              ),
              child: Center(
                child: Text("Entertainment list"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBarOption extends StatelessWidget {
  final String option;
  final bool isActive;
  final Function onPress;
  final int optionNum;

  const _TopBarOption({
    this.option,
    this.isActive,
    this.onPress,
    this.optionNum,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPress(optionNum);
      },
      child: Container(
        padding: EdgeInsets.only(left: kDefaultPadding, right: kDefaultPadding),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isActive ? kWhite : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}

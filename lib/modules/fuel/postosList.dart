import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/unit_controller.dart';
import 'package:fuel_tracker_app/data/models/maintenance_entry_model.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/fuel_list_controller.dart';
import 'package:fuel_tracker_app/modules/fuel/controllers/maintenance_controller.dart';
import 'package:fuel_tracker_app/core/app_theme.dart';
import 'package:fuel_tracker_app/core/app_localizations.dart';
import 'package:fuel_tracker_app/modules/fuel/widgets/searchList.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

class PostosList extends StatefulWidget {
  const PostosList({super.key});

  @override
  State<PostosList> createState() => _PostosListState();
}

class _PostosListState extends State<PostosList> {
  TextEditingController _textController = TextEditingController();
  String? search;
  var _length = 0;

  @override
  void initState() {
    super.initState();
    search = _textController.text;
    _length = search!.length;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text('Procurar Postos'),
        backgroundColor: Colors.transparent,
        actions: [
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
              width: MediaQuery.of(context).size.width,
              child: TextFormField(
                controller: _textController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(
                    left: 20,
                    top: 10,
                    bottom: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.indigo[300],
                  hintText: "Procurar Posto",
                  hintStyle: GoogleFonts.lato(
                    color: Colors.black26,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  prefixIcon: Icon(RemixIcons.search_2_line, size: 20),
                  prefixStyle: TextStyle(color: Colors.grey[300]),
                  suffixIcon: _textController.text.length != 0
                      ? TextButton(
                          onPressed: () {
                            setState(() {
                              _textController.clear();
                              _length = search!.length;
                            });
                          },
                          child: Icon(Icons.close_rounded, size: 20),
                        )
                      : SizedBox(),
                ),
                onChanged: (String _searchKey) {
                  setState(() {
                    print('>>>' + _searchKey);
                    search = _searchKey;
                    _length = search!.length;
                  });
                },
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textInputAction: TextInputAction.search,
                autofocus: false,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: _length == 0
            ? Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _length = 1;
                          });
                        },
                        child: Text(
                          'Show All',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Image(image: AssetImage('assets/search-bg.png')),
                    ],
                  ),
                ),
              )
            : SearchList(searchKey: search!),
      ),
    );
  }
}

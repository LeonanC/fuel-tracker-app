import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/data/services/application.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class SearchList extends StatefulWidget {
  final String searchKey;
  const SearchList({super.key, required this.searchKey});

  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('postos')
              .orderBy('nome')
              .startAt([widget.searchKey])
              .endAt([widget.searchKey + '\uf8ff'])
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                return snapshot.data!.size == 0
                    ? Center(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No Postos found!',
                                style: GoogleFonts.lato(
                                  color: Colors.blue[800],
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Image(
                                image: AssetImage('assets/error-404.jpg'),
                                height: 250,
                                width: 250,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Scrollbar(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.size,
                          itemBuilder: (context, index) {
                            DocumentSnapshot posto = snapshot.data!.docs[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: Card(
                                color: Colors.blue[50],
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: InkWell(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                posto['nome'] ?? 'Sem Nome',
                                                style: GoogleFonts.lato(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.black87,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  RemixIcons
                                                      .money_dollar_circle_line,
                                                  size: 18,
                                                  color: Colors.indigo,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  doubleToCurrency(
                                                    posto['preco'],
                                                  ),
                                                  style: GoogleFonts.lato(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 17,
                                                    color: Colors.indigo[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          posto['brand'] ?? '',
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Divider(height: 15),
                                        Row(
                                          children: [
                                            Icon(
                                              RemixIcons.map_pin_2_line,
                                              size: 14,
                                              color: Colors.redAccent,
                                            ),
                                            SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                posto['endereco'] ??
                                                    'Endereço não informado',
                                                style: GoogleFonts.lato(
                                                  fontSize: 13,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            if (posto['is24Hours'] == true)
                                              _buildFeatureChip(
                                                '24h',
                                                RemixIcons.time_line,
                                              ),
                                            if (posto['hasConvenientStore'] ==
                                                true)
                                              _buildFeatureChip(
                                                'Loja',
                                                RemixIcons
                                                    .shopping_basket_2_line,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
              },
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.blue[800]),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11,
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/data_center.dart';
import '../../../Widgets/playlist_card.dart';
import '../../../size_confg.dart';

class AllPlaylists extends StatelessWidget {
  const AllPlaylists({super.key});

  @override
  Widget build(BuildContext context) {
    final dataCenter = Provider.of<DataCenter>(context);
    return SizedBox(
      height: getProportionateScreenHeight(170),
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dataCenter.playlists.length,
        itemBuilder: (context, index) {
          return PlayListCard(id: dataCenter.playlists[index].playlistid);
        },
      ),
    );
  }
}

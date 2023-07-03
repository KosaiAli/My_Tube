import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Models/data_center.dart';
import '../../../../Models/database.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dataCenter = Provider.of<DataCenter>(context);
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () async {
          await DB.instance.createPLaylist(dataCenter);
          dataCenter.downloadList();
          dataCenter.panelController.close();
        },
        child: Container(
          color: Colors.blue,
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          width: double.infinity,
          height: 60,
          child: const Text('download'),
        ),
      ),
    );
  }
}

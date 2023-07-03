import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/data_center.dart';
import './widgets/download_list.dart';

class DownloadScreen extends StatefulWidget {
  static const routeName = 'DownloadScreen';
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dataCenter = Provider.of<DataCenter>(context);
    return SafeArea(
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              dataCenter.initDownloadQueue();
              dataCenter.downloadAll();
            },
            child: const Text('start all'),
          ),
          const DownloadList(),
        ],
      ),
    );
  }
}

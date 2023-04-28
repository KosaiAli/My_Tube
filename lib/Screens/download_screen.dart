import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/data_center.dart';
import '../Widgets/video_card.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen(this.url, {super.key});
  final String? url;
  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    textEditingController.text = widget.url ?? '';

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataCenter>(
      builder: (context, dataCenter, child) {
        return SafeArea(
          child: Column(
            children: [
              TextButton(
                  onPressed: () {
                    dataCenter.downloadAll();
                  },
                  child: Text('start all')),
              Expanded(
                child: ListView.builder(
                  itemCount: dataCenter.videos.length,
                  itemBuilder: (context, index) {
                    return VideoCard(
                      video: dataCenter.videos[index],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

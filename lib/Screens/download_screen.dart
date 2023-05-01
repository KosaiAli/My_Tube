import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Models/data_center.dart';
import '../Widgets/video_card.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
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
                    dataCenter.initDownloadQueue();
                    dataCenter.downloadAll();
                  },
                  child: const Text('start all')),
              Expanded(
                child: ListView.builder(
                  itemCount: dataCenter.videos.length,
                  itemBuilder: (context, index) {
                    return VideoCard(
                      id: dataCenter.videos[index].id!,
                    );
                  },
                ),
              ),
              const SizedBox(height: 50)
            ],
          ),
        );
      },
    );
  }
}

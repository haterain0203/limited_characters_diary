import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                //TODO 月を変更する処理
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
            //TODO 固定値
            const Text('2023年3月'),
            TextButton(
              onPressed: () {
                //TODO 月を変更する処理
              },
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              //TODO
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView.builder(
        //TODO 固定値
        itemCount: 30,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            //TODO 本日はハイライト
            leading: Text(
              //TODO 日付と曜日が入ります
              //TODO 土日祝日は色を変える
              index.toString(),
            ),
            title: const Text(
              //TODO 日記の内容を表示
              '日記が入ります',
            ),
          );
        },
      ),
    );
  }
}

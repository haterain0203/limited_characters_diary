import 'package:flutter/material.dart';

class LocalNotificationSettingPage extends StatelessWidget {
  const LocalNotificationSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //TODO 時間設定
          TextButton(
            onPressed: () async {
              await showTimePicker(
                context: context,
                //TODO 固定値
                initialTime: TimeOfDay(hour: 21, minute: 00),
              );
            },
            //TODO 固定値
            child: Text('21:00'),
          ),
          ElevatedButton(
            child: const Text('設定'),
            onPressed: () {
              //TODO 通知パーミッション確認
              //TODO 通知スケジュール設定
            },
          ),
        ],
      ),
    );
  }
}

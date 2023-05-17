## 16文字日記
- 16文字までしか入力できない日記アプリ
- [AppStore](https://apps.apple.com/us/app/16%E6%96%87%E5%AD%97%E6%97%A5%E8%A8%98/id6448646374)
- [GooglePlay](https://play.google.com/store/apps/details?id=com.futtaro.limited_characters_diary)

## 機能
- 匿名認証
- 縦型カレンダーでの日記一覧表示
- 日記の登録/更新/削除
- 日記入力ダイアログの自動表示
- リマインダー通知
- パスコードロック
- アカウントおよびデータの削除
- 強制アップデート

## 使用技術
- Flutter
```
% fvm flutter --version
Flutter 3.7.12 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 4d9e56e694 (4 weeks ago) • 2023-04-17 21:47:46 -0400
Engine • revision 1a65d409c7
Tools • Dart 2.19.6 • DevTools 2.20.1
```
- [hooks_riverpod](https://pub.dev/packages/hooks_riverpod)
- Firebase
  - firebase_auth
  - cloud_firestore
  - firebase_analytics
  - firebase_app_check
- fvm（Flutter Version Management）
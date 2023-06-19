## 16文字日記
- 16文字までしか入力できない日記アプリ
- [AppStore](https://apps.apple.com/us/app/16%E6%96%87%E5%AD%97%E6%97%A5%E8%A8%98/id6448646374)
- [GooglePlay](https://play.google.com/store/apps/details?id=com.futtaro.limited_characters_diary)
<img src="https://github.com/haterain0203/limited_characters_diary/assets/58384546/0d8e5254-ea64-4528-84b8-dc3a00a35ebb" width=400>
<img src="https://github.com/haterain0203/limited_characters_diary/assets/58384546/837870fb-55d0-454e-bafe-2d4a50ba702e" width=400>

## 主な機能
- 匿名認証
- 縦型カレンダーでの日記一覧表示
- 日記の登録/更新/削除
- 特定条件での日記入力ダイアログの自動表示
- リマインダー通知（ローカルプッシュ通知）
- パスコードロック
- アカウントおよびデータの削除（退会処理）
- 強制アップデート
- WebView(問い合わせ・利用規約・プライバシーポリシーに使用)

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

## アーキテクチャ
- MVC + Repository
- 状態管理：Riverpod
<img src="https://github.com/haterain0203/limited_characters_diary/assets/58384546/92eac6f7-b0ca-445c-b4b1-36596038189a">

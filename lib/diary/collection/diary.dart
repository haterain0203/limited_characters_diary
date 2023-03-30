import 'package:isar/isar.dart';

part 'diary.g.dart';

@Collection()
class Diary {
  /// 自動インクリメントする ID
  Id id = Isar.autoIncrement;

  /// 日記の内容
  late String content;

  /// 日記の対象日付
  /// あらかじめ diary で並び替えて DB に保存されるのでメモ一覧の表示が高速化
  @Index()
  late DateTime diaryDate;

  /// 作成日時
  late DateTime createdAt;

  /// 更新日時
  late DateTime updatedAt;
}

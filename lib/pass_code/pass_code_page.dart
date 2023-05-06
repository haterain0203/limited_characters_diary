import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:limited_characters_diary/constant/enum.dart';
import 'package:limited_characters_diary/pass_code/pass_code_functions.dart';

/// PassCode設定がOnの場合、アプリ起動時にPassCodeを表示する
///
/// showScreenLockは関数のため、本来ListPage表示時に関数を読んでListPageにScreenLockが重なって表示されるべきだが、
/// ListPageの[WidgetsBinding.instance.addPostFrameCallback]で実行すると、ListPageが一瞬表示されてしまう。
/// それではPassCodeロックの意味がないため、アプリ起動時には画面遷移で実現することとした。
class PassCodePage extends HookConsumerWidget {
  const PassCodePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showScreenLock(
        context,
        ref,
        ShowScreenLockSituation.appStart,
      );
    });
    return const SizedBox();
  }
}

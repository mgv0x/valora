// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Valora';

  @override
  String get tagline => '無駄を減らし、もっと豊かに。';

  @override
  String get homeTitle => 'ホーム';

  @override
  String get pantryTitle => 'パントリー';

  @override
  String get expiryCenterTitle => '賞味期限センター';

  @override
  String get impactTitle => '実績・成果';

  @override
  String get settingsTitle => '設定';

  @override
  String get greetingMorning => 'おはようございます';

  @override
  String get greetingAfternoon => 'こんにちは';

  @override
  String get greetingEvening => 'こんばんは';

  @override
  String activeItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '保管中 $count 品',
      one: '保管中 1 品',
      zero: '保管中の食材はありません',
    );
    return '$_temp0';
  }

  @override
  String needsAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 品が注意を要します',
      one: '1 品が注意を要します',
      zero: '注意が必要な食材はありません',
    );
    return '$_temp0';
  }

  @override
  String expiringSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 品がもうすぐ期限切れです',
      one: '1 品がもうすぐ期限切れです',
      zero: 'もうすぐ期限切れの食材はありません',
    );
    return '$_temp0';
  }

  @override
  String get priorityItems => '優先対応の食材';

  @override
  String get consumeFirstTitle => '早めに消費';

  @override
  String get insightNoneUrgent => '現在、急ぎの対応が必要な食材はありません。';

  @override
  String insightExpired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 品の食材が賞味期限を過ぎています。廃棄を防ぐため早めに対応しましょう。',
      one: '1 品の食材がすでに賞味期限を過ぎています。廃棄を防ぐため早めに対応しましょう。',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 品が本日賞味期限を迎えます。早めにいただきましょう。',
      one: '1 品が本日賞味期限を迎えます。早めにいただきましょう。',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'これら $count 品は明日賞味期限を迎えます。',
      one: 'この食材は明日賞味期限を迎えます。',
    );
    return '$_temp0';
  }

  @override
  String get insightGeneralPriority => '食品ロス削減のため、これらの食材から優先的に料理しましょう。';

  @override
  String get priorityHigh => '優先度：高';

  @override
  String get priorityAttention => '注意';

  @override
  String get priorityOnTrack => '順調';

  @override
  String get viewAll => 'すべて表示';

  @override
  String get addFood => '食材を追加';

  @override
  String get editFood => '食材を編集';

  @override
  String get foodDetails => '食材の詳細';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get confirm => '確認';

  @override
  String get consume => '消費する';

  @override
  String get discard => '廃棄する';

  @override
  String get markConsumed => '消費済みとして記録';

  @override
  String get markDiscarded => '廃棄として記録';

  @override
  String get all => 'すべて';

  @override
  String get foodName => '食材名';

  @override
  String get foodNameHint => '例：有機牛乳、新鮮なリンゴ';

  @override
  String get foodNameRequired => '食材名を入力してください';

  @override
  String get category => 'カテゴリー';

  @override
  String get categoryRequired => 'カテゴリーを選択してください';

  @override
  String get quantity => '数量';

  @override
  String get quantityRequired => '0 より大きい数量を入力してください';

  @override
  String get unit => '単位';

  @override
  String get expiryDate => '賞味期限・消費期限';

  @override
  String get unknownExpiry => '期限不明';

  @override
  String get expiryDateRequired => '期限を選択するか、不明を選択してください';

  @override
  String get purchasePrice => '購入価格';

  @override
  String get purchasePriceOptional => '購入価格（任意）';

  @override
  String get purchasePriceInvalid => '価格にマイナス値は設定できません';

  @override
  String get storageLocation => '保管場所';

  @override
  String get storageLocationOptional => '保管場所（任意）';

  @override
  String get purchaseDate => '購入日';

  @override
  String get purchaseDateOptional => '購入日（任意）';

  @override
  String get notes => 'メモ';

  @override
  String get notesOptional => 'メモ（任意）';

  @override
  String get notesHint => 'ブランド、保存棚、ロット番号など';

  @override
  String get catFruits => 'フルーツ・果物';

  @override
  String get catVegetables => '野菜';

  @override
  String get catDairy => '乳製品';

  @override
  String get catMeatFish => '肉・魚介類';

  @override
  String get catBakery => 'パン・ベーカリー';

  @override
  String get catPantryStaples => '乾物・調味料・穀物';

  @override
  String get catFrozen => '冷凍食品';

  @override
  String get catDrinks => '飲料・ドリンク';

  @override
  String get catOther => 'その他';

  @override
  String get locRefrigerator => '冷蔵庫';

  @override
  String get locFreezer => '冷凍庫';

  @override
  String get locPantry => '常温・パントリー';

  @override
  String get locOther => 'その他';

  @override
  String get unitPiece => '個';

  @override
  String get unitGram => 'g';

  @override
  String get unitKilogram => 'kg';

  @override
  String get unitMilliliter => 'ml';

  @override
  String get unitLiter => 'L';

  @override
  String get unitPackage => 'パック/袋';

  @override
  String get statusExpired => '期限切れ';

  @override
  String get statusExpiringToday => '本日期限';

  @override
  String get statusExpiringSoon => 'もうすぐ期限切れ';

  @override
  String get statusFresh => '新鮮・良好';

  @override
  String get statusUnknown => '期限未設定';

  @override
  String daysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '残り $days 日',
      one: '残り 1 日',
      zero: '本日が期限',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 日前に期限切れ',
      one: '昨日期限切れ',
      zero: '本日期限切れ',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => '食材名で検索...';

  @override
  String get filterAll => 'すべて';

  @override
  String get sortBy => '並び替え';

  @override
  String get sortExpirySoonest => '賞味期限：近い順';

  @override
  String get sortExpiryLatest => '賞味期限：遠い順';

  @override
  String get sortNameAZ => '名前：あいうえお順';

  @override
  String get sortNameZA => '名前：逆順';

  @override
  String get emptyPantryTitle => 'パントリーが空です';

  @override
  String get emptyPantrySubtitle => 'ご家庭の食材を登録して、食品ロスを防ぎながら美味しく使い切りましょう。';

  @override
  String get emptySearchTitle => '一致する食材が見つかりません';

  @override
  String get emptySearchSubtitle => '別のキーワードで検索するか、フィルター条件を変更してください。';

  @override
  String get emptyExpiryTitle => 'すべて順調です！';

  @override
  String get emptyExpirySubtitle => '現在の設定期間内に期限切れまたは期限間近の食材はありません。';

  @override
  String get emptyImpactTitle => '記録がまだありません';

  @override
  String get emptyImpactSubtitle =>
      '食材を消費または廃棄として記録すると、Valora がここに客観的なデータをまとめます。';

  @override
  String get groupExpired => '期限切れ';

  @override
  String get groupExpiringToday => '本日期限';

  @override
  String get groupExpiringSoon => 'もうすぐ期限切れ';

  @override
  String get groupLater => '余裕あり';

  @override
  String get groupUnknown => '期限未設定';

  @override
  String get consumeDialogTitle => '消費の記録';

  @override
  String get consumeDialogPrompt => 'この食材をどれだけ消費しましたか？';

  @override
  String get discardDialogTitle => '廃棄の記録';

  @override
  String get discardDialogPrompt => 'この食材をどれだけ廃棄しましたか？';

  @override
  String get resetFilters => 'フィルターをリセット';

  @override
  String quantityRemaining(String qty, String unit) {
    return '残量：$qty $unit';
  }

  @override
  String quantityOriginal(String qty, String unit) {
    return '当初量：$qty $unit';
  }

  @override
  String quantityConsumed(String qty, String unit) {
    return '消費済：$qty $unit';
  }

  @override
  String quantityDiscarded(String qty, String unit) {
    return '廃棄済：$qty $unit';
  }

  @override
  String get deleteConfirmTitle => '食材を削除しますか？';

  @override
  String deleteConfirmContent(String name) {
    return '「$name」を削除してもよろしいですか？過去の消費・廃棄履歴は維持されます。';
  }

  @override
  String get actionSuccessSaved => '食材を保存しました。';

  @override
  String get actionSuccessConsumed => '消費として記録しました。';

  @override
  String get actionSuccessDiscarded => '廃棄として記録しました。';

  @override
  String get actionSuccessDeleted => 'パントリーから食材を削除しました。';

  @override
  String get impactSummary => '活動サマリー';

  @override
  String get itemsConsumed => '記録された消費食材数';

  @override
  String get itemsDiscarded => '記録された廃棄食材数';

  @override
  String get valueConsumed => '消費した推定額';

  @override
  String get valueDiscarded => '廃棄した推定額';

  @override
  String get consumptionRate => '消費率';

  @override
  String get impactDisclaimer =>
      'すべての指標は実際の記録に基づいて計算されます。Valora は誇張された節約額や環境数値を捏造しません。';

  @override
  String get impactHistoryTitle => '最近のアクティビティ履歴';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsNotifications => '通知設定';

  @override
  String get settingsEnableNotifications => '賞味期限リマインダー';

  @override
  String get settingsNotificationDesc => '食材の期限が近づいた際に端末通知を受け取ります。';

  @override
  String get settingsNotificationThreshold => '事前通知日数';

  @override
  String get settingsNotificationThresholdDesc => '賞味期限の何日前に通知するか設定します';

  @override
  String daysUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 日',
      one: '1 日',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataManagement => 'データ管理';

  @override
  String get settingsExportData => 'データのエクスポート (JSON)';

  @override
  String get settingsExportSuccess => 'データのエクスポートが完了しました。';

  @override
  String get settingsImportData => 'データのインポート (JSON)';

  @override
  String get settingsImportSuccess => 'データのインポートが完了しました。';

  @override
  String get settingsImportInvalid => '無効な JSON データファイルです。';

  @override
  String get settingsClearData => 'すべてのデータを消去';

  @override
  String get settingsClearDataConfirm =>
      'この操作は取り消せません。登録中のすべての食材とアクティビティ履歴が完全に削除されます。';

  @override
  String get settingsClearDataSuccess => '端末のローカルデータをすべて消去しました。';

  @override
  String get settingsAbout => 'Valora について';

  @override
  String get settingsAboutDesc =>
      'Valora は、Hack Club Cider チャレンジのために開発された、オフライン優先の洗練された食品在庫＆期限管理アプリです。';

  @override
  String get settingsPrivacy => 'プライバシーとデータ保管';

  @override
  String get settingsPrivacyDesc =>
      'すべてのデータは 100% お手元の端末内に保管されます。追跡ツールや不要なアカウント登録、強制クラウド同期はありません。';

  @override
  String get settingsLicense => 'オープンソースライセンス';

  @override
  String get settingsLicenseDesc => 'MIT ライセンスのもとで公開されています。';

  @override
  String get unsavedChangesTitle => '変更を破棄しますか？';

  @override
  String get unsavedChangesMessage => '未保存の変更があります。保存せずに終了してもよろしいですか？';

  @override
  String get expirySafetyDisclaimerTitle => '賞味期限と食品の安全性について';

  @override
  String get expirySafetyDisclaimerContent =>
      '賞味期限・消費期限は品質保持の目安です。必ず見た目、におい、状態をご自身で確認してください。期限未設定の食材はご自身で状態を確認する必要があり、自動的に安全または危険と判断されることはありません。';

  @override
  String get partial => '一部消費/廃棄';

  @override
  String quantityExceedsRemaining(String qty, String unit) {
    return '残量 ($qty $unit) を超える数量は入力できません';
  }

  @override
  String get discardConfirmPermanent => '廃棄の確定';

  @override
  String discardConfirmPermanentPrompt(String qty, String unit, String name) {
    return '「$name」の $qty $unit を廃棄として記録しますか？この操作は食品ロスとして集計され、元に戻せません。';
  }

  @override
  String get consumeNotesHint => '例：夕食の調理、お弁当';

  @override
  String get discardNotesHint => '例：傷み、期限超過';

  @override
  String get homeNeedsAction => '要対応';

  @override
  String get homeAddFoodDesc => '買ってきた食材を登録して食品ロスを防ぎましょう';

  @override
  String get activityDetailsTitle => 'アクティビティ詳細';

  @override
  String get activityDate => '日時';

  @override
  String get activityType => 'アクション種別';

  @override
  String get activityEstimatedValue => '推定金額';

  @override
  String get activityValueFormulaNotice => '入力された購入価格をもとに比率計算されています。';

  @override
  String get filterPeriod => '期間';

  @override
  String get filterPeriodAll => '全期間';

  @override
  String get filterPeriod7Days => '過去 7 日間';

  @override
  String get filterPeriod30Days => '過去 30 日間';

  @override
  String get filterType => '種別';

  @override
  String get filterTypeAll => 'すべてのアクション';

  @override
  String get filterTypeConsumed => '消費のみ';

  @override
  String get filterTypeDiscarded => '廃棄のみ';

  @override
  String get unitBreakdownTitle => '単位別の記録数量';

  @override
  String get consumedUnits => '消費量';

  @override
  String get discardedUnits => '廃棄量';

  @override
  String get fromPricedItems => '購入価格が記録された食材から算出';

  @override
  String get settingsPreferences => 'アプリ設定';

  @override
  String get settingsTheme => '外観テーマ';

  @override
  String get themeSystem => 'システムの標準設定に従う';

  @override
  String get themeLight => 'ライトモード';

  @override
  String get themeDark => 'ダークモード';

  @override
  String get themeSystemOption => 'システム';

  @override
  String get themeLightOption => 'ライト';

  @override
  String get themeDarkOption => 'ダーク';

  @override
  String get copyToClipboard => 'クリップボードにコピー';

  @override
  String get dataCopiedToClipboard => 'データをクリップボードにコピーしました！';

  @override
  String exportFailed(String error) {
    return 'エクスポートに失敗しました：$error';
  }

  @override
  String get importPastePrompt =>
      'エクスポートした Valora の JSON バックアップデータを下に貼り付けてください：';

  @override
  String get notificationPermissionDenied => '端末の設定で通知が許可されていません。';

  @override
  String get appVersionDetails => 'バージョン 1.0.0 • Hack Club Cider 提出作品';

  @override
  String get selectLanguage => '言語の選択 / Select Language';

  @override
  String get langPortuguese => 'Português (ポルトガル語/ブラジル)';

  @override
  String get langEnglish => 'English (英語)';

  @override
  String get langSpanish => 'Español (スペイン語)';

  @override
  String get langFrench => 'Français (フランス語)';

  @override
  String get langGerman => 'Deutsch (ドイツ語)';

  @override
  String get langItalian => 'Italiano (イタリア語)';

  @override
  String get langChinese => '中文 (中国語・簡体字)';

  @override
  String get langJapanese => '日本語';

  @override
  String get langRussian => 'Русский (ロシア語)';

  @override
  String get langArabic => 'العربية (アラビア語)';

  @override
  String get langHindi => 'हिन्दी (ヒンディー語)';

  @override
  String get langSystem => 'システムの標準設定 / System Default';

  @override
  String get subscriptionTitle => 'サブスクリプション＆紹介特典';

  @override
  String get subscriptionMonthlyPrice => '¥980 / 月';

  @override
  String get subscriptionFreeTrial => '7 日間無料トライアル';

  @override
  String get subscriptionTrialActive => '無料トライアル期間中';

  @override
  String subscriptionTrialDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '無料トライアル残り $days 日',
      one: '無料トライアル残り 1 日',
      zero: '無料トライアル最終日',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpired => 'トライアル期間が終了しました';

  @override
  String get subscriptionExpiredDesc =>
      'Android で Valora を継続してご利用いただくには、月額 ¥980 で登録するか、お友達を招待して無料日数を獲得してください。';

  @override
  String get subscriptionActive => 'サブスクリプション有効中';

  @override
  String get subscribeButton => '月額 ¥980 で登録する';

  @override
  String get referralTitle => 'お友達招待で +7 日間無料';

  @override
  String get referralDesc => 'お友達を 1 人招待するごとに、無料利用期間が +7 日間プレゼントされます！';

  @override
  String get referralYourCode => 'あなた専用の招待コード';

  @override
  String get referralEnterCode => '招待コードを入力';

  @override
  String get referralEnterCodePrompt => 'お友達の招待コードを入力して +7 日間の無料特典を受け取る：';

  @override
  String get referralApply => 'コードを適用';

  @override
  String get referralSuccess => 'おめでとうございます！+7 日間の無料期間が追加されました！';

  @override
  String get referralAlreadyUsed => 'この招待コードはすでに使用済みです。';

  @override
  String get referralSelfCode => 'ご自身の招待コードは使用できません。';

  @override
  String get referralInvalidCode => '無効な招待コードです。';

  @override
  String get referralSimulateInvite => 'お友達招待をテスト (+7 日)';

  @override
  String get referralShareText => '招待コードをシェア';

  @override
  String get referralInvitedCount => '招待した人数';

  @override
  String get referralBonusDaysCount => '獲得したボーナス日数';
}

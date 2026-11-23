// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Valora';

  @override
  String get tagline => '减少浪费，美好生活。';

  @override
  String get homeTitle => '首页';

  @override
  String get pantryTitle => '食品库';

  @override
  String get expiryCenterTitle => '保质期中心';

  @override
  String get impactTitle => '成效统计';

  @override
  String get settingsTitle => '设置';

  @override
  String get greetingMorning => '早上好';

  @override
  String get greetingAfternoon => '下午好';

  @override
  String get greetingEvening => '晚上好';

  @override
  String activeItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件在库食品',
      one: '1 件在库食品',
      zero: '暂无在库食品',
    );
    return '$_temp0';
  }

  @override
  String needsAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件食品需注意',
      one: '1 件食品需注意',
      zero: '无需特别关注',
    );
    return '$_temp0';
  }

  @override
  String expiringSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件食品即将过期',
      one: '1 件食品即将过期',
      zero: '无即将过期食品',
    );
    return '$_temp0';
  }

  @override
  String get priorityItems => '优先处理食品';

  @override
  String get consumeFirstTitle => '优先食用';

  @override
  String get insightNoneUrgent => '目前没有急需处理的食品。';

  @override
  String insightExpired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 件食品已过期，请优先处理以减少浪费。',
      one: '有 1 件食品已过期，请优先处理以减少浪费。',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 件食品今天到期，请尽快食用。',
      one: '有 1 件食品今天到期，请尽快食用。',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '这 $count 件食品明天到期。',
      one: '这件食品明天到期。',
    );
    return '$_temp0';
  }

  @override
  String get insightGeneralPriority => '优先处理这些食品以减少食物浪费。';

  @override
  String get priorityHigh => '高优先级';

  @override
  String get priorityAttention => '需关注';

  @override
  String get priorityOnTrack => '状态良好';

  @override
  String get viewAll => '查看全部';

  @override
  String get addFood => '添加食品';

  @override
  String get editFood => '编辑食品';

  @override
  String get foodDetails => '食品详情';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get confirm => '确认';

  @override
  String get consume => '食用';

  @override
  String get discard => '丢弃';

  @override
  String get markConsumed => '标记为已食用';

  @override
  String get markDiscarded => '标记为已丢弃';

  @override
  String get all => '全部';

  @override
  String get foodName => '食品名称';

  @override
  String get foodNameHint => '例如：有机牛奶、新鲜苹果';

  @override
  String get foodNameRequired => '请输入食品名称';

  @override
  String get category => '类别';

  @override
  String get categoryRequired => '请选择食品类别';

  @override
  String get quantity => '数量';

  @override
  String get quantityRequired => '请输入大于 0 的数量';

  @override
  String get unit => '单位';

  @override
  String get expiryDate => '保质期至';

  @override
  String get unknownExpiry => '保质期未知';

  @override
  String get expiryDateRequired => '请选择保质期或标记为未知';

  @override
  String get purchasePrice => '购买价格';

  @override
  String get purchasePriceOptional => '购买价格（选填）';

  @override
  String get purchasePriceInvalid => '价格不能为负数';

  @override
  String get storageLocation => '存放位置';

  @override
  String get storageLocationOptional => '存放位置（选填）';

  @override
  String get purchaseDate => '购买日期';

  @override
  String get purchaseDateOptional => '购买日期（选填）';

  @override
  String get notes => '备注';

  @override
  String get notesOptional => '备注（选填）';

  @override
  String get notesHint => '品牌、特定货架、批次等';

  @override
  String get catFruits => '水果';

  @override
  String get catVegetables => '蔬菜';

  @override
  String get catDairy => '乳制品';

  @override
  String get catMeatFish => '肉类与水产';

  @override
  String get catBakery => '烘焙糕点';

  @override
  String get catPantryStaples => '粮油干货';

  @override
  String get catFrozen => '冷冻食品';

  @override
  String get catDrinks => '酒水饮料';

  @override
  String get catOther => '其他';

  @override
  String get locRefrigerator => '冷藏室';

  @override
  String get locFreezer => '冷冻室';

  @override
  String get locPantry => '储藏柜';

  @override
  String get locOther => '其他位置';

  @override
  String get unitPiece => '个/件';

  @override
  String get unitGram => '克';

  @override
  String get unitKilogram => '千克';

  @override
  String get unitMilliliter => '毫升';

  @override
  String get unitLiter => '升';

  @override
  String get unitPackage => '包/盒';

  @override
  String get statusExpired => '已过期';

  @override
  String get statusExpiringToday => '今天到期';

  @override
  String get statusExpiringSoon => '即将到期';

  @override
  String get statusFresh => '新鲜良好';

  @override
  String get statusUnknown => '未知状态';

  @override
  String daysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '还剩 $days 天',
      one: '还剩 1 天',
      zero: '今天到期',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '已过期 $days 天',
      one: '昨天已过期',
      zero: '今天已过期',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => '按名称搜索食品...';

  @override
  String get filterAll => '全部';

  @override
  String get sortBy => '排序方式';

  @override
  String get sortExpirySoonest => '保质期：从早到晚';

  @override
  String get sortExpiryLatest => '保质期：从晚到早';

  @override
  String get sortNameAZ => '名称：A 到 Z';

  @override
  String get sortNameZA => '名称：Z 到 A';

  @override
  String get emptyPantryTitle => '食品库空空如也';

  @override
  String get emptyPantrySubtitle => '开始整理家里的食材，避免浪费，享受更优质的健康烹饪。';

  @override
  String get emptySearchTitle => '未找到匹配食品';

  @override
  String get emptySearchSubtitle => '请尝试搜索其他关键词或调整筛选条件。';

  @override
  String get emptyExpiryTitle => '一切状态良好！';

  @override
  String get emptyExpirySubtitle => '在当前预警期内没有已过期或即将过期的食品。';

  @override
  String get emptyImpactTitle => '暂无记录';

  @override
  String get emptyImpactSubtitle => '当您记录食用或丢弃食品时，Valora 会在此为您生成真实的统计洞察。';

  @override
  String get groupExpired => '已过期';

  @override
  String get groupExpiringToday => '今天到期';

  @override
  String get groupExpiringSoon => '即将到期';

  @override
  String get groupLater => '保质期充裕';

  @override
  String get groupUnknown => '保质期未知';

  @override
  String get consumeDialogTitle => '记录食用';

  @override
  String get consumeDialogPrompt => '您食用了多少该食品？';

  @override
  String get discardDialogTitle => '记录丢弃';

  @override
  String get discardDialogPrompt => '丢弃了多少该食品？';

  @override
  String get resetFilters => '重置筛选';

  @override
  String quantityRemaining(String qty, String unit) {
    return '剩余：$qty $unit';
  }

  @override
  String quantityOriginal(String qty, String unit) {
    return '初始：$qty $unit';
  }

  @override
  String quantityConsumed(String qty, String unit) {
    return '已食用：$qty $unit';
  }

  @override
  String quantityDiscarded(String qty, String unit) {
    return '已丢弃：$qty $unit';
  }

  @override
  String get deleteConfirmTitle => '删除食品？';

  @override
  String deleteConfirmContent(String name) {
    return '您确定要删除“$name”吗？历史活动记录将被保留。';
  }

  @override
  String get actionSuccessSaved => '食品保存成功。';

  @override
  String get actionSuccessConsumed => '已记录为食用。';

  @override
  String get actionSuccessDiscarded => '已记录为丢弃。';

  @override
  String get actionSuccessDeleted => '食品已从在库列表中移除。';

  @override
  String get impactSummary => '活动摘要';

  @override
  String get itemsConsumed => '记录已食用食品数';

  @override
  String get itemsDiscarded => '记录已丢弃食品数';

  @override
  String get valueConsumed => '已食用估计价值';

  @override
  String get valueDiscarded => '已丢弃估计价值';

  @override
  String get consumptionRate => '食用率';

  @override
  String get impactDisclaimer => '所有指标均根据真实记录计算。Valora 绝不会虚构节省金额或碳减排数字。';

  @override
  String get impactHistoryTitle => '近期活动记录';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsNotifications => '通知提醒';

  @override
  String get settingsEnableNotifications => '到期提醒通知';

  @override
  String get settingsNotificationDesc => '在食品临近保质期前接收设备通知提醒。';

  @override
  String get settingsNotificationThreshold => '提醒提前天数';

  @override
  String get settingsNotificationThresholdDesc => '提前多少天发出到期提醒';

  @override
  String daysUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天',
      one: '1 天',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataManagement => '数据管理';

  @override
  String get settingsExportData => '导出数据 (JSON)';

  @override
  String get settingsExportSuccess => '数据已成功导出。';

  @override
  String get settingsImportData => '导入数据 (JSON)';

  @override
  String get settingsImportSuccess => '数据导入成功。';

  @override
  String get settingsImportInvalid => '无效的 JSON 数据文件。';

  @override
  String get settingsClearData => '清除全部数据';

  @override
  String get settingsClearDataConfirm => '此操作无法撤销。所有在库食品和历史活动记录都将被永久删除。';

  @override
  String get settingsClearDataSuccess => '所有本地数据已清除。';

  @override
  String get settingsAbout => '关于 Valora';

  @override
  String get settingsAboutDesc =>
      'Valora 是一款纯净、优先离线的家庭食品库存管理与保质期追踪应用，专为 Hack Club Cider 挑战开发。';

  @override
  String get settingsPrivacy => '隐私与数据存储';

  @override
  String get settingsPrivacyDesc => '您的所有数据 100% 留存在本地设备上。无追踪器、无需账户、无云端强制同步。';

  @override
  String get settingsLicense => '开源许可';

  @override
  String get settingsLicenseDesc => '遵循 MIT 开源许可证发布。';

  @override
  String get unsavedChangesTitle => '放弃更改？';

  @override
  String get unsavedChangesMessage => '您有尚未保存的更改，确定要在未保存的情况下退出吗？';

  @override
  String get expirySafetyDisclaimerTitle => '保质期声明与食品安全';

  @override
  String get expirySafetyDisclaimerContent =>
      '保质期仅供食物品质和最佳风味参考。食用前请务必检查外观、气味和质地。未输入保质期的食品需人工检查，绝不会被自动视为安全或过期。';

  @override
  String get partial => '部分记录';

  @override
  String quantityExceedsRemaining(String qty, String unit) {
    return '不能超过剩余数量 ($qty $unit)';
  }

  @override
  String get discardConfirmPermanent => '确认丢弃';

  @override
  String discardConfirmPermanentPrompt(String qty, String unit, String name) {
    return '您确定要丢弃 $qty $unit 的“$name”吗？此操作将记录食物浪费且无法撤销。';
  }

  @override
  String get consumeNotesHint => '例如：家庭晚餐、便当制作';

  @override
  String get discardNotesHint => '例如：已变质、超过安全期';

  @override
  String get homeNeedsAction => '需尽快处理';

  @override
  String get homeAddFoodDesc => '及时录入新购买的食品以防止遗忘和浪费';

  @override
  String get activityDetailsTitle => '活动详情';

  @override
  String get activityDate => '日期与时间';

  @override
  String get activityType => '操作类型';

  @override
  String get activityEstimatedValue => '估算价值';

  @override
  String get activityValueFormulaNotice => '根据录入的购买价格按比例折算。';

  @override
  String get filterPeriod => '时间段';

  @override
  String get filterPeriodAll => '全部时间';

  @override
  String get filterPeriod7Days => '近 7 天';

  @override
  String get filterPeriod30Days => '近 30 天';

  @override
  String get filterType => '操作类型';

  @override
  String get filterTypeAll => '所有操作';

  @override
  String get filterTypeConsumed => '仅已食用';

  @override
  String get filterTypeDiscarded => '仅已丢弃';

  @override
  String get unitBreakdownTitle => '按单位记录的统计';

  @override
  String get consumedUnits => '已食用';

  @override
  String get discardedUnits => '已丢弃';

  @override
  String get fromPricedItems => '来源于有记录购买价格的食品';

  @override
  String get settingsPreferences => '应用偏好';

  @override
  String get settingsTheme => '外观主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色模式';

  @override
  String get themeDark => '深色模式';

  @override
  String get themeSystemOption => '跟随系统';

  @override
  String get themeLightOption => '浅色';

  @override
  String get themeDarkOption => '深色';

  @override
  String get copyToClipboard => '复制到剪贴板';

  @override
  String get dataCopiedToClipboard => '数据已复制到剪贴板！';

  @override
  String exportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String get importPastePrompt => '在下方粘贴您导出的 Valora JSON 备份内容：';

  @override
  String get notificationPermissionDenied => '设备系统设置未授予通知权限。';

  @override
  String get appVersionDetails => '版本 1.0.0 • Hack Club Cider 参赛作品';

  @override
  String get selectLanguage => '选择语言 / Select Language';

  @override
  String get langPortuguese => 'Português (葡萄牙语/巴西)';

  @override
  String get langEnglish => 'English (英语)';

  @override
  String get langSpanish => 'Español (西班牙语)';

  @override
  String get langFrench => 'Français (法语)';

  @override
  String get langGerman => 'Deutsch (德语)';

  @override
  String get langItalian => 'Italiano (意大利语)';

  @override
  String get langChinese => '中文 (简体)';

  @override
  String get langJapanese => '日本語 (日语)';

  @override
  String get langRussian => 'Русский (俄语)';

  @override
  String get langArabic => 'العربية (阿拉伯语)';

  @override
  String get langHindi => 'हिन्दी (印地语)';

  @override
  String get langSystem => '系统默认 / System Default';

  @override
  String get subscriptionTitle => '会员订阅与好友邀请';

  @override
  String get subscriptionMonthlyPrice => '¥9.90 / 月';

  @override
  String get subscriptionFreeTrial => '7 天免费试用';

  @override
  String get subscriptionTrialActive => '免费试用期';

  @override
  String subscriptionTrialDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '试用期剩余 $days 天',
      one: '试用期剩余 1 天',
      zero: '试用期最后一天',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpired => '试用期已结束';

  @override
  String get subscriptionExpiredDesc =>
      '若要在 Android 设备上继续使用 Valora，请订阅 ¥9.90/月或邀请好友赢取免费天数。';

  @override
  String get subscriptionActive => '会员订阅已生效';

  @override
  String get subscribeButton => '以 ¥9.90 / 月订阅';

  @override
  String get referralTitle => '推荐好友 (+7 天)';

  @override
  String get referralDesc => '您每邀请一位新好友，即可获赠 +7 天额外的免费使用时间！';

  @override
  String get referralYourCode => '您的专属推荐码';

  @override
  String get referralEnterCode => '输入好友推荐码';

  @override
  String get referralEnterCodePrompt => '输入好友的推荐码以领取 +7 天额外试用：';

  @override
  String get referralApply => '兑换推荐码';

  @override
  String get referralSuccess => '恭喜！您已成功获得 +7 天额外免费体验！';

  @override
  String get referralAlreadyUsed => '您已经兑换过该推荐码。';

  @override
  String get referralSelfCode => '不能使用您自己的推荐码。';

  @override
  String get referralInvalidCode => '无效的推荐码。';

  @override
  String get referralSimulateInvite => '模拟好友邀请 (+7天)';

  @override
  String get referralShareText => '分享邀请链接';

  @override
  String get referralInvitedCount => '已成功邀请好友';

  @override
  String get referralBonusDaysCount => '已赚取奖励天数';
}

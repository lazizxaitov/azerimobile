import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Azeri'**
  String get appTitle;

  /// No description provided for @menuLabel.
  ///
  /// In ru, this message translates to:
  /// **'Меню'**
  String get menuLabel;

  /// No description provided for @profileLabel.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileLabel;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите в свой аккаунт'**
  String get loginSubtitle;

  /// No description provided for @phoneHint.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get phoneHint;

  /// No description provided for @passwordHint.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыл пароль ?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get loginButton;

  /// No description provided for @guestButton.
  ///
  /// In ru, this message translates to:
  /// **'Войти как гость'**
  String get guestButton;

  /// No description provided for @registerButton.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get registerButton;

  /// No description provided for @registerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создайте свой аккаунт'**
  String get registerSubtitle;

  /// No description provided for @nameHint.
  ///
  /// In ru, this message translates to:
  /// **'Имя Фамилия'**
  String get nameHint;

  /// No description provided for @birthDateLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дата рождения'**
  String get birthDateLabel;

  /// No description provided for @birthDateHint.
  ///
  /// In ru, this message translates to:
  /// **'Дата рождения (ДД.ММ.ГГГГ)'**
  String get birthDateHint;

  /// No description provided for @createAccount.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт?'**
  String get alreadyHaveAccount;

  /// No description provided for @cartTitle.
  ///
  /// In ru, this message translates to:
  /// **'Корзина'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Корзина пустая'**
  String get cartEmpty;

  /// No description provided for @productDefault.
  ///
  /// In ru, this message translates to:
  /// **'Товар'**
  String get productDefault;

  /// No description provided for @totalSum.
  ///
  /// In ru, this message translates to:
  /// **'Общая сумма:'**
  String get totalSum;

  /// No description provided for @delivery.
  ///
  /// In ru, this message translates to:
  /// **'Доставка:'**
  String get delivery;

  /// No description provided for @discount.
  ///
  /// In ru, this message translates to:
  /// **'Скидка:'**
  String get discount;

  /// No description provided for @payButton.
  ///
  /// In ru, this message translates to:
  /// **'Оплатить'**
  String get payButton;

  /// No description provided for @authRequired.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы продолжить покупки надо авторизоваться'**
  String get authRequired;

  /// No description provided for @categoriesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get categoriesTitle;

  /// No description provided for @bonusSystem.
  ///
  /// In ru, this message translates to:
  /// **'Бонус система'**
  String get bonusSystem;

  /// No description provided for @topProducts.
  ///
  /// In ru, this message translates to:
  /// **'Топ товары'**
  String get topProducts;

  /// No description provided for @yourBonus.
  ///
  /// In ru, this message translates to:
  /// **'Ваш бонус'**
  String get yourBonus;

  /// No description provided for @notificationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notificationsTitle;

  /// No description provided for @notificationOrderAccepted.
  ///
  /// In ru, this message translates to:
  /// **'Ваш заказ принят'**
  String get notificationOrderAccepted;

  /// No description provided for @notificationOrderAcceptedSub.
  ///
  /// In ru, this message translates to:
  /// **'Ожидайте подтверждение от заведения'**
  String get notificationOrderAcceptedSub;

  /// No description provided for @notificationBonusAdded.
  ///
  /// In ru, this message translates to:
  /// **'Начислены бонусы'**
  String get notificationBonusAdded;

  /// No description provided for @notificationBonusAddedSub.
  ///
  /// In ru, this message translates to:
  /// **'Вы получили 5 000 бонусов'**
  String get notificationBonusAddedSub;

  /// No description provided for @markAllRead.
  ///
  /// In ru, this message translates to:
  /// **'Прочитал все'**
  String get markAllRead;

  /// No description provided for @categoryBreakfast.
  ///
  /// In ru, this message translates to:
  /// **'Завтраки'**
  String get categoryBreakfast;

  /// No description provided for @categoryPorridge.
  ///
  /// In ru, this message translates to:
  /// **'Каши'**
  String get categoryPorridge;

  /// No description provided for @categoryPancakes.
  ///
  /// In ru, this message translates to:
  /// **'Блины'**
  String get categoryPancakes;

  /// No description provided for @categoryDesserts.
  ///
  /// In ru, this message translates to:
  /// **'Десерты'**
  String get categoryDesserts;

  /// No description provided for @categoryDrinks.
  ///
  /// In ru, this message translates to:
  /// **'Напитки'**
  String get categoryDrinks;

  /// No description provided for @categorySalads.
  ///
  /// In ru, this message translates to:
  /// **'Салаты'**
  String get categorySalads;

  /// No description provided for @sampleProductName.
  ///
  /// In ru, this message translates to:
  /// **'Брускета с тунцом'**
  String get sampleProductName;

  /// No description provided for @sampleDescriptionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get sampleDescriptionTitle;

  /// No description provided for @sampleDescriptionText.
  ///
  /// In ru, this message translates to:
  /// **'Брускетта с тунцом\nСвежая, сбалансированная и лёгкая.\nИдеальный вариант для тех, кто хочет вкусно, но не тяжело.'**
  String get sampleDescriptionText;

  /// No description provided for @portionHalf.
  ///
  /// In ru, this message translates to:
  /// **'Половина'**
  String get portionHalf;

  /// No description provided for @portionFull.
  ///
  /// In ru, this message translates to:
  /// **'Полная'**
  String get portionFull;

  /// No description provided for @addButton.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get addButton;

  /// No description provided for @addToCart.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в корзину'**
  String get addToCart;

  /// No description provided for @portionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Порция'**
  String get portionTitle;

  /// No description provided for @checkoutTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение оплаты'**
  String get checkoutTitle;

  /// No description provided for @orderType.
  ///
  /// In ru, this message translates to:
  /// **'Тип заказа'**
  String get orderType;

  /// No description provided for @deliveryOption.
  ///
  /// In ru, this message translates to:
  /// **'Доставка'**
  String get deliveryOption;

  /// No description provided for @pickupOption.
  ///
  /// In ru, this message translates to:
  /// **'Самовывоз'**
  String get pickupOption;

  /// No description provided for @deliveryAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес доставки'**
  String get deliveryAddress;

  /// No description provided for @pickupPlace.
  ///
  /// In ru, this message translates to:
  /// **'Выбор заведения'**
  String get pickupPlace;

  /// No description provided for @paymentMethod.
  ///
  /// In ru, this message translates to:
  /// **'Способ оплаты'**
  String get paymentMethod;

  /// No description provided for @payByCard.
  ///
  /// In ru, this message translates to:
  /// **'Картой'**
  String get payByCard;

  /// No description provided for @payByCash.
  ///
  /// In ru, this message translates to:
  /// **'Наличными'**
  String get payByCash;

  /// No description provided for @copy.
  ///
  /// In ru, this message translates to:
  /// **'Копировать'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get copied;

  /// No description provided for @youHaveBonuses.
  ///
  /// In ru, this message translates to:
  /// **'У вас {count} бонусов'**
  String youHaveBonuses(Object count);

  /// No description provided for @bonusAmountHint.
  ///
  /// In ru, this message translates to:
  /// **'Количество бонусов'**
  String get bonusAmountHint;

  /// No description provided for @orderComment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий к заказу'**
  String get orderComment;

  /// No description provided for @grandTotal.
  ///
  /// In ru, this message translates to:
  /// **'Итого:'**
  String get grandTotal;

  /// No description provided for @confirmOrder.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить заказ'**
  String get confirmOrder;

  /// No description provided for @useBonus.
  ///
  /// In ru, this message translates to:
  /// **'Использовать бонус'**
  String get useBonus;

  /// No description provided for @addNewAddress.
  ///
  /// In ru, this message translates to:
  /// **'Добавить новый адрес'**
  String get addNewAddress;

  /// No description provided for @newAddressTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый адрес'**
  String get newAddressTitle;

  /// No description provided for @mapLocation.
  ///
  /// In ru, this message translates to:
  /// **'Карта и определение местоположения'**
  String get mapLocation;

  /// No description provided for @addressNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Имя адреса (Дом, Работа...)'**
  String get addressNameHint;

  /// No description provided for @addressAutoHint.
  ///
  /// In ru, this message translates to:
  /// **'Адрес (определяется автоматически)'**
  String get addressAutoHint;

  /// No description provided for @addressCommentHint.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий к адресу'**
  String get addressCommentHint;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @commentPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Введите комментарий'**
  String get commentPlaceholder;

  /// No description provided for @ordersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заказы'**
  String get ordersTitle;

  /// No description provided for @ordersEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Заказы будут здесь'**
  String get ordersEmpty;

  /// No description provided for @orderSuccessTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заказ успешно отправлен'**
  String get orderSuccessTitle;

  /// No description provided for @goToOrder.
  ///
  /// In ru, this message translates to:
  /// **'Перейти к заказу'**
  String get goToOrder;

  /// No description provided for @continueShopping.
  ///
  /// In ru, this message translates to:
  /// **'Продолжать покупки'**
  String get continueShopping;

  /// No description provided for @myAddressesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои адреса'**
  String get myAddressesTitle;

  /// No description provided for @addAddress.
  ///
  /// In ru, this message translates to:
  /// **'Добавить адрес'**
  String get addAddress;

  /// No description provided for @addressHome.
  ///
  /// In ru, this message translates to:
  /// **'Дом'**
  String get addressHome;

  /// No description provided for @addressWork.
  ///
  /// In ru, this message translates to:
  /// **'Работа'**
  String get addressWork;

  /// No description provided for @sampleDeliveryAddress1.
  ///
  /// In ru, this message translates to:
  /// **'Ташкент, Мирзо-Улугбек, 12'**
  String get sampleDeliveryAddress1;

  /// No description provided for @sampleDeliveryAddress2.
  ///
  /// In ru, this message translates to:
  /// **'Ташкент, Чиланзар, 45'**
  String get sampleDeliveryAddress2;

  /// No description provided for @sampleDeliveryAddress3.
  ///
  /// In ru, this message translates to:
  /// **'Самарканд, Центр, 7'**
  String get sampleDeliveryAddress3;

  /// No description provided for @sampleStore1.
  ///
  /// In ru, this message translates to:
  /// **'Azeri — Ташкент (Центр)'**
  String get sampleStore1;

  /// No description provided for @sampleStore2.
  ///
  /// In ru, this message translates to:
  /// **'Azeri — Ташкент (Юнусабад)'**
  String get sampleStore2;

  /// No description provided for @sampleStore3.
  ///
  /// In ru, this message translates to:
  /// **'Azeri — Самарканд'**
  String get sampleStore3;

  /// No description provided for @sampleUserAddressHomeLine.
  ///
  /// In ru, this message translates to:
  /// **'ул. Ташкент 12, кв 34'**
  String get sampleUserAddressHomeLine;

  /// No description provided for @sampleUserAddressWorkLine.
  ///
  /// In ru, this message translates to:
  /// **'пр. Независимости 7'**
  String get sampleUserAddressWorkLine;

  /// No description provided for @myBonusesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои бонусы'**
  String get myBonusesTitle;

  /// No description provided for @bonusHistory.
  ///
  /// In ru, this message translates to:
  /// **'История бонусов'**
  String get bonusHistory;

  /// No description provided for @bonusReasonRedeemed.
  ///
  /// In ru, this message translates to:
  /// **'Бонус списан'**
  String get bonusReasonRedeemed;

  /// No description provided for @bonusReasonManualAdjustment.
  ///
  /// In ru, this message translates to:
  /// **'Ручная корректировка бонусов'**
  String get bonusReasonManualAdjustment;

  /// No description provided for @bonusPurchase.
  ///
  /// In ru, this message translates to:
  /// **'Покупка'**
  String get bonusPurchase;

  /// No description provided for @bonusAccrual.
  ///
  /// In ru, this message translates to:
  /// **'Начисление'**
  String get bonusAccrual;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Язык приложения'**
  String get languageTitle;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageUzbek.
  ///
  /// In ru, this message translates to:
  /// **'Oʻzbekcha'**
  String get languageUzbek;

  /// No description provided for @languageEnglish.
  ///
  /// In ru, this message translates to:
  /// **'Английский'**
  String get languageEnglish;

  /// No description provided for @changePassword.
  ///
  /// In ru, this message translates to:
  /// **'Изменить пароль'**
  String get changePassword;

  /// No description provided for @myAddresses.
  ///
  /// In ru, this message translates to:
  /// **'Мои адреса'**
  String get myAddresses;

  /// No description provided for @myOrders.
  ///
  /// In ru, this message translates to:
  /// **'Мои заказы'**
  String get myOrders;

  /// No description provided for @myBonuses.
  ///
  /// In ru, this message translates to:
  /// **'Мои бонусы'**
  String get myBonuses;

  /// No description provided for @logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get deleteAccount;

  /// No description provided for @unauthorizedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь не авторизован'**
  String get unauthorizedMessage;

  /// No description provided for @login.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get register;

  /// No description provided for @newAddressMapTitle.
  ///
  /// In ru, this message translates to:
  /// **'Карта и определение местоположения'**
  String get newAddressMapTitle;

  /// No description provided for @addressTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Название (Дом, Работа)'**
  String get addressTitleHint;

  /// No description provided for @addressHint.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get addressHint;

  /// No description provided for @commentHint.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get commentHint;

  /// No description provided for @changePasswordTitle.
  ///
  /// In ru, this message translates to:
  /// **'Изменить пароль'**
  String get changePasswordTitle;

  /// No description provided for @oldPassword.
  ///
  /// In ru, this message translates to:
  /// **'Старый пароль'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In ru, this message translates to:
  /// **'Новый пароль'**
  String get newPassword;

  /// No description provided for @confirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get confirm;

  /// No description provided for @oldPasswordWrong.
  ///
  /// In ru, this message translates to:
  /// **'Старый пароль неверный'**
  String get oldPasswordWrong;

  /// No description provided for @enterNewPassword.
  ///
  /// In ru, this message translates to:
  /// **'Введите новый пароль'**
  String get enterNewPassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Пароль обновлён'**
  String get passwordUpdated;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы точно хотите выйти?'**
  String get logoutConfirmMessage;

  /// No description provided for @logoutConfirmButton.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logoutConfirmButton;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт будет удалён. Продолжить?'**
  String get deleteConfirmMessage;

  /// No description provided for @deleteConfirmButton.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get deleteConfirmButton;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @selectLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Выберите язык'**
  String get selectLanguage;

  /// No description provided for @aboutButtonLabel.
  ///
  /// In ru, this message translates to:
  /// **'О нас'**
  String get aboutButtonLabel;

  /// No description provided for @aboutTitle.
  ///
  /// In ru, this message translates to:
  /// **'О нас'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In ru, this message translates to:
  /// **'Azeri Cafe Bakery - свежая выпечка, десерты и завтраки каждый день.'**
  String get aboutDescription;

  /// No description provided for @aboutCafeName.
  ///
  /// In ru, this message translates to:
  /// **'Ресторан:'**
  String get aboutCafeName;

  /// No description provided for @aboutAddress.
  ///
  /// In ru, this message translates to:
  /// **'Адрес:'**
  String get aboutAddress;

  /// No description provided for @aboutPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон:'**
  String get aboutPhone;

  /// No description provided for @aboutHours.
  ///
  /// In ru, this message translates to:
  /// **'Время:'**
  String get aboutHours;

  /// No description provided for @aboutContacts.
  ///
  /// In ru, this message translates to:
  /// **'Контакты'**
  String get aboutContacts;

  /// No description provided for @aboutInstagram.
  ///
  /// In ru, this message translates to:
  /// **'Instagram:'**
  String get aboutInstagram;

  /// No description provided for @aboutTelegram.
  ///
  /// In ru, this message translates to:
  /// **'Telegram:'**
  String get aboutTelegram;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @currencySum.
  ///
  /// In ru, this message translates to:
  /// **'сум'**
  String get currencySum;

  /// No description provided for @bonusAmount.
  ///
  /// In ru, this message translates to:
  /// **'{amount} сум'**
  String bonusAmount(Object amount);

  /// No description provided for @unknownRoute.
  ///
  /// In ru, this message translates to:
  /// **'Unknown route: {routeName}'**
  String unknownRoute(Object routeName);

  /// No description provided for @noAddresses.
  ///
  /// In ru, this message translates to:
  /// **'Адресов пока нет'**
  String get noAddresses;

  /// No description provided for @noPickupPoints.
  ///
  /// In ru, this message translates to:
  /// **'Заведений пока нет'**
  String get noPickupPoints;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Детали заказа'**
  String get orderDetailsTitle;

  /// No description provided for @orderItemsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Состав заказа'**
  String get orderItemsTitle;

  /// No description provided for @orderStatusAccepted.
  ///
  /// In ru, this message translates to:
  /// **'Заказ принят'**
  String get orderStatusAccepted;

  /// No description provided for @orderStatusDelivering.
  ///
  /// In ru, this message translates to:
  /// **'Заказ доставляется'**
  String get orderStatusDelivering;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In ru, this message translates to:
  /// **'Доставлен'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCanceled.
  ///
  /// In ru, this message translates to:
  /// **'Отменен'**
  String get orderStatusCanceled;

  /// No description provided for @courierInfoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Доставщик'**
  String get courierInfoTitle;

  /// No description provided for @courierName.
  ///
  /// In ru, this message translates to:
  /// **'Имя:'**
  String get courierName;

  /// No description provided for @courierPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон:'**
  String get courierPhone;

  /// No description provided for @courierCar.
  ///
  /// In ru, this message translates to:
  /// **'Машина:'**
  String get courierCar;

  /// No description provided for @callCourier.
  ///
  /// In ru, this message translates to:
  /// **'Позвонить'**
  String get callCourier;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

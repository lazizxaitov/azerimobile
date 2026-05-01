// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Azeri';

  @override
  String get menuLabel => 'Меню';

  @override
  String get profileLabel => 'Профиль';

  @override
  String get loginTitle => 'Вход';

  @override
  String get loginSubtitle => 'Войдите в свой аккаунт';

  @override
  String get phoneHint => 'Номер телефона';

  @override
  String get passwordHint => 'Пароль';

  @override
  String get forgotPassword => 'Забыл пароль ?';

  @override
  String get loginButton => 'Войти';

  @override
  String get guestButton => 'Войти как гость';

  @override
  String get registerButton => 'Зарегистрироваться';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get registerSubtitle => 'Создайте свой аккаунт';

  @override
  String get nameHint => 'Имя Фамилия';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get cartTitle => 'Корзина';

  @override
  String get cartEmpty => 'Корзина пустая';

  @override
  String get productDefault => 'Товар';

  @override
  String get totalSum => 'Общая сумма:';

  @override
  String get delivery => 'Доставка:';

  @override
  String get discount => 'Скидка:';

  @override
  String get payButton => 'Оплатить';

  @override
  String get authRequired => 'Чтобы продолжить покупки надо авторизоваться';

  @override
  String get categoriesTitle => 'Категории';

  @override
  String get bonusSystem => 'Бонус система';

  @override
  String get topProducts => 'Топ товары';

  @override
  String get yourBonus => 'Ваш бонус';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationOrderAccepted => 'Ваш заказ принят';

  @override
  String get notificationOrderAcceptedSub =>
      'Ожидайте подтверждение от заведения';

  @override
  String get notificationBonusAdded => 'Начислены бонусы';

  @override
  String get notificationBonusAddedSub => 'Вы получили 5 000 бонусов';

  @override
  String get markAllRead => 'Прочитал все';

  @override
  String get categoryBreakfast => 'Завтраки';

  @override
  String get categoryPorridge => 'Каши';

  @override
  String get categoryPancakes => 'Блины';

  @override
  String get categoryDesserts => 'Десерты';

  @override
  String get categoryDrinks => 'Напитки';

  @override
  String get categorySalads => 'Салаты';

  @override
  String get sampleProductName => 'Брускета с тунцом';

  @override
  String get sampleDescriptionTitle => 'Описание';

  @override
  String get sampleDescriptionText =>
      'Брускетта с тунцом\nСвежая, сбалансированная и лёгкая.\nИдеальный вариант для тех, кто хочет вкусно, но не тяжело.';

  @override
  String get portionHalf => 'Половина';

  @override
  String get portionFull => 'Полная';

  @override
  String get addButton => 'Добавить';

  @override
  String get addToCart => 'Добавить в корзину';

  @override
  String get portionTitle => 'Порция';

  @override
  String get checkoutTitle => 'Подтверждение оплаты';

  @override
  String get orderType => 'Тип заказа';

  @override
  String get deliveryOption => 'Доставка';

  @override
  String get pickupOption => 'Самовывоз';

  @override
  String get deliveryAddress => 'Адрес доставки';

  @override
  String get pickupPlace => 'Выбор заведения';

  @override
  String get paymentMethod => 'Способ оплаты';

  @override
  String get payByCard => 'Картой';

  @override
  String get payByCash => 'Наличными';

  @override
  String get copy => 'Копировать';

  @override
  String get copied => 'Скопировано';

  @override
  String youHaveBonuses(Object count) {
    return 'У вас $count бонусов';
  }

  @override
  String get bonusAmountHint => 'Количество бонусов';

  @override
  String get orderComment => 'Комментарий к заказу';

  @override
  String get grandTotal => 'Итого:';

  @override
  String get confirmOrder => 'Подтвердить заказ';

  @override
  String get useBonus => 'Использовать бонус';

  @override
  String get addNewAddress => 'Добавить новый адрес';

  @override
  String get newAddressTitle => 'Новый адрес';

  @override
  String get mapLocation => 'Карта и определение местоположения';

  @override
  String get addressNameHint => 'Имя адреса (Дом, Работа...)';

  @override
  String get addressAutoHint => 'Адрес (определяется автоматически)';

  @override
  String get addressCommentHint => 'Комментарий к адресу';

  @override
  String get save => 'Сохранить';

  @override
  String get commentPlaceholder => 'Введите комментарий';

  @override
  String get ordersTitle => 'Заказы';

  @override
  String get ordersEmpty => 'Заказы будут здесь';

  @override
  String get orderSuccessTitle => 'Заказ успешно отправлен';

  @override
  String get goToOrder => 'Перейти к заказу';

  @override
  String get continueShopping => 'Продолжать покупки';

  @override
  String get myAddressesTitle => 'Мои адреса';

  @override
  String get addAddress => 'Добавить адрес';

  @override
  String get addressHome => 'Дом';

  @override
  String get addressWork => 'Работа';

  @override
  String get sampleDeliveryAddress1 => 'Ташкент, Мирзо-Улугбек, 12';

  @override
  String get sampleDeliveryAddress2 => 'Ташкент, Чиланзар, 45';

  @override
  String get sampleDeliveryAddress3 => 'Самарканд, Центр, 7';

  @override
  String get sampleStore1 => 'Azeri — Ташкент (Центр)';

  @override
  String get sampleStore2 => 'Azeri — Ташкент (Юнусабад)';

  @override
  String get sampleStore3 => 'Azeri — Самарканд';

  @override
  String get sampleUserAddressHomeLine => 'ул. Ташкент 12, кв 34';

  @override
  String get sampleUserAddressWorkLine => 'пр. Независимости 7';

  @override
  String get myBonusesTitle => 'Мои бонусы';

  @override
  String get bonusHistory => 'История бонусов';

  @override
  String get bonusPurchase => 'Покупка';

  @override
  String get bonusAccrual => 'Начисление';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get languageTitle => 'Язык приложения';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageUzbek => 'Oʻzbekcha';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get myAddresses => 'Мои адреса';

  @override
  String get myOrders => 'Мои заказы';

  @override
  String get myBonuses => 'Мои бонусы';

  @override
  String get logout => 'Выйти из аккаунта';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get unauthorizedMessage => 'Пользователь не авторизован';

  @override
  String get login => 'Войти';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get newAddressMapTitle => 'Карта и определение местоположения';

  @override
  String get addressTitleHint => 'Название (Дом, Работа)';

  @override
  String get addressHint => 'Адрес';

  @override
  String get commentHint => 'Комментарий';

  @override
  String get changePasswordTitle => 'Изменить пароль';

  @override
  String get oldPassword => 'Старый пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get oldPasswordWrong => 'Старый пароль неверный';

  @override
  String get enterNewPassword => 'Введите новый пароль';

  @override
  String get passwordUpdated => 'Пароль обновлён';

  @override
  String get logoutConfirmTitle => 'Выйти из аккаунта?';

  @override
  String get logoutConfirmMessage => 'Вы точно хотите выйти?';

  @override
  String get logoutConfirmButton => 'Выйти';

  @override
  String get deleteConfirmTitle => 'Удалить аккаунт?';

  @override
  String get deleteConfirmMessage => 'Аккаунт будет удалён. Продолжить?';

  @override
  String get deleteConfirmButton => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get aboutButtonLabel => 'О нас';

  @override
  String get aboutTitle => 'О нас';

  @override
  String get aboutDescription =>
      'Azeri Cafe Bakery - свежая выпечка, десерты и завтраки каждый день.';

  @override
  String get aboutCafeName => 'Ресторан:';

  @override
  String get aboutAddress => 'Адрес:';

  @override
  String get aboutPhone => 'Телефон:';

  @override
  String get aboutHours => 'Время:';

  @override
  String get aboutContacts => 'Контакты';

  @override
  String get aboutInstagram => 'Instagram:';

  @override
  String get aboutTelegram => 'Telegram:';

  @override
  String get close => 'Закрыть';

  @override
  String get currencySum => 'сум';

  @override
  String bonusAmount(Object amount) {
    return '$amount сум';
  }

  @override
  String unknownRoute(Object routeName) {
    return 'Unknown route: $routeName';
  }

  @override
  String get noAddresses => 'Адресов пока нет';

  @override
  String get noPickupPoints => 'Заведений пока нет';

  @override
  String get orderDetailsTitle => 'Детали заказа';

  @override
  String get orderItemsTitle => 'Состав заказа';

  @override
  String get orderStatusAccepted => 'Заказ принят';

  @override
  String get orderStatusDelivering => 'Заказ доставляется';

  @override
  String get orderStatusDelivered => 'Доставлен';

  @override
  String get orderStatusCanceled => 'Отменен';

  @override
  String get courierInfoTitle => 'Доставщик';

  @override
  String get courierName => 'Имя:';

  @override
  String get courierPhone => 'Телефон:';

  @override
  String get courierCar => 'Машина:';

  @override
  String get callCourier => 'Позвонить';
}

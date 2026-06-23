import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PizzaModel {
  final String id;
  final String name;
  final String desc;
  final int price;
  final String image;
  final String tag;
  final String category;

  PizzaModel({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    required this.image,
    required this.tag,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'desc': desc,
        'price': price,
        'image': image,
        'tag': tag,
        'category': category,
      };

  factory PizzaModel.fromJson(Map<String, dynamic> json) => PizzaModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        desc: json['desc'] ?? '',
        price: json['price'] ?? 0,
        image: json['image'] ?? 'assets/1.png',
        tag: json['tag'] ?? 'pizza_${DateTime.now().millisecondsSinceEpoch}',
        category: json['category'] ?? 'Classic',
      );
}

class CartItem {
  final String name;
  final String size;
  final List<String> toppings;
  final String drink;
  final int quantity;
  final int totalPrice;
  final String image;

  CartItem({
    required this.name,
    required this.size,
    required this.toppings,
    required this.drink,
    required this.quantity,
    required this.totalPrice,
    required this.image,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'size': size,
        'toppings': toppings,
        'drink': drink,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'image': image,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        name: json['name'] ?? '',
        size: json['size'] ?? '',
        toppings: List<String>.from(json['toppings'] ?? const []),
        drink: json['drink'] ?? '',
        quantity: json['quantity'] ?? 1,
        totalPrice: json['totalPrice'] ?? 0,
        image: json['image'] ?? 'assets/1.jpg',
      );
}

class OrderModel {
  final String id;
  final List<CartItem> items;
  final int totalAmount;
  final String address;
  final String phone;
  final DateTime dateTime;
  final String userEmail;
  final String customerName;
  final String paymentMethod;
  final String status;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.address,
    required this.phone,
    required this.dateTime,
    this.userEmail = '',
    this.customerName = '',
    this.paymentMethod = 'cash',
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'address': address,
        'phone': phone,
        'dateTime': Timestamp.fromDate(dateTime),
        'userEmail': userEmail,
        'customerName': customerName,
        'paymentMethod': paymentMethod,
        'status': status,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['dateTime'];
    final dateTime = rawDate is Timestamp
        ? rawDate.toDate()
        : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now();

    return OrderModel(
      id: json['id'] ?? '',
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      totalAmount: json['totalAmount'] ?? 0,
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      dateTime: dateTime,
      userEmail: json['userEmail'] ?? '',
      customerName: json['customerName'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'cash',
      status: json['status'] ?? 'pending',
    );
  }
}

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String phone;
  final String password;
  final String role;
  final String defaultAddress;
  final String linkedPaymentMethod;
  final bool notificationsEnabled;
  final String language;
  final bool disabled;
  final int loyaltyPoints;

  UserModel({
    this.uid = '',
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    this.role = 'user',
    this.defaultAddress = '',
    this.linkedPaymentMethod = '',
    this.notificationsEnabled = true,
    this.language = 'Tiáº¿ng Viá»‡t',
    this.disabled = false,
    this.loyaltyPoints = 0,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
        'defaultAddress': defaultAddress,
        'linkedPaymentMethod': linkedPaymentMethod,
        'notificationsEnabled': notificationsEnabled,
        'language': language,
        'disabled': disabled,
        'loyaltyPoints': loyaltyPoints,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] ?? '',
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        password: json['password'] ?? '',
        role: json['role'] ?? 'user',
        defaultAddress: json['defaultAddress'] ?? '',
        linkedPaymentMethod: json['linkedPaymentMethod'] ?? '',
        notificationsEnabled: json['notificationsEnabled'] ?? true,
        language: json['language'] ?? 'Tiáº¿ng Viá»‡t',
        disabled: json['disabled'] ?? false,
        loyaltyPoints: json['loyaltyPoints'] ?? 0,
      );

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? phone,
    String? password,
    String? role,
    String? defaultAddress,
    String? linkedPaymentMethod,
    bool? notificationsEnabled,
    String? language,
    bool? disabled,
    int? loyaltyPoints,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role ?? this.role,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      linkedPaymentMethod: linkedPaymentMethod ?? this.linkedPaymentMethod,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      disabled: disabled ?? this.disabled,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    );
  }
}

class CartManager extends ChangeNotifier {
  CartManager._privateConstructor();
  static final CartManager _instance = CartManager._privateConstructor();
  factory CartManager() => _instance;

  late final firebase_auth.FirebaseAuth _auth =
      firebase_auth.FirebaseAuth.instance;
  late final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  firebase_auth.FirebaseAuth? _adminCreationAuth;

  final List<CartItem> _items = [];
  final List<OrderModel> _orderHistory = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;

  static List<UserModel> _registeredUsers = [
    UserModel(
        username: 'Admin',
        email: 'admin@gmail.com',
        phone: '0123456789',
        password: '123456',
        role: 'admin'),
  ];

  List<PizzaModel> _availablePizzas = [
    // HOT DEALS
    PizzaModel(
        id: '1',
        name: 'Vesuvius Inferno',
        desc:
            'S\u1ef1 k\u1ebft h\u1ee3p b\u00f9ng n\u1ed5 c\u1ee7a x\u00fac x\u00edch cay Pepperoni v\u00e0 ph\u00f4 mai.',
        price: 229000,
        image: 'assets/1.jpg',
        tag: 'pizza_0',
        category: 'Hot Deals'),
    PizzaModel(
        id: '6',
        name: 'Meat Lovers',
        desc:
            'Th\u1ecbt x\u00f4ng kh\u00f3i, x\u00fac x\u00edch \u00dd, th\u1ecbt b\u00f2 vi\u00ean v\u00e0 ph\u00f4 mai ph\u1ee7 ph\u00ea.',
        price: 269000,
        image: 'assets/6.jpg',
        tag: 'pizza_5',
        category: 'Hot Deals'),
    PizzaModel(
        id: '7',
        name: 'BBQ Pork Ribs',
        desc:
            'S\u01b0\u1eddn heo BBQ \u0111\u1eadm v\u1ecb, h\u00e0nh t\u00edm v\u00e0 l\u1edbp ph\u00f4 mai b\u00e9o th\u01a1m.',
        price: 289000,
        image: 'assets/7.png',
        tag: 'pizza_6',
        category: 'Hot Deals'),

    // CLASSIC
    PizzaModel(
        id: '3',
        name: 'Margherita Classica',
        desc:
            'S\u1ed1t c\u00e0 chua t\u01b0\u01a1i, ph\u00f4 mai Mozzarella t\u01b0\u01a1i v\u00e0 l\u00e1 h\u00fang t\u00e2y.',
        price: 189000,
        image: 'assets/3.jpg',
        tag: 'pizza_2',
        category: 'Classic'),
    PizzaModel(
        id: '5',
        name: 'Chicken Supreme',
        desc:
            'G\u00e0 n\u01b0\u1edbng, h\u00e0nh t\u00e2y, \u1edbt chu\u00f4ng xanh v\u00e0 n\u1ea5m t\u01b0\u01a1i.',
        price: 239000,
        image: 'assets/5.jpg',
        tag: 'pizza_4',
        category: 'Classic'),
    PizzaModel(
        id: '8',
        name: 'Pepperoni Feast',
        desc:
            'G\u1ea5p \u0111\u00f4i pepperoni, g\u1ea5p \u0111\u00f4i mozzarella, th\u01a1m b\u00e9o d\u1ec5 m\u00ea.',
        price: 219000,
        image: 'assets/8.png',
        tag: 'pizza_7',
        category: 'Classic'),
    PizzaModel(
        id: '9',
        name: 'Hawaiian Tropical',
        desc:
            'D\u1ee9a t\u01b0\u01a1i, jambon v\u00e0 s\u1ed1t c\u00e0 chua c\u00e2n b\u1eb1ng v\u1ecb ng\u1ecdt m\u1eb7n.',
        price: 199000,
        image: 'assets/9.png',
        tag: 'pizza_8',
        category: 'Classic'),

    // GOURMET
    PizzaModel(
        id: '2',
        name: 'Quattro Formaggi',
        desc:
            '4 lo\u1ea1i ph\u00f4 mai h\u1ea3o h\u1ea1ng nh\u1ea5t t\u1eeb \u00dd, b\u00e9o ng\u1eady \u0111\u1eb7c tr\u01b0ng.',
        price: 249000,
        image: 'assets/2.jpg',
        tag: 'pizza_1',
        category: 'Gourmet'),
    PizzaModel(
        id: '4',
        name: 'Seafood Premium',
        desc:
            'T\u00f4m, m\u1ef1c v\u00e0 ngh\u00eau t\u01b0\u01a1i ngon h\u00f2a quy\u1ec7n s\u1ed1t Thousand Island.',
        price: 279000,
        image: 'assets/4.png',
        tag: 'pizza_3',
        category: 'Gourmet'),
    PizzaModel(
        id: '10',
        name: 'Truffle Mushroom',
        desc:
            'N\u1ea5m r\u1eebng, s\u1ed1t truffle \u0111en v\u00e0 ph\u00f4 mai n\u01b0\u1edbng v\u00e0ng m\u1eb7t.',
        price: 329000,
        image: 'assets/10.png',
        tag: 'pizza_9',
        category: 'Gourmet'),

    // DRINKS
    PizzaModel(
        id: '11',
        name: 'Coca-Cola 330ml',
        desc:
            'N\u01b0\u1edbc ng\u1ecdt c\u00f3 gas v\u1ecb cola truy\u1ec1n th\u1ed1ng, u\u1ed1ng l\u1ea1nh ngon nh\u1ea5t.',
        price: 25000,
        image: 'assets/Coca-Cola.png',
        tag: 'drink_0',
        category: 'Drinks'),
    PizzaModel(
        id: '12',
        name: 'Pepsi 330ml',
        desc:
            'V\u1ecb cola s\u1ea3ng kho\u00e1i, h\u1ee3p v\u1edbi pizza nhi\u1ec1u ph\u00f4 mai.',
        price: 25000,
        image: 'assets/Pepsi.png',
        tag: 'drink_1',
        category: 'Drinks'),
    PizzaModel(
        id: '13',
        name: 'Sprite 330ml',
        desc:
            'V\u1ecb chanh m\u00e1t l\u1ea1nh, nh\u1eb9 nh\u00e0ng v\u00e0 d\u1ec5 u\u1ed1ng.',
        price: 25000,
        image: 'assets/Sprite.png',
        tag: 'drink_2',
        category: 'Drinks'),
    PizzaModel(
        id: '14',
        name: 'N\u01b0\u1edbc Cam \u00c9p',
        desc:
            'N\u01b0\u1edbc cam t\u01b0\u01a1i gi\u00e0u vitamin C, c\u00e2n b\u1eb1ng v\u1ecb b\u00e9o c\u1ee7a pizza.',
        price: 35000,
        image: 'assets/Nuoccamep.png',
        tag: 'drink_3',
        category: 'Drinks'),
  ];
  bool _isLoggedIn = false;
  UserModel? _currentUser;

  List<CartItem> get items => _items;
  List<OrderModel> get orderHistory => _orderHistory;
  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?.role == 'admin';
  List<UserModel> get allUsers => _registeredUsers;
  List<PizzaModel> get availablePizzas => _availablePizzas;
  List<MapEntry<String, int>> get favoriteFoodCounts {
    final counts = <String, int>{};
    for (final order in _orderHistory) {
      if (_currentUser != null &&
          order.userEmail.isNotEmpty &&
          order.userEmail != _currentUser!.email) {
        continue;
      }
      for (final item in order.items) {
        counts[item.name] = (counts[item.name] ?? 0) + item.quantity;
      }
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  int get itemCount => _items.length;
  int get totalAmount =>
      _items.fold(0, (total, item) => total + item.totalPrice);
  int get totalRevenue =>
      _orderHistory.fold(0, (total, order) => total + order.totalAmount);
  int get completedRevenue => _orderHistory
      .where((order) => order.status != 'cancelled')
      .fold(0, (total, order) => total + order.totalAmount);
  int get pendingOrderCount =>
      _orderHistory.where((order) => order.status == 'pending').length;
  int get completedOrderCount =>
      _orderHistory.where((order) => order.status == 'completed').length;

  Future<void> init() async {
    await _loadUsers();
    await _loadPizzas();
    await _loadOrders();
    _listenToOrders();
    await _loadCurrentFirebaseUser();
  }

  Future<void> _loadUsers() async {
    final snapshot = await _firestore.collection('users').get();
    final firebaseUsers = snapshot.docs
        .map((doc) => UserModel.fromJson({...doc.data(), 'uid': doc.id}))
        .where((user) => !user.disabled && user.role != 'deleted')
        .toList();

    _registeredUsers = [
      ...firebaseUsers,
      if (!firebaseUsers.any((u) => u.email == 'admin@gmail.com'))
        UserModel(
          username: 'Admin',
          email: 'admin@gmail.com',
          phone: '0123456789',
          password: '',
          role: 'admin',
        ),
    ];
    notifyListeners();
  }

  Future<void> _loadCurrentFirebaseUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;

    _currentUser = await _loadOrCreateUserProfile(firebaseUser);
    if (_currentUser!.disabled || _currentUser!.role == 'deleted') {
      await _auth.signOut();
      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
      return;
    }
    _isLoggedIn = true;
    _listenToCurrentUser(firebaseUser.uid);
    notifyListeners();
  }

  void _listenToCurrentUser(String uid) {
    _userSubscription?.cancel();
    _userSubscription =
        _firestore.collection('users').doc(uid).snapshots().listen((doc) {
      if (!doc.exists || doc.data() == null) return;
      final updatedUser = UserModel.fromJson({...doc.data()!, 'uid': doc.id});
      if (updatedUser.disabled || updatedUser.role == 'deleted') {
        logout();
        return;
      }

      _currentUser = updatedUser;
      final userIndex = _registeredUsers
          .indexWhere((user) => user.email == updatedUser.email);
      if (userIndex != -1) {
        _registeredUsers[userIndex] = updatedUser;
      }
      notifyListeners();
    });
  }

  Future<UserModel> _loadOrCreateUserProfile(
    firebase_auth.User firebaseUser, {
    String? username,
    String? phone,
  }) async {
    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    final userDoc = await userRef.get();

    if (userDoc.exists && userDoc.data() != null) {
      return UserModel.fromJson({...userDoc.data()!, 'uid': userDoc.id});
    }

    final email = firebaseUser.email ?? '';
    final role = email.toLowerCase() == 'admin@gmail.com' ? 'admin' : 'user';
    final profile = UserModel(
      uid: firebaseUser.uid,
      username: username?.trim().isNotEmpty == true
          ? username!.trim()
          : (firebaseUser.displayName?.trim().isNotEmpty == true
              ? firebaseUser.displayName!.trim()
              : email.split('@').first),
      email: email,
      phone: phone ?? '',
      password: '',
      role: role,
    );

    await userRef.set(profile.toJson());
    return profile;
  }

  Future<void> _loadPizzas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pizzasData = prefs.getString('available_pizzas');
    if (pizzasData != null) {
      final List<dynamic> decoded = jsonDecode(pizzasData);
      final savedPizzas =
          decoded.map((item) => PizzaModel.fromJson(item)).toList();
      if (_hasBrokenVietnamese(savedPizzas)) {
        await _savePizzas();
        return;
      }
      _availablePizzas = savedPizzas;
      notifyListeners();
    }
  }

  bool _hasBrokenVietnamese(List<PizzaModel> pizzas) {
    const brokenMarks = [
      '\u00c3',
      '\u00c2',
      '\u00c4',
      '\u00c6',
      '\u00e1\u00c2',
      '\u00e2\u20ac'
    ];
    return pizzas.any((pizza) {
      final text = '${pizza.name} ${pizza.desc}';
      return brokenMarks.any(text.contains);
    });
  }

  Future<void> _savePizzas() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(_availablePizzas.map((p) => p.toJson()).toList());
    await prefs.setString('available_pizzas', encoded);
  }

  Future<void> _loadOrders() async {
    final snapshot = await _firestore
        .collection('orders')
        .orderBy('dateTime', descending: true)
        .get();

    _replaceOrders(snapshot.docs);
  }

  void _listenToOrders() {
    _ordersSubscription?.cancel();
    _ordersSubscription = _firestore
        .collection('orders')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .listen((snapshot) => _replaceOrders(snapshot.docs));
  }

  void _replaceOrders(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    _orderHistory
      ..clear()
      ..addAll(docs.map((doc) => OrderModel.fromJson({
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          })));
    notifyListeners();
  }

  void addPizza(PizzaModel pizza) {
    _availablePizzas.add(pizza);
    _savePizzas();
    notifyListeners();
  }

  void removePizza(String id) {
    _availablePizzas.removeWhere((p) => p.id == id);
    _savePizzas();
    notifyListeners();
  }

  Future<String?> registerUser(UserModel newUser) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: newUser.email.trim(),
        password: newUser.password,
      );
      await credential.user?.updateDisplayName(newUser.username);

      final role =
          newUser.email.toLowerCase() == 'admin@gmail.com' ? 'admin' : 'user';
      final profile = UserModel(
        uid: credential.user!.uid,
        username: newUser.username,
        email: newUser.email.trim(),
        phone: newUser.phone,
        password: '',
        role: role,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(profile.toJson());

      _currentUser = profile;
      _isLoggedIn = true;
      _listenToCurrentUser(credential.user!.uid);
      await _loadUsers();
      notifyListeners();
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _firebaseAuthMessage(e);
    } catch (_) {
      return 'Kh\u00f4ng th\u1ec3 \u0111\u0103ng k\u00fd. Vui l\u00f2ng th\u1eed l\u1ea1i.';
    }
  }

  Future<String?> loginUser(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _currentUser = await _loadOrCreateUserProfile(credential.user!);
      if (_currentUser!.disabled || _currentUser!.role == 'deleted') {
        await _auth.signOut();
        _currentUser = null;
        _isLoggedIn = false;
        return 'T\u00e0i kho\u1ea3n n\u00e0y \u0111\u00e3 b\u1ecb v\u00f4 hi\u1ec7u h\u00f3a.';
      }
      _isLoggedIn = true;
      _listenToCurrentUser(credential.user!.uid);
      await _loadUsers();
      notifyListeners();
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _firebaseAuthMessage(e);
    } catch (_) {
      return 'Kh\u00f4ng th\u1ec3 \u0111\u0103ng nh\u1eadp. Vui l\u00f2ng th\u1eed l\u1ea1i.';
    }
  }

  Future<firebase_auth.FirebaseAuth> _getAdminCreationAuth() async {
    if (_adminCreationAuth != null) return _adminCreationAuth!;

    const appName = 'admin-user-creation';
    FirebaseApp secondaryApp;
    try {
      secondaryApp = Firebase.app(appName);
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: appName,
        options: Firebase.app().options,
      );
    }

    _adminCreationAuth =
        firebase_auth.FirebaseAuth.instanceFor(app: secondaryApp);
    return _adminCreationAuth!;
  }

  Future<String?> createUserByAdmin({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final secondaryAuth = await _getAdminCreationAuth();
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(username.trim());

      final profile = UserModel(
        uid: credential.user!.uid,
        username: username.trim(),
        email: email.trim(),
        phone: phone.trim(),
        password: '',
        role: role,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(profile.toJson(), SetOptions(merge: true));
      await secondaryAuth.signOut();
      await _loadUsers();
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _firebaseAuthMessage(e);
    } catch (_) {
      return 'Kh\u00f4ng th\u1ec3 th\u00eam ng\u01b0\u1eddi d\u00f9ng. Vui l\u00f2ng th\u1eed l\u1ea1i.';
    }
  }

  Future<String?> deleteUserByAdmin(UserModel user) async {
    if (_currentUser?.email == user.email) {
      return 'KhÃ´ng thá»ƒ xÃ³a tÃ i khoáº£n Ä‘ang Ä‘Äƒng nháº­p.';
    }
    if (user.role == 'admin' &&
        _registeredUsers.where((u) => u.role == 'admin').length <= 1) {
      return 'Cáº§n giá»¯ láº¡i Ã­t nháº¥t má»™t tÃ i khoáº£n admin.';
    }

    try {
      final updates = {
        'disabled': true,
        'role': 'deleted',
        'deletedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (user.uid.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(updates, SetOptions(merge: true));
      } else {
        final snapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        for (final doc in snapshot.docs) {
          await doc.reference.set(updates, SetOptions(merge: true));
        }
      }

      _registeredUsers.removeWhere((item) => item.email == user.email);
      notifyListeners();
      return null;
    } catch (_) {
      return 'Kh\u00f4ng th\u1ec3 x\u00f3a ng\u01b0\u1eddi d\u00f9ng. Vui l\u00f2ng th\u1eed l\u1ea1i.';
    }
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    _userSubscription?.cancel();
    _userSubscription = null;
    _auth.signOut();
    notifyListeners();
  }

  Future<void> updateUserPreferences({
    String? defaultAddress,
    String? linkedPaymentMethod,
    bool? notificationsEnabled,
    String? language,
  }) async {
    final firebaseUser = _auth.currentUser;
    final currentUser = _currentUser;
    if (firebaseUser == null || currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      defaultAddress: defaultAddress,
      linkedPaymentMethod: linkedPaymentMethod,
      notificationsEnabled: notificationsEnabled,
      language: language,
    );

    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(updatedUser.toJson(), SetOptions(merge: true));

    _currentUser = updatedUser;
    final userIndex =
        _registeredUsers.indexWhere((user) => user.email == updatedUser.email);
    if (userIndex != -1) {
      _registeredUsers[userIndex] = updatedUser;
    }
    notifyListeners();
  }

  Future<void> submitContactRequest({
    required String name,
    required String phone,
    required String email,
    required String subject,
    required String message,
  }) async {
    await _firestore.collection('contact_requests').add({
      'name': name,
      'phone': phone,
      'email': email,
      'subject': subject,
      'message': message,
      'recipientEmail': 'haohuynh090805@gmail.com',
      'userEmail': _currentUser?.email ?? '',
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'status': 'new',
    });
  }

  String _firebaseAuthMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email n\u00e0y \u0111\u00e3 t\u1ed3n t\u1ea1i!';
      case 'invalid-email':
        return 'Email kh\u00f4ng h\u1ee3p l\u1ec7!';
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Email ho\u1eb7c m\u1eadt kh\u1ea9u kh\u00f4ng \u0111\u00fang!';
      case 'weak-password':
        return 'M\u1eadt kh\u1ea9u qu\u00e1 y\u1ebfu!';
      case 'network-request-failed':
        return 'Kh\u00f4ng c\u00f3 k\u1ebft n\u1ed1i m\u1ea1ng. Vui l\u00f2ng th\u1eed l\u1ea1i.';
      default:
        return e.message ??
            'C\u00f3 l\u1ed7i x\u1ea3y ra. Vui l\u00f2ng th\u1eed l\u1ea1i.';
    }
  }

  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void checkout(
    String address,
    String phone, {
    String? customerName,
    String paymentMethod = 'cash',
  }) {
    if (_items.isEmpty) return;
    final newOrder = OrderModel(
      id: 'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      items: List.from(_items),
      totalAmount: totalAmount,
      address: address,
      phone: phone,
      dateTime: DateTime.now(),
      userEmail: _currentUser?.email ?? '',
      customerName: customerName?.trim().isNotEmpty == true
          ? customerName!.trim()
          : (_currentUser?.username ?? ''),
      paymentMethod: paymentMethod,
      status: 'pending',
    );
    _orderHistory.insert(0, newOrder);
    _saveOrder(newOrder);
    _addLoyaltyPoints(totalAmount);
    _items.clear();
    notifyListeners();
  }

  Future<void> _addLoyaltyPoints(int orderTotal) async {
    final firebaseUser = _auth.currentUser;
    final currentUser = _currentUser;
    if (firebaseUser == null || currentUser == null || orderTotal < 10000) {
      return;
    }

    final earnedPoints = orderTotal ~/ 10000;
    final updatedUser = currentUser.copyWith(
      loyaltyPoints: currentUser.loyaltyPoints + earnedPoints,
    );

    await _firestore.collection('users').doc(firebaseUser.uid).set({
      'loyaltyPoints': updatedUser.loyaltyPoints,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));

    _currentUser = updatedUser;
    final userIndex =
        _registeredUsers.indexWhere((user) => user.email == updatedUser.email);
    if (userIndex != -1) {
      _registeredUsers[userIndex] = updatedUser;
    }
    notifyListeners();
  }

  Future<void> _saveOrder(OrderModel order) async {
    await _firestore.collection('orders').doc(order.id).set(order.toJson());
  }

  Future<void> refreshOrders() async {
    await _loadOrders();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final existingIndex =
        _orderHistory.indexWhere((order) => order.id == orderId);
    final existingOrder =
        existingIndex == -1 ? null : _orderHistory[existingIndex];

    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
    });

    if (existingOrder != null) {
      final points = existingOrder.totalAmount ~/ 10000;
      if (points > 0 &&
          existingOrder.status != 'cancelled' &&
          status == 'cancelled') {
        await _adjustLoyaltyPointsForOrder(existingOrder, -points);
      } else if (points > 0 &&
          existingOrder.status == 'cancelled' &&
          status != 'cancelled') {
        await _adjustLoyaltyPointsForOrder(existingOrder, points);
      }
    }

    final index = _orderHistory.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final order = _orderHistory[index];
      _orderHistory[index] = OrderModel(
        id: order.id,
        items: order.items,
        totalAmount: order.totalAmount,
        address: order.address,
        phone: order.phone,
        dateTime: order.dateTime,
        userEmail: order.userEmail,
        customerName: order.customerName,
        paymentMethod: order.paymentMethod,
        status: status,
      );
      notifyListeners();
    }
  }

  Future<void> _adjustLoyaltyPointsForOrder(
      OrderModel order, int points) async {
    if (order.userEmail.isEmpty || points == 0) return;

    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: order.userEmail)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;

    final userDoc = snapshot.docs.first;
    final currentPoints = userDoc.data()['loyaltyPoints'] ?? 0;
    final nextPoints =
        ((currentPoints + points) as num).clamp(0, 1 << 31).toInt();
    await userDoc.reference.set({
      'loyaltyPoints': nextPoints,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));

    if (_currentUser?.email == order.userEmail) {
      _currentUser = _currentUser!.copyWith(loyaltyPoints: nextPoints);
    }

    final userIndex =
        _registeredUsers.indexWhere((user) => user.email == order.userEmail);
    if (userIndex != -1) {
      _registeredUsers[userIndex] =
          _registeredUsers[userIndex].copyWith(loyaltyPoints: nextPoints);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}

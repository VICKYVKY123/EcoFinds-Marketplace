import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:confetti/confetti.dart';

// Use with alias
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataService()),
        ChangeNotifierProvider(create: (_) => SustainabilityService()),
      ],
      child: const EcoFindsApp(),
    ),
  );
}

class EcoFindsApp extends StatelessWidget {
  const EcoFindsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoFinds',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const OnboardingScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/auth': (context) => const AuthScreen(),
      },
    );
  }
}

// SUSTAINABILITY MODELS & SERVICES
class SustainabilityMetrics {
  double carbonSaved; // in kg
  double wasteDiverted; // in kg
  int itemsRescued;
  double waterSaved; // in liters
  double energySaved; // in kWh

  SustainabilityMetrics({
    this.carbonSaved = 0,
    this.wasteDiverted = 0,
    this.itemsRescued = 0,
    this.waterSaved = 0,
    this.energySaved = 0,
  });
}

class SustainabilityService extends ChangeNotifier {
  SustainabilityMetrics _metrics = SustainabilityMetrics();
  List<SustainabilityTip> tips = [];
  List<SustainabilityChallenge> challenges = [];

  SustainabilityMetrics get metrics => _metrics;

  void updateMetrics(Product product) {
    final impact = _calculateImpact(product);
    
    _metrics.carbonSaved += impact['carbonSaved']!;
    _metrics.wasteDiverted += impact['wasteDiverted']!;
    _metrics.itemsRescued += 1;
    _metrics.waterSaved += impact['waterSaved']!;
    _metrics.energySaved += impact['energySaved']!;
    
    notifyListeners();
  }

  Map<String, double> _calculateImpact(Product product) {
    const Map<String, Map<String, double>> impactFactors = {
      'Electronics': {'carbonSaved': 50.0, 'wasteDiverted': 5.0, 'waterSaved': 500.0, 'energySaved': 100.0},
      'Clothing': {'carbonSaved': 20.0, 'wasteDiverted': 2.0, 'waterSaved': 2500.0, 'energySaved': 50.0},
      'Furniture': {'carbonSaved': 100.0, 'wasteDiverted': 15.0, 'waterSaved': 1000.0, 'energySaved': 150.0},
      'Books': {'carbonSaved': 5.0, 'wasteDiverted': 1.0, 'waterSaved': 100.0, 'energySaved': 10.0},
      'Sports': {'carbonSaved': 30.0, 'wasteDiverted': 3.0, 'waterSaved': 300.0, 'energySaved': 40.0},
      'Upcycled': {'carbonSaved': 40.0, 'wasteDiverted': 8.0, 'waterSaved': 800.0, 'energySaved': 80.0},
      'Other': {'carbonSaved': 15.0, 'wasteDiverted': 2.0, 'waterSaved': 200.0, 'energySaved': 25.0},
    };

    final factors = impactFactors[product.category] ?? impactFactors['Other']!;
    return factors;
  }

  void loadTips() {
    tips = [
      SustainabilityTip(
        title: 'Wash clothes in cold water',
        description: 'Save energy by washing your clothes in cold water instead of hot',
        impact: 'Saves up to 90% of energy per load',
        category: 'Laundry',
      ),
      SustainabilityTip(
        title: 'Use a clothesline',
        description: 'Skip the dryer and use natural air drying',
        impact: 'Saves 3-4 kg of CO2 per load',
        category: 'Laundry',
      ),
    ];
  }

  void loadChallenges() {
    challenges = [
      SustainabilityChallenge(
        title: 'No New Clothes Month',
        description: 'Commit to not buying any new clothing for 30 days',
        duration: 30,
        rewardPoints: 100,
      ),
      SustainabilityChallenge(
        title: 'Meat-Free Week',
        description: 'Go vegetarian for one week to reduce your carbon footprint',
        duration: 7,
        rewardPoints: 75,
      ),
    ];
  }
}

class SustainabilityTip {
  final String title;
  final String description;
  final String impact;
  final String category;

  SustainabilityTip({
    required this.title,
    required this.description,
    required this.impact,
    required this.category,
  });
}

class SustainabilityChallenge {
  final String title;
  final String description;
  final int duration;
  final int rewardPoints;

  SustainabilityChallenge({
    required this.title,
    required this.description,
    required this.duration,
    required this.rewardPoints,
  });
}

// DATA MODELS
class Product {
  final String id;
  final String userId;
  String title;
  String description;
  String category;
  double price;
  List<String> imageUrls;
  DateTime createdAt;
  String condition;
  String sustainabilityRating;
  bool isLocalPickup;
  String ecoCertification;

  Product({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrls,
    required this.createdAt,
    this.condition = 'Good',
    this.sustainabilityRating = 'B',
    this.isLocalPickup = true,
    this.ecoCertification = 'None',
  });
}

class User {
  final String id;
  String email;
  String username;
  int ecoPoints;
  int itemsSold;
  int itemsBought;
  SustainabilityScore sustainabilityScore;
  List<Badge> badges;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.ecoPoints = 0,
    this.itemsSold = 0,
    this.itemsBought = 0,
    SustainabilityScore? sustainabilityScore,
    List<Badge>? badges,
  }) : sustainabilityScore = sustainabilityScore ?? SustainabilityScore(),
        badges = badges ?? [];
}

class SustainabilityScore {
  double overall;
  double carbonReduction;
  double wasteReduction;
  double communityImpact;

  SustainabilityScore({
    this.overall = 0,
    this.carbonReduction = 0,
    this.wasteReduction = 0,
    this.communityImpact = 0,
  });
}

class Badge {
  final String name;
  final String description;
  final String icon;
  final DateTime earnedDate;

  Badge({
    required this.name,
    required this.description,
    required this.icon,
    required this.earnedDate,
  });
}

class Purchase {
  final String id;
  final String userId;
  final String productId;
  final DateTime purchaseDate;

  Purchase({
    required this.id,
    required this.userId,
    required this.productId,
    required this.purchaseDate,
  });
}

// DATA SERVICE
class DataService extends ChangeNotifier {
  List<User> users = [];
  List<Product> products = [];
  List<Purchase> purchases = [];
  User? currentUser;
  List<Product> featuredSustainableProducts = [];

  bool register(String email, String password, String username) {
    if (users.any((user) => user.email == email)) return false;
    
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      username: username,
    );
    
    users.add(newUser);
    currentUser = newUser;
    return true;
  }
  
  bool login(String email, String password) {
    final user = users.firstWhere(
      (user) => user.email == email,
      orElse: () => User(id: '', email: '', username: ''),
    );
    
    if (user.id.isNotEmpty) {
      currentUser = user;
      return true;
    }
    return false;
  }
  
  void logout() {
    currentUser = null;
  }
  
  void addProduct(Product product) {
    products.add(product);
    notifyListeners();
  }
  
  List<Product> getUserProducts(String userId) {
    return products.where((product) => product.userId == userId).toList();
  }
  
  List<Product> getProductsByCategory(String category) {
    if (category == 'All') return products;
    return products.where((product) => product.category == category).toList();
  }
  
  List<Product> searchProducts(String query) {
    return products.where((product) => 
      product.title.toLowerCase().contains(query.toLowerCase())).toList();
  }
  
  void addPurchase(Purchase purchase) {
    purchases.add(purchase);
    if (currentUser != null) {
      currentUser!.itemsBought++;
    }
    notifyListeners();
  }
  
  List<Purchase> getUserPurchases(String userId) {
    return purchases.where((purchase) => purchase.userId == userId).toList();
  }

  void addEcoPoints(int points) {
    if (currentUser != null) {
      currentUser!.ecoPoints += points;
      _checkForBadges();
      notifyListeners();
    }
  }

  void _checkForBadges() {
    if (currentUser == null) return;
    
    final user = currentUser!;
    List<Badge> newBadges = [];
    
    if (user.ecoPoints >= 100 && !user.badges.any((b) => b.name == 'EcoStarter')) {
      newBadges.add(Badge(
        name: 'EcoStarter',
        description: 'Earned 100 eco points',
        icon: '🌱',
        earnedDate: DateTime.now(),
      ));
    }
    
    if (user.itemsSold >= 10 && !user.badges.any((b) => b.name == 'Circular Champion')) {
      newBadges.add(Badge(
        name: 'Circular Champion',
        description: 'Sold 10 pre-loved items',
        icon: '♻️',
        earnedDate: DateTime.now(),
      ));
    }
    
    user.badges.addAll(newBadges);
    if (newBadges.isNotEmpty) {
      notifyListeners();
    }
  }

  void loadFeaturedSustainableProducts() {
    featuredSustainableProducts = products.where((product) {
      return product.sustainabilityRating == 'A' || 
             product.ecoCertification != 'None' ||
             product.category == 'Upcycled';
    }).toList();
  }
}

// ONBOARDING SCREEN
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to EcoFinds',
      'description': 'Join our community dedicated to sustainable shopping and reducing waste',
      'color': Colors.green,
    },
    {
      'title': 'Reduce Your Carbon Footprint',
      'description': 'Every second-hand purchase saves resources and reduces emissions',
      'color': Colors.lightGreen,
    },
    {
      'title': 'Earn Rewards for Being Green',
      'description': 'Get eco-points, badges, and discounts for sustainable choices',
      'color': Colors.teal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (_, index) {
              return OnboardingPageWidget(page: _pages[index]);
            },
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: _pages.length,
                effect: const WormEffect(
                  activeDotColor: Colors.green,
                  dotColor: Colors.grey,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    Navigator.pushReplacementNamed(context, '/auth');
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final Map<String, dynamic> page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: (page['color'] as Color).withOpacity(0.1),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco, size: 100, color: page['color']),
          const SizedBox(height: 40),
          Text(
            page['title'],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: page['color'],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page['description'],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// AUTH SCREEN
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              Text(
                'EcoFinds',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              if (!_isLogin)
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(_isLogin ? 'Login' : 'Sign Up'),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin
                    ? 'Create an account'
                    : 'I already have an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final dataService = Provider.of<DataService>(context, listen: false);
      bool success;
      
      if (_isLogin) {
        success = dataService.login(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        success = dataService.register(
          _emailController.text,
          _passwordController.text,
          _usernameController.text,
        );
      }
      
      if (success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin
                ? 'Login failed. Please check your credentials.'
                : 'Registration failed. Email may already be in use.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}

// HOME SCREEN
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const ProductFeedScreen(),
    const MyListingsScreen(),
    const CartScreen(),
    const PreviousPurchasesScreen(),
    const UserDashboardScreen(),
    const SustainabilityDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoFinds'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Purchases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Eco Impact',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProductScreen(),
                  ),
                );
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

// PRODUCT FEED SCREEN
class ProductFeedScreen extends StatefulWidget {
  const ProductFeedScreen({super.key});

  @override
  State<ProductFeedScreen> createState() => _ProductFeedScreenState();
}

class _ProductFeedScreenState extends State<ProductFeedScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Electronics',
    'Clothing',
    'Furniture',
    'Books',
    'Sports',
    'Upcycled',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final products = dataService.getProductsByCategory(_selectedCategory);
    
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FilterChip(
                  label: Text(_categories[index]),
                  selected: _selectedCategory == _categories[index],
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = _categories[index];
                    });
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return SustainableProductCard(product: product);
            },
          ),
        ),
      ],
    );
  }
}

// SUSTAINABLE PRODUCT CARD
class SustainableProductCard extends StatelessWidget {
  final Product product;

  const SustainableProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[200],
                child: Stack(
                  children: [
                    const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                    if (product.sustainabilityRating == 'A')
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.eco, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Eco Choice', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (product.isLocalPickup)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Local Pickup',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    _buildSustainabilityBadges(),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getRatingColor(product.sustainabilityRating),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.sustainabilityRating,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(String rating) {
    switch (rating) {
      case 'A': return Colors.green;
      case 'B': return Colors.lightGreen;
      case 'C': return Colors.orange;
      case 'D': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildSustainabilityBadges() {
    List<Widget> badges = [];
    
    if (product.ecoCertification != 'None') {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.green),
          ),
          child: Text(
            product.ecoCertification,
            style: TextStyle(
              color: Colors.green[800],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    
    if (product.condition == 'Like New') {
      badges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue),
          ),
          child: const Text(
            'Like New',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: badges,
    );
  }
}

// ADD PRODUCT SCREEN
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Electronics';
  String _selectedCondition = 'Good';
  String _selectedEcoCertification = 'None';
  bool _isLocalPickup = true;

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Furniture',
    'Books',
    'Sports',
    'Upcycled',
    'Other',
  ];

  final List<String> _conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
  ];

  final List<String> _ecoCertifications = [
    'None',
    'Organic',
    'Recycled',
    'Upcycled',
    'Fair Trade',
    'Vegan',
    'Carbon Neutral',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Product Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                ),
                items: _conditions.map((String condition) {
                  return DropdownMenuItem<String>(
                    value: condition,
                    child: Text(condition),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCondition = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedEcoCertification,
                decoration: const InputDecoration(
                  labelText: 'Eco Certification (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: _ecoCertifications.map((String cert) {
                  return DropdownMenuItem<String>(
                    value: cert,
                    child: Text(cert),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEcoCertification = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Local Pickup Available'),
                value: _isLocalPickup,
                onChanged: (bool value) {
                  setState(() {
                    _isLocalPickup = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image placeholder added')),
                  );
                },
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Image (Placeholder)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Submit Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final dataService = Provider.of<DataService>(context, listen: false);
      final sustainabilityService = Provider.of<SustainabilityService>(context, listen: false);
      
      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: dataService.currentUser!.id,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        imageUrls: ['placeholder'],
        createdAt: DateTime.now(),
        condition: _selectedCondition,
        ecoCertification: _selectedEcoCertification,
        isLocalPickup: _isLocalPickup,
        sustainabilityRating: _calculateSustainabilityRating(),
      );
      
      dataService.addProduct(product);
      sustainabilityService.updateMetrics(product);
      
      if (_selectedEcoCertification != 'None' || _selectedCategory == 'Upcycled') {
        dataService.addEcoPoints(25);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product listed successfully!')),
      );
      Navigator.pop(context);
    }
  }

  String _calculateSustainabilityRating() {
    int score = 0;
    
    if (_selectedEcoCertification != 'None') score += 2;
    if (_selectedCategory == 'Upcycled') score += 2;
    if (_selectedCondition == 'Like New' || _selectedCondition == 'New') score += 1;
    if (_isLocalPickup) score += 1;
    
    if (score >= 4) return 'A';
    if (score >= 3) return 'B';
    if (score >= 2) return 'C';
    return 'D';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

// PRODUCT DETAIL SCREEN
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final sustainabilityService = Provider.of<SustainabilityService>(context, listen: false);
    final dataService = Provider.of<DataService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 200,
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Chip(label: Text(product.category)),
                const SizedBox(width: 8),
                Chip(
                  label: Text(product.condition),
                  backgroundColor: Colors.blue[100],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(product.description),
            const SizedBox(height: 20),
            if (product.ecoCertification != 'None')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Eco Certification',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Chip(
                    label: Text(product.ecoCertification),
                    backgroundColor: Colors.green[100],
                  ),
                ],
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final purchase = Purchase(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    userId: dataService.currentUser!.id,
                    productId: product.id,
                    purchaseDate: DateTime.now(),
                  );
                  dataService.addPurchase(purchase);
                  sustainabilityService.updateMetrics(product);
                  dataService.addEcoPoints(10);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchased successfully!')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MY LISTINGS SCREEN
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final userProducts = dataService.getUserProducts(dataService.currentUser!.id);
    
    return ListView.builder(
      itemCount: userProducts.length,
      itemBuilder: (context, index) {
        final product = userProducts[index];
        return Dismissible(
          key: Key(product.id),
          background: Container(color: Colors.red),
          onDismissed: (direction) {
            setState(() {
              dataService.products.removeWhere((p) => p.id == product.id);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product deleted')),
            );
          },
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              color: Colors.grey[200],
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            title: Text(product.title),
            subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit feature coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// CART SCREEN
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Your cart is empty', style: TextStyle(fontSize: 18)),
    );
  }
}

// PREVIOUS PURCHASES SCREEN
class PreviousPurchasesScreen extends StatelessWidget {
  const PreviousPurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final purchases = dataService.getUserPurchases(dataService.currentUser!.id);
    
    if (purchases.isEmpty) {
      return const Center(
        child: Text('No previous purchases', style: TextStyle(fontSize: 18)),
      );
    }
    
    return ListView.builder(
      itemCount: purchases.length,
      itemBuilder: (context, index) {
        final purchase = purchases[index];
        final product = dataService.products.firstWhere(
          (p) => p.id == purchase.productId,
          orElse: () => Product(
            id: '',
            userId: '',
            title: 'Product no longer available',
            description: '',
            category: '',
            price: 0,
            imageUrls: [],
            createdAt: DateTime.now(),
          ),
        );
        
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            color: Colors.grey[200],
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          title: Text(product.title),
          subtitle: Text(DateFormat('MMM dd, yyyy').format(purchase.purchaseDate)),
          trailing: Text('\$${product.price.toStringAsFixed(2)}'),
        );
      },
    );
  }
}

// USER DASHBOARD SCREEN
class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final dataService = Provider.of<DataService>(context, listen: false);
    final currentUser = dataService.currentUser;
    _usernameController.text = currentUser?.username ?? '';
    _emailController.text = currentUser?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final user = dataService.currentUser!;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Eco Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('${user.ecoPoints}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const Text('Eco Points'),
                        ],
                      ),
                      Column(
                        children: [
                          Text('${user.itemsSold}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const Text('Items Sold'),
                        ],
                      ),
                      Column(
                        children: [
                          Text('${user.itemsBought}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const Text('Items Bought'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (user.badges.isNotEmpty) ...[
            const Text('Your Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: user.badges.map((badge) {
                return Chip(
                  label: Text(badge.name),
                  avatar: Text(badge.icon),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: _updateProfile,
            child: const Text('Save Changes'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              dataService.logout();
              Navigator.pushReplacementNamed(context, '/auth');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _updateProfile() {
    final dataService = Provider.of<DataService>(context, listen: false);
    final currentUser = dataService.currentUser;
    if (currentUser != null) {
      currentUser.username = _usernameController.text;
      currentUser.email = _emailController.text;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

// SUSTAINABILITY DASHBOARD SCREEN
class SustainabilityDashboardScreen extends StatelessWidget {
  const SustainabilityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sustainabilityService = Provider.of<SustainabilityService>(context);
    final metrics = sustainabilityService.metrics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sustainability Dashboard'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Environmental Impact',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildImpactCard(
              'Carbon Saved',
              '${metrics.carbonSaved.toStringAsFixed(2)} kg CO₂',
              'Equivalent to planting ${(metrics.carbonSaved / 21.77).toStringAsFixed(0)} trees',
              Icons.forest,
            ),
            const SizedBox(height: 12),
            _buildImpactCard(
              'Waste Diverted',
              '${metrics.wasteDiverted.toStringAsFixed(2)} kg',
              'Saved from landfills',
              Icons.delete_outline,
            ),
            const SizedBox(height: 12),
            _buildImpactCard(
              'Water Saved',
              '${metrics.waterSaved.toStringAsFixed(2)} liters',
              'Equivalent to ${(metrics.waterSaved / 15).toStringAsFixed(0)} days of drinking water',
              Icons.water_drop,
            ),
            const SizedBox(height: 12),
            _buildImpactCard(
              'Energy Saved',
              '${metrics.energySaved.toStringAsFixed(2)} kWh',
              'Enough to power a home for ${(metrics.energySaved / 30).toStringAsFixed(1)} days',
              Icons.bolt,
            ),
            const SizedBox(height: 24),
            const Text(
              'Sustainability Tips',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTipCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard(String title, String value, String subtitle, IconData icon) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16)),
                  Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sustainable Living Tip',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Air dry your clothes instead of using a dryer. This can save up to 4 kg of CO2 per load!',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.eco, color: Colors.green),
                const SizedBox(width: 4),
                const Text('Eco Tip', style: TextStyle(color: Colors.green)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Learn More'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// PRODUCT SEARCH DELEGATE
class ProductSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);
    final results = dataService.searchProducts(query);
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return SustainableProductCard(product: product);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);
    final suggestions = query.isEmpty
        ? dataService.products
        : dataService.searchProducts(query);
    
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final product = suggestions[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            color: Colors.grey[200],
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          title: Text(product.title),
          subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }
}
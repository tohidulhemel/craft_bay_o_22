class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://ecom-rs8e.onrender.com/api';

  // Auth
  static const String signup = '$baseUrl/auth/signup';
  static const String login = '$baseUrl/auth/login';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String resendOtp = '$baseUrl/auth/resend-otp';
  static const String profile = '$baseUrl/auth/profile';

  // Home
  static const String slides = '$baseUrl/slides';
  static const String categories = '$baseUrl/categories';

  // Products
  static const String products = '$baseUrl/products';
  static String productById(String id) => '$baseUrl/products/id/$id';

  // Reviews (the API uses "reviews" for the list and "review" for create)
  static const String reviews = '$baseUrl/reviews';
  static const String createReview = '$baseUrl/review';

  // Cart
  static const String cart = '$baseUrl/cart';
  static String cartItem(String id) => '$baseUrl/cart/$id';

  // Wishlist
  static const String wishlist = '$baseUrl/wishlist';
  static String wishlistItem(String id) => '$baseUrl/wishlist/$id';

  // Orders (the API uses "orders" for the list and "order" for create)
  static const String orders = '$baseUrl/orders';
  static const String createOrder = '$baseUrl/order';
  static String order(String id) => '$baseUrl/orders/$id';
  static String cancelOrder(String id) => '$baseUrl/orders/$id/cancel';
}
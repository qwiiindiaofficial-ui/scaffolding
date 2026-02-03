import 'package:get/get.dart';
import 'package:scaffolding_sale/backend/models.dart';
import 'package:scaffolding_sale/backend/services/services.dart';
import 'package:scaffolding_sale/backend/supabase_service.dart';

class AppController extends GetxController {
  static AppController get to => Get.find();

  // Observables
  final isLoading = false.obs;
  final isAuthenticated = false.obs;
  final currentUser = Rxn<UserProfile>();
  final currentCompany = Rxn<Company>();
  final userRole = Rxn<String>();
  final errorMessage = Rxn<String>();

  // Services
  late AuthService authService;
  late CompanyService companyService;
  late PartyService partyService;
  late StockService stockService;
  late StaffService staffService;
  late InvoiceService invoiceService;
  late PaymentService paymentService;
  late TransporterService transporterService;
  late PostService postService;

  @override
  void onInit() {
    super.onInit();
    initializeServices();
    checkAuthenticationState();
  }

  void initializeServices() {
    authService = AuthService();
    companyService = CompanyService();
    partyService = PartyService();
    stockService = StockService();
    staffService = StaffService();
    invoiceService = InvoiceService();
    paymentService = PaymentService();
    transporterService = TransporterService();
    postService = PostService();
  }

  Future<void> checkAuthenticationState() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // Listen to authentication state changes
      authService.authStateChanges.listen((authState) async {
        if (authState.session != null) {
          await loadUserProfile(authState.session!.user.id);
          isAuthenticated.value = true;
        } else {
          isAuthenticated.value = false;
          currentUser.value = null;
          currentCompany.value = null;
          userRole.value = null;
        }
      });
    } catch (e) {
      errorMessage.value = 'Authentication check failed: $e';
      print('Auth check error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserProfile(String userId) async {
    try {
      isLoading.value = true;
      final profile = await authService.getUserProfile(userId);

      if (profile != null) {
        currentUser.value = UserProfile.fromMap(profile);
        userRole.value = profile['role'] ?? 'viewer';

        // Load company details
        if (profile['company_id'] != null) {
          await loadCompany(profile['company_id']);
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load user profile: $e';
      print('Load profile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCompany(String companyId) async {
    try {
      final company = await companyService.getCompany(companyId);
      if (company != null) {
        currentCompany.value = Company.fromMap(company);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load company: $e';
      print('Load company error: $e');
    }
  }

  Future<bool> loginWithPhone(String phoneNumber) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      await authService.signInWithPhone(phoneNumber);
      return true;
    } catch (e) {
      errorMessage.value = 'Login failed: $e';
      print('Login error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final response = await authService.verifyOTP(phoneNumber, otp);
      if (response.user != null) {
        await loadUserProfile(response.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'OTP verification failed: $e';
      print('OTP error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUserProfile({
    required String userId,
    required String companyId,
    required String phoneNumber,
    String? fullName,
  }) async {
    try {
      isLoading.value = true;
      await authService.createUserProfile(
        userId: userId,
        companyId: companyId,
        phoneNumber: phoneNumber,
        fullName: fullName,
        role: 'admin',
      );

      await loadUserProfile(userId);
    } catch (e) {
      errorMessage.value = 'Failed to create profile: $e';
      print('Create profile error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await authService.signOut();
      currentUser.value = null;
      currentCompany.value = null;
      userRole.value = null;
      isAuthenticated.value = false;
    } catch (e) {
      errorMessage.value = 'Logout failed: $e';
      print('Logout error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool isAdmin() => userRole.value == 'admin';

  bool isEditor() => userRole.value == 'editor';

  bool isViewer() => userRole.value == 'viewer';

  String? get companyId => currentCompany.value?.id;

  String? get userId => currentUser.value?.id;
}

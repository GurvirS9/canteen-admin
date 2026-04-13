import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:manager_app/presentation/providers/auth_provider.dart';
import 'package:manager_app/presentation/providers/shop_provider.dart';
import 'package:manager_app/core/theme/app_colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCreating = false;

  // Step 2 — Shop Info
  final _infoFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _seatingCtrl = TextEditingController(text: '40');
  final _tableCtrl = TextEditingController(text: '10');

  // Step 3 — Hours & Location
  final _locationFormKey = GlobalKey<FormState>();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  TimeOfDay _openingTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 22, minute: 0);
  bool _isOpen = true;

  late AnimationController _heroAnim;
  late Animation<double> _heroScale;
  late Animation<double> _heroFade;

  @override
  void initState() {
    super.initState();
    _heroAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _heroScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _heroAnim, curve: Curves.elasticOut),
    );
    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroAnim, curve: const Interval(0, 0.5)),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heroAnim.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _seatingCtrl.dispose();
    _tableCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _nextPage() {
    if (_currentPage == 1 && !_infoFormKey.currentState!.validate()) return;
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _createShop() async {
    if (!_locationFormKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isCreating = true);
    try {
      await ref.read(shopProvider.notifier).createShop({
        'name': _nameCtrl.text.trim(),
        'ownerId': user.id,
        'address': _addressCtrl.text.trim(),
        'latitude': double.tryParse(_latCtrl.text) ?? 0.0,
        'longitude': double.tryParse(_lngCtrl.text) ?? 0.0,
        'seatingCapacity': int.tryParse(_seatingCtrl.text) ?? 40,
        'tableCount': int.tryParse(_tableCtrl.text) ?? 10,
        'openingTime': _formatTime(_openingTime),
        'closingTime': _formatTime(_closingTime),
        'isOpen': _isOpen,
        'isCurrentlyOpen': _isOpen,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 "${_nameCtrl.text.trim()}" is live!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create shop: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  void _skipOnboarding() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Skip Setup?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'You can always create your shop later from the Shop Settings screen.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
            ),
            child: const Text('Skip for now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A0A2E),
                    const Color(0xFF0D1B2E),
                    const Color(0xFF0A0A1A),
                  ]
                : [
                    const Color(0xFF6C35DE),
                    const Color(0xFF9B51E0),
                    const Color(0xFFD438B0),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Step indicator dots
                    Row(
                      children: List.generate(3, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── PageView ─────────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _WelcomePage(
                      userName: user?.name ?? 'Manager',
                      heroScale: _heroScale,
                      heroFade: _heroFade,
                      onNext: _nextPage,
                    ),
                    _ShopInfoPage(
                      formKey: _infoFormKey,
                      nameCtrl: _nameCtrl,
                      addressCtrl: _addressCtrl,
                      seatingCtrl: _seatingCtrl,
                      tableCtrl: _tableCtrl,
                      onNext: _nextPage,
                      onBack: _prevPage,
                    ),
                    _HoursLocationPage(
                      formKey: _locationFormKey,
                      latCtrl: _latCtrl,
                      lngCtrl: _lngCtrl,
                      openingTime: _openingTime,
                      closingTime: _closingTime,
                      isOpen: _isOpen,
                      isCreating: _isCreating,
                      onOpeningTimePick: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _openingTime,
                        );
                        if (t != null) setState(() => _openingTime = t);
                      },
                      onClosingTimePick: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _closingTime,
                        );
                        if (t != null) setState(() => _closingTime = t);
                      },
                      onIsOpenChanged: (v) => setState(() => _isOpen = v),
                      onBack: _prevPage,
                      onCreate: _createShop,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Step 1 — Welcome
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final String userName;
  final Animation<double> heroScale;
  final Animation<double> heroFade;
  final VoidCallback onNext;

  const _WelcomePage({
    required this.userName,
    required this.heroScale,
    required this.heroFade,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          ScaleTransition(
            scale: heroScale,
            child: FadeTransition(
              opacity: heroFade,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.1),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome,',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${userName.split(' ').first}! 👋',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Let\'s set up your canteen shop.\nIt only takes a minute.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 56),
          _PrimaryButton(label: "Let's Go  →", onPressed: onNext),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Step 2 — Shop Info
// ─────────────────────────────────────────────────────────────────────────────

class _ShopInfoPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController seatingCtrl;
  final TextEditingController tableCtrl;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _ShopInfoPage({
    required this.formKey,
    required this.nameCtrl,
    required this.addressCtrl,
    required this.seatingCtrl,
    required this.tableCtrl,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            step: '2 of 3',
            title: 'Shop Details',
            subtitle: 'Tell us about your canteen',
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 20),
          _GlassCard(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _OnboardingField(
                    label: 'Shop Name',
                    icon: Icons.store_rounded,
                    controller: nameCtrl,
                    hint: 'e.g. Campus Cafe',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Shop name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _OnboardingField(
                    label: 'Address',
                    icon: Icons.location_on_rounded,
                    controller: addressCtrl,
                    hint: 'e.g. Block A, Main Campus',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Address is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _OnboardingField(
                          label: 'Seating Capacity',
                          icon: Icons.chair_rounded,
                          controller: seatingCtrl,
                          hint: '40',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            final n = int.tryParse(v);
                            if (n == null || n <= 0) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _OnboardingField(
                          label: 'Table Count',
                          icon: Icons.table_restaurant_rounded,
                          controller: tableCtrl,
                          hint: '10',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            final n = int.tryParse(v);
                            if (n == null || n <= 0) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              _SecondaryButton(label: '← Back', onPressed: onBack),
              const SizedBox(width: 12),
              Expanded(child: _PrimaryButton(label: 'Next →', onPressed: onNext)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Step 3 — Hours & Location
// ─────────────────────────────────────────────────────────────────────────────

class _HoursLocationPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController latCtrl;
  final TextEditingController lngCtrl;
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final bool isOpen;
  final bool isCreating;
  final VoidCallback onOpeningTimePick;
  final VoidCallback onClosingTimePick;
  final ValueChanged<bool> onIsOpenChanged;
  final VoidCallback onBack;
  final VoidCallback onCreate;

  const _HoursLocationPage({
    required this.formKey,
    required this.latCtrl,
    required this.lngCtrl,
    required this.openingTime,
    required this.closingTime,
    required this.isOpen,
    required this.isCreating,
    required this.onOpeningTimePick,
    required this.onClosingTimePick,
    required this.onIsOpenChanged,
    required this.onBack,
    required this.onCreate,
  });

  String _pad(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            step: '3 of 3',
            title: 'Hours & Location',
            subtitle: 'When are you open and where?',
            icon: Icons.schedule_rounded,
          ),
          const SizedBox(height: 20),
          _GlassCard(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  // Opening / Closing time pickers
                  Row(
                    children: [
                      Expanded(
                        child: _TimeTile(
                          label: 'Opening Time',
                          icon: Icons.wb_sunny_rounded,
                          time: _pad(openingTime),
                          onTap: onOpeningTimePick,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimeTile(
                          label: 'Closing Time',
                          icon: Icons.nightlight_round,
                          time: _pad(closingTime),
                          onTap: onClosingTimePick,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // isOpen toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isOpen
                              ? Icons.lock_open_rounded
                              : Icons.lock_rounded,
                          color: isOpen
                              ? const Color(0xFF66BB6A)
                              : Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Open for Orders',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                isOpen
                                    ? 'Shop is accepting orders'
                                    : 'Shop is closed',
                                style: GoogleFonts.inter(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: isOpen,
                          activeThumbColor: const Color(0xFF66BB6A),
                          onChanged: onIsOpenChanged,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Lat / Lng
                  Row(
                    children: [
                      Expanded(
                        child: _OnboardingField(
                          label: 'Latitude',
                          icon: Icons.my_location_rounded,
                          controller: latCtrl,
                          hint: '28.6139',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^-?\d*\.?\d*')),
                          ],
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            final n = double.tryParse(v);
                            if (n == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _OnboardingField(
                          label: 'Longitude',
                          icon: Icons.explore_rounded,
                          controller: lngCtrl,
                          hint: '77.2090',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^-?\d*\.?\d*')),
                          ],
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            final n = double.tryParse(v);
                            if (n == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              _SecondaryButton(label: '← Back', onPressed: onBack),
              const SizedBox(width: 12),
              Expanded(
                child: _PrimaryButton(
                  label: isCreating ? 'Creating…' : '🚀  Launch Shop',
                  onPressed: isCreating ? null : onCreate,
                  isLoading: isCreating,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final IconData icon;

  const _StepHeader({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              step,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OnboardingField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  const _OnboardingField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
            ),
            prefixIcon: Icon(icon, color: Colors.white60, size: 18),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.error.withValues(alpha: 0.8)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            errorStyle:
                const TextStyle(color: Color(0xFFFF8A80), fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String time;
  final VoidCallback onTap;

  const _TimeTile({
    required this.label,
    required this.icon,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white60, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              time,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF6C35DE),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF6C35DE)),
                ),
              )
            : Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SecondaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}

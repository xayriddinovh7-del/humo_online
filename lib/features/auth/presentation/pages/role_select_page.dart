import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectPage extends StatefulWidget {
  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ─── Gradient fon ─────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A0A1A), Color(0xFF0D0D3D), Color(0xFF1A0533)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // ─── Dekor doiralar ────────────────────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: _glowCircle(const Color(0xFF7B10E6), 220, 0.3),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: _glowCircle(const Color(0xFFFF2DAF), 260, 0.25),
          ),
          // ─── Kontent ──────────────────────────────────────────────────
          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Column(
                children: [
                  // ─── Back tugmasi ──────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: InkWell(
                        onTap: () => context.go('/'),
                        borderRadius: BorderRadius.circular(12),
                        splashColor: Colors.pinkAccent.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ─── Sarlavha ─────────────────────────────────────
                  const SizedBox(height: 20),
                  const Text(
                    'Kirish turini tanlang',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Inter',
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Siz kim sifatida tizimga kirasiz?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.6),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 48),
                  // ─── Kartalar ─────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // O'quvchi karti
                          _RoleCard(
                            icon: Icons.person_rounded,
                            title: "O'quvchi",
                            subtitle: "Kurslar va darslarni ko'rish",
                            gradientColors: const [Color(0xFF0023E7), Color(0xFF7B10E6)],
                            glowColor: const Color(0xFF0023E7),
                            delay: 0,
                            onTap: () => context.push('/login?role=student'),
                            onRegisterTap: () => context.push('/register?role=student'),
                          ),
                          const SizedBox(height: 20),
                          // Ustoz karti
                          _RoleCard(
                            icon: Icons.school_rounded,
                            title: 'Ustoz',
                            subtitle: "Kurslarni boshqarish va o'qitish",
                            gradientColors: const [Color(0xFFFF2DAF), Color(0xFF7B10E6)],
                            glowColor: const Color(0xFFFF2DAF),
                            delay: 100,
                            onTap: () => context.push('/login?role=teacher'),
                            onRegisterTap: () => context.push('/register?role=teacher'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
        boxShadow: [BoxShadow(color: color.withOpacity(opacity + 0.1), blurRadius: 80)],
      ),
    );
  }
}

// ─── Rol karti ───────────────────────────────────────────────────────────────
class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final Color glowColor;
  final int delay;
  final VoidCallback onTap;
  final VoidCallback onRegisterTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.glowColor,
    required this.delay,
    required this.onTap,
    required this.onRegisterTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600 + widget.delay),
    )..forward();
    _slideAnim = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _fadeAnim.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, _slideAnim.value),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Ikonka
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.glowColor.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(widget.icon, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.subtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.65),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white.withOpacity(0.5),
                            size: 28,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // ─── Tugmalar ─────────────────────────────────
                      Row(
                        children: [
                          // Kirish tugmasi
                          Expanded(
                            child: _CardButton(
                              label: 'Kirish',
                              icon: Icons.login_rounded,
                              gradientColors: widget.gradientColors,
                              glowColor: widget.glowColor,
                              onTap: widget.onTap,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Ro'yxatdan o'tish tugmasi
                          Expanded(
                            child: _CardButton(
                              label: "Ro'yxat",
                              icon: Icons.person_add_rounded,
                              gradientColors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.05),
                              ],
                              glowColor: Colors.white,
                              borderColor: Colors.white.withOpacity(0.3),
                              onTap: widget.onRegisterTap,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Karta tugmasi ───────────────────────────────────────────────────────────
class _CardButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final Color glowColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _CardButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.glowColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: Colors.pinkAccent.withOpacity(0.3),
      highlightColor: Colors.pinkAccent.withOpacity(0.1),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1)
              : null,
          boxShadow: borderColor == null
              ? [
                  BoxShadow(
                    color: glowColor.withOpacity(0.35),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

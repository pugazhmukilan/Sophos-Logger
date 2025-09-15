import 'package:flutter/material.dart';
import 'package:sophos/Screens/Details.dart';
import 'package:sophos/Sophos%20Logger/local_storage.dart';
import 'package:sophos/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color _primaryNavy = Color.fromRGBO(20, 66, 114, 1);
  static const Color _deepBlue = Color(0xFF0A2647);
  static const Color _background = Color(0xFFF7F9FC);

  @override
  void initState() {
    super.initState();
    // call once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(CheckStatus());
    });
  }

  @override
  Widget build(BuildContext context) {
    final username = LocalStorage.getString("username") ?? "";

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // keep showing snackbars for failures, but no top banner
            if (state is LoginFailed) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red.shade700,
                    duration: const Duration(seconds: 2),
                  ),
                );
              });
            }
            if (state is HostelLoggedOut) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Logged out from Hostel WiFi Successfully"),
                    backgroundColor: Colors.green.shade300,
                    duration: const Duration(seconds: 2),
                  ),
                );
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
            child: Column(
              children: [
                // top header row
                _buildHeader(username),

                const SizedBox(height: 24),

                // content cards
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildSectionCard(
                        key: const ValueKey('hostel-card'),
                        title: "Hostel WiFi",
                        subtitle: "Login / Logout to hostel WiFi",
                        stateChecker: _HostelStateChecker(context),
                        onLogin: () => context.read<AuthBloc>().add(HostelLogin()),
                        onLogout: () => context.read<AuthBloc>().add(HostelLogout()),
                        primaryColor: _primaryNavy,
                        deepBlue: _deepBlue,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        key: const ValueKey('academic-card'),
                        title: "Academic WiFi",
                        subtitle: "Login / Logout to academic WiFi",
                        stateChecker: _AcademicStateChecker(context),
                        onLogin: () => context.read<AuthBloc>().add(AcademicLogin()),
                        onLogout: () => context.read<AuthBloc>().add(AcademicLogout()),
                        primaryColor: _primaryNavy,
                        deepBlue: _deepBlue,
                      ),
                      const SizedBox(height: 24),
                      // footer
                      Center(
                        child: Text(
                          "Made for VIT students • Easy WiFi logger",
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeader(String username) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: const Icon(Icons.wifi, color: Color(0xFF2575FC), size: 32),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome${username.isNotEmpty ? ', $username' : ''}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _deepBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Manage your VIT WiFi access",
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // placeholder for settings / profile
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  Details(),
                ),
              );

            //navigate

          },
          icon: Icon(Icons.more_vert, color: Colors.grey[700]),
        ),
      ],
    );
  }

  // ---------- Section Card Builder ----------
  Widget _buildSectionCard({
    required Key key,
    required String title,
    required String subtitle,
    required _StateChecker stateChecker,
    required VoidCallback onLogin,
    required VoidCallback onLogout,
    required Color primaryColor,
    required Color deepBlue,
  }) {
    return Card(
      key: key,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title row (left) and inline status (right)
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: deepBlue),
                  ),
                ),
                // Inline status indicator — this will be built by stateChecker if needed via buildStatus
                Builder(builder: (context) {
                  return stateChecker.buildStatus(context);
                }),
              ],
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            const SizedBox(height: 16),

            // dynamic state area (loading / button)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              child: Builder(builder: (context) {
                final stateView = stateChecker.buildView(
                  context,
                  primaryColor: primaryColor,
                  deepBlue: deepBlue,
                );
                return SizedBox(key: ValueKey(stateView.runtimeType), child: stateView);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Loading widget ----------
  Widget _buildLoading(String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 56,
          width: 56,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: const AlwaysStoppedAnimation(Color(0xFF144272)),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0A2647)),
        ),
      ],
    );
  }
}

/// ---------- Helpers to isolate state-specific UI logic ----------
/// Each checker returns both a small inline status widget (buildStatus)
/// and the larger main view (buildView) to be shown in the card.

abstract class _StateChecker {
  Widget buildStatus(BuildContext context); // small inline widget near title
  Widget buildView(BuildContext context, {required Color primaryColor, required Color deepBlue});
}

/// Hostel state checker
_StateChecker _HostelStateChecker(BuildContext context) => _HostelChecker(context);

class _HostelChecker extends _StateChecker {
  final BuildContext ctx;
  _HostelChecker(this.ctx);

  @override
  Widget buildStatus(BuildContext context) {
    final state = ctx.watch<AuthBloc>().state;
    // if authenticating -> show neutral loading dot
    if (state is HostelAuthenticating) {
      return const SizedBox(
        width: 90,
        child: Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // if logged in -> green pill
    if (state is HosteLoggedIn) {
      return _StatusPill(label: "Connected", color: Colors.green.shade600, icon: Icons.check_circle);
    }

    // logged out -> grey pill
    return _StatusPill(label: "Disconnected", color: Colors.grey.shade400, icon: Icons.toggle_off);
  }

  @override
  Widget buildView(BuildContext context, {required Color primaryColor, required Color deepBlue}) {
    final state = ctx.watch<AuthBloc>().state;

    if (state is HostelAuthenticating) {
      return Center(child: (context.findAncestorStateOfType<_HomePageState>()?._buildLoading(state.message)) ?? const SizedBox());
    }

    if (state is HosteLoggedIn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () => ctx.read<AuthBloc>().add(HostelLogout()),
            icon: const Icon(Icons.logout),
            label: const Text("Hostel Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white, // button text white
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      );
    }

    // logged out
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => ctx.read<AuthBloc>().add(HostelLogin()),
          icon: const Icon(Icons.login),
          label: const Text("Hostel Login"),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white, // button text white
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Implement logout from all devices
            print("Hostel - Logout from All Devices clicked");
            context.read<AuthBloc>().add(HostelLogout());
          },
          icon: const Icon(Icons.logout_outlined),
          label: const Text("Logout from All Devices"),
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

/// Academic state checker
_StateChecker _AcademicStateChecker(BuildContext context) => _AcademicChecker(context);

class _AcademicChecker extends _StateChecker {
  final BuildContext ctx;
  _AcademicChecker(this.ctx);

  @override
  Widget buildStatus(BuildContext context) {
    final state = ctx.watch<AuthBloc>().state;

    if (state is AcademicAuthenticating) {
      return const SizedBox(
        width: 90,
        child: Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (state is AcademicLoggedIn) {
      return _StatusPill(label: "Connected", color: Colors.green.shade600, icon: Icons.check_circle);
    }

    return _StatusPill(label: "Disconnected", color: Colors.grey.shade400, icon: Icons.toggle_off);
  }

  @override
  Widget buildView(BuildContext context, {required Color primaryColor, required Color deepBlue}) {
    final state = ctx.watch<AuthBloc>().state;

    if (state is AcademicAuthenticating) {
      return Center(child: (context.findAncestorStateOfType<_HomePageState>()?._buildLoading(state.message)) ?? const SizedBox());
    }

    if (state is AcademicLoggedIn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () => ctx.read<AuthBloc>().add(AcademicLogout()),
            icon: const Icon(Icons.logout),
            label: const Text("Academic Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white, // button text white
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => ctx.read<AuthBloc>().add(AcademicLogin()),
          icon: const Icon(Icons.login),
          label: const Text("Academic Login"),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white, // button text white
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Implement logout from all devices
            print("Academic - Logout from All Devices clicked");
          },
          icon: const Icon(Icons.logout_outlined),
          label: const Text("Logout from All Devices"),
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

/// Small reusable pill widget used for inline status indicator
class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusPill({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sophos/bloc/auth_bloc.dart';
import 'package:sophos/Sophos%20Logger/local_storage.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final TextEditingController _usernameController =
      TextEditingController(text: LocalStorage.getString("username") ?? "");
  final TextEditingController _passwordController =
      TextEditingController(text: LocalStorage.getString("password") ?? "");

  bool _isSaving = false;
  bool _obscurePassword = true; // toggle for password

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF144272),
          title: const Text(
            "WiFi Credentials",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
            // Wait for logout completion
            if (state is HostelLoggedOut || state is AcademicLoggedOut) {
              // Step 2: Save new credentials
              LocalStorage.setString("username", _usernameController.text);
              LocalStorage.setString("password", _passwordController.text);

              setState(() => _isSaving = false);

              // Step 3: Show feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("✅ Credentials updated successfully"),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Update Credentials",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A2647),
                  ),
                ),
                const SizedBox(height: 16),

                // Username Field
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    labelStyle: const TextStyle(color: Color(0xFF0A2647)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF144272), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field (with toggle)
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Color(0xFF0A2647)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF144272), width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF144272),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF144272),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() => _isSaving = true);

                            final authBloc = context.read<AuthBloc>();
                            final currentState = authBloc.state;

                            // Step 1: Logout from whichever is logged in
                            if (currentState is HosteLoggedIn) {
                              authBloc.add(HostelLogout());
                            } else if (currentState is AcademicLoggedIn) {
                              authBloc.add(AcademicLogout());
                            } else {
                              // If already logged out, just save directly
                              LocalStorage.setString("username",
                                  _usernameController.text);
                              LocalStorage.setString("password",
                                  _passwordController.text);

                              setState(() => _isSaving = false);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "✅ Credentials updated successfully"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                    child: _isSaving
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text("Logging out & saving..."),
                            ],
                          )
                        : const Text(
                            "Save",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

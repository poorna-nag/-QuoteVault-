import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_event.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_state.dart';
import 'package:quote_vault/features/quotes/presentation/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess && state.userId.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QuoteVault',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin ? 'Login' : 'Sign Up',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const CircularProgressIndicator();
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();
                          
                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill in all fields')),
                            );
                            return;
                          }
                          
                          if (!email.contains('@')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid email')),
                            );
                            return;
                          }
                          
                          if (password.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password must be at least 6 characters')),
                            );
                            return;
                          }
                          
                          if (isLogin) {
                            context.read<AuthBloc>().add(
                                  LoginEvent(email, password),
                                );
                          } else {
                            context.read<AuthBloc>().add(
                                  SignUpEvent(email, password),
                                );
                          }
                        },
                        child: Text(isLogin ? 'Login' : 'Create Account'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? "Don't have an account? Sign Up"
                        : "Already have an account? Login",
                  ),
                ),
                if (isLogin) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController();
                          return AlertDialog(
                            title: const Text('Reset Password'),
                            content: TextField(
                              controller: controller,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: 'Email'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<AuthBloc>().add(ResetPasswordEvent(controller.text.trim()));
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Password reset email sent')),
                                  );
                                },
                                child: const Text('Send'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
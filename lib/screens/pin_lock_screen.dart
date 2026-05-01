import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _enteredPin = '';
  bool _hasError = false;

  void _onKeyPressed(String key) {
    if (_enteredPin.length >= 4) return;

    setState(() {
      _enteredPin += key;
      _hasError = false;
    });

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _hasError = false;
      });
    }
  }

  void _verifyPin() {
    final appState = context.read<AppStateProvider>();
    if (appState.verifyPin(_enteredPin)) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() {
        _hasError = true;
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const Icon(
                Icons.lock_rounded,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _hasError ? 'Incorrect PIN. Try again.' : 'Enter your PIN',
                style: TextStyle(
                  fontSize: 16,
                  color: _hasError ? AppTheme.errorColor : Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              _buildPinDots(),
              const SizedBox(height: 48),
              _buildKeypad(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < _enteredPin.length;
        return Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            border: _hasError
                ? Border.all(color: AppTheme.errorColor, width: 2)
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) {
              return const SizedBox(width: 80, height: 80);
            }
            if (key == 'back') {
              return _KeypadButton(
                onTap: _onBackspace,
                child: const Icon(Icons.backspace_outlined,
                    color: Colors.white, size: 24),
              );
            }
            return _KeypadButton(
              onTap: () => _onKeyPressed(key),
              child: Text(
                key,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _KeypadButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
        ),
        child: Center(child: child),
      ),
    );
  }
}

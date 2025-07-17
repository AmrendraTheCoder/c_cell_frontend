import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:google_fonts/google_fonts.dart';

class KeyboardShortcutsOverlay extends StatefulWidget {
  final Widget child;
  final Function(int)? onNavigationShortcut;
  final VoidCallback? onRefreshShortcut;
  final VoidCallback? onSearchShortcut;
  final VoidCallback? onHelpShortcut;

  const KeyboardShortcutsOverlay({
    super.key,
    required this.child,
    this.onNavigationShortcut,
    this.onRefreshShortcut,
    this.onSearchShortcut,
    this.onHelpShortcut,
  });

  @override
  State<KeyboardShortcutsOverlay> createState() => _KeyboardShortcutsOverlayState();
}

class _KeyboardShortcutsOverlayState extends State<KeyboardShortcutsOverlay> {
  bool _showShortcuts = false;
  final FocusNode _focusNode = FocusNode();

  final Map<LogicalKeySet, String> _shortcuts = {
    LogicalKeySet(LogicalKeyboardKey.digit1): 'Navigate to Home',
    LogicalKeySet(LogicalKeyboardKey.digit2): 'Navigate to Gymkhana',
    LogicalKeySet(LogicalKeyboardKey.digit3): 'Navigate to Notifications',
    LogicalKeySet(LogicalKeyboardKey.digit4): 'Navigate to LNMIIT',
    LogicalKeySet(LogicalKeyboardKey.digit5): 'Navigate to More',
    LogicalKeySet(LogicalKeyboardKey.keyR, LogicalKeyboardKey.control): 'Refresh content',
    LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control): 'Search (Future)',
    LogicalKeySet(LogicalKeyboardKey.keyH, LogicalKeyboardKey.control): 'Show keyboard shortcuts',
    LogicalKeySet(LogicalKeyboardKey.arrowLeft): 'Previous tab',
    LogicalKeySet(LogicalKeyboardKey.arrowRight): 'Next tab',
    LogicalKeySet(LogicalKeyboardKey.escape): 'Close dialogs/overlays',
  };

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Toggle shortcuts overlay
      if (event.logicalKey == LogicalKeyboardKey.keyH && 
          event.isControlPressed) {
        setState(() => _showShortcuts = !_showShortcuts);
        return;
      }

      // Close shortcuts overlay
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (_showShortcuts) {
          setState(() => _showShortcuts = false);
          return;
        }
      }

      // Navigation shortcuts
      if (event.logicalKey == LogicalKeyboardKey.digit1) {
        widget.onNavigationShortcut?.call(0);
      } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
        widget.onNavigationShortcut?.call(1);
      } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
        widget.onNavigationShortcut?.call(2);
      } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
        widget.onNavigationShortcut?.call(3);
      } else if (event.logicalKey == LogicalKeyboardKey.digit5) {
        widget.onNavigationShortcut?.call(4);
      }

      // Refresh shortcut
      if (event.logicalKey == LogicalKeyboardKey.keyR && 
          event.isControlPressed) {
        widget.onRefreshShortcut?.call();
      }

      // Search shortcut (future implementation)
      if (event.logicalKey == LogicalKeyboardKey.keyF && 
          event.isControlPressed) {
        widget.onSearchShortcut?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyPress,
      child: Stack(
        children: [
          widget.child,
          if (_showShortcuts) _buildShortcutsOverlay(),
          _buildShortcutsHint(),
        ],
      ),
    );
  }

  Widget _buildShortcutsOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Keyboard Shortcuts',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _showShortcuts = false),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _shortcuts.entries.map((entry) {
                        return _buildShortcutItem(entry.key, entry.value);
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Press Ctrl+H to toggle this help, ESC to close',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutItem(LogicalKeySet keySet, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0175C2).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF0175C2).withOpacity(0.5)),
            ),
            child: Text(
              _formatKeySet(keySet),
              style: GoogleFonts.sourceCodePro(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0175C2),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutsHint() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: _showShortcuts ? 0.0 : 0.7,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.keyboard,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(
                'Ctrl+H for shortcuts',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatKeySet(LogicalKeySet keySet) {
    final keys = keySet.keys.toList();
    final keyStrings = keys.map((key) {
      if (key == LogicalKeyboardKey.control) return 'Ctrl';
      if (key == LogicalKeyboardKey.shift) return 'Shift';
      if (key == LogicalKeyboardKey.alt) return 'Alt';
      if (key == LogicalKeyboardKey.meta) return 'Cmd';
      if (key == LogicalKeyboardKey.arrowLeft) return '←';
      if (key == LogicalKeyboardKey.arrowRight) return '→';
      if (key == LogicalKeyboardKey.arrowUp) return '↑';
      if (key == LogicalKeyboardKey.arrowDown) return '↓';
      if (key == LogicalKeyboardKey.escape) return 'Esc';
      if (key == LogicalKeyboardKey.enter) return 'Enter';
      if (key == LogicalKeyboardKey.space) return 'Space';
      return key.keyLabel.toUpperCase();
    }).toList();

    return keyStrings.join(' + ');
  }
}

// Accessibility improvements
class AccessibilityWrapper extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? tooltip;
  final VoidCallback? onTap;
  final bool excludeFromSemantics;

  const AccessibilityWrapper({
    super.key,
    required this.child,
    this.semanticLabel,
    this.tooltip,
    this.onTap,
    this.excludeFromSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget wrappedChild = child;

    if (tooltip != null) {
      wrappedChild = Tooltip(
        message: tooltip!,
        child: wrappedChild,
      );
    }

    if (semanticLabel != null) {
      wrappedChild = Semantics(
        label: semanticLabel!,
        button: onTap != null,
        excludeSemantics: excludeFromSemantics,
        child: wrappedChild,
      );
    }

    if (onTap != null) {
      wrappedChild = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: wrappedChild,
      );
    }

    return wrappedChild;
  }
}

// Focus management for better keyboard navigation
class FocusableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool autofocus;

  const FocusableCard({
    super.key,
    required this.child,
    this.onTap,
    this.tooltip,
    this.autofocus = false,
  });

  @override
  State<FocusableCard> createState() => _FocusableCardState();
}

class _FocusableCardState extends State<FocusableCard> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: _isFocused
            ? Border.all(color: const Color(0xFF0175C2), width: 2)
            : null,
      ),
      child: widget.child,
    );

    if (widget.tooltip != null) {
      card = Tooltip(message: widget.tooltip!, child: card);
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKey: (node, event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          widget.onTap?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
          widget.onTap?.call();
        },
        child: card,
      ),
    );
  }
}

// Screen reader announcements
class ScreenReaderAnnouncer {
  static void announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  static void announcePageChange(String pageName) {
    announce('Navigated to $pageName page');
  }

  static void announceAction(String action) {
    announce(action);
  }

  static void announceError(String error) {
    announce('Error: $error');
  }

  static void announceSuccess(String success) {
    announce('Success: $success');
  }
}

// High contrast theme support
class HighContrastTheme {
  static ThemeData getHighContrastTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.black,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
        bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
        headlineLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.yellow, width: 3),
        ),
      ),
    );
  }
}

// Text scaling support
class TextScaleWrapper extends StatelessWidget {
  final Widget child;
  final double? maxScaleFactor;

  const TextScaleWrapper({
    super.key,
    required this.child,
    this.maxScaleFactor = 1.3,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, maxScaleFactor ?? 1.3),
      ),
      child: child,
    );
  }
} 
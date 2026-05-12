import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputRow extends StatefulWidget {
  final int length;
  final bool isObscured;
  final double boxSize;
  final double boxSpacing;
  final ValueChanged<String>? onCompleted;

  const PinInputRow({
    super.key,
    this.length = 4,
    this.isObscured = false,
    this.boxSize = 70,
    this.boxSpacing = 15,
    this.onCompleted,
  });

  @override
  State<PinInputRow> createState() => _PinInputRowState();
}

class _PinInputRowState extends State<PinInputRow> {
  late final List<FocusNode> _focusNodes;
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _controllers = List.generate(widget.length, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final node in _focusNodes) node.dispose();
    for (final ctrl in _controllers) ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        final pin = _controllers.map((c) => c.text).join();
        if (pin.length == widget.length) {
          widget.onCompleted?.call(pin);
        }
      }
    } else if (index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  Widget _buildSingleBox(int index) {
    // Scale font and padding proportionally to box size
    final double fontSize = widget.boxSize * 0.4;
    final double verticalPadding = widget.boxSize * 0.285;

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[index].text.isEmpty &&
            index > 0) {
          FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
        }
      },
      child: SizedBox(
        width: widget.boxSize,
        height: widget.boxSize,
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          obscureText: widget.isObscured,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (value) => _onChanged(value, index),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.symmetric(vertical: verticalPadding),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.boxSize * 0.285),
              borderSide: const BorderSide(color: Colors.black54, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.boxSize * 0.257),
              borderSide: const BorderSide(color: Color(0xFF165B9E), width: 2),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < widget.length; i++) ...[
          _buildSingleBox(i),
          if (i < widget.length - 1) SizedBox(width: widget.boxSpacing),
        ],
      ],
    );
  }
}
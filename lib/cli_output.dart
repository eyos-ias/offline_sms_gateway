import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CLIOutput extends StatefulWidget {
  final String output;
  final Function(String) updateOutput;

  CLIOutput({required this.output, required this.updateOutput});

  @override
  _CLIOutputState createState() => _CLIOutputState();
}

class _CLIOutputState extends State<CLIOutput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 500,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(0),
      ),
      child: CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Text(
            widget.output,
            style: const TextStyle(
                fontFamily: 'Courier', fontSize: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

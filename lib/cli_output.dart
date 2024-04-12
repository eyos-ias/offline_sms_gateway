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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void didUpdateWidget(CLIOutput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.output != oldWidget.output) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

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
          controller: _scrollController,
          child: Text(
            widget.output,
            style: const TextStyle(
                fontFamily: 'Courier', fontSize: 12, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

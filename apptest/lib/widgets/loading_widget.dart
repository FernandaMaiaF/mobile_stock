import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final bool fullScreen;
  const LoadingWidget({
    Key? key,
    this.fullScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

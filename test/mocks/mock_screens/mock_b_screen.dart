import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_b_viewmodel.dart';
import 'mock_screen_base.dart';

class MockBScreen extends MockScreenBase {
  MockBScreen({super.key, MockBViewModel? viewModel}) 
      : super(viewModel: viewModel ?? MockBViewModel());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return super.build(context, ref);
  }
}
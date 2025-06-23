import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_a_viewmodel.dart';
import 'mock_screen_base.dart';

class MockAScreen extends MockScreenBase {
  MockAScreen({super.key, MockAViewModel? viewModel}) 
      : super(viewModel: viewModel ?? MockAViewModel());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return super.build(context, ref);
  }
}
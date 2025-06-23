import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_c_viewmodel.dart';
import 'mock_screen_base.dart';

class MockCScreen extends MockScreenBase {
  MockCScreen({super.key, MockCViewModel? viewModel}) 
      : super(viewModel: viewModel ?? MockCViewModel());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return super.build(context, ref);
  }
}
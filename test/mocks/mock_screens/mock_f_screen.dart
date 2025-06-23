import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_f_viewmodel.dart';
import 'mock_screen_base.dart';

class MockFScreen extends MockScreenBase {
  MockFScreen({super.key, MockFViewModel? viewModel}) 
      : super(viewModel: viewModel ?? MockFViewModel());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return super.build(context, ref);
  }
}
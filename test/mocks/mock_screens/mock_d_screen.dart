import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_d_viewmodel.dart';
import 'mock_screen_base.dart';

class MockDScreen extends MockScreenBase {
  MockDScreen({super.key, MockDViewModel? viewModel}) 
      : super(viewModel: viewModel ?? MockDViewModel());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return super.build(context, ref);
  }
}
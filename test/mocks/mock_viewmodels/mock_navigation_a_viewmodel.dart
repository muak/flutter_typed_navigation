import 'mock_viewmodel_base.dart';

class MockNavigationAViewModel extends MockViewModelBase {
  MockNavigationAViewModel([Object? parameter]) {
    if (parameter != null) {
      setParameters(parameter);
    }
    actionLogQueue.add('initializeAsync');
  }
}
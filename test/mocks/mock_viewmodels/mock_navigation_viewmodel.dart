import 'mock_viewmodel_base.dart';

class MockNavigationViewModel extends MockViewModelBase {
  MockNavigationViewModel([Object? parameter]) {
    if (parameter != null) {
      setParameters(parameter);
    }
    actionLogQueue.add('initializeAsync');
  }
}
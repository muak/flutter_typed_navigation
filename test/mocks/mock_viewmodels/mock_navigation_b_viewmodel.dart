import 'mock_viewmodel_base.dart';

class MockNavigationBViewModel extends MockViewModelBase {
  MockNavigationBViewModel([Object? parameter]) {
    if (parameter != null) {
      setParameters(parameter);
    }
    actionLogQueue.add('initializeAsync');
  }
}
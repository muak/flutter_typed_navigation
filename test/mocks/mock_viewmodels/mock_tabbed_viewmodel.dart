import 'mock_viewmodel_base.dart';

class MockTabbedViewModel extends MockViewModelBase {
  MockTabbedViewModel([Object? parameter]) {
    if (parameter != null) {
      setParameters(parameter);
    }
    actionLogQueue.add('initializeAsync');
  }
}
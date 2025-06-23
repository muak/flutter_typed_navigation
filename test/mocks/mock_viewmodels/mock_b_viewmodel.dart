import '../test_parameter.dart';
import 'mock_viewmodel_base.dart';

class MockBViewModel extends MockViewModelBase {
  MockBViewModel([Object? parameter]) {
    if (parameter != null) {
      setParameters(parameter);
      actionLogQueue.add('initializeAsync');
      
      if (parameter is TestParameter && parameter.isCancel) {
        actionLogQueue.add('initializeAsyncCancel');
      }
    } else {
      actionLogQueue.add('initializeAsync');
    }
  }
}
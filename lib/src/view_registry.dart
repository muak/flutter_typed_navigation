import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tab_base_widget.dart';

typedef ViewCreator = Widget Function();
typedef ViewCreatorP = Widget Function(dynamic parameter);
typedef TabCreator = Widget Function(TabConfigState config);
typedef ViewModelCreatorP = ProviderListenable Function(dynamic parameter);
typedef Registration = ({ProviderListenable viewModelProvider, ViewCreator viewCreator});
typedef RegistrationP = ({ViewModelCreatorP viewModelCreator, ViewCreatorP viewCreator});
typedef RegistrationTab = ({ProviderListenable viewModelProvider, TabCreator tabCreator});
typedef ViewModelProvider<T> = ProviderListenable<T> Function();

class ViewRegistry{
  final Map<String, dynamic> _viewRegistry = {};    

  Registration? getRegistration(String viewModelType){
    return _viewRegistry[viewModelType];
  }

  RegistrationP? getRegistrationWithParameter(String viewModelType){
    return _viewRegistry[viewModelType];
  }

  RegistrationTab? getTabRegistration(String viewModelType){
    return _viewRegistry[viewModelType];
  }
  
  ViewRegistry register<TViewModel>(ProviderListenable viewModelProvider, ViewCreator viewCreator) {
    _viewRegistry[TViewModel.toString()] = (viewModelProvider: viewModelProvider, viewCreator: viewCreator);
    return this;
  }

  ViewRegistry registerWithParameter<TViewModel>(ViewModelCreatorP viewModelCreator, ViewCreatorP viewCreator) {
    _viewRegistry[TViewModel.toString()] = (viewModelCreator: viewModelCreator, viewCreator: viewCreator);
    return this;
  }

  ViewRegistry registerTab<TViewModel>(ProviderListenable viewModelProvider, TabCreator tabCreator) {
    _viewRegistry[TViewModel.toString()] = (viewModelProvider: viewModelProvider, tabCreator: tabCreator);
    return this;
  }
}

final viewRegistryProvider = Provider<ViewRegistry>((ref) => ViewRegistry());
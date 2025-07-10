import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tab_base_widget.dart';

typedef ViewCreator = Widget Function();
typedef ViewCreatorP = Widget Function(dynamic parameter);
typedef TabCreator = Widget Function(TabConfigState config);
typedef ViewModelCreatorP = ProviderListenable Function(dynamic parameter);
typedef Registration = ({ViewCreator viewCreator, ProviderListenable viewModelProvider});
typedef RegistrationP = ({ViewCreatorP viewCreator, ViewModelCreatorP viewModelCreator});
typedef RegistrationTab = ({TabCreator tabCreator, ProviderListenable viewModelProvider});
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
  
  ViewRegistry register<TViewModel>(ViewCreator viewCreator, ProviderListenable viewModelProvider) {
    _viewRegistry[TViewModel.toString()] = (viewCreator: viewCreator, viewModelProvider: viewModelProvider);
    return this;
  }

  ViewRegistry registerWithParameter<TViewModel>(ViewCreatorP viewCreator, ViewModelCreatorP viewModelCreator) {
    _viewRegistry[TViewModel.toString()] = (viewCreator: viewCreator, viewModelCreator: viewModelCreator);
    return this;
  }

  ViewRegistry registerTab<TViewModel>(TabCreator tabCreator, ProviderListenable viewModelProvider) {
    _viewRegistry[TViewModel.toString()] = (tabCreator: tabCreator, viewModelProvider: viewModelProvider);
    return this;
  }
}

final viewRegistryProvider = Provider<ViewRegistry>((ref) => ViewRegistry());
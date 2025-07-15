import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../annotations.dart';

/// ViewRegistryの自動登録コードを生成するジェネレータ
class ViewRegistryGenerator extends GeneratorForAnnotation<RegisterFor> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'RegisterFor can only be applied to classes.',
        element: element,
      );
    }

    final viewClass = element;
    final viewModelType = getViewModelType(annotation);
    
    if (viewModelType == null) {
      throw InvalidGenerationSourceError(
        'RegisterFor annotation must have a type argument.',
        element: element,
      );
    }

    final constructorInfo = _analyzeConstructor(viewClass);
    if (constructorInfo == null) {
      throw InvalidGenerationSourceError(
        'Class ${viewClass.name} must have a constructor.',
        element: element,
      );
    }

    final isTabWidget = _isTabBaseWidget(viewClass);
    final creatorFunction = _generateCreatorFunction(viewClass, constructorInfo, isTabWidget);
    final registerCall = _generateRegisterCall(viewModelType, creatorFunction, isTabWidget, constructorInfo.hasRequiredFirstParameter);

    return registerCall;
  }

  ViewModelTypeInfo? getViewModelType(ConstantReader annotation) {
    final annotationType = annotation.objectValue.type;
    if (annotationType is InterfaceType) {
      final typeArguments = annotationType.typeArguments;
      if (typeArguments.isEmpty) {
        return null;
      }

      final viewModelType = typeArguments.first;
      return ViewModelTypeInfo(
        name: viewModelType.getDisplayString(withNullability: false),
        libraryUri: viewModelType.element?.library?.source.uri.toString(),
      );
    }
    return null;
  }

  ConstructorInfo? _analyzeConstructor(ClassElement viewClass) {
    final constructor = viewClass.unnamedConstructor;
    if (constructor == null) {
      return null;
    }

    final parameters = constructor.parameters;
    
    // TabBaseWidgetの場合は特別な処理
    if (_isTabBaseWidget(viewClass)) {
      // TabBaseWidgetのコンストラクタは config パラメータを持つ
      return ConstructorInfo(
        parameters: parameters,
        hasRequiredFirstParameter: false, // TabCreatorは特別な扱い
      );
    }
    
    // 第一引数が必須かどうかをチェック
    bool hasRequiredFirstParameter = false;
    if (parameters.isNotEmpty) {
      final firstParam = parameters.first;
      if (firstParam.isRequiredPositional) {
        hasRequiredFirstParameter = true;
      }
    }

    return ConstructorInfo(
      parameters: parameters,
      hasRequiredFirstParameter: hasRequiredFirstParameter,
    );
  }

  bool _isTabBaseWidget(ClassElement element) {
    return _isSubclassOf(element, 'TabBaseWidget');
  }

  bool _isSubclassOf(ClassElement element, String className) {
    if (element.name == className) {
      return true;
    }
    
    final supertype = element.supertype;
    if (supertype != null) {
      final supertypeElement = supertype.element;
      if (supertypeElement is ClassElement) {
        return _isSubclassOf(supertypeElement, className);
      }
    }
    
    return false;
  }

  String _generateCreatorFunction(ClassElement viewClass, ConstructorInfo constructorInfo, bool isTabWidget) {
    final className = viewClass.name;
    final parameters = constructorInfo.parameters;
    
    if (isTabWidget) {
      // TabCreator: Widget Function(TabConfigState config)
      return '(config) => $className(config: config)';
    } else if (constructorInfo.hasRequiredFirstParameter) {
      // ViewCreatorP: Widget Function(dynamic parameter)
      return '(parameter) => $className(parameter)';
    } else {
      // ViewCreator: Widget Function()
      return '() => const $className()';
    }
  }

  String _generateRegisterCall(ViewModelTypeInfo viewModelType, String creatorFunction, bool isTabWidget, bool hasRequiredFirstParameter) {
    final viewModelName = viewModelType.name;
    final providerName = _getProviderName(viewModelName);
    
    if (isTabWidget) {
      return 'registry.registerTab<$viewModelName>($creatorFunction, ${providerName}.notifier);';
    } else if (hasRequiredFirstParameter) {
      // registerWithParameterの場合、パラメータ付きProviderを使用
      final viewModelCreatorFunction = '(parameter) => ${providerName}(parameter).notifier';
      return 'registry.registerWithParameter<$viewModelName>($creatorFunction, $viewModelCreatorFunction);';
    } else {
      return 'registry.register<$viewModelName>($creatorFunction, ${providerName}.notifier);';
    }
  }

  String _getProviderName(String viewModelName) {
    // ViewModelの名前からProviderの名前を推測
    // 例: TestViewModel -> testViewModelProvider
    // 例: AlphaParamViewModel -> alphaParamViewModelProvider
    final baseName = viewModelName.replaceFirst('ViewModel', '');
    final camelCaseName = baseName[0].toLowerCase() + baseName.substring(1);
    return '${camelCaseName}ViewModelProvider';
  }
}

/// ViewModelの型情報を保持するクラス
class ViewModelTypeInfo {
  final String name;
  final String? libraryUri;

  ViewModelTypeInfo({required this.name, this.libraryUri});
}

class ConstructorInfo {
  final List<ParameterElement> parameters;
  final bool hasRequiredFirstParameter;

  ConstructorInfo({
    required this.parameters,
    required this.hasRequiredFirstParameter,
  });
} 
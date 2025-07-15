import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';
import 'view_registry_generator.dart';

/// Builder factoryを提供
Builder autoRegisterBuilder(BuilderOptions options) => AutoRegisterBuilder();

/// auto_register.g.dartファイルを生成するBuilder
class AutoRegisterBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': ['auto_register.g.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final generator = ViewRegistryGenerator();
    final registrations = <String>[];
    final requiredImports = <String>{};

    // lib/以下のすべてのDartファイルをスキャン
    final dartFiles = Glob('lib/**.dart');
    await for (final assetId in buildStep.findAssets(dartFiles)) {
      if (assetId.path.endsWith('.g.dart') || assetId.path.endsWith('.freezed.dart')) {
        continue; // 生成されたファイルはスキップ
      }

      final library = await buildStep.resolver.libraryFor(assetId);
      
      for (final element in library.topLevelElements) {
        if (element is ClassElement) {
          final registerForAnnotation = _getRegisterForAnnotation(element);
          if (registerForAnnotation != null) {
            try {
              final registration = await generator.generateForAnnotatedElement(
                element,
                registerForAnnotation,
                buildStep,
              );
              registrations.add(registration);
              
              // 必要なimportを追加
              requiredImports.add(assetId.uri.toString());
              
              // ViewModelの型情報を取得してimportを追加
              final viewModelTypeInfo = generator.getViewModelType(registerForAnnotation);
              if (viewModelTypeInfo?.libraryUri != null) {
                requiredImports.add(viewModelTypeInfo!.libraryUri!);
              }
            } catch (e) {
              // エラーは無視して次の要素に進む
              print('Warning: Failed to generate registration for ${element.name}: $e');
            }
          }
        }
      }
    }

    if (registrations.isNotEmpty) {
      final content = _generateFileContent(registrations, requiredImports, buildStep.inputId.package);
      final outputId = AssetId(buildStep.inputId.package, 'lib/auto_register.g.dart');
      await buildStep.writeAsString(outputId, content);
    }
  }

  ConstantReader? _getRegisterForAnnotation(ClassElement element) {
    for (final annotation in element.metadata) {
      final annotationValue = annotation.computeConstantValue();
      if (annotationValue != null && 
          annotationValue.type?.element?.name == 'RegisterFor') {
        return ConstantReader(annotationValue);
      }
    }
    return null;
  }

  String _generateFileContent(List<String> registrations, Set<String> requiredImports, String packageName) {
    final buffer = StringBuffer();
    
    // 必要最小限のimport
    buffer.writeln("import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';");
    
    // 必要なimportを追加
    for (final importUri in requiredImports) {
      if (importUri.startsWith('package:') || importUri.startsWith('dart:')) {
        buffer.writeln("import '$importUri';");
      } else {
        // asset URIの場合は適切に変換
        String relativePath = importUri;
        if (importUri.startsWith('asset:')) {
          final assetPrefix = 'asset:$packageName/';
          if (importUri.startsWith(assetPrefix)) {
            relativePath = importUri.replaceFirst(assetPrefix, '');
          } else {
            // 他のパッケージのasset URIの場合はそのまま使用
            // この場合は通常package:形式になるべきだが、念のため警告を出す
            print('Warning: Unexpected asset URI format: $importUri');
            continue;
          }
        }
        
        if (relativePath.startsWith('lib/')) {
          buffer.writeln("import '${relativePath.substring(4)}';");
        } else {
          buffer.writeln("import '$relativePath';");
        }
      }
    }
    
    buffer.writeln();
    buffer.writeln('extension ViewRegistryExtension on ViewRegistry {');
    buffer.writeln('  ViewRegistry registerAuto() {');
    buffer.writeln('    final registry = this;');
    
    for (final registration in registrations) {
      buffer.writeln('    $registration');
    }
    
    buffer.writeln('    return registry;');
    buffer.writeln('  }');
    buffer.writeln('}');

    try {
      final formatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);
      return formatter.format(buffer.toString());
    } catch (e) {
      // フォーマットに失敗した場合は、フォーマットなしで返す
      return buffer.toString();
    }
  }
} 
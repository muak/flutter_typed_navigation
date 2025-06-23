import 'package:flutter/material.dart';

extension LocalKeyExtensions on LocalKey?{

  String toStringValue(){
    if(this == null){
      return '';
    }
    if(this case ValueKey key){
      return key.value.toString();
    }
    else{
      return toString();
    }
  }  
}

extension KeyExtensions on Key?{

  String toStringValue(){
    if(this == null){
      return '';
    }
    if(this case ValueKey key){
      return key.value.toString();
    }
    else{
      return toString();
    }
  }  
}
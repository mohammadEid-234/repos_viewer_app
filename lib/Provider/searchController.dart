import 'package:flutter/widgets.dart';
import 'package:github_reps/Constants/filterTypes.dart';

class FilterController extends ChangeNotifier{
  //change search filter without rebuilding the whole page
  FilterTypes _filter=FilterTypes.name;


  void changeFilter(FilterTypes newFilter){
    _filter = newFilter;
    notifyListeners();
  }
  FilterTypes get filter => _filter;

  set filter(FilterTypes value) {
    _filter = value;
  }


}
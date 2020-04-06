import 'dart:convert';

import 'package:http/http.dart';

Future<String> getData() async {
  var results = await get(
      'https://opendata.ecdc.europa.eu/covid19/casedistribution/json/');
  var json = jsonDecode(results.body);
  var data = filterData(json);
  return (jsonEncode(data));
}

dynamic filterData(dynamic data) {
  List<dynamic> records = data['records'];
  var results = records.where((record) => record['geoId'] == 'SE').toList();
  print('Found ${results.length} records');

  var result = {
    'results': results.reversed.toList(),
    'totalCases': getTotal(results, dataSet: 'cases'),
    'totalDeaths': getTotal(results, dataSet: 'deaths')
  };
  return result;
}

int getTotal(List<dynamic> data, {String dataSet}) {
  return data.reduce((value, element) {
    if (value is int) {
      return value + int.parse(element[dataSet]);
    } else {
      return int.parse(value[dataSet]);
    }
  });
}

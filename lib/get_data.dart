import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

dynamic poormansRedis = null;

Future<String> getData() async {
  if (poormansRedis == null) {
    var results = await get(
        'https://opendata.ecdc.europa.eu/covid19/casedistribution/json/');
    var json = jsonDecode(results.body);
    var data = filterData(json);
    return (jsonEncode(data));
  } else {
    print('Returning "cache"');
    return await jsonEncode(poormansRedis);
  }
}

dynamic filterData(dynamic data) {
  List<dynamic> records = data['records'];
  var results = records.where((record) => record['geoId'] == 'SE').toList();
  print('Found ${results.length} records');

  var reversed = results.reversed.toList();
  var index = 0;
  var withTotals = reversed.map((result) {
    result['totaldeaths'] = getTotalToday(reversed, index, dataSet: 'deaths');
    result['totalcases'] = getTotalToday(reversed, index, dataSet: 'cases');
    index++;
    return {
      'date': result['dateRep'],
      'cases': result['cases'],
      'deaths': result['deaths'],
      'totalDeaths': result['totaldeaths'],
      'totaCases': result['totalcases']
    };
  });

  var result = {
    'results': withTotals.toList(),
    'totalCases': getTotal(results, dataSet: 'cases'),
    'totalDeaths': getTotal(results, dataSet: 'deaths')
  };
  poormansRedis = result;
  Timer(Duration(hours: 1), () {
    poormansRedis = null;
  });
  return result;
}

int getTotalToday(List<dynamic> data, int index, {String dataSet}) {
  if (index == 0) {
    return 0;
  } else {
    return data[index - 1]['total$dataSet'] + int.parse(data[index][dataSet]);
  }
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

import 'dart:io';

import 'package:api/get_data.dart';

var envVars = Platform.environment;
var PORT = int.parse(envVars['PORT']);

void main(List<String> arguments) async {
  var envVars = Platform.environment;
  var PORT = int.parse(envVars['PORT']);
  var server = await HttpServer.bind('0.0.0.0', PORT);
  print('Listening on ${server.address.host}:${server.port}');

  try {
    await for (HttpRequest request in server) {
      var requestedPath = request.requestedUri.toString().split('/')[3];
      print(requestedPath);
      if (requestedPath.contains('list')) {
        var result = await getData();
        request.response.headers.contentType =
            ContentType('application', 'json', charset: 'utf-8');
        request.response.write(result);
      } else {
        request.response.write('You\'re lost');
      }
      await request.response.close();
    }
    print('WAT');
  } catch (err) {
    print(err);
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

late final DbCollection users;
late final DbCollection sets;

final _router = Router()
  ..post('/register', _register)
  ..post('/login', _login)
  ..get('/sets/<userId>', _getSets)
  ..post('/sets', _createSet)
  ..get('/set/<setId>', _getSet);

Response _json(int status, Map<String, dynamic> body) => Response(
  status,
  body: jsonEncode(body),
  headers: {'content-type': 'application/json'},
);

Future<Response> _register(Request req) async {
  final body = jsonDecode(await req.readAsString());
  final username = (body['username'] as String).trim().toLowerCase();
  final password = body['password'] as String;

  if (username.isEmpty || password.length < 6) {
    return _json(400, {
      'error': 'Enter an username and a 6+ character password',
    });
  }
  if (await users.findOne(where.eq('username', username)) != null) {
    return _json(409, {'error': 'username already registered'});
  }

  final result = await users.insertOne({
    'username': username,
    'passwordHash': BCrypt.hashpw(password, BCrypt.gensalt()),
  });
  return _json(201, {'username': username, 'id': (result.id as ObjectId).oid});
}

Future<Response> _login(Request req) async {
  final body = jsonDecode(await req.readAsString());
  final username = (body['username'] as String).trim().toLowerCase();
  final password = body['password'] as String;

  final user = await users.findOne(where.eq('username', username));
  if (user == null || !BCrypt.checkpw(password, user['passwordHash'])) {
    return _json(401, {'error': 'Invalid username or password'});
  }
  return _json(200, {'id': (user['_id'] as ObjectId).oid});
}

Future<Response> _getSets(Request req, String userId) async {
  final list = await sets.find(where.eq('userId', userId)).toList();
  final result = list
      .map(
        (s) => {
          'id': (s['_id'] as ObjectId).oid,
          'title': s['title'],
          'public': s['public'],
        },
      )
      .toList();
  return Response.ok(
    jsonEncode(result),
    headers: {'content-type': 'application/json'},
  );
}

Future<Response> _createSet(Request req) async {
  final body = jsonDecode(await req.readAsString());
  final result = await sets.insertOne({
    'userId': body['userId'],
    'title': body['title'],
    'cards': body['cards'] ?? [],
    'public': body['public'] ?? false,
  });
  return _json(201, {'id': (result.id as ObjectId).oid});
}

Future<Response> _getSet(Request req, String setId) async {
  final s = await sets.findOne(where.id(ObjectId.fromHexString(setId)));
  if (s == null) return _json(404, {'error': 'Set not found'});
  return _json(200, {
    'id': setId,
    'title': s['title'],
    'public': s['public'],
    'cards': s['cards'] ?? [],
  });
}

void main() async {
  final env = DotEnv(includePlatformEnvironment: true)..load();

  final db = await Db.create(env['MONGODB_URI']!);
  await db.open();
  users = db.collection('users');
  sets = db.collection('sets');
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_router.call);
  final server = await serve(handler, InternetAddress.anyIPv4, 8080);
  print('Server listening on port ${server.port}');
}

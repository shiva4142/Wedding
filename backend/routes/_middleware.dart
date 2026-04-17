import 'package:dart_frog/dart_frog.dart';
import 'package:wedding_backend/store.dart';

final _store = Store.create();

Handler middleware(Handler handler) {
  return handler.use(provider<Store>((_) => _store)).use(_cors());
}

Middleware _cors() {
  return (handler) {
    return (context) async {
      if (context.request.method == HttpMethod.options) {
        return Response(
          headers: _corsHeaders,
        );
      }
      final response = await handler(context);
      return response.copyWith(
        headers: {
          ...response.headers,
          ..._corsHeaders,
        },
      );
    };
  };
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods':
      'GET, POST, PUT, DELETE, PATCH, OPTIONS',
  'Access-Control-Allow-Headers':
      'Content-Type, Authorization, X-Requested-With',
  'Access-Control-Max-Age': '86400',
};

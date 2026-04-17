import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'name': 'wedding_backend',
      'status': 'ok',
      'docs': {
        'POST /rsvp': 'Submit or update an RSVP',
        'GET /rsvp': '(admin) List all RSVPs',
        'GET /stats': 'Live attending count',
        'GET /wishes': 'List public wishes',
        'POST /wishes': 'Add a public wish',
        'GET /guests': '(admin) List guests',
        'POST /guests': '(admin) Add a guest',
        'DELETE /guests': '(admin) Delete a guest by id',
        'GET /guests/<slug>': 'Public lookup of a guest by slug',
        'POST /admin/login': 'Issue admin JWT',
        'GET /admin/rsvps': '(admin) RSVP table data',
        'GET /admin/export': '(admin) Download CSV',
        'POST /admin/remind': '(admin) Generate WhatsApp reminder link',
      },
    },
  );
}

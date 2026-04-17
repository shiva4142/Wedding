# Pooja & Shiva · Wedding Invitation Platform

A premium, animated digital wedding invitation built with **Flutter Web** + **Dart Frog**.
Designed to feel like a luxury product — soft pastel palette, gold accents, glassmorphism cards,
falling petals, custom serif type, and smooth scroll animations.

```
d:\wedding
├── frontend/   # Flutter Web app  (Riverpod, GoRouter, flutter_animate)
└── backend/    # Dart Frog API    (JWT auth, Firestore-or-memory store)
```

## Features

### Landing page
- Animated gradient hero with falling petals & couple monogram
- Live countdown to the wedding date
- Love-story timeline with scroll-triggered animations
- Event grid (Haldi · Mehendi · Wedding · Reception) with directions, dress code & "Add to calendar"
- Photo gallery with full-screen lightbox & pinch-zoom
- Background music toggle (royalty-free piano)
- Glassmorphism cards · Playfair Display serif · gold dividers
- Light / Dark theme · English / Telugu language toggle
- WhatsApp share + QR code floating action

### RSVP
- Inline form (name, phone, attending, guests, message)
- Submits to backend, animated success state
- Pre-fills name when opened from a personalized link
- Live "X guests attending" badge powered by `/stats`

### Personalized invites
- `/invite?guest=<slug>` shows a 2-second welcome overlay with the guest's name
- Hero shows "Dearest, &lt;name&gt;" chip
- The slug is included in the RSVP submission so the admin can correlate

### Wishes Wall
- Real-time poll of `/wishes` (every 6 s)
- Tilted, multi-coloured cards with cursive signatures

### Admin dashboard (`/admin/login` → `/admin/dashboard`)
- JWT-protected (default `admin@wedding.com / wedding2026`)
- Stat tiles · Search · Filter (attending/declined) · CSV export
- Guest list with one-click copy / open / WhatsApp reminder / delete
- "Pending responses" cards for guests who haven't RSVP'd

---

## 1. Prerequisites

- Flutter SDK ≥ 3.22 (`flutter --version`)
- Dart SDK ≥ 3.4 (bundled with Flutter)
- Dart Frog CLI:
  ```bash
  dart pub global activate dart_frog_cli
  ```

---

## 2. Run the backend

```powershell
cd d:\wedding\backend
dart pub get
# (optional) configure env
copy .env.example .env
notepad .env

# start the API on http://localhost:8080
dart_frog dev
```

You should see:
```
[store] Using in-memory store (no FIREBASE_PROJECT_ID set).
The Dart VM service is listening on ...
[hotreload] dart_frog server is ready.
```

The API runs out-of-the-box with seeded sample data (no database required).
Available endpoints:

| Method | Path | Description |
|--------|------|-------------|
| POST | `/rsvp` | Submit / update an RSVP |
| GET  | `/stats` | Public live count |
| GET  | `/wishes` | Public wishes feed |
| POST | `/wishes` | Add a wish |
| GET  | `/guests/{slug}` | Public guest lookup (for personalization) |
| POST | `/admin/login` | Issue JWT |
| GET  | `/admin/rsvps` | All RSVPs + pending list (admin) |
| GET  | `/admin/export` | CSV download (admin) |
| POST | `/admin/remind` | Generate WhatsApp reminder link |
| GET  | `/guests` | List guest book (admin) |
| POST | `/guests` | Add a guest (admin) |
| DELETE | `/guests` | Delete a guest by id (admin) |

### Switching to real Firestore

1. Create a Firebase project and enable Firestore in **test mode** (or write proper rules).
2. From *Project Settings → General*, copy the **Web API key** and **Project ID**.
3. Set them as env vars before starting Dart Frog:

   ```powershell
   $env:FIREBASE_PROJECT_ID = "your-project-id"
   $env:FIREBASE_API_KEY    = "AIzaSy..."
   $env:JWT_SECRET          = "a-long-random-string"
   $env:ADMIN_EMAIL         = "you@example.com"
   $env:ADMIN_PASSWORD      = "change-me"
   dart_frog dev
   ```

The backend uses the Firestore **REST API** (no service account needed for prototype use).
For production you should add Firebase Auth-mediated rules or a service account — see
`backend/lib/firestore_rest.dart` for the integration point.

---

## 3. Run the frontend

In a **second terminal**:

```powershell
cd d:\wedding\frontend
flutter pub get

# Run against the local backend (http://localhost:8080)
flutter run -d chrome --web-port=5000
```

Open <http://localhost:5000>. Try:

- `/` — public landing page
- `/invite?guest=rahul-sharma` — personalized invite (seed guest)
- `/admin/login` — admin (default `admin@wedding.com` / `wedding2026`)

### Pointing to a remote backend

```powershell
flutter run -d chrome --web-port=5000 `
  --dart-define=API_BASE=https://api.yourdomain.com `
  --dart-define=SITE_URL=https://yourdomain.com
```

---

## 4. Build for production

```powershell
cd d:\wedding\frontend
flutter build web --release `
  --dart-define=API_BASE=https://api.yourdomain.com `
  --dart-define=SITE_URL=https://yourdomain.com
```

Output goes to `build/web/`. Deploy that folder to any static host
(Firebase Hosting, Vercel, Netlify, S3+CloudFront, GitHub Pages, etc.).

### Firebase Hosting (recommended)

```powershell
npm install -g firebase-tools
cd d:\wedding\frontend
firebase login
firebase init hosting   # public dir: build/web, single-page app: yes
firebase deploy
```

### Backend deployment

`dart_frog build` produces a Docker-ready server at `build/`. Deploy it to
Cloud Run, Fly.io, Render, Railway, or any Docker host:

```powershell
cd d:\wedding\backend
dart_frog build
docker build -t wedding-api build/
docker run -p 8080:8080 `
  -e JWT_SECRET="..." `
  -e ADMIN_EMAIL="..." `
  -e ADMIN_PASSWORD="..." `
  -e FIREBASE_PROJECT_ID="..." `
  -e FIREBASE_API_KEY="..." `
  wedding-api
```

---

## 5. Customize

Almost everything you'll want to change lives in **`frontend/lib/core/config/`**:

| File | What's inside |
|------|---------------|
| `wedding_config.dart` | Couple names, date, hashtag, city |
| `events.dart`         | Haldi/Mehendi/Wedding/Reception details, gradients, venues |
| `love_story.dart`     | Timeline entries + gallery image URLs |
| `theme/app_theme.dart`| Palette, fonts, glass card styling |
| `i18n/translations.dart` | English + Telugu strings |

Replace the gallery URLs with your own (Cloudinary, Firebase Storage, etc.).
Replace the music URL inside `features/landing/widgets/music_player_fab.dart` to
swap in your own background track.

---

## 6. Architecture

```
frontend/lib
├── main.dart, app.dart               # bootstrap, MaterialApp.router
├── core/
│   ├── config/                       # static wedding data
│   ├── theme/                        # palette + light/dark
│   ├── i18n/                         # translations + locale controller
│   └── router/app_router.dart        # GoRouter (/, /invite, /admin/*)
├── models/                           # Rsvp, Guest, Wish DTOs
├── services/
│   ├── api_service.dart              # http client → Dart Frog
│   └── providers.dart                # Riverpod streams + admin token
├── widgets/                          # GlassCard, GoldDivider, PrimaryButton
└── features/
    ├── landing/                      # public landing + 11 section widgets
    ├── invite/                       # personalized invite wrapper
    └── admin/                        # login + dashboard
```

```
backend/
├── lib/
│   ├── models.dart                   # Rsvp / Wish / Guest
│   ├── store.dart                    # Store interface + MemoryStore
│   ├── firestore_rest.dart           # Firestore REST implementation
│   └── auth.dart                     # JWT helpers
└── routes/
    ├── _middleware.dart              # CORS + Store provider
    ├── index.dart, stats/, rsvp/, wishes/, guests/[slug]
    └── admin/
        ├── login/, rsvps/, export/, remind/
```

---

## 7. Going further

- **Real-time streams instead of polling** — replace the polled providers in
  `services/providers.dart` with `cloud_firestore` snapshot streams once you
  enable Firestore. The widget code does not need to change (still consumes
  `StreamProvider<int>` / `StreamProvider<List<Wish>>`).
- **Firebase Auth for admin** — swap `AdminTokenController.login` to use
  `FirebaseAuth.instance.signInWithEmailAndPassword(...)`, and have the
  backend verify the resulting ID token via Firebase Admin (replace the JWT
  middleware in `backend/lib/auth.dart`).
- **WhatsApp Cloud API** — replace the `wa.me` link generation in
  `routes/admin/remind/index.dart` with a real WhatsApp Business send.
- **Image assets** — drop your own photos under `frontend/web/photos/` and
  reference them as `/photos/...` in `core/config/love_story.dart`.

Built with ❤ in Flutter.

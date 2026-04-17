# Wedding image assets

Drop your photos in this folder. File names matter — they must match what the
app expects. After adding/replacing images, just hot-restart (`R`) the app.

```
assets/images/
├── niece.jpg                 # the "little inviter" photo
└── gallery/
    ├── 1.jpg
    ├── 2.jpg
    ├── 3.jpg
    ├── 4.jpg
    ├── 5.jpg
    ├── 6.jpg
    ├── 7.jpg
    └── 8.jpg
```

## Rules / tips

- Any common format works: `.jpg`, `.jpeg`, `.png`, `.webp`. If you save as
  `.png` instead of `.jpg`, rename it to the exact name above (including
  extension) or update the paths in:
  - `lib/features/landing/widgets/inviter_section.dart` → `inviterImage`
  - `lib/core/config/love_story.dart` → `galleryImages`
- Keep the gallery photos roughly square for the cleanest grid. Aim for
  1200×1200 or 1600×1600 pixels.
- Keep the niece's photo close to square too (the app crops it into a circle).
- Total size: try to keep each image under ~400 KB for fast loading on
  Firebase Hosting. Use https://squoosh.app/ or https://tinypng.com/ to
  compress.
- Missing a file? The app shows a friendly placeholder instead of crashing,
  so you can ship incrementally.

## Adding more gallery photos

1. Drop `9.jpg`, `10.jpg`, … into `assets/images/gallery/`.
2. Add the same paths to the `galleryImages` list in
   `lib/core/config/love_story.dart`.
3. Hot-restart.

## Adding entirely new image slots

If you want to show extra photos elsewhere (e.g. parents' photos, a venue
photo), drop the file in `assets/images/` and reference it as
`assets/images/your-file.jpg` in your widget. The `assets/images/` folder is
registered in `pubspec.yaml`, so any file you drop here is available instantly.

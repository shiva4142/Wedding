# Wedding background music

Place your MP3 here as:

`wedding_song.mp3`

Copy from your PC, for example:

```powershell
Copy-Item "$env:USERPROFILE\Downloads\wedding_song.mp3" -Destination "d:\wedding\frontend\assets\audio\wedding_song.mp3"
```

Then run `flutter pub get` (if you changed `pubspec.yaml`) and **hot restart** (`R`).

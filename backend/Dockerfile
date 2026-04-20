# Build stage: produce a production Dart Frog server.
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub global activate dart_frog_cli
RUN dart pub global run dart_frog_cli:dart_frog build

# Compile to a fast native AOT binary
WORKDIR /app/build
RUN dart pub get --offline || dart pub get
RUN dart compile exe bin/server.dart -o bin/server

# Runtime: `scratch` + bundled Dart AOT runtime.
# Do NOT use `COPY /runtime/ /` on Debian/Ubuntu bases — their `/lib` is a
# symlink and BuildKit fails with "cannot copy to non-directory".
FROM scratch

COPY --from=build /runtime/ /
COPY --from=build /app/build/bin/server /app/bin/server

# CA bundle for HTTPS (Firestore REST, external APIs).
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

ENV PORT=8080
EXPOSE 8080
CMD ["/app/bin/server"]

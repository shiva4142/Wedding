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

# Runtime stage: tiny image with just the binary.
FROM debian:stable-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app/build/bin/server /app/bin/server
COPY --from=build /runtime/ /

ENV PORT=8080
EXPOSE 8080
CMD ["/app/bin/server"]

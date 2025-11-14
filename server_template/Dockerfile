# Build Flutter Application
FROM --platform=linux/amd64 instrumentisto/flutter:3.35.7 AS builder
WORKDIR /app

# Copy models dependency first
RUN mkdir /APPNAME_models
COPY APPNAME_models/pubspec.* /APPNAME_models/
COPY pubspec.* ./
RUN flutter pub get

# Copy models and server code
COPY APPNAME_models /APPNAME_models/
COPY . .

# Build the server
RUN flutter clean && flutter pub get
RUN flutter build linux --release

# Build Server Runtime
FROM --platform=linux/amd64 ubuntu:24.04
RUN apt-get update && apt-get install -y \
    wget \
    xvfb \
    libgtk-3-0 \
    libegl1 \
    libgles2 \
    imagemagick && \
    rm -rf /var/lib/apt/lists/*

RUN ldconfig

WORKDIR /app
COPY --from=builder /app/build/linux/x64/release/bundle ./bundle

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib:/usr/lib:

# Find the executable name dynamically
RUN find ./bundle -type f -executable ! -name "*.so" -printf "%f\n" > executable_name.txt

EXPOSE 8080

CMD xvfb-run -a ./bundle/$(cat executable_name.txt)

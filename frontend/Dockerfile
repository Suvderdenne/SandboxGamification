FROM cirrusci/flutter:stable

WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN flutter pub get

# Copy project files
COPY . .

# Enable web
RUN flutter config --enable-web

# Expose port
EXPOSE 8080

# Run flutter web
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080", "--web-hostname", "0.0.0.0"]

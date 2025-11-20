FROM cirrusci/flutter:stable

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install required Android SDK components
RUN yes | sdkmanager "build-tools;30.0.3" "platforms;android-31"

# Create non-root user with UID/GID 1000 to match host user
RUN groupadd -g 1000 flutter && useradd -u 1000 -g flutter -m -d /home/flutter flutter

# Set up Flutter SDK permissions - make writable by any user for development
RUN chmod -R 777 /sdks/flutter

# Create app directory and set ownership
RUN mkdir -p /app && chown -R flutter:flutter /app

# Switch to non-root user
USER flutter

WORKDIR /app

# Accept Android licenses
RUN yes | flutter doctor --android-licenses || true

# Pre-cache Flutter dependencies
RUN flutter precache

ENTRYPOINT ["flutter"]

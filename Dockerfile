FROM cirrusci/flutter:stable

WORKDIR /app

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Accept Android licenses
RUN yes | flutter doctor --android-licenses || true

# Pre-cache Flutter dependencies
RUN flutter precache

ENTRYPOINT ["flutter"]

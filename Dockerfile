FROM ubuntu:22.04

ARG FLUTTER_VERSION=3.22.0
ARG ANDROID_SDK_VERSION=9477386
ARG ANDROID_BUILD_TOOLS_VERSION=34.0.0
ARG ANDROID_PLATFORM_VERSION=34

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android-sdk
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}:${PATH}"
ENV CHROME_EXECUTABLE=/usr/bin/google-chrome

RUN apt-get update && apt-get install -y \
    curl git wget unzip xz-utils zip libglu1-mesa \
    openjdk-17-jdk clang cmake ninja-build pkg-config \
    libgtk-3-dev liblzma-dev libstdc++-12-dev gnupg ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip -O /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools \
    && mv /tmp/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm /tmp/cmdline-tools.zip

RUN yes | sdkmanager --licenses \
    && sdkmanager \
        "platform-tools" \
        "platforms;android-${ANDROID_PLATFORM_VERSION}" \
        "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
    https://github.com/flutter/flutter.git ${FLUTTER_HOME}

RUN flutter config --no-analytics \
    && flutter config --enable-web \
    && flutter precache --android --web \
    && flutter doctor --android-licenses || true

WORKDIR /workspace

RUN useradd -ms /bin/bash developer \
    && chown -R developer:developer ${FLUTTER_HOME} \
    && chown -R developer:developer ${ANDROID_HOME}

USER developer

RUN flutter pub cache repair || true

EXPOSE 8080

CMD ["flutter", "run", "--web-port=8080", "--web-hostname=0.0.0.0"]

#
# GitLab CI Android Runner
#
#
FROM openjdk:alpine

ENV ANDROID_BUILD_TOOLS "25.0.1"
ENV ANDROID_SDK_TOOLS "25.2.3"
ENV ANDROID_SYS_IMG "x86_64"
ENV ANDROID_HOME "/android-sdk"
ENV PATH=$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Prepare environment
RUN apk add --no-cache --update ca-certificates openssl && update-ca-certificates

# Install sdk tools
RUN wget -O android-sdk.zip https://dl.google.com/android/repository/tools_r${ANDROID_SDK_TOOLS}-linux.zip
RUN unzip android-sdk.zip -d $ANDROID_HOME
RUN rm android-sdk.zip

# Add tools from travis
ADD https://raw.githubusercontent.com/appunite/docker/eacea57245e95f112c55c41b41d2c0cf218fd334/android-java8/tools/android-accept-licenses.sh /usr/local/bin/android-accept-licenses
RUN chmod +x /usr/local/bin/android-accept-licenses

ADD https://raw.githubusercontent.com/travis-ci/travis-cookbooks/ca800a93071a603745a724531c425a41493e70ff/community-cookbooks/android-sdk/files/default/android-wait-for-emulator /usr/local/bin/android-wait-for-emulator
RUN chmod +x /usr/local/bin/android-wait-for-emulator

# Update platform tools
RUN update_sdk platform-tools

# Update build tools
RUN update_sdk build-tools-${ANDROID_BUILD_TOOLS}

# Update SDKs
RUN update_sdk android-24
RUN update_sdk android-23
RUN update_sdk android-22

# Update emulators
RUN update_sdk sys-img-${ANDROID_SYS_IMG}-android-24
RUN update_sdk sys-img-${ANDROID_SYS_IMG}-android-23
RUN update_sdk sys-img-${ANDROID_SYS_IMG}-android-22

# Update extra
RUN update_sdk extra-android-m2repository
RUN update_sdk extra-google-m2repository
RUN update_sdk extra-google-google_play_services

RUN uname -m

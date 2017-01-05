#
# GitLab CI Android Runner
#
#
FROM openjdk:8-jdk

ENV ANDROID_BUILD_TOOLS "25.0.1"
ENV ANDROID_SDK_TOOLS "25.2.4"
ENV ANDROID_HOME "/android-sdk"
ENV PATH=$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Prepare dependencies
RUN mkdir $ANDROID_HOME \
  && apt-get update --yes \
  && apt-get install --yes wget tar unzip libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 libqt5widgets5 \
  && apt-get clean \
  && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install sdk tools
RUN wget -O android-sdk.zip https://dl.google.com/android/repository/tools_r${ANDROID_SDK_TOOLS}-linux.zip \
  && unzip -q android-sdk.zip -d $ANDROID_HOME \
  && rm android-sdk.zip

# Add tools from travis
ADD https://raw.githubusercontent.com/appunite/docker/eacea57245e95f112c55c41b41d2c0cf218fd334/android-java8/tools/android-accept-licenses.sh /usr/local/bin/android-accept-licenses
ADD https://raw.githubusercontent.com/travis-ci/travis-cookbooks/ca800a93071a603745a724531c425a41493e70ff/community-cookbooks/android-sdk/files/default/android-wait-for-emulator /usr/local/bin/android-wait-for-emulator
RUN chmod +x /usr/local/bin/android-accept-licenses \
  && chmod +x /usr/local/bin/android-wait-for-emulator

# Add own tools
COPY update_sdk /usr/local/bin/update_sdk
RUN chmod +x /usr/local/bin/update_sdk

# Update platform and build tools
RUN update_sdk platform-tools \
  && update_sdk build-tools-${ANDROID_BUILD_TOOLS}

# Update SDKs
RUN update_sdk android-24 \
  && update_sdk android-23

# Update emulators
RUN update_sdk sys-img-armeabi-v7a-google_apis-24 \
  && update_sdk sys-img-armeabi-v7a-google_apis-23

# Update extra
RUN update_sdk extra-android-m2repository \
  && update_sdk extra-google-m2repository \
  && update_sdk extra-google-google_play_services

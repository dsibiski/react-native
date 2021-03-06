# inspired by https://github.com/Originate/guide/blob/master/android/guide/Continuous%20Integration.md

function getAndroidSDK {
  export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$PATH"

  DEPS="$ANDROID_HOME/installed-dependencies"

  if [ ! -e $DEPS ]; then
    echo y | android update sdk --no-ui --all --filter "tools" &&
    echo y | android update sdk --no-ui --all --filter "platform-tools" &&
    echo y | android update sdk --no-ui --all --filter "build-tools" &&
    echo y | android update sdk --no-ui --all --filter "android-19" &&
    echo y | android update sdk -a --no-ui --filter sys-img-armeabi-v7a-android-19,sys-img-x86_64-android-19 &&
    echo y | android update sdk --no-ui --all --filter "extra-google-m2repository" &&
    echo y | android update sdk --no-ui --all --filter "extra-google-google_play_services" &&
    echo y | android update sdk --no-ui --all --filter "extra-android-support" &&
    echo y | android update sdk --no-ui --all --filter "extra-android-m2repository" &&
    echo no | android create avd -n testAVD -f -t android-19 --abi default/armeabi-v7a &&
    touch $DEPS
  fi
}

function waitForAVD {
  local bootanim=""
  export PATH=$(dirname $(dirname $(which android)))/platform-tools:$PATH
  until [[ "$bootanim" =~ "stopped" ]]; do
    sleep 5
    bootanim=$(adb -e shell getprop init.svc.bootanim 2>&1)
    echo "emulator status=$bootanim"
  done
}

function retry3 {
  local n=1
  local max=3
  local delay=1
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        echo "The command has failed after $n attempts." >&2
        return 1
      fi
    }
  done
}

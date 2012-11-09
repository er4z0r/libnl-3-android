LOCAL_PATH := $(call my-dir)

# Optimizations
#APP_OPTIM := release
APP_OPTIM := debug

# Build target
APP_ABI := armeabi
#APP_ABI := armeabi armeabi-v7a x86 mips
#APP_ABI := all

# API 9 has RW Mutex implementation in pthread lib
APP_PLATFORM := android-9
#APP_PLATFORM := android-14

APP_MODULES := nl-3
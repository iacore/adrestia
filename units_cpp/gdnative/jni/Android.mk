# Android.mk
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := godot-cpp
LOCAL_SRC_FILES := ../godot-cpp/obj/local/$(TARGET_ARCH_ABI)/libgodot-cpp.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := gdexample
LOCAL_CPPFLAGS := -std=c++14
LOCAL_CPP_FEATURES := rtti exceptions
LOCAL_LDLIBS := -llog

LOCAL_SRC_FILES += ../src/gdlibrary.cpp
LOCAL_SRC_FILES += ../src/gdexample.cpp

LOCAL_STATIC_LIBRARIES += godot-cpp

LOCAL_C_INCLUDES += $(LOCAL_PATH)/../godot-cpp/include/core
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../godot-cpp/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../godot_headers

include $(BUILD_SHARED_LIBRARY)

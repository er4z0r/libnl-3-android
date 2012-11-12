LOCAL_PATH := $(call my-dir)
JNI_PATH := $(LOCAL_PATH)
MAIN_PATH := $(LOCAL_PATH)/../..
NL_LIB_PATH := $(MAIN_PATH)/lib

$(info Value of LOCAL_PATH is '$(LOCAL_PATH)')
$(info Value of MAIN_PATH is '$(MAIN_PATH)')
$(info Value of NL_LIB_PATH is '$(NL_LIB_PATH)')

# -----------------------------------------------------------------------------
# Creates subdirs list from given root (root is included) and append given
# suffix to each element 
#
# Function : make-subdirs-list-with-suffix
# Returns  : list of subdirs with suffix appended
# Usage    : $(call make-subdirs-wildcards,<DIR>,<SUFFIX>)
# -----------------------------------------------------------------------------
make-subdirs-list-with-suffix = $(addsuffix $2, $(sort $(dir $(wildcard $1/**/))))

# -----------------------------------------------------------------------------
# List all files with given extension(s) from given directory and all of subdirs.
# Returned list is root relative (that is contains files in form: ./subdir/file.ext) 
#
# Function : list-all
# Returns  : list of files relative to root
# Usage    : $(call list-all,<DIR>,<EXTENSIONS-LIST>)
# -----------------------------------------------------------------------------
list-all = $(subst $1, ., $(wildcard $(foreach ext,$2,$(call make-subdirs-list-with-suffix,$1,$(ext)))))


#
# Include System V search as static library
# Files are copied from https://github.com/android/platform_bionic/commit/21eab513e7eec280a7a8bcb9482a1a8b61e59442
#
-include $(LOCAL_PATH)/system-v-search/Android.mk

#
# Generate parser
#
$(info generating pktloc_grammar: $(shell (cd $(NL_LIB_PATH); lex --header-file=route/pktloc_grammar.h -o route/pktloc_grammar.c route/pktloc_grammar.l)))
$(info generating pktloc_syntax: $(shell (cd $(NL_LIB_PATH); yacc -d -o route/pktloc_syntax.c route/pktloc_syntax.y)))
$(info generating ematch_grammar: $(shell (cd $(NL_LIB_PATH); lex --header-file=route/cls/ematch_grammar.h -o route/cls/ematch_grammar.c route/cls/ematch_grammar.l)))
$(info generating ematch_syntax: $(shell (cd $(NL_LIB_PATH); yacc -d -o route/cls/ematch_syntax.c route/cls/ematch_syntax.y)))

#
# Define includes for all modules
#
# Android NDK misses some includes. They are copied from https://github.com/android/kernel_common/tree/android-3.4/include/
MY_INCLUDES := \
	$(JNI_PATH)/missing_include \
	$(JNI_PATH)/generated_include \
	$(MAIN_PATH)/include \
	$(NL_LIB_PATH) \
	$(NL_LIB_PATH)/route \
	$(NL_LIB_PATH)/route/cls

MY_CFLAGS := \
	-DSYSCONFDIR=\"$(sysconfdir)/libnl\"

$(info Value of MY_INCLUDES is '$(MY_INCLUDES)')

#
# nl-3
#
# everything remaining is relative to NL_LIB_PATH
LOCAL_PATH := $(NL_LIB_PATH)
include $(CLEAR_VARS)

LOCAL_MODULE := nl-3
LOCAL_SRC_FILES = \
	addr.c attr.c cache.c cache_mngr.c cache_mngt.c data.c \
	error.c handlers.c msg.c nl.c object.c socket.c utils.c \
	version.c

LOCAL_CFLAGS := $(MY_CFLAGS)
LOCAL_C_INCLUDES := $(MY_INCLUDES)
# other modules depending of nl-3 will get these exports:
LOCAL_EXPORT_CFLAGS := $(MY_CFLAGS)
LOCAL_EXPORT_C_INCLUDES := $(MY_INCLUDES)

include $(BUILD_SHARED_LIBRARY)

#
# nl-genl-3
#
include $(CLEAR_VARS)

LOCAL_MODULE := nl-genl-3
LOCAL_SRC_FILES := \
	$(call list-all,$(LOCAL_PATH),genl/*.c)

$(info Value of LOCAL_SRC_FILES is '$(LOCAL_SRC_FILES)')

LOCAL_SHARED_LIBRARIES = nl-3

include $(BUILD_SHARED_LIBRARY)

#
# nl-nf-3
#
include $(CLEAR_VARS)

LOCAL_MODULE := nl-nf-3
LOCAL_SRC_FILES := \
	$(call list-all,$(LOCAL_PATH),netfilter/*.c)

$(info Value of LOCAL_SRC_FILES is '$(LOCAL_SRC_FILES)')

LOCAL_SHARED_LIBRARIES = nl-3

include $(BUILD_SHARED_LIBRARY)

#
# nl-route-3
#
include $(CLEAR_VARS)

LOCAL_MODULE := nl-route-3
LOCAL_SRC_FILES := \
	$(call list-all,$(LOCAL_PATH),route/*.c) \
	$(call list-all,$(LOCAL_PATH),route/cls/*.c) \
	$(call list-all,$(LOCAL_PATH),route/cls/ematch/*.c) \
	$(call list-all,$(LOCAL_PATH),route/link/*.c) \
	$(call list-all,$(LOCAL_PATH),route/qdisc/*.c) \
	$(call list-all,$(LOCAL_PATH),route/fib_lookup/*.c)

$(info Value of LOCAL_SRC_FILES is '$(LOCAL_SRC_FILES)')

LOCAL_STATIC_LIBRARIES := system-v-search
LOCAL_SHARED_LIBRARIES := nl-3

include $(BUILD_SHARED_LIBRARY)

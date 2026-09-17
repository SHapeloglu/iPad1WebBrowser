TARGET := iphone:clang:6.1:5.0
ARCHS := armv7

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME := iPad1WebBrowser
iPad1WebBrowser_FILES := main.m AppDelegate.m BrowserViewController.m
iPad1WebBrowser_FRAMEWORKS := UIKit Foundation
iPad1WebBrowser_CFLAGS := -fno-objc-arc -Wall

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall iPad1WebBrowser 2>/dev/null || true"

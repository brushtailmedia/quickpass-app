#import <UIKit/UIKit.h>
#include "bindings/bindings.h"

// Privacy overlay: blur the key window whenever the app resigns active, so the app
// switcher snapshot, Control Center and incoming-call banners never show the form.
// iOS offers no API to block screenshots; this covers the snapshot cases only.
static UIVisualEffectView *privacyOverlay = nil;

static UIWindow *keyWindow(void) {
	for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
		if (![scene isKindOfClass:[UIWindowScene class]]) {
			continue;
		}
		for (UIWindow *window in ((UIWindowScene *)scene).windows) {
			if (window.isKeyWindow) {
				return window;
			}
		}
	}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	// Tauri may run without a scene delegate; fall back to the legacy window list.
	for (UIWindow *window in UIApplication.sharedApplication.windows) {
		if (window.isKeyWindow) {
			return window;
		}
	}
	return UIApplication.sharedApplication.windows.lastObject;
#pragma clang diagnostic pop
}

static void installPrivacyOverlay(void) {
	NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
	[center addObserverForName:UIApplicationWillResignActiveNotification
	                    object:nil
	                     queue:NSOperationQueue.mainQueue
	                usingBlock:^(NSNotification *note) {
		UIWindow *window = keyWindow();
		if (window == nil || privacyOverlay != nil) {
			return;
		}
		UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThickMaterial];
		privacyOverlay = [[UIVisualEffectView alloc] initWithEffect:blur];
		privacyOverlay.frame = window.bounds;
		privacyOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[window addSubview:privacyOverlay];
	}];
	[center addObserverForName:UIApplicationDidBecomeActiveNotification
	                    object:nil
	                     queue:NSOperationQueue.mainQueue
	                usingBlock:^(NSNotification *note) {
		[privacyOverlay removeFromSuperview];
		privacyOverlay = nil;
	}];
}

int main(int argc, char * argv[]) {
	installPrivacyOverlay();
	ffi::start_app();
	return 0;
}

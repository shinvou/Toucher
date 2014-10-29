//
//  Tweak.xm
//  Toucher
//
//  Created by Timm Kandziora on 29.10.14.
//  Copyright (c) 2014 Timm Kandziora. All rights reserved.
//

#import <substrate.h>

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <SpringBoard/SpringBoard.h>

#define settingsPath @"/var/mobile/Library/Preferences/com.shinvou.toucher.plist"

static BOOL toucherEnabled = YES;
static UIImage *image;
static UIImageView *imageView;

%hook UIWindow

- (void)sendEvent:(UIEvent *)event
{
	if (toucherEnabled) {
		UITouch *touch = [[event allTouches] anyObject];
		UITouchPhase phase = [touch phase];

		if (phase != UITouchPhaseEnded && phase != UITouchPhaseCancelled) {
			CGPoint location = [touch locationInView:self];
			imageView.center = location;
			[self addSubview:imageView];

			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.25];
			[imageView setAlpha:1.0];
			[UIView commitAnimations];
		} else {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.25];
			[imageView setAlpha:0.0];
			[UIView commitAnimations];
		}
	}

	%orig(event);
}

%end

static void ReloadSettings()
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

    if (settings) {
        if ([settings objectForKey:@"isEnabled"]) {
            toucherEnabled = [[settings objectForKey:@"isEnabled"] boolValue];
        }
    }

    [settings release];
}

%ctor {
	@autoreleasepool {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										(CFNotificationCallback)ReloadSettings,
										CFSTR("com.shinvou.toucher/reloadPreferences"),
										NULL,
										CFNotificationSuspensionBehaviorCoalesce);

		ReloadSettings();

		image = [UIImage imageWithContentsOfFile:@"/Library/Toucher/dot@2x.png"];
		imageView = [[UIImageView alloc] initWithImage:image];
		[imageView setAlpha:1.0];
	}
}

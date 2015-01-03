#import "../PS.h"

NSString *const tweakKey = @"NSEnabled";
NSString *const PREF_PATH = @"/var/mobile/Library/Preferences/com.PS.NoSquare.plist";
CFStringRef const PreferencesNotification = CFSTR("com.PS.NoSquare.prefs");
BOOL tweakEnabled;

%group iOS7

%hook PLCameraController

- (void)_setSupportedCameraModes:(NSArray *)modes
{
	if (tweakEnabled) {
		NSMutableArray *newModes = [NSMutableArray arrayWithArray:modes];
		[newModes removeObject:@4];
		%orig(newModes);
	} else
		%orig;
}

- (void)setCameraMode:(int)mode device:(int)device
{
	%orig(mode == 4 ? 0 : mode, device);
}

%end

%hook PLCameraView

- (void)setCameraMode:(int)mode
{
	%orig(mode == 4 ? 0 : mode);
}

%end

%end

%group iOS8

%hook CAMCaptureController

- (void)_setSupportedCameraModes:(NSArray *)modes
{
	if (tweakEnabled) {
		NSMutableArray *newModes = [NSMutableArray arrayWithArray:modes];
		[newModes removeObject:@4];
		%orig(newModes);
	} else
		%orig;
}

- (void)setCameraMode:(int)mode device:(int)device
{
	%orig(mode == 4 ? 0 : mode, device);
}

%end

%hook CAMCameraView

- (void)setCameraMode:(int)mode
{
	%orig(mode == 4 ? 0 : mode);
}

%end

%end

static void reloadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	CFPreferencesAppSynchronize(CFSTR("com.PS.NoSquare"));
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
	tweakEnabled = prefs[tweakKey] ? [prefs[tweakKey] boolValue] : YES;
}

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &reloadSettings, PreferencesNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
	reloadSettings(NULL, NULL, NULL, NULL, NULL);
	if (isiOS8Up) {
		%init(iOS8);
	} else {
		%init(iOS7);
	}
  	[pool drain];
}

// Ersatz - Replace any text system-wide!
// By Skitty

#import <UIKit/UIKit.h>
#import <rootless.h>

static NSString *bundleIdentifier = @"xyz.skitty.ersatz";
static NSString *settingsPath = ROOT_PATH_NS(@"/var/mobile/Library/Preferences/");

static BOOL enabled = YES;
static NSMutableDictionary *settings;
static NSMutableDictionary *keyedSettings;
static NSDictionary<NSString *, NSString *> *strings;

// Preference updates
void refreshPrefs() {
	CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else {
		settings = nil;
	}
	if (!settings) {
		settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@%@.plist", settingsPath, bundleIdentifier]];
	}

	keyedSettings = [[NSMutableDictionary alloc] init];
	strings = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *unsortedStrings = [[NSMutableDictionary alloc] init];
	for (NSDictionary *obj in settings[@"strings"]) {
		[strings setValue:obj[@"replacement"] forKey:obj[@"phrase"]];
		[keyedSettings setValue:obj forKey:obj[@"phrase"]];
	}
	// Sort phrases
	for (NSString *phrase in [[unsortedStrings allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
		[strings setValue:[unsortedStrings objectForKey:phrase] forKey:phrase];
	}
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  refreshPrefs();
}

// Replace strings
NSString *stringWithReplacement(NSString *origString, NSString *find, NSString *replace, BOOL caseSensitive) { // options
	NSString *newString;
	if (caseSensitive) {
		newString = [origString stringByReplacingOccurrencesOfString:find withString:replace];
	} else {
		newString = [origString stringByReplacingOccurrencesOfString:find withString:replace options:NSCaseInsensitiveSearch range:NSMakeRange(0, [origString length])];
	}
	return newString;
}
NSAttributedString *attributedStringWithReplacement(NSAttributedString *origString, NSString *find, NSString *replace) {
	NSMutableAttributedString *newString = [origString mutableCopy];
	while ([newString.mutableString containsString:find]) {
        NSRange range = [newString.mutableString rangeOfString:find];
		NSMutableAttributedString *replaceString = [[NSMutableAttributedString alloc] initWithString:replace];
		[newString enumerateAttributesInRange:range options:0 usingBlock:^(NSDictionary<NSAttributedStringKey, id> *attrs, NSRange range, BOOL *stop) {
			[replaceString addAttributes:attrs range:NSMakeRange(0, replaceString.length)];
		}];
        [newString replaceCharactersInRange:range withAttributedString:replaceString];
    }
	return [newString copy];
}

// Global text views
%hook UILabel

- (void)setText:(NSString *)text {
	if (enabled && self.tag != 317) {
		for (NSString *find in strings) {
			text = stringWithReplacement(text, find, [strings objectForKey:find], [[[keyedSettings objectForKey:find] objectForKey:@"caseSensitive"] boolValue]);
		}
	}
	%orig(text);
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
	if (enabled) {
		for (NSString *find in strings) {
			attributedText = attributedStringWithReplacement(attributedText, find, [strings objectForKey:find]);
		}
	}
	%orig(attributedText);
}

%end

%hook UITextView

- (void)setText:(NSString *)text {
	if (enabled) {
		for (NSString *find in strings) {
			text = stringWithReplacement(text, find, [strings objectForKey:find], [[[keyedSettings objectForKey:find] objectForKey:@"caseSensitive"] boolValue]);
		}
	}
	%orig(text);
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
	if (enabled) {
		for (NSString *find in strings) {
			attributedText = attributedStringWithReplacement(attributedText, find, [strings objectForKey:find]);
		}
	}
	%orig(attributedText);
}

%end

// App names
%hook SBApplication

- (void)setDisplayName:(id)text {
	if (enabled){
		for (NSString *find in strings) {
			text = stringWithReplacement(text, find, [strings objectForKey:find], [[[keyedSettings objectForKey:find] objectForKey:@"caseSensitive"] boolValue]);
		}
	}
	%orig(text);
}

- (id)displayName {
	if (enabled) {
		NSString *text = %orig;
		for (NSString *find in strings) {
			text = stringWithReplacement(text, find, [strings objectForKey:find], [[[keyedSettings objectForKey:find] objectForKey:@"caseSensitive"] boolValue]);
		}
		return text;
	}
	return %orig;
}

%end

// Folder names
%hook SBFolder

- (void)setDisplayName:(id)text {
	if (enabled) {
		for (NSString *find in strings) {
			text = stringWithReplacement(text, find, [strings objectForKey:find], [[[keyedSettings objectForKey:find] objectForKey:@"caseSensitive"] boolValue]);
		}
	}
	%orig(text);
}

- (id)displayName {
	if (enabled) {
		NSString *text = %orig;
		for (NSString *find in strings) {
			text = stringWithReplacement(text, find, [strings objectForKey:find], [[[keyedSettings objectForKey:find] objectForKey:@"caseSensitive"] boolValue]);
		}
		return text;
	}
	return %orig;
}

%end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, (CFStringRef)[NSString stringWithFormat:@"%@.prefschanged", bundleIdentifier], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	refreshPrefs();
}

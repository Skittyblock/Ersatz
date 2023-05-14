// EZPhraseListViewController.m

#import <CoreData/CoreData.h>
#import "EZPhraseListViewController.h"
#import "EZAddPhraseViewController.h"
#import "EZEditPhraseViewController.h"

static NSString *settingsPath = ROOT_PATH_NS(@"/var/mobile/Library/Preferences/xyz.skitty.ersatz.plist");

@implementation EZPhraseListViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = @"Ersatz";

	UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhrase)];
	self.navigationItem.rightBarButtonItem = plusButton;

	self.tableView = [[UITableView alloc] init];
	self.tableView.frame = self.view.bounds;
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.view addSubview:self.tableView];

	// Load settings
	CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("xyz.skitty.ersatz"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		_settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR("xyz.skitty.ersatz"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else {
		_settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
	}
	if (!_settings) {
		_settings = [[NSMutableDictionary alloc] init];
	}

	_settings[@"strings"] = [_settings[@"strings"] mutableCopy];

	[self sortSettings];
}

- (void)updateSettings {
	CFPreferencesSetAppValue((CFStringRef)@"strings", (CFPropertyListRef)_settings[@"strings"], CFSTR("xyz.skitty.ersatz"));
	if (@available(iOS 11.0, *)) {
		[_settings writeToURL:[NSURL fileURLWithPath:settingsPath] error:nil];
	} else {
		[_settings writeToFile:settingsPath atomically:YES];
	}
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("xyz.skitty.ersatz.prefschanged"), nil, nil, true);
}

- (void)sortSettings {
	_strings = [[NSMutableDictionary alloc] init];
	for (NSDictionary *obj in _settings[@"strings"]) {
		[_strings setValue:obj[@"replacement"] forKey:obj[@"phrase"]];
	}

	// Sort strings
	_sortedStrings = [[NSMutableDictionary alloc] init];
	NSArray *keys = [[_strings allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

	for (NSString *temp in keys) {
		NSString *first = [temp substringToIndex:1].uppercaseString;
		[_sortedStrings setValue:[[NSMutableArray alloc] init] forKey:first];
	}
	for (NSString *temp in keys) {
		[[_sortedStrings objectForKey:[temp substringToIndex:1].uppercaseString] addObject:temp];
	}
}

- (void)addPhrase {
	EZAddPhraseViewController *addController = [[EZAddPhraseViewController alloc] init];
	addController.parent = self;
	[[self navigationController] pushViewController:addController animated:YES];
}

- (void)addPhrase:(NSString *)phrase replacement:(NSString *)replacement caseSensitive:(BOOL)caseSensitive {
	if (!_settings[@"shownPrompt"]) {
		UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Notice" message:@"To apply this replacement system-wide, you'll need to respring. Alternatively, you can close and reopen any app to apply it there." preferredStyle:UIAlertControllerStyleAlert];

    	UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];

    	[alert addAction:okButton];

    	[self presentViewController:alert animated:YES completion:nil];
		_settings[@"shownPrompt"] = @YES;
	}
	if (!_settings[@"strings"]) {
		_settings[@"strings"] = [[NSMutableArray alloc] init];
	}
	[_settings[@"strings"] addObject:@{@"phrase": phrase, @"replacement": replacement, @"caseSensitive": @(caseSensitive)}];
	[self updateSettings];
	[self sortSettings];
	[self.tableView reloadData];
}

- (void)editPhrase:(NSString *)phrase newPhrase:(NSString *)newPhrase replacement:(NSString *)replacement caseSensitive:(BOOL)caseSensitive {
	NSDictionary *remove;
	for (NSDictionary *obj in _settings[@"strings"]) {
		if (obj[@"phrase"] == phrase) {
			remove = obj;
			break;
		}
	}
	if (remove) {
		[_settings[@"strings"] removeObject:remove];
		NSMutableDictionary *newObj = [remove mutableCopy];
		newObj[@"phrase"] = newPhrase;
		newObj[@"replacement"] = replacement;
		newObj[@"caseSensitive"] = @(caseSensitive);
		[_settings[@"strings"] addObject:newObj];
	}
	[self updateSettings];
	[self sortSettings];
	[self.tableView reloadData];
}

// Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[_sortedStrings allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[_sortedStrings objectForKey:[[[_sortedStrings allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[[_sortedStrings allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section].uppercaseString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	}

	cell.textLabel.tag = 317; // Prevents ersatz from overriding text
	cell.textLabel.text = [[_sortedStrings objectForKey:[[[_sortedStrings allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

	cell.detailTextLabel.tag = 317;
	cell.detailTextLabel.text = [_strings objectForKey:cell.textLabel.text];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *phrase = [[_sortedStrings objectForKey:[[[_sortedStrings allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	NSDictionary *dict;
	for (NSDictionary *obj in _settings[@"strings"]) {
		if (obj[@"phrase"] == phrase) {
			dict = obj;
		}
	}

	EZEditPhraseViewController *editController = [[EZEditPhraseViewController alloc] initWithDictionary:dict];
	editController.parent = self;
	[[self navigationController] pushViewController:editController animated:YES];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Swipe to delete
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *phrase = [[_sortedStrings objectForKey:[[[_sortedStrings allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	NSDictionary *remove;
	for (NSDictionary *obj in _settings[@"strings"]) {
		if (obj[@"phrase"] == phrase) {
			remove = obj;
			break;
		}
	}
	if (remove) [_settings[@"strings"] removeObject:remove];

	NSInteger rows = [self tableView:self.tableView numberOfRowsInSection:indexPath.section];

	[tableView beginUpdates];
	[self updateSettings];
	[self sortSettings];
	if (rows == 1) {
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
	} else {
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
	[tableView endUpdates];
}

@end

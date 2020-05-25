// EZPhraseListViewController.h

#import <Preferences/PSViewController.h>

@interface EZPhraseListViewController : PSViewController <UITableViewDataSource, UITableViewDelegate> {
	NSMutableDictionary *_settings;
	NSMutableDictionary *_strings;
	NSMutableDictionary<NSString *, NSMutableArray *> *_sortedStrings;
}

@property (nonatomic, retain) UITableView *tableView;

- (void)addPhrase:(NSString *)addPhrase replacement:(NSString *)replacement caseSensitive:(BOOL)caseSensitive;
- (void)editPhrase:(NSString *)phrase newPhrase:(NSString *)newPhrase replacement:(NSString *)replacement caseSensitive:(BOOL)caseSensitive;

@end

// EZAddPhraseViewController.h

#import <Preferences/PSViewController.h>
#import "EZPhraseListViewController.h"

@interface EZAddPhraseViewController : PSViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSString *target;
@property (nonatomic, retain) NSString *replacement;
@property (nonatomic, assign) BOOL caseSensitive;
@property (nonatomic, retain) EZPhraseListViewController *parent;
@property (nonatomic, retain) UITableView *tableView;

@end

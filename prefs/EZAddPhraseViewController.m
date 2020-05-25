// EZAddPhraseViewController.m

#import "EZAddPhraseViewController.h"
#import <Preferences/PSEditableTableCell.h>
#import <Preferences/PSSwitchTableCell.h>

@interface PSEditableTableCell (Missing)
- (UITextField *)textField;
@end

@implementation EZAddPhraseViewController

- (instancetype)init {
	self = [super init];

	if (self) {
		self.caseSensitive = YES;
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = @"Add Phrase";

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(addPhrase)];
    self.navigationItem.rightBarButtonItem = doneButton;
	self.navigationItem.rightBarButtonItem.enabled = NO;

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)addPhrase {
	[self.parent addPhrase:self.target replacement:self.replacement caseSensitive:self.caseSensitive];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)setTarget:(NSString *)target {
	_target = target;
	if (target && self.replacement && target != self.replacement) {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	} else {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (void)setReplacement:(NSString *)replacement {
	_replacement = replacement;
	if (replacement && self.target && replacement != self.target) {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	} else {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (void)setTargetValue:(id)value forSpecifier:(PSSpecifier *)specifier {
	self.target = value;
}

- (id)readTargetValue:(PSSpecifier *)specifier {
	return self.target;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 2;
		case 1:
			return 1;
	}
	return 0;
}

- (void)targetTextDidChange:(UITextField *)textField {
	self.target = textField.text;
}

- (void)replacementTextDidChange:(UITextField *)textField {
	self.replacement = textField.text;
}

- (void)caseSwitchDidChange:(UISwitch *)caseSwitch {
	self.caseSensitive = caseSwitch.on;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 0) {
		PSEditableTableCell *cell = [[PSEditableTableCell alloc] initWithStyle:1000 reuseIdentifier:@"EditTextCell"];
    	cell.textLabel.tag = 317;
		cell.textLabel.text = @"Phrase";
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textField.text = self.target;
		[cell.textField addTarget:self action:@selector(targetTextDidChange:) forControlEvents:UIControlEventEditingChanged];
		return cell;
	} else if (indexPath.section == 0 && indexPath.row == 1) {
		PSEditableTableCell *cell = [[PSEditableTableCell alloc] initWithStyle:1000 reuseIdentifier:@"EditTextCell"];
    	cell.textLabel.tag = 317;
		cell.textLabel.text = @"Replacement";
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textField.text = self.replacement;
		[cell.textField addTarget:self action:@selector(replacementTextDidChange:) forControlEvents:UIControlEventEditingChanged];
		[cell.textField setReturnKeyType:UIReturnKeyDone];
		return cell;
	} else if (indexPath.section == 1 && indexPath.row == 0) {
		PSSwitchTableCell *cell = [[PSSwitchTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CaseSwitchCell" specifier:nil];
   		cell.textLabel.tag = 317;
		cell.textLabel.text = @"Case Sensitive";
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell setValue:[NSNumber numberWithBool:self.caseSensitive]];
		[cell.control addTarget:self action:@selector(caseSwitchDidChange:) forControlEvents:UIControlEventValueChanged];
		return cell;
	}
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

// EZEditPhraseViewController.m

#import "EZEditPhraseViewController.h"

@implementation EZEditPhraseViewController

- (instancetype)initWithDictionary:(NSDictionary *)dict {
	self = [super init];

	if (self) {
		self.originalPhrase = dict[@"phrase"];
		self.target = dict[@"phrase"];
		self.replacement = dict[@"replacement"];
		self.caseSensitive = [dict[@"caseSensitive"] boolValue];
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = @"Edit Phrase";
}

- (void)addPhrase {
	[self.parent editPhrase:self.originalPhrase newPhrase:self.target replacement:self.replacement caseSensitive:self.caseSensitive];
	[self.navigationController popViewControllerAnimated:YES];
}

@end

// EZEditPhraseViewController.h

#import "EZAddPhraseViewController.h"

@interface EZEditPhraseViewController : EZAddPhraseViewController

@property (nonatomic, assign) NSString *originalPhrase;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

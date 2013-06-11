#import "RootViewController.h"
#import "LocalizedStrings.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)init
{
	self = [super init];
    
	if (self)
	{
		self.title = LS_ROOT_TITLE;
	}
    
	return self;
}

- (void)loadView
{
	[super loadView];
}

@end
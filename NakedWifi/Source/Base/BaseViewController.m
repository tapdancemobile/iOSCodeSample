#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor darkGrayColor];
}

@end
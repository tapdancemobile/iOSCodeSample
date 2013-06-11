#import "KIFTestStep+Integrations.h"

@implementation KIFTestStep (Integrations)

+ (id)stepToReset
{
	return [self stepWithDescription:@"Reset the application state." executionBlock:^(KIFTestStep *step, NSError **error) {
		NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
		[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
        
		KIFTestCondition(YES, error, @"Failed to reset some part of the application.");
        
		return KIFTestStepResultSuccess;
	}];
}

@end

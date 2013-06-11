#import "KIFTestScenario+TestScenario.h"
#import "KIFTestStep.h"
#import "KIFTestStep+Integrations.h"
#import "LocalizedStrings.h"

@implementation KIFTestScenario (TestScenario)

+ (id)scenarioToConfirmRootViewControllerPresence
{
	KIFTestScenario *scenario = [KIFTestScenario scenarioWithDescription:@"When the app starts, the user should be presented with the main view controller."];
    
	[scenario addStep:[KIFTestStep stepToReset]];
	[scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:LS_ROOT_TITLE]];
	
	// https://github.com/square/KIF#example

	return scenario;
}

@end

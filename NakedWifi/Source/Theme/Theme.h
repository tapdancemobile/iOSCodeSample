#import <Foundation/Foundation.h>

typedef enum
{
	TextStyleUndetermined = -1,
	TextStylePlain
} TextStyle;

typedef enum
{
	ButtonStyleUndetermined = -1,
	ButtonStylePlain
} ButtonStyle;

@protocol Theme <NSObject>

- (void)applyTextStyle:(TextStyle)style toLabel:(UILabel *)label;

- (void)applyTextStyle:(TextStyle)style toLabel:(UILabel *)label forControlState:(UIControlState)controlState;

- (void)applyTextStyle:(TextStyle)style toTextField:(UITextField *)textField;

- (void)applyButtonStyle:(ButtonStyle)style toButton:(UIButton *)button;

@end

@interface Theme : NSObject

+ (id <Theme>)currentTheme;

+ (void)setCurrentTheme:(id <Theme>)theme;

- (CGSize)UIOffsetValueToCGSize:(NSValue *)offsetValue;

@end

@interface NSDictionary (Theme)

- (void)forAttribute:(id)attribute performBlock:(void (^)(id value))block;

@end
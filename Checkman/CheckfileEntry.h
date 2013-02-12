#import <Foundation/Foundation.h>
#import "TaggedObject.h"

@interface CheckfileEntry : TaggedObject
+ (CheckfileEntry *)fromLine:(NSString *)line;

- (BOOL)isCommandEntry;
- (BOOL)isSeparatorEntry;
- (BOOL)isTitledSeparatorEntry;
@end

@interface CheckfileCommandEntry : CheckfileEntry
// e.g. 'command-name: bash command'
+ (CheckfileCommandEntry *)fromLine:(NSString *)line;

@property (nonatomic, retain) NSString *primaryContextName;
@property (nonatomic, retain) NSString *secondaryContextName;

- (id)initWithName:(NSString *)name command:(NSString *)command;
- (NSString *)name;
- (NSString *)command;
@end

@interface CheckfileSeparatorEntry : CheckfileEntry
// e.g. '#-'
+ (CheckfileSeparatorEntry *)fromLine:(NSString *)line;
@end

@interface CheckfileTitledSeparatorEntry : CheckfileEntry
// e.g. '#- title for a separator'
+ (CheckfileTitledSeparatorEntry *)fromLine:(NSString *)line;

- (id)initWithTitle:(NSString *)title;
- (NSString *)title;
@end

#import "CheckfileEntry.h"

@implementation CheckfileEntry
+ (CheckfileEntry *)fromLine:(NSString *)line {
    CheckfileEntry *entry = nil;
    (entry = [CheckfileCommandEntry fromLine:line]) ||
    (entry = [CheckfileSeparatorEntry fromLine:line]) ||
    (entry = [CheckfileTitledSeparatorEntry fromLine:line]);
    return entry;
}

+ (NSString *)_trimString:(NSString *)string {
    return [string stringByTrimmingCharactersInSet:
                [NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)isCommandEntry {
    return [self isKindOfClass:[CheckfileCommandEntry class]];
}

- (BOOL)isSeparatorEntry {
    return [self isKindOfClass:[CheckfileSeparatorEntry class]];
}

- (BOOL)isTitledSeparatorEntry {
    return [self isKindOfClass:[CheckfileTitledSeparatorEntry class]];
}
@end


@interface CheckfileCommandEntry ()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *command;
@end

@implementation CheckfileCommandEntry
@synthesize
    name = _name,
    command = _command,
    primaryContextName = _primaryContextName,
    secondaryContextName = _secondaryContextName;

+ (CheckfileCommandEntry *)fromLine:(NSString *)line {
    line = [self _trimString:line];
    if (line.length == 0 || [line characterAtIndex:0] == '#') return nil;

    NSArray *components = [line componentsSeparatedByString:@": "];
    if (components.count != 2) return nil;

    NSString *name = [components objectAtIndex:0];
    NSString *command = [components objectAtIndex:1];
    return [[CheckfileCommandEntry alloc] initWithName:name command:command];
}

- (id)initWithName:(NSString *)name command:(NSString *)command {
    if (self = [super init]) {
        self.name = name;
        self.command = command;
    }
    return self;
}

- (NSString *)description {
    return F(@"<CheckfileCommandEntry: %p> name=%@ command='%@'",
             self, self.name, self.command);
}
@end


@implementation CheckfileSeparatorEntry
+ (CheckfileSeparatorEntry *)fromLine:(NSString *)line {
    BOOL isComment = [[self _trimString:line] isEqualToString:@"#-"];
    return isComment ? [[self alloc] init] : nil;
}
@end


@interface CheckfileTitledSeparatorEntry ()
@property (nonatomic, strong) NSString *title;
@end

@implementation CheckfileTitledSeparatorEntry
@synthesize title = _title;

+ (CheckfileTitledSeparatorEntry *)fromLine:(NSString *)line {
    line = [self _trimString:line];

    NSArray *components = [line componentsSeparatedByString:@"#- "];
    if (components.count != 2) return nil;

    NSString *separator = [components objectAtIndex:0];
    if (separator.length != 0) return nil;

    NSString *title = [components objectAtIndex:1];
    return title.length ? [[self alloc] initWithTitle:title] : nil;
}

- (id)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        self.title = title;
    }
    return self;
}

- (NSString *)description {
    return F(@"<CheckfileTitledSeparatorEntry: %p> title=%@", self, self.title);
}
@end

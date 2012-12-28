#import "CheckfileEntry.h"

@implementation CheckfileEntry
+ (CheckfileEntry *)fromLine:(NSString *)line {
    CheckfileEntry *entry = nil;
    (entry = [CheckfileCommandEntry fromLine:line]) ||
    (entry = [CheckfileSeparatorEntry fromLine:line]);
    return entry;
}

- (BOOL)isCommandEntry {
    return [self isKindOfClass:[CheckfileCommandEntry class]];
}

- (BOOL)isSeparatorEntry {
    return [self isKindOfClass:[CheckfileSeparatorEntry class]];
}
@end


@implementation CheckfileSeparatorEntry
+ (CheckfileSeparatorEntry *)fromLine:(NSString *)line {
    line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];    
    return [line isEqualToString:@"#-"] ? [[self alloc] init] : nil;
}
@end


@interface CheckfileCommandEntry ()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *command;
@end

@implementation CheckfileCommandEntry

@synthesize 
    name = _name,
    command = _command;

+ (CheckfileCommandEntry *)fromLine:(NSString *)line {
    line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];    
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
    return F(@"<CheckfileCommandEntry: %p> name=%@ command='%@'", self, self.name, self.command);
}
@end

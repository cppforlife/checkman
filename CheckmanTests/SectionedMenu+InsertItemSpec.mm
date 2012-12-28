#include "SectionedMenu.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SectionedMenu_InsertItemSpec)

const int sectionTag = 111;
__block NSMenuItem *insertedItem, *item0, *item1, *item2;
__block SectionedMenu *menu;

beforeEach(^{
    menu = [[SectionedMenu alloc] init];
    insertedItem = [[NSMenuItem alloc] init];
    item0 = [[NSMenuItem alloc] init];
    item1 = [[NSMenuItem alloc] init];
    item2 = [[NSMenuItem alloc] init];
});

void (^ensureItemAtIndex)(NSUInteger, NSMenuItem*) = ^(NSUInteger i, NSMenuItem *item){
    [menu.itemArray objectAtIndex:i] should be_same_instance_as(item);
};

describe(@"-insertItem:atIndex:inSectionWithTag:", ^{
    beforeEach(^{ [menu insertSectionWithTag:sectionTag atIndex:0]; });

    context(@"when inserting item into first position", ^{
        void (^insert)(void) = ^{ [menu insertItem:insertedItem atIndex:0 inSectionWithTag:sectionTag]; };

        context(@"when section is without items", ^{
            it(@"inserts new item into first position", ^{
                insert();
                ensureItemAtIndex(1, insertedItem);
            });
        });

        context(@"when section is with items", ^{
            beforeEach(^{
                [menu insertItem:item0 atIndex:0 inSectionWithTag:sectionTag];
                [menu insertItem:item1 atIndex:1 inSectionWithTag:sectionTag];
                insert();
            });

            it(@"inserts new item into first position", ^{
                ensureItemAtIndex(1, insertedItem);
            });

            it(@"pushes up item at insert position", ^{
                ensureItemAtIndex(2, item0);
            });

            it(@"pushes up item at above insert position", ^{
                ensureItemAtIndex(3, item1);
            });
        });
    });
    
    context(@"when inserting item into the middle of the section", ^{
        void (^insert)(void) = ^{ [menu insertItem:insertedItem atIndex:1 inSectionWithTag:sectionTag]; };

        beforeEach(^{
            [menu insertItem:item0 atIndex:0 inSectionWithTag:sectionTag];
            [menu insertItem:item1 atIndex:1 inSectionWithTag:sectionTag];
            [menu insertItem:item2 atIndex:2 inSectionWithTag:sectionTag];
            insert();
        });

        it(@"keeps item below insert position where it is", ^{
            ensureItemAtIndex(1, item0);
        });

        it(@"inserts new item at given position", ^{
            ensureItemAtIndex(2, insertedItem);
        });

        it(@"pushes up item at insert position", ^{
            ensureItemAtIndex(3, item1);
        });

        it(@"pushes up item at above insert position", ^{
            ensureItemAtIndex(4, item2);
        });
    });

    context(@"when inserting item at the end of the section", ^{
        void (^insert)(void) = ^{ [menu insertItem:insertedItem atIndex:1 inSectionWithTag:sectionTag]; };

        beforeEach(^{
            [menu insertItem:item0 atIndex:0 inSectionWithTag:sectionTag];
            insert();
        });

        it(@"keeps existing menu items at their positions", ^{
            ensureItemAtIndex(1, item0);
        });

        it(@"inserts new item at given position", ^{
            ensureItemAtIndex(2, insertedItem);
        });
    });
});

SPEC_END

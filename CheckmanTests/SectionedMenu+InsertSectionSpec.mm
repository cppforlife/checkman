#include "SectionedMenu.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SectionedMenu_InsertSectionSpec)

int insertedSectionTag = 999;
int sectionTag0 = 111,
    sectionTag1 = 222,
    sectionTag2 = 333;

__block NSMenuItem *item0, *item1, *item2;
__block SectionedMenu *menu;

beforeEach(^{
    menu = [[SectionedMenu alloc] init];
    item0 = [[NSMenuItem alloc] init];
    item1 = [[NSMenuItem alloc] init];
    item2 = [[NSMenuItem alloc] init];
});

void (^ensureTaggedSectionSeparatorAtIndex)(NSUInteger, int) = ^(NSUInteger i, int tag){
    NSMenuItem *item = [menu.itemArray objectAtIndex:i];
    item.isSeparatorItem should be_truthy;
    item.tag should equal(tag);
};

void (^ensureItemAtIndex)(NSUInteger, NSMenuItem*) = ^(NSUInteger i, NSMenuItem *item){
    [menu.itemArray objectAtIndex:i] should be_same_instance_as(item);
};

describe(@"-insertSectionWithTag:atIndex:", ^{
    context(@"when inserting section as first section", ^{
        void (^insert)(void) = ^{ [menu insertSectionWithTag:insertedSectionTag atIndex:0]; };

        context(@"when menu is empty", ^{
            it(@"inserts new 0th section separator", ^{
                insert();
                ensureTaggedSectionSeparatorAtIndex(0, insertedSectionTag);
            });
        });

        context(@"when menu contains sections without items", ^{
            beforeEach(^{
                [menu insertSectionWithTag:sectionTag0 atIndex:0];
                [menu insertSectionWithTag:sectionTag1 atIndex:1];
                insert();
            });

            it(@"inserts new 0th section", ^{
                ensureTaggedSectionSeparatorAtIndex(0, insertedSectionTag);
            });

            it(@"pushes up section at insert position", ^{
                ensureTaggedSectionSeparatorAtIndex(1, sectionTag0);
            });

            it(@"pushes up section at above insert position", ^{
                ensureTaggedSectionSeparatorAtIndex(2, sectionTag1);
            });
        });

        context(@"when menu contains sections with items", ^{
            beforeEach(^{
                [menu insertSectionWithTag:sectionTag0 atIndex:0];
                [menu insertItem:item0 atIndex:0 inSectionWithTag:sectionTag0];
                [menu insertSectionWithTag:sectionTag1 atIndex:1];
                [menu insertItem:item1 atIndex:0 inSectionWithTag:sectionTag1];
                insert();
            });

            it(@"inserts new 0th section separator", ^{
                ensureTaggedSectionSeparatorAtIndex(0, insertedSectionTag);
            });

            it(@"pushes up section at insert position", ^{
                ensureTaggedSectionSeparatorAtIndex(1, sectionTag0);
            });

            it(@"pushes up items from section at insert position", ^{
                ensureItemAtIndex(2, item0);
            });

            it(@"pushes up section at above insert position", ^{
                ensureTaggedSectionSeparatorAtIndex(3, sectionTag1);
            });

            it(@"pushes up items from section above insert position", ^{
                ensureItemAtIndex(4, item1);
            });
        });
    });

    context(@"when inserting section in the middle of the menu", ^{
        void (^insert)(void) = ^{ [menu insertSectionWithTag:insertedSectionTag atIndex:1]; };

        context(@"when menu is empty", ^{
            it(@"raises an exception", ^{
                // ^{ insert(); } should raise_exception;
            });
        });

        context(@"when menu contains sections without items", ^{
            beforeEach(^{
                [menu insertSectionWithTag:sectionTag0 atIndex:0];
                [menu insertSectionWithTag:sectionTag1 atIndex:1];
                [menu insertSectionWithTag:sectionTag2 atIndex:2];
                insert();
            });

            it(@"keeps section below insert position where it is", ^{
                ensureTaggedSectionSeparatorAtIndex(0, sectionTag0);
            });

            it(@"inserts new section at insert position", ^{
                ensureTaggedSectionSeparatorAtIndex(1, insertedSectionTag);
            });

            it(@"pushes up section at insert position", ^{
                ensureTaggedSectionSeparatorAtIndex(2, sectionTag1);
            });

            it(@"pushes up section at above insert position", ^{
                ensureTaggedSectionSeparatorAtIndex(3, sectionTag2);
            });
        });

        context(@"when menu contains sections with items", ^{
            beforeEach(^{
                [menu insertSectionWithTag:sectionTag0 atIndex:0];
                [menu insertItem:item0 atIndex:0 inSectionWithTag:sectionTag0];
                [menu insertSectionWithTag:sectionTag1 atIndex:1];
                [menu insertItem:item1 atIndex:0 inSectionWithTag:sectionTag1];
                [menu insertSectionWithTag:sectionTag2 atIndex:2];
                [menu insertItem:item2 atIndex:0 inSectionWithTag:sectionTag2];
                insert();
            });

            it(@"keeps section below insert position where it is", ^{
                ensureTaggedSectionSeparatorAtIndex(0, sectionTag0);
            });

            it(@"keeps items from section below insert position", ^{
                ensureItemAtIndex(1, item0);
            });

            it(@"inserts new section at given position", ^{
                ensureTaggedSectionSeparatorAtIndex(2, insertedSectionTag);
            });

            it(@"pushes up section at insert position", ^{
                ensureTaggedSectionSeparatorAtIndex(3, sectionTag1);
            });

            it(@"pushes up items from section at insert position", ^{
                ensureItemAtIndex(4, item1);
            });

            it(@"pushes up section at above insert position", ^{
                ensureTaggedSectionSeparatorAtIndex(5, sectionTag2);
            });

            it(@"pushes up items from section above insert position", ^{
                ensureItemAtIndex(6, item2);
            });
        });
    });
});

SPEC_END

#include "SectionedMenu.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SectionedMenu_RemoveSectionSpec)

int tag0 = 111,
    tag1 = 222,
    tag2 = 333;

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

describe(@"-removeSectionWithTag:", ^{
    context(@"when removing first section", ^{
        void (^remove)(void) = ^{ [menu removeSectionWithTag:tag0]; };

        context(@"when menu has only one section", ^{
            context(@"when section is without items", ^{
                it(@"empties out menu", ^{
                    [menu insertSectionWithTag:tag0 atIndex:0];
                    remove();
                    menu.numberOfItems should equal(0);
                });
            });

            context(@"when section is with items", ^{
                it(@"empties out menu and its items", ^{
                    [menu insertSectionWithTag:tag0 atIndex:0];
                    [menu insertItem:item0 atIndex:0 inSectionWithTag:tag0];
                    remove();
                    menu.numberOfItems should equal(0);
                });
            });
        });

        context(@"when menu has more than one section", ^{
            context(@"when sections are without items", ^{
                beforeEach(^{
                    [menu insertSectionWithTag:tag0 atIndex:0];
                    [menu insertSectionWithTag:tag1 atIndex:1];
                    remove();
                });
                
                it(@"removes section", ^{
                    menu.numberOfItems should equal(1);
                });
                
                it(@"pushes down above section", ^{
                    ensureTaggedSectionSeparatorAtIndex(0, tag1);
                });
            });

            context(@"when sections are with items", ^{
                beforeEach(^{
                    [menu insertSectionWithTag:tag0 atIndex:0];
                    [menu insertItem:item0 atIndex:0 inSectionWithTag:tag0];
                    [menu insertSectionWithTag:tag1 atIndex:1];
                    [menu insertItem:item1 atIndex:0 inSectionWithTag:tag1];
                    remove();
                });

                it(@"removes section and its items", ^{
                    menu.numberOfItems should equal(2);
                });

                it(@"pushes down above section", ^{
                    ensureTaggedSectionSeparatorAtIndex(0, tag1);
                });

                it(@"pushes down items from section above", ^{
                    ensureItemAtIndex(1, item1);
                });
            });
        });
    });

    context(@"when removing section from the middle of the menu", ^{
        void (^remove)(void) = ^{ [menu removeSectionWithTag:tag1]; };

        context(@"when sections are without items", ^{
            beforeEach(^{
                [menu insertSectionWithTag:tag0 atIndex:0];
                [menu insertSectionWithTag:tag1 atIndex:1];
                [menu insertSectionWithTag:tag2 atIndex:2];
                remove();
            });
            
            it(@"keeps section below given position", ^{
                ensureTaggedSectionSeparatorAtIndex(0, tag0);
            });
            
            it(@"removes section at given position", ^{
                menu.numberOfItems should equal(2);
            });
            
            it(@"pushes down above section", ^{
                ensureTaggedSectionSeparatorAtIndex(1, tag2);
            });
        });
        
        context(@"when sections are with items", ^{
            beforeEach(^{
                [menu insertSectionWithTag:tag0 atIndex:0];
                [menu insertItem:item0 atIndex:0 inSectionWithTag:tag0];
                [menu insertSectionWithTag:tag1 atIndex:1];
                [menu insertItem:item1 atIndex:0 inSectionWithTag:tag1];
                [menu insertSectionWithTag:tag2 atIndex:2];
                [menu insertItem:item2 atIndex:0 inSectionWithTag:tag2];
                remove();
            });

            it(@"keeps section below given position", ^{
                ensureTaggedSectionSeparatorAtIndex(0, tag0);
            });

            it(@"keeps itesm from section below", ^{
                ensureItemAtIndex(1, item0);
            });

            it(@"removes section and its items at given position", ^{
                menu.numberOfItems should equal(4);
            });

            it(@"pushes down above section", ^{
                ensureTaggedSectionSeparatorAtIndex(2, tag2);
            });

            it(@"pushes down items from section avove", ^{
                ensureItemAtIndex(3, item2);
            });
        });
    });

    context(@"when removing section from the end of the menu", ^{
        void (^remove)(void) = ^{ [menu removeSectionWithTag:tag1]; };
        
        context(@"when sections are without items", ^{
            beforeEach(^{
                [menu insertSectionWithTag:tag0 atIndex:0];
                [menu insertSectionWithTag:tag1 atIndex:1];
                remove();
            });

            it(@"keeps section below given position where they are", ^{
                ensureTaggedSectionSeparatorAtIndex(0, tag0);
            });
            
            it(@"removes section at given position", ^{
                menu.numberOfItems should equal(1);
            });
        });

        context(@"when sections are with items", ^{
            beforeEach(^{
                [menu insertSectionWithTag:tag0 atIndex:0];
                [menu insertItem:item0 atIndex:0 inSectionWithTag:tag0];
                [menu insertSectionWithTag:tag1 atIndex:1];
                [menu insertItem:item1 atIndex:0 inSectionWithTag:tag1];
                remove();
            });

            it(@"keeps section below given position where they are", ^{
                ensureTaggedSectionSeparatorAtIndex(0, tag0);
            });

            it(@"keeps items from section below given position", ^{
                ensureItemAtIndex(1, item0);
            });

            it(@"removes section and its items at given position", ^{
                menu.numberOfItems should equal(2);
            });
        });
    });
});

SPEC_END

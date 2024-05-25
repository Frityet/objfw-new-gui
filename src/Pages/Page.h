#include "common.h"

#pragma clang assume_nonnull begin

@protocol Page

- (OUIControl *)render;
- (void)doActionWithTitle: (OFString *)title window: (OUIWindow *)window;

@property(readonly) OFString *title;

@end

static OUIButton *actionButton(id<Page> page)
{
    OUIButton *button = [OUIButton buttonWithLabel: @"Create"];
    button.onChanged = ^(OUIControl *) {
        #pragma clang diagnostic ignored "-Warc-retain-cycles"
        weak OUIControl *root = button;
        #pragma clang diagnostic error "-Warc-retain-cycles"
        while (root.parent != nil) {
            root = root.parent;
        }

        if (![root isKindOfClass: OUIWindow.class]) {
            @throw [OFInvalidArgumentException exception];
        }

        [page doActionWithTitle: page.title window: (OUIWindow *)root];
    };
    return button;
}

#pragma clang assume_nonnull end

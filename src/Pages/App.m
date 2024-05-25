#include "App.h"

@implementation AppPage {
    OUIEntry *titleEntry;
}

- (OFString *)title
{ return titleEntry.text; }

- (OUIControl *)render
{
    auto vbox = [OUIBox verticalBox];
    vbox.padded = true;
    {

    }
    return vbox;
}

- (void)doActionWithTitle:(OFString *)title window:(nonnull OUIWindow *)window
{
    @throw [OFNotImplementedException exceptionWithSelector: _cmd object: self];
}

@end

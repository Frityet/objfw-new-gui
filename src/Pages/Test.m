#include "Test.h"

@implementation TestPage

- (OUIControl *)render
{
    auto vbox = [OUIBox verticalBox];
    vbox.padded = true;
    {

    }
    return vbox;
}

- (void)doActionWithTitle:(OFString *)title
{

}

@end
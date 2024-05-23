#include "Page.h"

@implementation OUIEntry(LabelExtensions)

+ (OUIBox *)entryWithLabel: (OFString *)labelText placeholder: (OFString *)placeholder
{
    auto hbox = [OUIBox horizontalBox];
    {
        auto label = [OUILabel labelWithText: labelText];
        [hbox appendControl: label];

        [hbox appendControl: [OUISeperator horizontalSeperator] stretchy: true];

        auto entry = [OUIEntry entry];
        entry.text = placeholder;
        [hbox appendControl: entry];
    }
    return hbox;
}

@end

@implementation OUIControl(CentredExtensions)

- (OUIBox *)centered
{
    auto hbox = [OUIBox horizontalBox];
    {
        [hbox appendControl: [OUISeperator horizontalSeperator] stretchy: true];
        [hbox appendControl: self];
        [hbox appendControl: [OUISeperator horizontalSeperator] stretchy: true];
    }
    return hbox;
}

@end

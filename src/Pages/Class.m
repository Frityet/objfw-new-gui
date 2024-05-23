#include "Class.h"

#import "PropertyList.h"

@interface OUIControl(ParentExtensions)

- (OUIControl *nilable)parent;

@end

@implementation OUIControl(ParentExtensions)

- (OUIControl *nilable)parent
{
    uiControl *parent = uiControlParent(uiControl(self.control));
    if (parent == NULL)
        return nil;
    auto ctl = [[OUIControl alloc] init];
    ctl->_control = parent;
    return ctl;
}

@end

@implementation ClassPage {
    PropertyListModel *_model;
}

- (instancetype)init
{
    self = [super init];

    _model = [[PropertyListModel alloc] init];

    return self;
}

- (OUIControl *)render
{
    auto vbox = [OUIBox verticalBox];
    vbox.padded = true;
    {
        [vbox appendControl: [OUIEntry entryWithLabel: @"Superclass" placeholder: @"OFObject"]];
        auto propBox = [OUIBox verticalBox];
        propBox.padded = true;
        {
            //the same thing without tables
            const auto renderProp = ^(Property *property, OUIBox *propBox) {
                auto hbox = [OUIBox horizontalBox];
                hbox.padded = true;
                {
                    auto vbox = [OUIBox verticalBox];
                    {
                        [vbox appendControl: [OUIEntry entryWithLabel: @"Name" placeholder: property.name]];
                        [vbox appendControl: [OUIEntry entryWithLabel: @"Type" placeholder: property.type]];
                        [vbox appendControl: [OUIEntry entryWithLabel: @"Attributes" placeholder: concat(property.attributes, @", ")]];
                    }
                    [hbox appendControl: vbox];

                    auto index = propBox.childCount;
                    auto button = [OUIButton buttonWithLabel: @"Remove"];
                    button.onChanged = ^(OUIControl *nonnil) {
                        [_model.properties removeObject: property];
                        [OFStdOut writeFormat: @"Removed property at index %zu\n", index];
                        [propBox delete: index];
                    };
                    [hbox appendControl: button];
                }
                [propBox appendControl: hbox];
            };

            for (Property *property in _model.properties)
                renderProp(property, propBox);

            auto button = [OUIButton buttonWithLabel: @"Add Property"];
            button.onChanged = ^(OUIControl *nonnil ctl) {
                [_model.properties addObject: [Property propertyWithName: @"myProperty" type: @"OFObject *" attributes: [@[ @"readonly" ] mutableCopy]]];
                [OFStdOut writeFormat: @"Added property: %@\n", _model.properties.lastObject];
                auto propBox = (OUIBox *)ctl.parent;
                renderProp(_model.properties.lastObject, propBox);
            };

            [propBox appendControl: button];
        }
        [vbox appendControl: propBox];
    }
    return vbox;
}

- (void)doActionWithTitle: (OFString *)title
{
    [OFStdOut writeFormat: @"Action: %@\n", title];
}

@end


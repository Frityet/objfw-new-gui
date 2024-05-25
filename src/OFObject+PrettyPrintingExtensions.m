#include "OFObject+PrettyPrintingExtensions.h"

@implementation OFObject(PropertyNameExtensions)

- (OFArray<OFString *> *)propertyNames
{ return [self propertyNamesTerminatingAtClass: OFObject.class]; }

//gets all properties in the class and its superclasses
- (OFArray<OFString *> *)propertyNamesTerminatingAtClass: (Class)termClass
{
    auto names = [OFMutableArray<OFString *> array];

    auto cls = self.class;
    while (cls != termClass) {
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        if (properties == nilptr) {
            @throw [OFInitializationFailedException exceptionWithClass: cls];
        }

        for (unsigned int i = 0; i < count; i++)
            [names addObject: [OFString stringWithUTF8String: property_getName(properties[i])]];

        free(properties);
        cls = cls.superclass;
    }

    [names makeImmutable];
    return names;
}

@end


@implementation OFObject(PrettyPrintingExtensions)

- (OFString *)prettyDescriptionWithIndentation: (unsigned int)indentation class: (Class)cls
{
    //get all properties
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    if (properties == nilptr || count == 0) {
        return self.description;
    }

    auto description = [OFMutableString string];
    [description appendFormat: @"%@: {\n", cls, self];

    const auto mkIdent = ^(unsigned int i) {
        auto ident = [OFMutableString string];
        for (unsigned int j = 0; j < i; j++) {
            [ident appendString: @" "];
        }
        return ident;
    };

    OFString *fieldIdent = mkIdent(indentation + 4);

    if (cls.superclass && cls.superclass != OFObject.class) {
        [description appendFormat: @"%@super %@;\n", fieldIdent, [self prettyDescriptionWithIndentation: indentation + 4 class: cls.superclass]];
    }

    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        auto name = [OFString stringWithUTF8String: property_getName(property)];
        id val;
        @try {
            val = [self valueForKey: name];
        } @catch (OFUndefinedKeyException *e) {
            //get the offset of the ivar
            Ivar ivar = class_getInstanceVariable(cls, name.UTF8String);
            if (!ivar) {
                char buf[512] = {0};
                snprintf(buf, sizeof(buf), "_%s", name.UTF8String);
                ivar = class_getInstanceVariable(cls, buf);
            }

            if (ivar) {
                val = [OFString stringWithFormat: @"<undefined: %p>", (uintptr_t)self + ivar_getOffset(ivar)];
            } else {
                val = @"<undefined>";
            }
        }

        [description appendFormat: @"%@%@ = %@;\n", fieldIdent, name, [val respondsToSelector: @selector(prettyDescription)] ? [val prettyDescriptionWithIndentation: indentation + 4 class: [val class]] : val];
    }
    [description appendFormat: @"%@}", mkIdent(indentation)];
    free(properties);

    [description makeImmutable];
    return description;
}

- (OFString *)prettyDescription
{
    return [self prettyDescriptionWithIndentation: 0 class: self.class];
}

@end

#include "PropertyList.h"

#define auto __auto_type

@implementation Property

- (instancetype)initWithName: (OFString *)name type: (OFString *)type attributes: (OFMutableArray<OFString *> *)attributes
{
    self = [super init];

    _name = name;
    _type = type;
    _attributes = attributes;

    return self;
}

+ (instancetype)propertyWithName: (OFString *)name type: (OFString *)type attributes: (OFMutableArray<OFString *> *)attributes
{
    return [[self alloc] initWithName: name type: type attributes: attributes];
}

- (OFString *)description
{
    return [OFString stringWithFormat: @"<Property: %@ %@ %@>", _type, _name, _attributes];
}

@end

OFString *concat(OFArray<OFString *> *strs, OFString *separator)
{
    auto ret = [OFMutableString string];

    for (OFString *str in strs) {
        [ret appendString: str];
        [ret appendString: separator];
    }

    if (ret.length > 0) {
        [ret replaceCharactersInRange: OFMakeRange(ret.length - separator.length, separator.length) withString: @""];
    }

    return ret;
}


@implementation PropertyListModel

- (instancetype)init
{
    self = [super init];

    _properties = [@[
        [Property propertyWithName: @"name" type: @"OFString *" attributes: [@[ @"readonly" ] mutableCopy]],
    ] mutableCopy];

    return self;
}

- (int)columnCount
{
    return 3;
}

- (int)rowCount
{
    return self.properties.count;
}

- (uiTableValueType)typeForColumn: (int)column
{
    return uiTableValueTypeString;
}

- (id<TableValue>)valueForRow: (int)row column: (int)column
{
    auto property = self.properties[row];
    switch (column) {
        case 0:
            return [StringTableValue valueWithString: property.name];
        case 1:
            return [StringTableValue valueWithString: property.type];
        case 2:
            return [StringTableValue valueWithString: concat(property.attributes, @", ")];
        default:
            @throw [OFOutOfRangeException exception];
    }
}

- (void)setCellValueForRow: (int)row column: (int)column value: (StringTableValue *)value
{
    auto property = self.properties[row];
    switch (column) {
        case 0:
            property.name = value.value ?: @"";
            break;
        case 1:
            property.type = value.value ?: @"";
            break;
        case 2:
            property.attributes = [[value.value componentsSeparatedByString: @", "] mutableCopy];
            break;
        default:
            @throw [OFOutOfRangeException exception];
    }
}

@end

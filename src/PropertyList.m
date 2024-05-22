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

@end


@implementation PropertyListModel

- (instancetype)init
{
    self = [super init];

    _properties = [OFMutableArray array];

    return self;
}

- (int)columnCount
{
    //one for the property type, one for the property name, and the rest for the attributes
    size_t maxAttributes = 0;
    for (Property *property in self.properties) {
        if (property.attributes.count > maxAttributes) {
            maxAttributes = property.attributes.count;
        }
    }

    return 2 + maxAttributes;
}

- (int)rowCount
{
    return self.properties.count;
}

- (uiTableValueType)typeForColumn: (int)column
{
    return uiTableValueTypeString;
}

- (TableValue *)valueForRow: (int)row column: (int)column
{
    auto property = self.properties[row];
    switch (column) {
        case 0:
            return [StringTableValue valueWithString: property.type];
        case 1:
            return [StringTableValue valueWithString: property.name];
        default: {
            if (column - 2 < (int)property.attributes.count) {
                return [StringTableValue valueWithString: property.attributes[column - 2]];
            } else {
                @throw [OFOutOfRangeException exception];
            }
        }
    }
}

- (void)setCellValueForRow: (int)row column: (int)column value: (StringTableValue *)value
{
    auto property = self.properties[row];
    switch (column) {
        case 0:
            property.type = value.value;
            break;
        case 1:
            property.name = value.value;
            break;
        default: {
            if (column - 2 < (int)property.attributes.count) {
                property.attributes[column - 2] = value.value;
            } else {
                @throw [OFOutOfRangeException exception];
            }
        }
    }
}

@end

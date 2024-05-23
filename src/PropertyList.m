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
    return [OFString stringWithFormat: @"<Property: type = %@, name = %@, attributes = [ %@ ]>", _type, _name, [_attributes componentsJoinedByString: @", "]];
}

@end


@implementation PropertyListModel

- (instancetype)init
{
    self = [super init];

    _properties = [OFMutableArray array];
    _onDelete =  ^(int index) {};

    return self;
}

+ (instancetype)model
{ return [[self alloc] init]; }

- (int)columnCount
{
    return 4;
}

- (int)rowCount
{
    return self.properties.count;
}

- (uiTableValueType)typeForColumn: (int)column
{
    return uiTableValueTypeString;
}


- (nullable id<TableValue>)valueForRow: (int)row column: (int)column
{
    Property *property;
    @try {
        property = self.properties[row];
    } @catch (OFOutOfRangeException *e) {
        [OFStdErr writeFormat: @"Invalid row: %d\n", row];
        return [NilTableValue value];
    }
    switch (column) {
        case 0:
            return [StringTableValue valueWithString: property.name];
        case 1:
            return [StringTableValue valueWithString: property.type];
        case 2:
            return [StringTableValue valueWithString: [property.attributes componentsJoinedByString: @", "]];
        case 3:
            return [StringTableValue valueWithString: @"Remove"];
        default:
            [OFStdErr writeFormat: @"Invalid column: %d\n", column];
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

        //the remove button
        case 3:
            [self.properties removeObjectAtIndex: row];
            self.onDelete(row);
            break;
        default:
            @throw [OFOutOfRangeException exception];
    }
}

@end

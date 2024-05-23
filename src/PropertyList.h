#import <ObjFW/ObjFW.h>
#import <ObjUI/ObjUI.h>
#import "Table.h"

#pragma clang assume_nonnull begin

@interface Property : OFObject

@property OFString *name;
@property OFString *type;
@property OFMutableArray<OFString *> *attributes;

- (instancetype)initWithName: (OFString *)name type: (OFString *)type attributes: (OFMutableArray<OFString *> *)attributes;
+ (instancetype)propertyWithName: (OFString *)name type: (OFString *)type attributes: (OFMutableArray<OFString *> *)attributes;

@end

OFString *concat(OFArray<OFString *> *strs, OFString *separator);
@interface PropertyListModel : OFObject<TableModelDelegate>

@property(readonly) OFMutableArray<Property *> *properties;

@end

#pragma clang assume_nonnull end

#import "common.h"

@interface OFObject(PropertyNameExtensions)

- (OFArray<OFString *> *)propertyNames;
- (OFArray<OFString *> *)propertyNamesTerminatingAtClass: (Class)cls;

@end

@interface OFObject(PrettyPrintingExtensions)

- (OFString *)prettyDescription;
- (OFString *)prettyDescriptionWithIndentation: (unsigned int)indentation class: (Class)cls;

@end

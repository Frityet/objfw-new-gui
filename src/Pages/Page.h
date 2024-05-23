#include "common.h"

#pragma clang assume_nonnull begin

@protocol Page

- (OUIControl *)render;

- (void)doActionWithTitle: (OFString *)title;

@end

@interface OUIEntry(LabelExtensions)
+ (OUIBox *)entryWithLabel: (OFString *)labelText placeholder: (OFString *)placeholder;
@end

@interface OUIControl(CentredExtensions)
- (OUIBox *)centered;
@end

#pragma clang assume_nonnull end

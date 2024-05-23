#include "common.h"

#pragma clang assume_nonnull begin

@protocol Page

- (OUIControl *)render;

- (void)doActionWithTitle: (OFString *)title window: (OUIWindow *)window;

@end

#pragma clang assume_nonnull end

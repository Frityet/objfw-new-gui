#include <ObjFW/OFObject.h>
#import <ObjFW/ObjFW.h>
#import <ObjUI/ObjUI.h>

#pragma clang assume_nonnull begin

@interface TableValue<T> : OFObject {
    @protected uiTableValue *_backingValue;
}
@property(readonly) uiTableValue *backingValue;

@property(readonly) T value;
- (instancetype)initWithValue: (T)value;

@end

@interface StringTableValue : TableValue<OFString *>

+ (instancetype)valueWithString: (OFString *)string;

@end

@interface IntegerTableValue : TableValue<OFNumber *>

+ (instancetype)valueWithNumber: (OFNumber *)number;

@end

@protocol TableModelDelegate<OFObject>

- (int)columnCount;
- (int)rowCount;
- (uiTableValueType)typeForColumn:(int)column;
- (TableValue *)valueForRow:(int)row column:(int)column;
- (void)setCellValueForRow:(int)row column:(int)column value: (TableValue *)value;

@end

@interface TableModel : OFObject
@property(readonly) uiTableModel *model;
@property id<TableModelDelegate> delegate;

- (instancetype)initWithDelegate: (id<TableModelDelegate>)delegate;
+ (instancetype)modelWithDelegate: (id<TableModelDelegate>)delegate;

- (void)alertRowInsertedAt: (int)row;
- (void)alertRowMutatedAt: (int)row;
- (void)alertRowDeletedAt: (int)row;

@end

@interface Table : OUIControl

@property(readonly) TableModel *model;

@property bool headerIsVisible;
@property(nonatomic) void (^onRowClicked)(Table *table, int row);
@property(nonatomic) void (^onRowDoubleClicked)(Table *table, int row);

- (instancetype)initWithModel: (TableModel *)model;
+ (instancetype)tableDescribedByModel: (TableModel *)model;

- (void)appendTextColumnWithTitle: (OFString *)title textModelColumn: (int)column isEditable: (bool)editable;

@end

#pragma clang assume_nonnull end

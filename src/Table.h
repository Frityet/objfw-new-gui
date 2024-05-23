#import "common.h"

#pragma clang assume_nonnull begin

@protocol TableValue

@property(readonly) uiTableValue *backingValue;
@property(readonly) id value;

- (instancetype)initWithValue: (id)value;
@end

@interface StringTableValue : OFObject<TableValue>

+ (instancetype)valueWithString: (OFString *)string;

@end

@interface NilTableValue : OFObject<TableValue>

+ (instancetype)value;

@end

@interface IntegerTableValue : OFObject<TableValue>

+ (instancetype)valueWithNumber: (OFNumber *)number;

@end

@interface InvalidTableValueException : OFException

@property(readonly) uiTableValueType type;

- (instancetype)initWithType: (uiTableValueType)type;
+ (instancetype)exceptionWithType: (uiTableValueType)type;

@end

@protocol TableModelDelegate<OFObject>

- (int)columnCount;
- (int)rowCount;
- (uiTableValueType)typeForColumn:(int)column;
- (nullable id<TableValue>)valueForRow:(int)row column:(int)column;
- (void)setCellValueForRow:(int)row column:(int)column value: (nullable id<TableValue>)value;

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

- (void)appendTextColumnWithTitle: (OFString *)title column: (int)column isEditable: (bool)editable;
- (void)appendButtonColumnWithTitle: (OFString *)title column: (int)column;

@end

#pragma clang assume_nonnull end

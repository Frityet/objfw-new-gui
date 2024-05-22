#include "Table.h"

#define auto __auto_type

@implementation TableValue

- (instancetype)initWithValue: (id)value
{
    @throw [OFNotImplementedException exceptionWithSelector: @selector(initWithValue:) object: self];
}

- (void)dealloc
{
    uiFreeTableValue(_backingValue);
}

@end

@implementation StringTableValue

- (instancetype)initWithValue: (OFString *)value
{
    self = [super init];

    _backingValue = uiNewTableValueString([value UTF8String]);

    return self;
}

+ (instancetype)valueWithString: (OFString *)value
{ return [[self alloc] initWithValue: value]; }

@end

@implementation IntegerTableValue

- (instancetype)initWithValue: (OFNumber *)value
{
    self = [super init];

    _backingValue = uiNewTableValueInt(value.intValue);

    return self;
}

+ (instancetype)valueWithNumber: (OFNumber *)value
{ return [[self alloc] initWithValue: value]; }

@end

static int ui_table_model_handler_num_columns(uiTableModelHandler *handler, uiTableModel *model)
{
    auto self = (__weak TableModel **)(handler - 1);
    return (*self).delegate.columnCount;
}

static int ui_table_model_handler_num_rows(uiTableModelHandler *handler, uiTableModel *model)
{
    auto self = (__weak TableModel **)(handler - 1);
    return (*self).delegate.rowCount;
}

static uiTableValueType ui_table_model_handler_column_type(uiTableModelHandler *handler, uiTableModel *model, int column)
{
    auto self = (__weak TableModel **)(handler - 1);
    return [(*self).delegate typeForColumn: column];
}

static uiTableValue *ui_table_model_handler_cell_value(uiTableModelHandler *handler, uiTableModel *model, int row, int column)
{
    auto self = (__weak TableModel **)(handler - 1);
    return [(*self).delegate valueForRow: row column: column].backingValue;
}

static void ui_table_model_handler_set_cell_value(uiTableModelHandler *handler, uiTableModel *model, int row, int column, const uiTableValue *value)
{
    auto self = (__weak TableModel **)(handler - 1);
    [(*self).delegate setCellValueForRow: row column: column value: ({
        uiTableValueType t = uiTableValueGetType(value);

        TableValue *val;
        switch (t) {
        case uiTableValueTypeString:
            val = [StringTableValue valueWithString: [OFString stringWithUTF8String: uiTableValueString(value)]];
            break;
        case uiTableValueTypeInt:
            val = [IntegerTableValue valueWithNumber: [OFNumber numberWithInt: uiTableValueInt(value)]];
            break;
        default:
            @throw [OFInvalidArgumentException exception];
        }
        val;
    })];
}

@implementation TableModel {
    //hack to get around the fact that in the callbacks we only get a pointer to the handler.
    struct {
        __weak TableModel *self;
        uiTableModelHandler handler;
    } _handler;
}

- (instancetype)initWithDelegate:(id<TableModelDelegate>)delegate
{
    self = [super init];

    _delegate = delegate;
    _handler.handler = (uiTableModelHandler) {
        .NumColumns = ui_table_model_handler_num_columns,
        .NumRows = ui_table_model_handler_num_rows,
        .ColumnType = ui_table_model_handler_column_type,
        .CellValue = ui_table_model_handler_cell_value,
        .SetCellValue = ui_table_model_handler_set_cell_value,
    };
    _handler.self = self;

    return self;
}

+ (instancetype)modelWithDelegate:(id<TableModelDelegate>)delegate
{ return [[self alloc] initWithDelegate: delegate]; }

- (void)alertRowDeletedAt: (int)row
{
    uiTableModelRowDeleted(_model, row);
}

- (void)alertRowInsertedAt: (int)row
{
    uiTableModelRowInserted(_model, row);
}

- (void)alertRowMutatedAt: (int)row
{
    uiTableModelRowChanged(_model, row);
}

@end

@implementation Table

- (instancetype)initWithModel: (TableModel *)model
{
    self = [super init];

    _model = model;
    _control = uiControl(uiNewTable(&(uiTableParams) {
        .Model = model.model,
    }));

    return self;
}
+ (instancetype)tableDescribedByModel: (TableModel *)model
{ return [[self alloc] initWithModel: model]; }

- (bool)headerIsVisible
{
    return uiTableHeaderVisible(uiTable(_control));
}

- (void)setHeaderIsVisible:(bool)headerIsVisible
{
    uiTableHeaderSetVisible(uiTable(_control), headerIsVisible);
}

static void ui_table_on_row_clicked(uiTable *table, int i, void *data)
{
    auto self = (__bridge Table *)data;
    self.onRowClicked(self, i);
}

- (void)setOnRowClicked: (void (^)(Table * _Nonnull, int))onRowClicked
{
    _onRowClicked = onRowClicked;
    uiTableOnRowClicked(uiTable(_control), ui_table_on_row_clicked, (__bridge void *)self);
}

static void ui_table_on_row_double_clicked(uiTable *table, int i, void *data)
{
    auto self = (__bridge Table *)data;
    self.onRowDoubleClicked(self, i);
}

- (void)setOnRowDoubleClicked:(void (^)(Table * _Nonnull, int))onRowDoubleClicked
{
    _onRowDoubleClicked = onRowDoubleClicked;
    uiTableOnRowDoubleClicked(uiTable(_control), ui_table_on_row_double_clicked, (__bridge void *)self);
}

- (void)appendTextColumnWithTitle:(OFString *)title textModelColumn:(int)column isEditable:(bool)editable
{
    uiTableAppendTextColumn(uiTable(_control), [title UTF8String], column, editable ? uiTableModelColumnAlwaysEditable : uiTableModelColumnNeverEditable, nil);
}

@end

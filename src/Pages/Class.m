#include "Class.h"

#import "PropertyList.h"
#include <ctype.h>
#include <ObjFW/macros.h>

#include <assert.h>

@implementation ClassPage {
    PropertyListModel *model;
    OUIEntry *superClassLabel;
}

- (OUIControl *)render
{
    auto vbox = [OUIBox verticalBox];
    vbox.padded = true;
    {
        superClassLabel = [OUIEntry entry];
        superClassLabel.text = @"OFObject";
        {
            auto hbox = [OUIBox horizontalBox];
            hbox.padded = true;
            {
                auto lbl = [OUILabel labelWithText: @"Superclass"];
                [hbox appendControl: lbl];
                [hbox appendControl: [OUISeperator horizontalSeperator] stretchy: true];
                [hbox appendControl: superClassLabel];
            }
            [vbox appendControl: hbox];
        }

        model = [PropertyListModel model];
        auto modelObj = [TableModel modelWithDelegate: model];
        // The reason I had to add an onDelete block is because you dont have a reference to the table itself when
        // you have an interaction on a button column. This is because it hates me.
        model.onDelete = ^(int index) {
            [modelObj alertRowDeletedAt: index];
        };
        auto table = [Table tableDescribedByModel: modelObj];
        [table appendTextColumnWithTitle:   @"Name"         column: 0 isEditable: true];
        [table appendTextColumnWithTitle:   @"Type"         column: 1 isEditable: true];
        [table appendTextColumnWithTitle:   @"Properties"   column: 2 isEditable: true];
        [table appendButtonColumnWithTitle: @"Remove"       column: 3];
        [vbox appendControl: table];

        auto addProp = [OUIButton buttonWithLabel: @"Add Property"];
        addProp.onChanged = ^(OUIControl *) {
            [model.properties addObject: [Property propertyWithName: @"myProperty" type: @"OFString *" attributes: [@[ @"readonly" ] mutableCopy]]];
            [table.model alertRowInsertedAt: model.properties.count - 1];
        };
        [vbox appendControl: addProp stretchy: true];
    }
    return vbox;
}

- (void)doActionWithTitle: (OFString *)title window: (OUIWindow *)window
{
    OFString *outDir = [OUIDialog openDirectoryDialogForWindow: window];
    auto headerFilePath = [[OFIRI fileIRIWithPath: outDir] IRIByAppendingPathComponent: [title stringByAppendingPathExtension: @"h"]];
    auto sourceFilePath = [[OFIRI fileIRIWithPath: outDir] IRIByAppendingPathComponent: [title stringByAppendingPathExtension: @"m"]];


    OFMutableString *camelCasedTitle = [title mutableCopy];
    [camelCasedTitle setCharacter: (char)tolower([camelCasedTitle characterAtIndex: 0]) atIndex: 0];
    auto f = [OFIRIHandler openItemAtIRI: headerFilePath mode: @"w"];
    {
        [f writeLine: @"#import <ObjFW/ObjFW.h>"];
        [f writeLine: @""];
        [f writeFormat: @"@interface %@ : %@\n\n", title, superClassLabel.text];

        for (Property *prop in model.properties) {
            [f writeFormat: @"@property(%@) %@%s%@;\n", [prop.attributes componentsJoinedByString: @", "], prop.type, [prop.type characterAtIndex: prop.type.length - 1] == '*' ? "" : " ", prop.name];
        }

        [f writeLine: @""];
        [f writeFormat: @"+ (instancetype) %@;\n", camelCasedTitle];
        [f writeLine: @""];
        [f writeLine: @"@end"];
    }
    [f close];

    f = [OFIRIHandler openItemAtIRI: sourceFilePath mode: @"w"];
    {
        [f writeFormat: @"#import \"%@.h\"\n", title];
        [f writeLine:   @""];
        [f writeFormat: @"@implementation %@\n", title];
        [f writeLine:   @""];
        [f writeLine:   @"- (instancetype)init"];
        [f writeLine:   @"{"];
        [f writeLine:   @"    self = [super init];"];
        [f writeLine:   @""];
        [f writeLine:   @"    return self;"];
        [f writeLine:   @"}"];
        [f writeLine:   @""];
        [f writeFormat: @"+ (instancetype) %@\n", camelCasedTitle];
        [f writeLine:   @"{ return [[self alloc] init]; }"];
        [f writeLine:   @""];
        [f writeLine:   @"@end"];
    }
    [f close];

    [OUIDialog messageBoxForWindow: window title: @"Success" message: [OFString stringWithFormat: @"Created %@ and %@", headerFilePath.path, sourceFilePath.path]];
}

@end


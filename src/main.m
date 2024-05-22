#import <ObjFW/ObjFW.h>
#import <ObjUI/ObjUI.h>

#import "Table.h"
#import "PropertyList.h"

#define nonnil _Nonnull
#define nilable _Nullable
#define auto __auto_type
#define nilptr ((void *nillable)NULL)

#pragma clang assume_nonnull begin

@protocol Page

- (OUIControl *)render;

- (void)doActionWithTitle: (OFString *)title;

@end

@interface ClassPage : OFObject<Page> @end
// @interface TestPage : OFObject<Page> @end
// @interface AppPage : OFObject<Page> @end

@implementation ClassPage {
    PropertyListModel *_model;
}

- (instancetype)init
{
    self = [super init];

    _model = [[PropertyListModel alloc] init];

    return self;
}

- (OUIControl *)render
{
    auto vbox = [OUIBox verticalBox];
    {
        [vbox appendControl: [OUILabel labelWithText: @"Create a new class"]];
        [vbox appendControl: [Table tableDescribedByModel: [TableModel modelWithDelegate: _model]]];
    }
    return vbox;
}

- (void)doActionWithTitle: (OFString *)title
{
    OFLog(@"ClassPage: %@", title);
}

@end

@interface Application : OFObject<OFApplicationDelegate> @end

@implementation Application {
    id<Page> classPage, testPage, appPage;
}

- (OUIControl *)ui
{
    auto tab = [OUITab tab];

    [tab appendControl: [classPage render] label: @"Class"];

    return tab;
}

- (void)applicationDidFinishLaunching: (OFNotification *)notification
{
    classPage = [[ClassPage alloc] init];
    // testPage = [[TestPage alloc] init];
    // appPage = [[AppPage alloc] init];

    OUIWindow *wind = [[OUIWindow alloc] initWithTitle: @"ObjFW-new" width: 640 height: 480 hasMenubar: false];
    wind.child = self.ui;
    wind.onClosing = ^(OUIWindow *nonnil window) {
        [OFApplication terminate];
        return 0;
    };

    [wind show];
    [OUI main];
    [OFApplication terminate];
}

@end

#if defined(OF_WINDOWS)
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    extern int __argc;
    extern char **__argv;
    return OFApplicationMain(&__argc, &__argv, [[Application alloc] init]);
}
#else
int main(int argc, char *nonnil argv[nonnil ])
{
    return OFApplicationMain(&argc, &argv, [[Application alloc] init]);
}
#endif

#pragma clang assume_nonnull end

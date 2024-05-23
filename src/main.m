#import "common.h"

#import "Pages/App.h"
#import "Pages/Class.h"
#import "Pages/Test.h"

#import "Table.h"

#pragma clang assume_nonnull begin

@interface Application : OFObject<OFApplicationDelegate> @end

@implementation Application {
    id<Page> classPage, testPage, appPage;
}

- (OUIControl *)ui
{
    classPage = [[ClassPage alloc] init];
    testPage = [[TestPage alloc] init];
    appPage = [[AppPage alloc] init];

    auto vbox = [OUIBox verticalBox];
    vbox.padded = true;
    {
        [vbox appendControl: [OUIEntry entryWithLabel: @"Name" placeholder: @"MyClass"]];
        auto tab = [OUITab tab];
        {
            [tab appendControl: [classPage render] label: @"Class"];
            [tab appendControl: [testPage render] label: @"Test"];
            [tab appendControl: [appPage render] label: @"App"];
        }
        [vbox appendControl: tab];

        [vbox appendControl: [OUIButton buttonWithLabel: @"Create"] stretchy: true];
    }
    return vbox;
}

- (void)applicationDidFinishLaunching: (OFNotification *)notification
{
    OUIWindow *wind = [[OUIWindow alloc] initWithTitle: @"ObjFW-new" width: 640 height: 480 hasMenubar: false];
    wind.child = self.ui;
    wind.onClosing = ^(OUIWindow *nonnil window) {
        [OFApplication terminate];
        return 0;
    };
    wind.margined = true;

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

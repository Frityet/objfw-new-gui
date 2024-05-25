#import "common.h"

#import "Pages/App.h"
#import "Pages/Class.h"
#import "Pages/Test.h"

#import "Table.h"

#import "OFObject+PrettyPrintingExtensions.h"

#pragma clang assume_nonnull begin

@interface Application : OFObject<OFApplicationDelegate> @end

@implementation Application {
    id<Page> classPage, testPage, appPage;
    OUIWindow *window;
}

- (instancetype)init
{
    self = [super init];

    classPage = [[ClassPage alloc] init];
    testPage = [[TestPage alloc] init];
    appPage = [[AppPage alloc] init];

    return self;
}

- (OUIControl *)ui
{
    auto vbox = [OUIBox verticalBox];
    vbox.padded = true;
    {
        auto nameEntry = [OUIEntry entry];
        nameEntry.text = @"MyClass";
        {
            auto hbox = [OUIBox horizontalBox];
            hbox.padded = true;
            {
                auto lbl = [OUILabel labelWithText: @"Name"];
                [hbox appendControl: lbl];
                [hbox appendControl: [OUISeperator horizontalSeperator] stretchy: true];
                [hbox appendControl: nameEntry];
                [OFStdOut writeLine: nameEntry.prettyDescription];
            }
            [vbox appendControl: hbox];
        }
        auto tab = [OUITab tab];
        {
            [tab appendControl: [classPage render]  label: @"Class"];
            [tab setMargined: true atIndex: 0];
            [tab appendControl: [testPage render]   label: @"Test"];
            [tab setMargined: true atIndex: 1];
            [tab appendControl: [appPage render]    label: @"App"];
            [tab setMargined: true atIndex: 2];
        }
        [vbox appendControl: tab];
    }
    return vbox;
}

- (void)applicationDidFinishLaunching: (OFNotification *)notification
{
    window = [[OUIWindow alloc] initWithTitle: @"ObjFW-new" width: 640 height: 480 hasMenubar: false];
    window.child = self.ui;
    window.onClosing = ^(OUIWindow *nonnil window) {
        [OFApplication terminate];
        return 0;
    };
    window.margined = true;

    [window show];
    @try {
        [OUI main];
    } @catch (OFException *e) {
        [OUIDialog errorBoxForWindow: window title: @"Error" message: [OFString stringWithFormat: @"Exception of type %@: %@\nStack: %@\n", e.className, e.description, e.stackTraceSymbols]];
        [OFApplication terminateWithStatus: EXIT_FAILURE];
    }
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

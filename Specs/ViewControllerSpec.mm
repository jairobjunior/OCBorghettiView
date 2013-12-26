#import <Swizzlean/Swizzlean.h>
#import "ViewController.h"
#import "OCBorghettiView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface ViewController (Spec)
@property (strong, nonatomic) OCBorghettiView *accordion;
- (void)setupAccordion;
@end

@interface OCBorghettiView (Spec)
@property (assign) NSInteger numberOfSections;
@end

SPEC_BEGIN(ViewControllerSpec)

describe(@"ViewController", ^{
    __block ViewController *controller;

    beforeEach(^{
        controller = [[ViewController alloc] init];
    });
   
    it(@"conforms to protocols", ^{
        [controller conformsToProtocol:@protocol(OCBorghettiViewDelegate)] should be_truthy;
        [controller conformsToProtocol:@protocol(UITableViewDelegate)] should be_truthy;
        [controller conformsToProtocol:@protocol(UITableViewDataSource)] should be_truthy;
    });
    
    describe(@"delegate methods", ^{
        it(@"implements numberOfSectionsInTableView:", ^{
            [controller respondsToSelector:@selector(numberOfSectionsInTableView:)] should be_truthy;
        });
        
        it(@"implements tableView:cellForRowAtIndexPath:", ^{
            [controller respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)] should be_truthy;
        });
        
        it(@"implements tableView:numberOfRowsInSection:", ^{
            [controller respondsToSelector:@selector(tableView:numberOfRowsInSection:)] should be_truthy;
        });
        
        it(@"implements tableView:heightForRowAtIndexPath:", ^{
            [controller respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)] should be_truthy;
        });
    });
    
    describe(@"#viewDidLoad", ^{
        __block Swizzlean *accordionSetupSwizz;
        __block BOOL methodHasBeenCalled;
        
        beforeEach(^{
            methodHasBeenCalled = NO;
            accordionSetupSwizz = [[Swizzlean alloc] initWithClassToSwizzle:[ViewController class]];
            
            [accordionSetupSwizz swizzleInstanceMethod:@selector(setupAccordion)
                         withReplacementImplementation:^(id _self) {
                             methodHasBeenCalled = YES;
            }];
            
            [controller viewDidLoad];
        });
        
        afterEach(^{
            [accordionSetupSwizz resetSwizzledInstanceMethod];
        });
        
        it(@"has proper background color", ^{
            controller.view.backgroundColor should equal([UIColor colorWithRed:0 green:0.447 blue:0.255 alpha:1]);
        });
        
        it(@"should have called Accordion setup", ^{
            methodHasBeenCalled should be_truthy;
        });
    });
    
    describe(@"#setupAccordion", ^{
        beforeEach(^{
            [controller setupAccordion];
        });
        
        it(@"has an accordion", ^{
            controller.accordion should be_truthy;
        });
        
        it(@"has the correct section height", ^{
            controller.accordion.accordionSectionHeight should equal(40);
        });
        
        it(@"has the correct section color", ^{
            controller.accordion.accordionSectionColor should equal([UIColor colorWithRed:0 green:0.447 blue:0.255 alpha:1]);
        });
        
        it(@"has the correct section border color", ^{
            controller.accordion.accordionSectionBorderColor should equal([UIColor colorWithRed:0.129 green:0.514 blue:0.349 alpha:1]);
        });
        
        it(@"has the correct font family and size", ^{
            controller.accordion.accordionSectionFont should equal([UIFont fontWithName:@"Avenir" size:16]);
        });
        
        it(@"is a subview", ^{
            controller.view.subviews should contain(controller.accordion);
        });
        
        it(@"has been called three times", ^{
            controller.accordion.numberOfSections should equal(3);
        });
    });
    
    describe(@"tableview", ^{
        it(@"#numberOfSectionsInTableView:", ^{
            [controller numberOfSectionsInTableView:nil] should equal(1);
        });
        
        it(@"#tableView:numberOfRowsInSection", ^{
            [controller tableView:nil numberOfRowsInSection:0] should equal(15);
        });
        
        it(@"#tableView:heightForRowAtIndexPath:", ^{
            [controller tableView:nil heightForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]] should equal(60);
        });
        
        it(@"#shouldAutorotate", ^{
            [controller shouldAutorotate] should be_truthy;
        });
    });
    
    describe(@"#preferredStatusBarStyle", ^{
        it(@"returns UIStatusBarStyleLightContent as preferred status bar style", ^{
            [controller preferredStatusBarStyle] should equal(UIStatusBarStyleLightContent);
        });
    });
});

SPEC_END

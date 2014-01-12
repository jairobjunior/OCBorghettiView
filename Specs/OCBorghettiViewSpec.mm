#import <Swizzlean/Swizzlean.h>
#import "OCBorghettiView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface OCBorghettiView (Spec)
@property (strong) NSMutableArray *views;
@property (strong) NSMutableArray *sections;
@property (assign) NSInteger numberOfSections;
@property (assign) BOOL shouldAnimate;
@property (assign) BOOL hasBorder;

- (void)initBorghetti;
- (void)sectionSelected:(id)sender;
- (void)processBorder:(UIButton *)sectionTitle
              atIndex:(NSInteger)index;
@end

SPEC_BEGIN(BorghettiViewSpec)

describe(@"OCBorghettiView", ^{
    __block OCBorghettiView *view;
    __block CGRect viewFrame;
    __block id<OCBorghettiViewDelegate> fakeDelegate;
    
    beforeEach(^{
        fakeDelegate = nice_fake_for(@protocol(OCBorghettiViewDelegate));
        fakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).and_return(YES);
        
        viewFrame = CGRectMake(0, 0, 320, 480);
        view = [[OCBorghettiView alloc] initWithFrame:viewFrame];
        view.delegate = fakeDelegate;
    });
    
    it(@"has the proper frame", ^{
        [NSValue valueWithCGRect:view.frame] should equal([NSValue valueWithCGRect:viewFrame]);
    });
    
    it(@"has delegate", ^{
        view.delegate should equal(fakeDelegate);
    });
    
    describe(@"border color", ^{
        context(@"is not set", ^{
            it(@"has no border between if border color is not set", ^{
                view.hasBorder should equal(NO);
            });
            
        });
        
        context(@"is set", ^{
            beforeEach(^{
                view.hasBorder = NO;
                view.accordionSectionBorderColor = [UIColor whiteColor];
            });
            
            it(@"has the proper color set", ^{
                view.accordionSectionBorderColor should equal([UIColor whiteColor]);
            });
            
            it(@"exists when the border color is set", ^{
                view.hasBorder should be_truthy;
            });
        });
    });
    
    describe(@"font family", ^{
        context(@"default", ^{
            it(@"has default font family if font is not set", ^{
                view.accordionSectionFont should equal([UIFont fontWithName:@"Arial-BoldMT" size:16]);
            });
        });
        
        context(@"user defined", ^{
            beforeEach(^{
                view.accordionSectionFont = [UIFont fontWithName:@"Arial-BoldMT" size:14];
            });
            
            it(@"has the proper font family", ^{
                view.accordionSectionFont should equal([UIFont fontWithName:@"Arial-BoldMT" size:14]);
            });
        });
    });
    
    describe(@"section title color", ^{
        context(@"default", ^{
            it(@"has default color set", ^{
                view.accordionSectionTitleColor should equal([UIColor whiteColor]);
            });
        });
        
        context(@"user defined", ^{
            beforeEach(^{
                view.accordionSectionTitleColor = [UIColor redColor];
            });
            
            it(@"has proper color set", ^{
                view.accordionSectionTitleColor should equal([UIColor redColor]);
            });
        });
    });
    
    describe(@"#sectionSelected:", ^{
        __block UIButton *fakeButton;
        __block Swizzlean *layoutSwizz;
        __block BOOL needsLayoutHasBeenCalled;
        
        __block NSArray *arrayOfViews;
        __block NSArray *arrayOfSections;
        
        __block UIButton *fakeSection;
        __block UILabel *titleLabel;
        __block UIView *fakeView;
        
        beforeEach(^{
            fakeButton = nice_fake_for([UIButton class]);
            fakeButton stub_method(@selector(tag)).and_return(0);
            
            fakeView = nice_fake_for([UIView class]);
            arrayOfViews = @[fakeView];
            view.views = [arrayOfViews copy];
            
            titleLabel = [[UILabel alloc] init];
            titleLabel.text = @"Section title";
            fakeSection = nice_fake_for([UIButton class]);
            fakeSection stub_method(@selector(titleLabel)).and_return(titleLabel);
            arrayOfSections = @[fakeButton];
            view.sections = [arrayOfSections copy];
            
            needsLayoutHasBeenCalled = NO;
            layoutSwizz = [[Swizzlean alloc] initWithClassToSwizzle:[view class]];
            [layoutSwizz swizzleInstanceMethod:@selector(setNeedsLayout)
                 withReplacementImplementation:^(id _self) {
                     needsLayoutHasBeenCalled = YES;
                 }];
            
            [view sectionSelected:fakeButton];
        });
        
        it(@"should set the ative section according the tag on the button", ^{
            view.accordionSectionActive should equal(0);
        });
        
        it(@"should have called the setNeedsLayout method", ^{
            needsLayoutHasBeenCalled should be_truthy;
        });
        
        describe(@"delegate", ^{
            context(@"is set", ^{
                it(@"should calls the delegate method", ^{
                    fakeDelegate should have_received(@selector(accordion:didSelectSection:withTitle:));
                });
            });
        });
    });
    
    describe(@"#init", ^{
        __block OCBorghettiView *borghettiView;
        
        it(@"should throw an exception", ^{
            NSString *reasonStr = [NSString stringWithFormat:@"Initialize with initWithFrame: selector instead."];
            ^{
                borghettiView = [[OCBorghettiView alloc] init];
            } should raise_exception([NSException exceptionWithName:@"BadInitCall" reason:reasonStr userInfo:nil]);
        });
    });
    
    describe(@"#initWithFrame", ^{
        __block Swizzlean *borghettiSwizz;
        __block BOOL methodHasBeenCalled;
        
        beforeEach(^{
            methodHasBeenCalled = NO;
            borghettiSwizz = [[Swizzlean alloc] initWithClassToSwizzle:[OCBorghettiView class]];
            
            [borghettiSwizz swizzleInstanceMethod:@selector(initBorghetti)
                    withReplacementImplementation:^(id _self){
                        methodHasBeenCalled = YES;
                    }];
            
            view = [[OCBorghettiView alloc] initWithFrame:viewFrame];
        });
        
        afterEach(^{
            [borghettiSwizz resetSwizzledInstanceMethod];
        });
        
        it(@"has called the initBorghetti", ^{
            methodHasBeenCalled should be_truthy;
        });
    });
    
    describe(@"#initBorghetti", ^{
        beforeEach(^{
            [view initBorghetti];
        });
        
        it(@"has an array of views", ^{
            view.views should_not be_nil;
        });
        
        it(@"has an array of sections", ^{
            view.sections should_not be_nil;
        });
        
        it(@"has default section height", ^{
            view.accordionSectionHeight should equal(30);
        });
        
        it(@"has default section background color", ^{
            view.accordionSectionColor should equal([UIColor blackColor]);
        });
        
        it(@"has default border color", ^{
            view.accordionSectionBorderColor should equal([UIColor colorWithWhite:0.8f alpha:1.0f]);
        });
        
        it(@"has border disabled by default", ^{
            view.hasBorder should_not be_truthy;
        });
        
        it(@"has clear background color", ^{
            view.backgroundColor should equal([UIColor clearColor]);
        });
        
        it(@"should allow user interaction", ^{
            view.userInteractionEnabled should be_truthy;
        });
        
        it(@"should allow subview autoresize", ^{
            view.userInteractionEnabled should be_truthy;
        });
        
        it(@"has proper autoresize masks", ^{
            view.autoresizingMask should equal(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        });
        
        it(@"does not animate right after allocated", ^{
            view.shouldAnimate should_not be_truthy;
        });
    });
    
    describe(@"#didAddSubview", ^{
        __block UIButton *fakeButtonView;
        __block UIView *fakeView;
        
        beforeEach(^{
            fakeButtonView = [[UIButton alloc] init];
            fakeView = [[UIView alloc] init];
            
            view.numberOfSections = 0;
            
            [view didAddSubview:fakeButtonView];
            [view didAddSubview:fakeButtonView];
            [view didAddSubview:fakeView];
        });
        
        it(@"should have added a single view", ^{
            view.numberOfSections should equal(1);
        });
    });
    
    describe(@"#addSectionWithTitle:andView:", ^{
        __block CGRect viewFrame;
        __block NSString *sectionTitle;
        __block UIView *sectionView;
        
        __block Swizzlean *targetActionSwizz;
        __block id passedTarget;
        __block SEL passedSelector;
        __block UIControlEvents passedEvents;
        
        beforeEach(^{
            viewFrame = view.frame;
            view.accordionSectionHeight = 40;
            view.accordionSectionColor = [UIColor purpleColor];
            view.accordionSectionFont = [UIFont fontWithName:@"Arial-BoldMT" size:14];
            view.accordionSectionTitleColor = [UIColor yellowColor];
            
            targetActionSwizz = [[Swizzlean alloc] initWithClassToSwizzle:[UIButton class]];
            [targetActionSwizz swizzleInstanceMethod:@selector(addTarget:action:forControlEvents:)
                       withReplacementImplementation:^(id _self, id target, SEL selector, UIControlEvents events) {
                           passedTarget = target;
                           passedSelector = selector;
                           passedEvents = events;
                       }];
            
            sectionTitle = @"Some title";
            sectionView = [[UIView alloc] init];
            [view addSectionWithTitle:sectionTitle andView:sectionView];
        });
        
        afterEach(^{
            [targetActionSwizz resetSwizzledInstanceMethod];
        });
        
        it(@"has a section", ^{
            view.sections.count should equal(1);
        });
        
        it(@"has a view", ^{
            view.views.count should equal(1);
            view.subviews should contain(sectionView);
        });
        
        it(@"sets the active section to 0", ^{
            view.accordionSectionActive should equal(0);
        });
        
        describe(@"section", ^{
            __block UIButton *currentSection;
            
            beforeEach(^{
                currentSection = view.sections[0];
            });
            
            it(@"has proper title", ^{
                currentSection.titleLabel.text should equal(@"Some title");
            });
            
            it(@"has correct font family and size", ^{
                currentSection.titleLabel.font should equal([UIFont fontWithName:@"Arial-BoldMT" size:14]);
            });
            
            it(@"has correcnt font color", ^{
                [currentSection titleColorForState:UIControlStateNormal] should equal([UIColor yellowColor]);
            });
            
            it(@"has the proper background color", ^{
                currentSection.backgroundColor should equal([UIColor purpleColor]);
            });
            
            it(@"has the proper horizontal content aligment", ^{
                currentSection.contentHorizontalAlignment should equal(UIControlContentHorizontalAlignmentLeft);
            });
            
            it(@"autoresizes subviews", ^{
                currentSection.autoresizesSubviews should be_truthy;
            });
            
            it(@"has the proper autoresizing subview mask", ^{
                currentSection.autoresizingMask should equal(UIViewAutoresizingFlexibleWidth);
            });
            
            it(@"should respond to selector addTarget:action:forControlEvents:", ^{
                [currentSection respondsToSelector:@selector(addTarget:action:forControlEvents:)] should be_truthy;
            });
            
            it(@"has a tag to identify itself", ^{
                currentSection.tag should equal(0);
            });
            
            it(@"disables the tap highlight", ^{
                currentSection.adjustsImageWhenHighlighted should equal(NO);
            });
            
            describe(@"target and action", ^{
                it(@"has correct target", ^{
                    passedTarget should equal(view);
                });
                
                it(@"has an action", ^{
                    passedSelector should equal(@selector(sectionSelected:));
                });
                
                it(@"has correnct event", ^{
                    passedEvents should equal(UIControlEventTouchUpInside);
                });
            });
        });
        
        describe(@"view", ^{
            __block UIView *currentView;
            
            beforeEach(^{
                currentView = view.views[0];
            });
            
            it(@"autoresizes subviews", ^{
                currentView.autoresizesSubviews should be_truthy;
            });
            
            it(@"has the proper autoresizing subview mask", ^{
                currentView.autoresizingMask should equal(UIViewAutoresizingFlexibleWidth);
            });
        });
    });
    
    describe(@"#layoutSubviews", ^{
        __block UIView *firstView;
        __block UIScrollView *secondView;
        __block UIView *thirdView;
        
        __block UIButton *firstSection;
        __block UIButton *secondSection;
        __block UIButton *thirdSection;
        
        beforeEach(^{
            firstView = [[UIView alloc] init];
            secondView = [[UIScrollView alloc] init];
            thirdView = [[UIView alloc] init];
            
            [view addSectionWithTitle:@"First Section" andView:firstView];
            [view addSectionWithTitle:@"Second Section" andView:secondView];
            [view addSectionWithTitle:@"Third Section" andView:thirdView];
            
            firstSection = view.sections[0];
            secondSection = view.sections[1];
            thirdSection = view.sections[2];
        });
        
        it(@"has three sections to find the correct frame", ^{
            view.numberOfSections should equal(3);
        });
        
        it(@"turns the animation on", ^{
            [view layoutSubviews];
            
            view.shouldAnimate should be_truthy;
        });
        
        it(@"sets proper edge insets for section title", ^{
            [view layoutSubviews];
            
            UIButton *firstSection = view.sections[0];
            firstSection.titleEdgeInsets should equal(UIEdgeInsetsMake(0.0f, -5.0f, 0.0f, 0.0f));
            firstSection.imageEdgeInsets should equal(UIEdgeInsetsMake(0.0f, 295.f, 0.0f, 0.0f));
        });
        
        describe(@"delegate implements accordion:shouldSelectSection:withTitle: returning YES", ^{
            context(@"active section is firstView", ^{
                beforeEach(^{
                    view.accordionSectionActive = 0;
                    [view layoutSubviews];
                });
                
                it(@"has views with proper frame", ^{
                    firstView.frame should equal(CGRectMake(0, 30, 320, 390));
                    secondView.frame should equal(CGRectMake(0, 450, 320, 0));
                    thirdView.frame should equal(CGRectMake(0, 480, 320, 0));
                });
                
                it(@"sets the proper image for the active section (firstView)", ^{
                    [firstSection imageForState:UIControlStateNormal] should equal([UIImage imageNamed:@"OCBorghettiView.bundle/icon_down_arrow.png"]);
                });
                
                it(@"sets the proper image for the non-active sections (second and third)", ^{
                    [secondSection imageForState:UIControlStateNormal] should equal([UIImage imageNamed:@"OCBorghettiView.bundle/icon_right_arrow.png"]);
                    [thirdSection imageForState:UIControlStateNormal] should equal([UIImage imageNamed:@"OCBorghettiView.bundle/icon_right_arrow.png"]);
                });
                
                it(@"unsets scroll to top for the non-active view (that responds to setScrollsToTop:)", ^{
                    secondView.scrollsToTop should_not be_truthy;
                });
            });
            
            context(@"active section is secondView", ^{
                beforeEach(^{
                    view.accordionSectionActive = 1;
                    [view layoutSubviews];
                });
                
                it(@"has views with proper frame", ^{
                    firstView.frame should equal(CGRectMake(0, 30, 320, 0));
                    secondView.frame should equal(CGRectMake(0, 60, 320, 390));
                    thirdView.frame should equal(CGRectMake(0, 480, 320, 0));
                });
                
                it(@"sets the proper image for the active section (secondSection)", ^{
                    [secondSection imageForState:UIControlStateNormal] should equal([UIImage imageNamed:@"OCBorghettiView.bundle/icon_down_arrow.png"]);
                });
                
                it(@"sets the proper image for the non-active sections (first and third)", ^{
                    [firstSection imageForState:UIControlStateNormal] should equal([UIImage imageNamed:@"OCBorghettiView.bundle/icon_right_arrow.png"]);
                    [thirdSection imageForState:UIControlStateNormal] should equal([UIImage imageNamed:@"OCBorghettiView.bundle/icon_right_arrow.png"]);
                });
                
                it(@"sets scroll to top for the active view (that responds to setScrollsToTop:)", ^{
                    secondView.scrollsToTop should be_truthy;
                });
            });
            
            context(@"active section is thirdView", ^{
                beforeEach(^{
                    view.accordionSectionActive = 2;
                    [view layoutSubviews];
                });
                
                it(@"has views with proper frame", ^{
                    firstView.frame should equal(CGRectMake(0, 30, 320, 0));
                    secondView.frame should equal(CGRectMake(0, 60, 320, 0));
                    thirdView.frame should equal(CGRectMake(0, 90, 320, 390));
                });
                
                it(@"sets the proper image for the active section (thirdSection)", ^{
                    [thirdSection imageForState:UIControlStateNormal] should equal([UIImage imageNamed:@"OCBorghettiView.bundle/icon_down_arrow.png"]);
                });
                
                it(@"sets the proper image for the non-active sections (first and second)", ^{
                    [firstSection imageForState:UIControlStateNormal] should equal([UIImage imageNamed:@"OCBorghettiView.bundle/icon_right_arrow.png"]);
                    [secondSection imageForState:UIControlStateNormal] should equal([UIImage imageNamed:@"OCBorghettiView.bundle/icon_right_arrow.png"]);
                });
            });
            
            context(@"active section is an invalid view (e.g. -1)", ^{
                beforeEach(^{
                    view.accordionSectionActive = 0;
                    view.accordionSectionActive = -1;
                    [view layoutSubviews];
                });
                
                it(@"active section is still accordionSectionActive = 0", ^{
                    view.accordionSectionActive should equal(0);
                });
                
                it(@"has views with proper frame", ^{
                    firstView.frame should equal(CGRectMake(0, 30, 320, 390));
                    secondView.frame should equal(CGRectMake(0, 450, 320, 0));
                    thirdView.frame should equal(CGRectMake(0, 480, 320, 0));
                });
            });
            
            context(@"active section is an invalid view (e.g. 4)", ^{
                beforeEach(^{
                    view.accordionSectionActive = 0;
                    view.accordionSectionActive = 4;
                    [view layoutSubviews];
                });
                
                it(@"active section is still accordionSectionActive = 0", ^{
                    view.accordionSectionActive should equal(0);
                });
                
                it(@"has views with proper frame", ^{
                    firstView.frame should equal(CGRectMake(0, 30, 320, 390));
                    secondView.frame should equal(CGRectMake(0, 450, 320, 0));
                    thirdView.frame should equal(CGRectMake(0, 480, 320, 0));
                });
            });
        });
        
        describe(@"delegate implements accordion:shouldSelectSection:withTitle: returning NO", ^{
            __block id<OCBorghettiViewDelegate> newfakeDelegate;
            
            beforeEach(^{
                newfakeDelegate = nice_fake_for(@protocol(OCBorghettiViewDelegate));
            });
            
            context(@"active section is first", ^{
                beforeEach(^{
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(secondView).and_with(@"Second Section").and_return(NO);
                    view.delegate = newfakeDelegate;
                    
                    view.accordionSectionActive = 0;
                    view.accordionSectionActive = 1;
                    [view layoutSubviews];
                });
                
                it(@"should stay on this view and second view is selected", ^{
                    view.accordionSectionActive should equal(0);
                });
                
                it(@"has views with proper frame", ^{
                    firstView.frame should equal(CGRectMake(0, 30, 320, 390));
                    secondView.frame should equal(CGRectMake(0, 450, 320, 0));
                    thirdView.frame should equal(CGRectMake(0, 480, 320, 0));
                });
            });
            
            context(@"active section is first", ^{
                beforeEach(^{
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(thirdView).and_with(@"Third Section").and_return(NO);
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(firstView).and_with(@"First Section").and_return(YES);
                    view.delegate = newfakeDelegate;
                    
                    view.accordionSectionActive = 0;
                    view.accordionSectionActive = 2;
                    [view layoutSubviews];
                });
                
                it(@"should stay on this view and third view is selected", ^{
                    view.accordionSectionActive should equal(0);
                });
                
                it(@"has views with proper frame", ^{
                    firstView.frame should equal(CGRectMake(0, 30, 320, 390));
                    secondView.frame should equal(CGRectMake(0, 450, 320, 0));
                    thirdView.frame should equal(CGRectMake(0, 480, 320, 0));
                });
            });
            
            context(@"active section is second", ^{
                beforeEach(^{
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(firstView).and_with(@"First Section").and_return(NO);
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(secondView).and_with(@"Second Section").and_return(YES);
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(thirdView).and_with(@"Third Section").and_return(YES);
                    view.delegate = newfakeDelegate;
                    
                    view.accordionSectionActive = 1;
                    view.accordionSectionActive = 0;
                    [view layoutSubviews];
                });
                
                it(@"should stay on this view and first view is selected", ^{
                    view.accordionSectionActive should equal(1);
                });
                
                it(@"has views with proper frame", ^{
                    firstView.frame should equal(CGRectMake(0, 30, 320, 0));
                    secondView.frame should equal(CGRectMake(0, 60, 320, 390));
                    thirdView.frame should equal(CGRectMake(0, 480, 320, 0));
                });
            });
            
            context(@"active section is second", ^{
                beforeEach(^{
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(firstView).and_with(@"First Section").and_return(YES);
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(secondView).and_with(@"Second Section").and_return(YES);
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(thirdView).and_with(@"Third Section").and_return(NO);
                    view.delegate = newfakeDelegate;
                    
                    view.accordionSectionActive = 1;
                    view.accordionSectionActive = 2;
                    [view layoutSubviews];
                });
                
                it(@"should stay on this view and third view is selected", ^{
                    view.accordionSectionActive should equal(1);
                });
                
                it(@"has views with proper frame", ^{
                    firstView.frame should equal(CGRectMake(0, 30, 320, 0));
                    secondView.frame should equal(CGRectMake(0, 60, 320, 390));
                    thirdView.frame should equal(CGRectMake(0, 480, 320, 0));
                });
            });
            
            context(@"active section is third", ^{
                beforeEach(^{
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(firstView).and_with(@"First Section").and_return(NO);
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(secondView).and_with(@"Second Section").and_return(YES);
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(thirdView).and_with(@"Third Section").and_return(YES);
                    view.delegate = newfakeDelegate;
                    
                    view.accordionSectionActive = 2;
                    view.accordionSectionActive = 0;
                    [view layoutSubviews];
                });
                
                it(@"should stay on this view and first view is selected", ^{
                    view.accordionSectionActive should equal(2);
                });
                
                it(@"has views with proper frame", ^{
                    firstView.frame should equal(CGRectMake(0, 30, 320, 0));
                    secondView.frame should equal(CGRectMake(0, 60, 320, 0));
                    thirdView.frame should equal(CGRectMake(0, 90, 320, 390));
                });
            });
            
            context(@"active section is third", ^{
                beforeEach(^{
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(thirdView).and_with(@"Third Section").and_return(YES);
                    newfakeDelegate stub_method(@selector(accordion:shouldSelectSection:withTitle:)).with(view).with(secondSection).and_with(@"First Section").and_return(NO);
                    view.delegate = newfakeDelegate;
                    
                    view.accordionSectionActive = 2;
                    view.accordionSectionActive = 1;
                    [view layoutSubviews];
                });
                
                it(@"should stay on this view and second view is selected", ^{
                    view.accordionSectionActive should equal(2);
                });
                
                it(@"has views with proper frame", ^{
                    firstView.frame should equal(CGRectMake(0, 30, 320, 0));
                    secondView.frame should equal(CGRectMake(0, 60, 320, 0));
                    thirdView.frame should equal(CGRectMake(0, 90, 320, 390));
                });
            });
        });
        
        describe(@"animation", ^{
            __block Swizzlean *beginSwizz;
            __block Swizzlean *animationDurationSwizz;
            __block Swizzlean *animationCurveSwizz;
            __block Swizzlean *animationFromStateSwizz;
            __block Swizzlean *animationCommitSwizz;
            
            __block NSString *passedAnimation;
            __block void *passedContext;
            __block NSTimeInterval passedTimeInterval;
            __block BOOL hasBeenCalledWithShouldAnimateNO;
            __block UIViewAnimationCurve passedCurve;
            __block BOOL passedBoolean;
            __block BOOL commitAnimationHasBeenCalled;
            
            beforeEach(^{
                beginSwizz = [[Swizzlean alloc] initWithClassToSwizzle:[UIView class]];
                animationDurationSwizz = [[Swizzlean alloc] initWithClassToSwizzle:[UIView class]];
                animationCurveSwizz = [[Swizzlean alloc] initWithClassToSwizzle:[UIView class]];
                animationFromStateSwizz = [[Swizzlean alloc] initWithClassToSwizzle:[UIView class]];
                animationCommitSwizz = [[Swizzlean alloc] initWithClassToSwizzle:[UIView class]];
                
                [beginSwizz swizzleClassMethod:@selector(beginAnimations:context:)
                 withReplacementImplementation:^(id _self, NSString *animation, void *context) {
                     passedAnimation = animation;
                     passedContext = context;
                 }];
                
                [animationDurationSwizz swizzleClassMethod:@selector(setAnimationDuration:)
                             withReplacementImplementation:^(id _self, NSTimeInterval duration) {
                                 passedTimeInterval = duration;
                                 if (!view.shouldAnimate) hasBeenCalledWithShouldAnimateNO = YES;
                             }];
                
                [animationCurveSwizz swizzleClassMethod:@selector(setAnimationCurve:)
                          withReplacementImplementation:^(id _self, UIViewAnimationCurve curve) {
                              passedCurve = curve;
                          }];
                
                [animationFromStateSwizz swizzleClassMethod:@selector(setAnimationBeginsFromCurrentState:)
                              withReplacementImplementation:^(id _self, BOOL boolean) {
                                  passedBoolean = boolean;
                              }];
                
                commitAnimationHasBeenCalled = NO;
                [animationCommitSwizz swizzleClassMethod:@selector(setAnimationBeginsFromCurrentState:)
                           withReplacementImplementation:^(id _self) {
                               commitAnimationHasBeenCalled = YES;
                           }];
            });
            
            afterEach(^{
                [beginSwizz resetSwizzledClassMethod];
                [animationDurationSwizz resetSwizzledClassMethod];
                [animationCurveSwizz resetSwizzledClassMethod];
                [animationFromStateSwizz resetSwizzledClassMethod];
                [animationCommitSwizz resetSwizzledClassMethod];
            });
            
            it(@"has proper animation and context", ^{
                [view layoutSubviews];
                passedAnimation should_not be_truthy;
                passedContext should_not be_truthy;
            });
            
            it(@"has proper curve time", ^{
                [view layoutSubviews];
                passedCurve should equal(UIViewAnimationCurveEaseOut);
            });
            
            it(@"should start animaton from current state", ^{
                [view layoutSubviews];
                passedBoolean should be_truthy;
            });
            
            it(@"should commit animations", ^{
                [view layoutSubviews];
                commitAnimationHasBeenCalled should be_truthy;
            });
            
            describe(@"duration", ^{
                context(@"should animate", ^{
                    beforeEach(^{
                        view.shouldAnimate = YES;
                        [view layoutSubviews];
                    });
                    
                    it(@"has proper time interval", ^{
                        passedTimeInterval should equal(0.1f);
                    });
                });
                
                context(@"shouldn't animate", ^{
                    beforeEach(^{
                        view.shouldAnimate = NO;
                        [view layoutSubviews];
                    });
                    
                    it(@"has proper time interval", ^{
                        [view layoutSubviews];
                        hasBeenCalledWithShouldAnimateNO should be_truthy;
                    });
                });
            });
        });
    });
    
    describe(@"#processBorder:atIndex:", ^{
        __block UIButton *fakeSection;
        __block NSArray *fakeSubviews;
        
        beforeEach(^{
            fakeSection = nice_fake_for([UIButton class]);
            fakeSubviews = @[nice_fake_for([UIImageView class]), nice_fake_for([UILabel class])];
            fakeSection stub_method(@selector(subviews)).and_return(fakeSubviews);
        });
        
        context(@"has border", ^{
            context(@"and index = 0", ^{
                beforeEach(^{
                    view.hasBorder = YES;
                    [view processBorder:fakeSection atIndex:0];
                });
                
                it(@"should not add border as subview", ^{
                    fakeSection should_not have_received(@selector(addSubview:));
                });
            });
            
            context(@"and index > 0", ^{
                beforeEach(^{
                    view.hasBorder = YES;
                    [view processBorder:fakeSection atIndex:1];
                });
                
                it(@"should have a border as subview", ^{
                    fakeSection should have_received(@selector(addSubview:));
                });
            });
        });
        
        context(@"does not have border", ^{
            beforeEach(^{
                view.hasBorder = NO;
                [view processBorder:fakeSection atIndex:1];
            });
            
            it(@"should not add border as subview", ^{
                fakeSection should_not have_received(@selector(addSubview:));
            });
        });
    });
});

SPEC_END

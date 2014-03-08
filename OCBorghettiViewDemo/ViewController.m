#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) OCBorghettiView *accordion;
@end

@implementation ViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.0f
                                                green:0.447f
                                                 blue:0.255f
                                                alpha:1.0f];
    
    [self setupAccordion];
}

- (void)setupAccordion
{
    self.accordion = [[OCBorghettiView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20)];
    self.accordion.headerHeight = 40;
    
    self.accordion.headerFont = [UIFont fontWithName:@"Avenir" size:16];
    
    self.accordion.headerBorderColor = [UIColor colorWithRed:0.129f
                                                                 green:0.514f
                                                                  blue:0.349f
                                                                 alpha:1.0f];
    self.accordion.headerColor = [UIColor colorWithRed:0.0f
                                                           green:0.447f
                                                            blue:0.255f
                                                           alpha:1.0f];
    [self.view addSubview:self.accordion];
    
    // Section One
    UITableView *sectionOne = [[UITableView alloc] init];
    [sectionOne setTag:1];
    [sectionOne setDelegate:self];
    [sectionOne setDataSource:self];
    [self.accordion addSectionWithTitle:@"Section One"
                                andView:sectionOne];
    
    // Section Two
    UITableView *sectionTwo = [[UITableView alloc] init];
    [sectionTwo setTag:2];
    [sectionTwo setDelegate:self];
    [sectionTwo setDataSource:self];
    [self.accordion addSectionWithTitle:@"Section Two"
                                andView:sectionTwo];
    
    // Section Three
    UITableView *sectionThree = [[UITableView alloc] init];
    [sectionThree setTag:3];
    [sectionThree setDelegate:self];
    [sectionThree setDataSource:self];
    [self.accordion addSectionWithTitle:@"Section Three"
                                andView:sectionThree];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"borghetti_cell"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"borghetti_cell"];
    
    cell.textLabel.font = [UIFont fontWithName:@"Avenir" size:16];
    cell.textLabel.text = [NSString stringWithFormat:@"Table %d - Cell %d", tableView.tag, indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithRed:0.46f green:0.46f blue:0.46f alpha:1.0f];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end

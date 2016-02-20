//
//  AddFriendViewController.m
//  Shopper
//
//  Created by Ninan Thomas on 7/2/13.
//
//

#import "AddFriendViewController.h"
#import "AppDelegate.h"

@interface AddFriendViewController ()

@end

@implementation AddFriendViewController

@synthesize frndSelector;
@synthesize bInDeleteFrnd;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        bValidEmail = false;
        
        addFTaskId = UIBackgroundTaskInvalid;
    
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
     NSString *title = @"Add Friend";
    if (bInDeleteFrnd)
    {
      title = @"Delete Friend";
    }
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationItem.title = [NSString stringWithString:title];
    UITableViewHeaderFooterView *aTableViewHeaderFooterView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"AddFriendHeaderViewIdentifier"];
    
    [self.tableView registerClass:[aTableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"AddFriendHeaderViewIdentifier"];
     UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:pDlg action:@selector(friendsAddDelDone) ];
    self.navigationItem.leftBarButtonItem = pBarItem;
    return;
    
}

-(void) loadView
{
    [super loadView];
    CGRect tableRect = CGRectMake(0, 50, 275, 430);
    UITableView *pTVw = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
    //[self.view insertSubview:self.pAllItms.tableView atIndex:1];
    self.tableView = pTVw;
    return;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section >= 2)
        return nil;
    static NSString *headerReuseIdentifier = @"AddFriendHeaderViewIdentifier";
    
    // Reuse the instance that was created in viewDidLoad, or make a new one if not enough.
    UITableViewHeaderFooterView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
    // Add any optional custom views of your own
    if (section ==0)
    {
        sectionHeaderView.textLabel.text = @"Friend's email";
        
    }
    else
    {
        sectionHeaderView.textLabel.text = @"Friend's nickname (optional)";  
        if (busyInd.isAnimating == YES)
        {
            [sectionHeaderView.contentView addSubview:busyInd];
            busyInd.center = CGPointMake(sectionHeaderView.contentView.bounds.size.width / 2.0f, sectionHeaderView.contentView.bounds.size.height / 2.0f);
            busyInd.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
        }
        

    }
    
    return sectionHeaderView;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section <1)
        return 60.0;
    if (section == 1)
        return 70.0;
    
    return 30.0;
}


- (void)textChanged:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    NSIndexPath *indPath = [self.tableView indexPathForCell:cell];
    
    if(indPath.section ==0)
    {
        userName = textField.text;
    }
    else if (indPath.section == 1)
    {
        nickName = textField.text;
    }
        
    if ([self NSStringIsValidEmail:userName])
    {
        if(!bValidEmail)
        {
            bValidEmail = true;
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:2];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
            [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }
    else
    {
        if(bValidEmail)
        {
            bValidEmail = false;
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:2];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
            [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }
    return;
}


-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    else
    {
        NSArray *pVws = [cell.contentView subviews];
        int cnt = (int)[pVws count];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            [[pVws objectAtIndex:i] removeFromSuperview];
        }
        cell.imageView.image = nil;
        cell.textLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (indexPath.section == 0 && indexPath.row ==0)
    {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 275, 25)];
        textField.delegate = self;
        [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        if (userName != nil)
            textField.text = userName;
        [cell.contentView addSubview:textField];
    }
    else if (indexPath.section == 1)
    {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 275, 25)];
        textField.delegate = self;
        [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        if (nickName != nil)
            textField.text = nickName;
        [cell.contentView addSubview:textField];
    }
    else if (indexPath.section == 2)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
        if (!bValidEmail)
        {
            [button setBackgroundImage:[[UIImage imageNamed:@"IphoneButton_White.png"]
                                        stretchableImageWithLeftCapWidth:8.0f
                                        topCapHeight:0.0f]
                              forState:UIControlStateNormal];
        }
        else
        {
            [button setBackgroundImage:[[UIImage imageNamed:@"IphoneButton_Green.png"]
                                        stretchableImageWithLeftCapWidth:8.0f
                                        topCapHeight:0.0f]
                              forState:UIControlStateNormal];
            
        }
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        button.titleLabel.shadowColor = [UIColor lightGrayColor];
        button.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [button setTitle:@"Submit" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchDown];
        [cell.contentView addSubview:button];
        
    }
    

    
    // Configure the cell...
    
    return cell;
}

-(void) deleteFriend
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray* aFrndsArr = [pDlg.friendList componentsSeparatedByString:@";"];
    NSInteger i = 0;
    NSInteger frndIndx = -1;
    NSString *newList = [[NSString alloc] init];
    for (NSString * frnd in  aFrndsArr)
    {
        if (frnd != nil && [frnd length] >0)
        {
            NSRange aR = [frnd rangeOfString:userName];
            if (aR.location == NSNotFound)
            {
                newList = [newList stringByAppendingFormat:@"%@;", frnd];
            }
            else
            {
                frndIndx = i;
            
            }
        }
        ++i;
    }
    if (frndIndx == -1)
    {
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Delete Friend failed" message:@"Cannot find friend to delete" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [pAvw show];
        return;
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"Deleted friend %@", userName];
        if (nickName != nil && [nickName length] > 0)
        {
            msg = [msg stringByAppendingFormat:@" with Nickname %@", nickName];
        }
        pDlg.friendList = newList;
        [pDlg storeFriends];
        dispatch_async(pDlg.dataSync.shareQ,
        ^{
             [AddFriendViewController storeFrndInCloud];
         });

        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Delete Friend Success" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [pAvw show];
        return;
    }
        
    
    return;
}

+(void) storeFrndInCloud
{
        return;
}

-(void) addFriend
{
 //Check whether friend is already registered. If not registered add him
    // any way and offer to send an email to friend to download app and register
    if (bInDeleteFrnd)
    {
        [self deleteFriend];
        return;
    }
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([userName isEqualToString:pDlg.userName])
    {
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Add Friend failed" message:@"Cannot add yourself as friend" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [pAvw show];
        return;
    }
    if (pDlg.friendList != nil && [pDlg.friendList length] >0)
    {
        NSRange aR = [pDlg.friendList rangeOfString:[userName lowercaseString]];
        if (aR.location != NSNotFound)
        {
            UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Add Friend failed" message:@"Friend already added" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [pAvw show];
            return;
        }
    }
    busyInd = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    busyInd.color =[UIColor blueColor];
    [self.tableView endEditing:YES];
    [busyInd startAnimating];
    [self.tableView reloadData];

    dispatch_async(pDlg.dataSync.shareQ,
    ^{
        addFTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:
        ^{
                [[UIApplication sharedApplication] endBackgroundTask:addFTaskId];
                  addFTaskId = UIBackgroundTaskInvalid;
                                      }];
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                       [self addFriendAction];
                [[UIApplication sharedApplication] endBackgroundTask:addFTaskId];
                addFTaskId = UIBackgroundTaskInvalid;
                if (addFTaskId == UIBackgroundTaskInvalid)
                {
                    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
                }
                       
            });
    

}

-(void) addFriendAction
{
    return;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    
    if (result == MFMailComposeResultSent)
    {
        NSLog(@"It's away! Email sent to friend %@ email=%@", nickName, userName);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == 1)
    {
        NSLog(@"Showing email dialog");
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:@"House hunting help needed"];
            NSArray *emails = [NSArray arrayWithObject:userName];
            [controller setToRecipients:emails];
            if (bClickShare)
            {
            	NSString *messageBody = @"Hello\n We are house hunting and we would like your opinion in choosing our dream home. Could you please take a look at the houses along with us. We would like to share the photos ,videos , notes of the houses we visited. Please download the OpenHouses app from Appstore and click the Share button to register to receive the details of our houses. \n\n http://itunes.apple.com/us/app/openhouses/id555632260?mt=8 \n\n\n Thanks and Regards\n";
            	[controller setMessageBody:messageBody isHTML:NO];
            }
            else
            {
            	NSString *messageBody = @"Hello\n We are house hunting and we would like your opinion in choosing our dream home. Could you please take a look at the houses along with us. We would like to share the photos ,videos , notes of the houses we visited. Please download the OpenHouses app from Appstore and open it to receive details of our houses. \n\n http://itunes.apple.com/us/app/openhouses/id555632260?mt=8 \n\n\n Thanks and Regards\n";
            	[controller setMessageBody:messageBody isHTML:NO];
            }
            if (controller)
                [self presentViewController:controller animated:YES completion:nil];
        }
        else
        {
            UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Email Failed" message:@"Failed to send email as no email client set up" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [pAvw show];
        }
    }
    userName = @"";
    nickName = @"";
    [self.tableView reloadData];
    return;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end

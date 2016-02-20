//
//  SelectFriendViewController.m
//  Shopper
//
//  Created by Ninan Thomas on 7/3/13.
//
//

#import "SelectFriendViewController.h"
#import "AppDelegate.h"
#import "AddFriendViewController.h"
#import "FriendDetails.h"

const NSInteger SELECTION_INDICATOR_TAG_1 = 54321;
const NSInteger TEXT_LABEL_TAG_1 = 54322;
const NSInteger EDITING_HORIZONTAL_OFFSET_1 = 35;


@interface SelectFriendViewController ()

@end

@implementation SelectFriendViewController

@synthesize frndDic;
@synthesize seletedItems;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        if ([frndDic count])
        {
            NSUInteger cnt = [frndDic count];
            seletedItems = [[NSMutableArray alloc] initWithCapacity:cnt];
            for (NSUInteger i=0; i < cnt; ++i)
            {
                [seletedItems addObject:[NSNumber numberWithBool:NO]];
            }
            rownoFrndDetail = [[NSMutableDictionary alloc] initWithCapacity:cnt];
            itr = [frndDic objectEnumerator];
            FriendDetails *frnd;
            NSUInteger i=0;
            
            while (frnd = [itr nextObject])
            {
                NSNumber *nmbr = [NSNumber numberWithUnsignedInteger:i];
                [rownoFrndDetail setObject:frnd forKey:nmbr];
                ++i;
            }
            
        }
        else
        {
            seletedItems = [[NSMutableArray alloc] init];
            rownoFrndDetail = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSArray *) getSelectedFriends
{
    NSUInteger cnt = [seletedItems count];
    NSLog(@"Selected %lu friends to share with", (unsigned long)cnt);
    NSMutableArray *selFrnds = [[NSMutableArray alloc] initWithCapacity:cnt];
    for (NSUInteger i=0; i < cnt; ++i)
    {
        NSNumber *nmbr = [seletedItems objectAtIndex:i];
        if ([nmbr boolValue] == YES)
        {
            FriendDetails *item = [rownoFrndDetail objectForKey:[NSNumber numberWithUnsignedInteger:i]];
            if (item != nil)
            {
                [selFrnds addObject:item];
                NSLog(@"Added friend %@  to share with", item.name);
            }
        }
    }
    
    return selFrnds;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSString *title = @"Select Friends";
    self.navigationItem.title = [NSString stringWithString:title];
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:pDlg action:@selector(shareRightNow) ];
    self.navigationItem.leftBarButtonItem = pBarItem;
   
    if(![frndDic count])
    {
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Add Friends" message:@"Click Action item on top right corner to add friends" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [pAvw show];
    }
        
}

-(void) dispFrndsFromCloud
{
     AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (pDlg.friendList != nil && [pDlg.friendList length] > 0)
    {
        NSArray *friends = [pDlg.friendList componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];
        NSUInteger cnt = [friends count];
        if(cnt >1)
        {
            for (NSUInteger i=0; i < cnt-1; ++i)
            {
                FriendDetails *frnd = [[FriendDetails alloc] initWithString:[friends objectAtIndex:i]];
                [self displayAddedFriend:frnd];
                
            }
        }
    }
    return;
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2)
    {
        return;
    }
    
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AddFriendViewController *addFrndVw = [AddFriendViewController alloc];
    if (buttonIndex ==0)
    {
        addFrndVw.bInDeleteFrnd = true;
    }
    else
    {
        addFrndVw.bInDeleteFrnd = false;
    }
    addFrndVw = [addFrndVw initWithNibName:nil bundle:nil];
    addFrndVw.frndSelector = self;
    [pDlg.navViewController pushViewController:addFrndVw animated:YES];
    return;
     
    

      
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    return;
}


-(bool) displayAddedFriend:(FriendDetails *) newFrnd
{
    NSUInteger cnt = [frndDic count];
    if ([frndDic objectForKey:newFrnd.name] == nil)
    {
        [frndDic setObject:newFrnd forKey:newFrnd.name];
        [rownoFrndDetail setObject:newFrnd forKey:[NSNumber numberWithUnsignedInteger:cnt]];
        [seletedItems addObject:[NSNumber numberWithBool:NO]];
        [self.tableView reloadData];
        
    }
    else
    {
        NSLog(@"Trying to add duplicate item\n");
        return false;
    }
    
	return true;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [frndDic count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelctFrndVwCell";
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

    
    // Configure the cell...
    UIImageView *indicator;
    UILabel *label;
    const NSInteger IMAGE_SIZE = 30;
    const NSInteger SIDE_PADDING = 35;
    
    NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row];
    if ([numbr boolValue] == YES)
    {
        indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IsSelected.png"]];
            NSLog(@"Setting image  selected\n");
    }
    else
    {
        indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotSelected.png"]];
        NSLog(@"Setting image not selected\n");
    }
    indicator.tag = SELECTION_INDICATOR_TAG_1;
    indicator.frame =
    CGRectMake(0, (0.5 * tableView.rowHeight) - (0.5 * IMAGE_SIZE), IMAGE_SIZE, IMAGE_SIZE);
    [cell.contentView addSubview:indicator];
        
    label = [[UILabel alloc] initWithFrame:CGRectMake(SIDE_PADDING, 0, 320, tableView.rowHeight)];
    label.tag = TEXT_LABEL_TAG_1;
        
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont boldSystemFontOfSize:14];
    [cell.contentView addSubview:label];
    NSUInteger row = indexPath.row;
    FriendDetails *item = [rownoFrndDetail objectForKey:[NSNumber numberWithUnsignedInteger:row]];
    NSString *labtxt;
    if (item != nil)
    {
        if (item.nickName != nil && [item.nickName length]>0)
        {
            labtxt = item.nickName;
        }
        else
        {
            labtxt  = item.name ;
        }
    }
    
    
    
    label.text = labtxt;
    NSLog(@"Setting main list label %@ %@\n", label.text, item.name);
    
    

    
    return cell;
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    
    UITableViewCell *cell =
    [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *indicator = (UIImageView *)[cell.contentView viewWithTag:SELECTION_INDICATOR_TAG_1];
    NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row];
    if ([numbr boolValue] == YES)
    {
        indicator.image = [UIImage imageNamed:@"NotSelected.png"];
        NSLog(@"Changing image Not selected\n");
        [seletedItems replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
    }
    else
    {
        indicator.image = [UIImage imageNamed:@"IsSelected.png"];
        NSUInteger crnt = indexPath.row;
        
        NSLog(@"Changing  image to selected at index %lu\n", (unsigned long)crnt);
        [seletedItems replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
    }

}

@end

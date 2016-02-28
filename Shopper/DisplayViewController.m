//
//  DisplayViewController.m
//  Shopper
//
//  Created by Ninan Thomas on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "common/AlbumContentsViewController.h"
#import "DisplayViewController.h"
#import "AppDelegate.h"
#import "common/MapViewController.h"
#include <sys/types.h>
#include <dirent.h>
#include "string.h"
#import "common/NotesViewController.h"
#include <math.h>

@implementation DisplayViewController

@synthesize nSmallest;
@synthesize processQuery;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
            nSmallest = 0;
        processQuery = true;
            AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	     NSString *pAlMoc = pDlg.pAlName;
	    printf("In DisplayViewController Selected album name %s\n", [pAlMoc UTF8String]);
	    char szFileNo[64];
	    if (pAlMoc == nil)
            return self;
	    
	    NSURL *albumurl = [NSURL URLWithString:pAlMoc];
        
        if ([pDlg.pFlMgr fileExistsAtPath:[albumurl path]] == YES)
       {
           NSLog(@"Album directory exists");
           
       }
        else
        {
            NSLog(@"Album directory does not exist");
        }
        NSArray *keys = [NSArray arrayWithObject:NSURLIsRegularFileKey];
        NSArray *files = [pDlg.pFlMgr contentsOfDirectoryAtURL:albumurl includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
        NSUInteger cnt = [files count];
         NSLog(@"Getting locally stored file %lu", (unsigned long)cnt);
        for (NSUInteger i = 0; i < cnt; ++i)
        {
            NSURL *fileurl = [files objectAtIndex:i];
            NSError *error;
            NSNumber *isReg;
            if ([fileurl getResourceValue:&isReg forKey:NSURLIsRegularFileKey error:&error] == YES)
            {
                if ([isReg boolValue] == YES)
                {
                    NSString *pFil = [fileurl lastPathComponent];
                    int size = (int) strcspn([pFil UTF8String], ".");
                    if (size)
                    {
                        strncpy(szFileNo, [pFil UTF8String], size);
                        szFileNo[size] = '\0';
                        int val = strtod(szFileNo, NULL);
                        if (val < nSmallest)
                            nSmallest = val;
                        if (nSmallest == 0)
                            nSmallest = val;
                    }
                    
                }
            }
            else
            {
                NSLog(@"Failed to get resource value %@\n", error);
            }
            
        }
        NSLog(@"album url %@ nSmallest %d\n", albumurl, nSmallest);
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void) loadView
{
    [super loadView];
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithTitle:@"House Info" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.backBarButtonItem = pBarItem1;
    NSString *title = @"House Info";
    //printf("%s", [title UTF8String]);
    self.navigationItem.title = [NSString stringWithString:title];
    UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:pDlg action:@selector(itemEdit) ];
    self.navigationItem.rightBarButtonItem = pBarItem;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    NSLog(@"Stopping iCloud query in DisplayViewController\n");
    
    if (query != nil)
    {
        NSLog(@"Stop query in DisplayViewController\n");
        [query stopQuery];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"DisplayViewController will appear\n");
    if (query != nil)
    {
        
        if (![query isStarted])
        {
            NSLog(@"Start query in DisplayViewController\n");
            [query startQuery];
            processQuery = true;
        }
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //printf
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"DisplayViewController will disappear\n");
    if (query != nil)
    {
        
        if (![query isStopped])
        {
            NSLog(@"Stop query in DisplayViewController\n");
            [query stopQuery];
            processQuery = false;
        }
    }

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return 12;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    if (indexPath.row == 0)
        cell.backgroundColor = [UIColor yellowColor];
    return;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSArray* fieldNames = nil;
    if (!fieldNames)
    {
        fieldNames = [NSArray arrayWithObjects:@"Name", @"Price", @"Area", @"Beds",  @"Notes", @"Pictures", @"Map", @"Street", @"City", @"State", @"Country", @"Postal Code", nil];
    }
    
    static NSArray *secondFieldNames = nil;
    
    if(!secondFieldNames)
    {
        secondFieldNames = [NSArray arrayWithObjects:@"Blank", @"Blank", @"Year", @"Baths", nil];
    }

    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUInteger row = indexPath.row;
    static NSString *CellIdentifier = @"itemdetail";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    printf("Drawing row %ld\n", (long)indexPath.row);
    
    if(indexPath.section == 0) 
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]; 
        }
        else
        {
            NSArray *pVws = [cell.contentView subviews];
            NSUInteger cnt = [pVws count];
            for (NSUInteger i=0; i < cnt; ++i)
            {
                [[pVws objectAtIndex:i] removeFromSuperview];
            }
            cell.imageView.image = nil;
            cell.textLabel.text = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (row ==2 || row == 3)
        {
            
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
            CGRect textFrame;
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:14];
            [cell.contentView addSubview:label];
            textFrame = CGRectMake(75, 12, 85, 25);
            UILabel *textField = [[UILabel alloc] initWithFrame:textFrame];
            NSString* fieldName = [fieldNames objectAtIndex:row];
            label.text = fieldName;
            [cell.contentView addSubview:textField];
            UILabel* label1 = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 75, 25)];
            NSString *secName = [secondFieldNames objectAtIndex:row];
            label1.text = secName;
            label1.textAlignment = NSTextAlignmentLeft;
            label1.font = [UIFont boldSystemFontOfSize:14];
            [cell.contentView addSubview:label1];
            textFrame = CGRectMake(235, 12, 85, 25);
            UILabel *textField1 = [[UILabel alloc] initWithFrame:textFrame];
            [cell.contentView addSubview:textField1];
            switch (row) 
            {
                case 2:
                {
                    if ([pDlg.selectedItem.area doubleValue] >= 0.0 )
                    {
                        char area1[64];
                        sprintf(area1, "%.0f", [pDlg.selectedItem.area floatValue]);
                        textField.text = [NSString stringWithUTF8String:area1];
                    }
                    
                    if (pDlg.selectedItem.year != 3000)
                    {
                        char year1[64];
                        sprintf(year1, "%d", pDlg.selectedItem.year);
                        textField1.text = [NSString stringWithUTF8String:year1];
                    }
                    
                }
                    break;
                    
                case 3:
                {
                    if ([pDlg.selectedItem.beds  doubleValue] >= 0.0 )
                    {
                        char beds1[64];
                        sprintf(beds1, "%.0f", [pDlg.selectedItem.beds floatValue]);
                        textField.text = [NSString stringWithUTF8String:beds1];
                    }
                    
                    if ([pDlg.selectedItem.baths  doubleValue] >= 0.0 )
                    {
                        char baths1[64];
                        sprintf(baths1, "%.1f", [pDlg.selectedItem.baths floatValue]);
                        textField1.text = [NSString stringWithUTF8String:baths1];
                    }
                }
                    break;
                    
                default:
                    break;
            }
            
        }
        else if (row < 2 || row > 6)
        {
            CGRect textFrame;
			
            // put a label and text field in the cell
            UILabel *label;
            if (row != 11)
                label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
            else
                label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 105, 25)];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:14];
            if (row == 0)
            {
                cell.backgroundColor = [UIColor yellowColor];
                label.backgroundColor = [UIColor yellowColor];
            }
            [cell.contentView addSubview:label];
            if (row != 11)
                textFrame = CGRectMake(75, 12, 200, 25);
            else
                textFrame = CGRectMake(110, 12, 170, 25);
            UILabel *textField = [[UILabel alloc] initWithFrame:textFrame];
            textField.lineBreakMode = NSLineBreakByCharWrapping;
            switch (row) 
            {
                case 0:
                    textField.text = pDlg.selectedItem.name;
                break;
                    
                case 1:
                {
                    if ([pDlg.selectedItem.price  doubleValue] >= 0.0 )
                    {
                        char price1[64];
                        sprintf(price1, "%.2f", [pDlg.selectedItem.price floatValue]);
                        textField.text = [NSString stringWithUTF8String:price1];
                    }
                }
                    break;
                    
                case 7:
                    textField.text = pDlg.selectedItem.street;
                    break;
                    
                case 8:
                    textField.text = pDlg.selectedItem.city ;
                    break;
                    
                case 9:
                    textField.text = pDlg.selectedItem.state;
                break;
                    
                case 10:
                    textField.text = pDlg.selectedItem.country;
                    break;
                case 11:
                    textField.text = pDlg.selectedItem.zip;
                    break;
                    
                default:
                    break;
            }
           
            [cell.contentView addSubview:textField];
            if (row == 0)
            {
                cell.backgroundColor = [UIColor yellowColor];
                label.backgroundColor = [UIColor yellowColor];
                textField.backgroundColor = [UIColor yellowColor];
            }
            
            NSString* fieldName = [fieldNames objectAtIndex:row];
            label.text = fieldName;
        }
        else if (row == 4)
        {
            cell.imageView.image = [UIImage imageNamed:@"note.png"];
            cell.textLabel.text = @"Notes";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
        }
        else if (row == 5)
        {
            
            printf("Selected album name %s nSmallest %d\n", [pDlg.pAlName UTF8String], nSmallest);
            if (nSmallest)
            {
                NSString *pFlName = [[NSNumber numberWithInt:nSmallest] stringValue];
                pFlName = [pFlName stringByAppendingString:@".jpg"];
		NSURL *pFlUrl;
		NSError *err;
		NSURL *albumurl = [NSURL URLWithString:pDlg.pAlName];
		if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
		{
		    pFlUrl = [albumurl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
		    pFlUrl = [pFlUrl URLByAppendingPathComponent:pFlName isDirectory:NO];
		}
		else 
		{
		   
		    pFlUrl = [pDlg.cloudDocsURL URLByAppendingPathComponent:@"albums" isDirectory:YES];
		     pFlUrl = [pFlUrl URLByAppendingPathComponent:pDlg.pAlName isDirectory:YES];
		    pFlUrl = [pFlUrl URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
		    pFlUrl = [pFlUrl URLByAppendingPathComponent:pFlName isDirectory:NO];
		}
	       
		NSDictionary *dict = [pDlg.pFlMgr attributesOfItemAtPath:[pFlUrl path] error:&err];
		if (dict != nil)
		    NSLog (@"Loading image in DisplayViewController %@ file size %lld\n", pFlUrl, [dict fileSize]);
		else 
		    NSLog (@"Loading image in DisplayViewController %@ file size not obtained\n", pFlUrl);
		UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:pFlUrl]];
                NSLog(@"Set icon image %@ in DisplayViewController\n", pFlUrl);
                cell.imageView.image = image;
            }
            cell.textLabel.text = @"Pictures";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
        }
        else if (row == 6)
        {
            cell.imageView.image = [UIImage imageNamed:@"map.png"];
            cell.textLabel.text = @"Map";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
        
    }
    else
    {
        
        return nil;
    }

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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *title ;
    if (pDlg.selectedItem.street != nil)
        title = pDlg.selectedItem.street;
    else 
        title = @" ";
    if (indexPath.row == 5)
    {
        AlbumContentsViewController *albumContentsViewController = [[AlbumContentsViewController alloc] initWithNibName:@"AlbumContentsViewController" bundle:nil];
        NSLog(@"Pushing AlbumContents view controller %s %d\n" , __FILE__, __LINE__);
      //  albumContentsViewController.assetsGroup = group_;
        
        [albumContentsViewController setDelphoto:false];
        [albumContentsViewController setPFlMgr:pDlg.pFlMgr];
        [albumContentsViewController setPAlName:pDlg.pAlName];
        [albumContentsViewController setNavViewController:pDlg.navViewController];
        [self.navigationController pushViewController:albumContentsViewController animated:NO];
        
        [albumContentsViewController  setTitle:title];
       pDlg.navViewController.navigationBar.topItem.title = [NSString stringWithString:title];
        
    }
    else if (indexPath.row == 6)
    {
        MKCoordinateSpan span;
        
        CLLocationCoordinate2D loc;
        AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        loc.longitude = pDlg.selectedItem.longitude;
        loc.latitude = pDlg.selectedItem.latitude;
        span.latitudeDelta = 0.001;
        span.longitudeDelta = 0.001;
        if (fabs(loc.latitude) > 50.0)
            span.longitudeDelta = 0.002;
        MKCoordinateRegion reg = MKCoordinateRegionMake(loc, span);
        MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
        NSLog(@"Setting region to %f %f %f %f\n", reg.center.latitude, reg.center.longitude, reg.span.longitudeDelta, reg.span.latitudeDelta);
        [mapViewController  setTitle:title];
        mapViewController.reg = reg;
         [self.navigationController pushViewController:mapViewController animated:NO];
    }
    else if (indexPath.row == 4)
    {
        NotesViewController *notesViewController = [[NotesViewController alloc] initWithNibName:@"NotesViewController" bundle:nil];
        NSLog(@"Pushing Notes view controller %s %d\n" , __FILE__, __LINE__);
        //  albumContentsViewController.assetsGroup = group_;
        notesViewController.notes.editable = NO;
        notesViewController.title = title;
        notesViewController.notesTxt = pDlg.selectedItem.notes;
        [self.navigationController pushViewController:notesViewController animated:NO];   
    }
}

@end

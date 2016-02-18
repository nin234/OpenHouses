/*
    File: AlbumContentsViewController.m
Abstract: View controller to manaage displaying the contents of an album.
 Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2011 Apple Inc. All Rights Reserved.

*/

#import "AlbumContentsViewController.h"

#import "AlbumContentsTableViewCell.h"
#import "PhotoDisplayViewController.h"
#import "AppDelegate.h"
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>
#include <MobileCoreServices/UTCoreTypes.h>
#include <MobileCoreServices/UTType.h>
#import "AddViewController.h"
#import "EditViewController.h"
#import "MainViewController.h"

@implementation AlbumContentsViewController

//@synthesize assetsGroup;
@synthesize tmpCell;
@synthesize nPicCnt;
@synthesize thumbnails;
@synthesize delphoto;
@synthesize title;
@synthesize tnailsquery;
@synthesize gotqueryres;
@synthesize reload;
@synthesize processQuery;
@synthesize emailphoto;
@synthesize photoSel;
@synthesize movOrImg;
@synthesize attchments;
@synthesize photoreqsource;
@synthesize pAddEditCntrl;
@synthesize name;
@synthesize street;


- (void)awakeFromNib {
    lastSelectedRow = NSNotFound;
}


#pragma mark View lifecycle


- (NSMetadataQuery*) imagesQuery 
{
    NSMetadataQuery* aQuery = [[NSMetadataQuery alloc] init];
    if (aQuery) 
    {
        // Search the Documents subdirectory only.
        AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
       NSURL *albumurl = [pDlg.cloudDocsURL URLByAppendingPathComponent:@"albums" isDirectory:YES];
        albumurl = [albumurl URLByAppendingPathComponent:pDlg.pAlName isDirectory:YES];
//       [aQuery setSearchScopes:[NSArray
  //                               arrayWithObject:albumurl]];
       [aQuery setSearchScopes:[NSArray
                               arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
        
        // Add a predicate for finding the documents.
        NSArray *scope = [aQuery searchScopes];
        NSUInteger cnt = [scope count];
        for (int i=0; i < cnt; ++i)
            NSLog(@"Search dir %@\n", [scope objectAtIndex:i]);
       NSString* filePattern = @"*.jpg";
        NSString* filePattern1 = @"*.MOV";
       [aQuery setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE %@ OR %K LIKE %@",
                             NSMetadataItemFSNameKey, filePattern, NSMetadataItemFSNameKey, filePattern1]];
    }
    
    return aQuery;
}

- (void)processQueryResults:(NSNotification*)aNotification
{
    
    if (!processQuery)
        return;
    [query disableUpdates];
    NSArray *queryResults = [query results];
   
    NSMutableArray *thumbindexes = [[NSMutableArray alloc] initWithCapacity:[queryResults count]];
    NSMutableArray *imgindexes = [[NSMutableArray alloc] initWithCapacity:[queryResults count]];
     AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (NSMetadataItem *result in queryResults) 
    {
        NSURL *fileURL = [result valueForAttribute:NSMetadataItemURLKey];
        // NSLog(@"Processing item at URL %@ \n", fileURL);
        if ([[result valueForAttribute:NSMetadataUbiquitousItemIsDownloadedKey] boolValue] == NO)
            continue;
        NSNumber *aBool = nil;
        [fileURL getResourceValue:&aBool forKey:NSURLIsRegularFileKey error:nil];
       
        if (aBool && [aBool boolValue])
        {
            NSString *str = [fileURL absoluteString];
            NSRange found = [str rangeOfString:pDlg.pAlName options:NSBackwardsSearch];
            if (found.location == NSNotFound)
                continue;
            
            NSURL *pIsThumbnail = [fileURL URLByDeletingLastPathComponent];
            NSString *last = [pIsThumbnail lastPathComponent];
            if ([last isEqualToString:@"thumbnails"] == YES)
            {
                NSString *pFil = [fileURL lastPathComponent];
                char szFileNo[64];
                int size = strcspn([pFil UTF8String], ".");
                if (size)
                {
                    strncpy(szFileNo, [pFil UTF8String], size);
                    szFileNo[size] = '\0';
                    int val = strtod(szFileNo, NULL);
                    [thumbindexes addObject:[NSNumber numberWithInt:val]];
                }

            }
            else 
            {
                NSString *pFil = [fileURL lastPathComponent];
                char szFileNo[64];
                int size = strcspn([pFil UTF8String], ".");
                if (size)
                {
                    strncpy(szFileNo, [pFil UTF8String], size);
                    szFileNo[size] = '\0';
                    int val = strtod(szFileNo, NULL);
                    [imgindexes addObject:[NSNumber numberWithInt:val]];
                }
            }
        }
    }
    NSArray *iIndxes = [NSArray arrayWithArray:[imgindexes sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }]];
    
    NSArray *tIndxes = [NSArray arrayWithArray:[thumbindexes sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }]];
    
    NSUInteger icnt = [iIndxes count];
    NSUInteger tcnt = [tIndxes count];
    NSUInteger cnt = icnt > tcnt?icnt:tcnt;
    NSUInteger iidx =0;
    NSUInteger tidx = 0;
    NSMutableArray *indexes = [[NSMutableArray alloc] initWithCapacity:cnt];
    
    for (NSUInteger i=0; i < cnt; ++i) 
    {
        if (tidx >= tcnt || iidx >= icnt)
            break;
        NSNumber *tno = [tIndxes objectAtIndex:tidx];
        NSNumber *ino = [iIndxes objectAtIndex:iidx];
        if ([ino intValue] == [tno intValue])
        {
            [indexes addObject:ino];
            ++iidx;
            ++tidx;
        }
        else if ([ino intValue] > [tno intValue])
        {
            ++tidx;
        }
        else 
        {
            ++iidx;
        }
    }
    tnailsquery = [NSArray arrayWithArray:indexes];
    nPicCnt = [thumbnails count];
     NSLog(@"Processed iCloud query results no of items %d nPicCnt %d\n", [queryResults count], nPicCnt);
    gotqueryres = true;
    [self.tableView reloadData];
    [query enableUpdates];
    return;
}

- (void)setupAndStartQuery 
{
    // Create the query object if it does not exist.
    if (!query)
        query = [self imagesQuery];
    
    // Register for the metadata query notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processQueryResults:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processQueryResults:)
                                                 name:NSMetadataQueryDidUpdateNotification
                                               object:nil];
    
    // Start the query and let it run.
    NSLog(@"In set up and  start query %@\n", query);
    if (![query startQuery])
        NSLog(@"Failed to start query %@\n", query);
    if ([query isStarted])
        NSLog(@"Started query %@\n", query);
    if ([query isGathering])
        NSLog(@" query Gathering %@\n", query);
}

-(void) noIcloudInit
{
    char szFileNo[64];
    nPicCnt = 0;
     AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *pAlMoc = pDlg.pAlName;
    NSURL *albumurl = [NSURL URLWithString:pAlMoc];
    NSArray *keys = [NSArray arrayWithObject:NSURLIsRegularFileKey];
    NSArray *files = [pDlg.pFlMgr contentsOfDirectoryAtURL:albumurl includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    NSMutableArray *imgindexes = [[NSMutableArray alloc] initWithCapacity:[files count]];
    NSUInteger cnt = [files count];
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
                int size = strcspn([pFil UTF8String], ".");
                if (size)
                {
                    strncpy(szFileNo, [pFil UTF8String], size);
                    szFileNo[size] = '\0';
                    int val = strtod(szFileNo, NULL);
                    [imgindexes addObject:[NSNumber numberWithInt:val]];
                    ++nPicCnt;
                }
                
            }
        }
        else
        {
            NSLog(@"Failed to get resource value %@\n", error);
        }
        
    }
    
    if (nPicCnt)
    {
        thumbnails = [NSArray arrayWithArray:[imgindexes sortedArrayUsingComparator: ^(id obj1, id obj2) {
            
            if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }]];
    }
    
    printf("No of pictures %d\n", nPicCnt);
    NSUInteger noOfIdxes = [thumbnails count];
    NSLog(@"Image index array ");
    for (NSUInteger i=0 ; i < noOfIdxes; ++i)
        NSLog(@" %@",[thumbnails objectAtIndex:i]);
    NSLog(@"\n");
    

    return;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    photoSel = [[NSMutableArray alloc] init];
    attchments = [[NSMutableArray alloc] init];
    movOrImg = [[NSMutableArray alloc] init];
    if (self) 
    {
        emailphoto = false;
        AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *pAlMoc = pDlg.pAlName;
        printf("In AlbumContentsViewController Selected album name %s\n", [pAlMoc UTF8String]);
        nPicCnt = 0;
        gotqueryres = false;
        reload = true;
        processQuery = true;
        
        if (pAlMoc == nil)
            return self;
        NSError *err;
        NSURL *albumurl = [NSURL URLWithString:pAlMoc];
        if (albumurl == nil || ![albumurl checkResourceIsReachableAndReturnError:&err])
        {
            //it should be ubiquitous
            bIniCloud = true;
            [self setupAndStartQuery];
            return self;
        }
        bIniCloud = false;
        [self noIcloudInit];
     }
     return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"DisplayViewController will appear\n");
    if (query != nil)
    {
        
        if ([query isStopped])
        {
            NSLog(@"Start query in AlbumContentsViewController\n");
            [query startQuery];
            processQuery = true;
        }
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (delphoto)
    {
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(camerarollAction) ];
        self.navigationItem.rightBarButtonItem = pBarItem1;
    }
    else if (emailphoto)
    {
        
        self.title = @"Select photos";
         AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        MainViewController *pMainVwCntrl = [pDlg.navViewController.viewControllers objectAtIndex:0];
        UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:pMainVwCntrl.pAllItms action:@selector(photoSelDone)];
        self.navigationItem.rightBarButtonItem = pBarItem;
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:pMainVwCntrl.pAllItms action:@selector(photoSelCancel)];
        self.navigationItem.leftBarButtonItem = pBarItem1;
        UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
                                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                    target:nil action:nil];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, self.view.frame.size.width, 21.0f)];
        [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        //[titleLabel setTextColor:[UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0]];
        [titleLabel setTextColor:[UIColor blackColor]];
        NSString *labtxt = name;
        labtxt = [labtxt stringByAppendingString:@" - "];
        if (street != nil)
            labtxt = [labtxt stringByAppendingString:street];
        [titleLabel setText:labtxt];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        
        UIBarButtonItem *pBarItem2 = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
        [self setToolbarItems:[NSArray arrayWithObjects:
                                                      flexibleSpaceButtonItem,
                                                      pBarItem2,
                                                      flexibleSpaceButtonItem,
                                                      nil]
                                            animated:YES];
        

    }
    self.navigationItem.title = [NSString stringWithString:title];
}
- (void)viewDidAppear:(BOOL)animated
{
     NSLog(@"In view did appear %s %d \n", __FILE__, __LINE__);
    if (lastSelectedRow != NSNotFound) 
    {
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:lastSelectedRow inSection:0];
        AlbumContentsTableViewCell *selectedCell = (AlbumContentsTableViewCell *)[(UITableView *)self.view cellForRowAtIndexPath:selectedIndexPath];
        [selectedCell clearSelection];
        
        lastSelectedRow = NSNotFound;
    }
    NSLog(@"In view did appear %s %d \n", __FILE__, __LINE__);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(gotqueryres && reload)
    {
        thumbnails = [NSArray arrayWithArray:tnailsquery];
        nPicCnt = [thumbnails count];
        gotqueryres = false;
    }
    NSLog(@"No of rows in AlbumContentsViewController %f\n",ceil((float)nPicCnt/4));
  return ceil((float)nPicCnt/4); // there are four photos per row.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell1 forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    AlbumContentsTableViewCell *cell = (AlbumContentsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"AlbumContentsTableViewCell" owner:self options:nil];
        cell = tmpCell;
        tmpCell = nil;
    }
    
    cell.rowNumber = indexPath.row;
    cell.selectionDelegate = self;
    cell.detailTextLabel.text = @"Loading…";
     // Configure the cell...
    NSUInteger firstPhotoInCell = indexPath.row * 4;
    NSUInteger lastPhotoInCell  = firstPhotoInCell + 4;
    
    if (nPicCnt <= firstPhotoInCell) {
        NSLog(@"We are out of range, asking to start with photo %d but we only have %d", firstPhotoInCell, nPicCnt);
        return nil;
    }
    
    NSUInteger currentPhotoIndex = 0;
    
    NSUInteger lastPhotoIndex = MIN(lastPhotoInCell, nPicCnt);
    
    for ( ; firstPhotoInCell + currentPhotoIndex < lastPhotoIndex ; currentPhotoIndex++) {
        
//        ALAsset *asset = [assets objectAtIndex:firstPhotoInCell + currentPhotoIndex];
        
        NSString *pFlName = [[thumbnails objectAtIndex:firstPhotoInCell + currentPhotoIndex] stringValue];
        pFlName = [pFlName stringByAppendingString:@".jpg"];
        AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
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
            NSLog (@"Loading image in AlbumContentsViewController %@ file size %lld\n", pFlUrl, [dict fileSize]);
        else 
            NSLog (@"Loading image in AlbumContentsViewController %@ file size not obtained\n", pFlUrl);
        UIImage *thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:pFlUrl]];
       // CGImageRef thumbnailImageRef = [asset thumbnail];
       // UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
        NSUInteger nAsstIndx = (cell.rowNumber*4) + currentPhotoIndex;
        NSUInteger cnt = [photoSel count];
        bool bSel = false;
        if (cnt >= nAsstIndx+1)
        {
            NSNumber *isSelect = [photoSel objectAtIndex:nAsstIndx];
            if ([isSelect boolValue])
            {
                NSLog(@"Picture already selected for emailing Setting bSel to true\n");
                bSel = true;
            }
        }
        switch (currentPhotoIndex) {
            case 0:
                [cell photo1].image = thumbnail;
                if (bSel)
                    [[cell photo1] addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IsSelected.png"]]];
                break;
            case 1:
                [cell photo2].image = thumbnail;
                if (bSel)
                    [[cell photo2] addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IsSelected.png"]]];
                break;
            case 2:
                [cell photo3].image = thumbnail;
                if (bSel)
                    [[cell photo3] addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IsSelected.png"]]];
                break;
            case 3:
                [cell photo4].image = thumbnail;
                if (bSel)
                    [[cell photo4] addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IsSelected.png"]]];
                break;
            default:
                break;
        }
    }
    
       return cell;
}

-(void) deletedPhotoAtIndx:(NSUInteger)nIndx
{
    NSLog(@"Removing thumbnail at index %d\n", nIndx);
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[thumbnails count]];
    NSUInteger cnt = [thumbnails count];
    for (NSUInteger i=0 ; i < cnt; ++i)
    {
        if (i != nIndx)
            [tmp addObject:[thumbnails objectAtIndex:i]];
    }
    thumbnails = [NSArray arrayWithArray:tmp];
    NSLog(@"Removed thumbnail at index %d\n", nIndx);
     --nPicCnt;
    [self.tableView reloadData];
    return; 
}

-(void) getAttchmentsUrls
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *pAlMoc = pDlg.pAlName;
    NSURL *pFlUrl;
    NSUInteger cnt = [photoSel count];
    for (NSUInteger i=0; i < cnt; ++i)
    {
        if ([[photoSel objectAtIndex:i] boolValue]) 
        {
            
            NSString *pFlName = [[thumbnails objectAtIndex:i] stringValue];
            NSString *pFlImgName = [pFlName stringByAppendingString:@".MOV"];
            pFlName = [pFlName stringByAppendingString:@".jpg"];
            NSError *err;
            NSURL *albumurl = [NSURL URLWithString:pDlg.pAlName];
            NSURL *imgUrl;
            NSURL *movUrl;
            
            if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
            {
                imgUrl = [albumurl URLByAppendingPathComponent:pFlName isDirectory:NO];
                movUrl = [albumurl URLByAppendingPathComponent:pFlImgName isDirectory:NO];
            }
            else 
            {
                pFlUrl = [pDlg.cloudDocsURL URLByAppendingPathComponent:@"albums" isDirectory:YES];
                pFlUrl = [pFlUrl URLByAppendingPathComponent:pAlMoc isDirectory:YES];
                imgUrl = [pFlUrl URLByAppendingPathComponent:pFlName isDirectory:NO];
                movUrl = [pFlUrl URLByAppendingPathComponent:pFlImgName isDirectory:NO];
            }
            
            NSLog(@"Attaching object at index %d  image file %@ movie file %@ \n", i,  imgUrl, movUrl);
            if ([imgUrl checkResourceIsReachableAndReturnError:&err] == YES)
            {
                [attchments addObject:imgUrl];
                [movOrImg addObject:[NSNumber numberWithBool:true]];
            }
            else if ([movUrl checkResourceIsReachableAndReturnError:&err] == YES)
            {
                [attchments addObject:movUrl];
                [movOrImg addObject:[NSNumber numberWithBool:false]];   
            }
        }
        
    }
    NSLog(@"Attached %d urls photoSel count %d\n", [attchments count], [photoSel count]);
    return;
}
#pragma mark -
#pragma mark AlbumContentsTableViewCellSelectionDelegate

- (void)albumContentsTableViewCell:(AlbumContentsTableViewCell *)cell selectedPhotoAtIndex:(NSUInteger)index
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *pAlMoc = pDlg.pAlName;
    lastSelectedRow = cell.rowNumber;
    NSUInteger nAsstIndx = (cell.rowNumber*4) + index;
    NSUInteger tcnt = [thumbnails count];
    if (nAsstIndx >= tcnt)
        return;
    if (emailphoto)
    {
        NSUInteger cnt = [photoSel count];
        if (cnt < tcnt)
        {
            for (NSUInteger i=cnt; i < tcnt; ++i)
                [photoSel addObject:[NSNumber numberWithBool:false]];
        }
        if(photoreqsource == PHOTOREQSOURCE_FB)
        {
            NSString *pFlName = [[thumbnails objectAtIndex:nAsstIndx] stringValue];
            NSString *pFlImgName = [pFlName stringByAppendingString:@".MOV"];
            pFlName = [pFlName stringByAppendingString:@".jpg"];
            NSURL *pFlUrl;
            NSError *err;
            NSURL *albumurl = [NSURL URLWithString:pDlg.pAlName];
            NSURL *imgUrl;
            NSURL *movUrl;
		
            if (albumurl != nil && [albumurl checkResourceIsReachableAndReturnError:&err])
            {
                imgUrl = [albumurl URLByAppendingPathComponent:pFlName isDirectory:NO];
                movUrl = [albumurl URLByAppendingPathComponent:pFlImgName isDirectory:NO];
            }
            else
            {
                pFlUrl = [pDlg.cloudDocsURL URLByAppendingPathComponent:@"albums" isDirectory:YES];
                pFlUrl = [pFlUrl URLByAppendingPathComponent:pAlMoc isDirectory:YES];
                imgUrl = [pFlUrl URLByAppendingPathComponent:pFlName isDirectory:NO];
                movUrl = [pFlUrl URLByAppendingPathComponent:pFlImgName isDirectory:NO];
            }
		
            NSLog(@"Attaching object at index %d  image file %@ movie file %@ \n", nAsstIndx,  imgUrl, movUrl);
            if ([imgUrl checkResourceIsReachableAndReturnError:&err] == YES)
            {
                NSLog(@"Image Url so can be selected %@\n", imgUrl);
            }
            else if ([movUrl checkResourceIsReachableAndReturnError:&err] == YES)
            {
                NSLog(@"Movie Url so cannot be selected in FB %@\n", movUrl);
                return;
            }
            else
            {
                return;
            }
        }
        
        NSNumber *valnow = [photoSel objectAtIndex:nAsstIndx];
        if (![valnow boolValue])
        {
            switch (index)
            {
                case 0:
                    [[cell photo1] addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IsSelected.png"]]];
                    break;
                case 1:
                    [[cell photo2] addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IsSelected.png"]]];
                break;
                    
                case 2:
                    [[cell photo3] addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IsSelected.png"]]];
                break;
                    
                case 3:
                    [[cell photo4] addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IsSelected.png"]]];
                break;
                    
                default:
                break;
            }
   
        }
        else
        {
            switch (index) 
            {
                case 0:
                    for(UIView *subview in [[cell photo1] subviews]) 
                    {
                        [subview removeFromSuperview];
                    }
                break;
                    
                case 1:
                    for(UIView *subview in [[cell photo2] subviews]) 
                    {
                        [subview removeFromSuperview];
                    }
                break;
                    
                case 2:
                    for(UIView *subview in [[cell photo3] subviews]) 
                    {
                        [subview removeFromSuperview];
                    }
                break;
                    
                case 3:
                    for(UIView *subview in [[cell photo4] subviews]) 
                    {
                        [subview removeFromSuperview];
                    }
                break;
                default:
                    break;
            }

        }
        [photoSel replaceObjectAtIndex:nAsstIndx withObject:[NSNumber numberWithBool:![valnow boolValue]]];
        return;
    }
    
    PhotoDisplayViewController *photoViewController = [[PhotoDisplayViewController alloc] initWithNibName:nil bundle:nil];
   // [photoViewController setAsset:[assets objectAtIndex:nAsstIndx]];
    [photoViewController setCurrIndx:nAsstIndx];
    [photoViewController setDelphoto:delphoto];
    [photoViewController setPAlbmVw:self];
    [photoViewController setSubject:title];
    reload = false;
   
    [[self navigationController] pushViewController:photoViewController animated:YES];
    
}

-(void) camerarollAction
{
    UIActionSheet *pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add from Camera Roll", @"Save to Camera Roll", nil];
    
    [pSh showInView:self.view];
    [pSh setDelegate:self];
   
    return;
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController: mediaUI animated:YES completion:nil];
    return YES;
}

-(void) camerarollSelDone
{
    NSLog(@"Selected pictures to save to camera roll\n");
    [self getAttchmentsUrls];
    NSUInteger cnt = [attchments count];
    for (NSUInteger i=0; i < cnt; ++i)
    {
        if ([[movOrImg objectAtIndex:i] boolValue])
        {
            UIImageWriteToSavedPhotosAlbum ([UIImage imageWithData:[NSData dataWithContentsOfURL:[attchments objectAtIndex:i]]], nil, nil, nil);
                                                    
        }
        else
        {
            NSString *moviePath = [[attchments objectAtIndex:i] path];
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath))
            {
                UISaveVideoAtPathToSavedPhotosAlbum (
                                                     moviePath, nil, nil, nil);
            }
        }
   
    }
    [attchments removeAllObjects];
    [movOrImg   removeAllObjects];
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    pDlg.navViewController.navigationBar.topItem.title = [NSString stringWithString:title];
    pDlg.navViewController.navigationBar.topItem.leftBarButtonItem = nil;
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(camerarollAction) ];
    pDlg.navViewController.navigationBar.topItem.rightBarButtonItem = pBarItem1;
    [pDlg.navViewController setToolbarHidden:YES animated:YES];
    cnt = [photoSel count];
    for (NSUInteger i=0; i < cnt; ++i)
    {
        [photoSel replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:false]];
    }
    [self.tableView reloadData];
    [self setEmailphoto:false];
    return;
}

-(void) camerarollSelCancel
{
    NSLog(@"Cancelled camera roll save action\n");
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    pDlg.navViewController.navigationBar.topItem.title = [NSString stringWithString:title];
    pDlg.navViewController.navigationBar.topItem.leftBarButtonItem = nil;
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(camerarollAction) ];
    pDlg.navViewController.navigationBar.topItem.rightBarButtonItem = pBarItem1;
    [pDlg.navViewController setToolbarHidden:YES animated:YES];
    NSUInteger cnt = [photoSel count];
    for (NSUInteger i=0; i < cnt; ++i)
    {
        [photoSel replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:false]];
    }

    [self.tableView reloadData];
     [self setEmailphoto:false];
    return;
}


-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    printf("Clicked button at index %d\n", buttonIndex);
    
    switch (buttonIndex)
    {
        case 0:
            [self startMediaBrowserFromViewController:self
                                        usingDelegate: self];
            break;
        case 1:
        {
            NSString *title1 = @"Select photos";
            AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            pDlg.navViewController.navigationBar.topItem.title = [NSString stringWithString:title1];
            UIBarButtonItem *pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(camerarollSelDone)];
            pDlg.navViewController.navigationBar.topItem.rightBarButtonItem = pBarItem;
            UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(camerarollSelCancel)];
            pDlg.navViewController.navigationBar.topItem.leftBarButtonItem = pBarItem1;
            UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc]
                                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                        target:nil action:nil];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, self.view.frame.size.width, 21.0f)];
            [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
            [titleLabel setBackgroundColor:[UIColor clearColor]];
            [titleLabel setTextColor:[UIColor whiteColor]];
            [titleLabel setText:title];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            NSLog(@"Setting tool bar title %@ in save to camera roll operation\n", titleLabel);
            
            UIBarButtonItem *pBarItem2 = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
            
            [self setToolbarItems:[NSArray arrayWithObjects:
                                                          flexibleSpaceButtonItem,
                                                          pBarItem2,
                                                          flexibleSpaceButtonItem,
                                                          nil]
                                                animated:YES];
            [pDlg.navViewController setToolbarHidden:NO animated:YES];
            [self setEmailphoto:true];
            
            
        }
        break;
            
        default:
            break;
    }
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    bool bReload = false;
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo)
    {
        bReload = true;
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        // Do something with imageToUse
        
        
        if ([pAddEditCntrl isKindOfClass:[AddViewController class]])
        {
            AddViewController *pAddCntrl = (AddViewController *) pAddEditCntrl;
            [pAddCntrl saveImage:imageToUse];
        }
        else
        {
            EditViewController *pEditCntrl = (EditViewController *) pAddEditCntrl;
            [pEditCntrl saveImage:imageToUse];
        }
    }
    
    // Handle a movied picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo)
    {
        bReload = true;   
        NSURL *movie = [info objectForKey:UIImagePickerControllerMediaURL];
        if ([pAddEditCntrl isKindOfClass:[AddViewController class]])
        {
            AddViewController *pAddCntrl = (AddViewController *) pAddEditCntrl;
            [pAddCntrl saveMovie:movie];
        }
        else
        {
            EditViewController *pEditCntrl = (EditViewController *) pAddEditCntrl;
            [pEditCntrl saveMovie:movie];
        }

        // Do something with the picked movie available at moviePath
    }
    
    //[[picker parentViewController] dismissModalViewControllerAnimated: YES];
    
    [picker dismissViewControllerAnimated:YES completion:^(void)
    {
        if(bReload)
        {
            if(!bIniCloud)
                [self noIcloudInit];
            [self.tableView reloadData];
        }
        NSLog(@"Reloaded album contents view controller after picking from camera roll\n");
    }];
    

}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

-(void) viewWillDisappear:(BOOL)animated
{
      [super viewWillDisappear:animated];
    NSLog(@"DisplayViewController will disappear\n");
    if (query != nil)
    {
        
        if (![query isStopped])
        {
            NSLog(@"Stop query in AlbumContentsViewController\n");
            [query stopQuery];
            processQuery = false;
        }
    }


    return;
}

- (void)viewDidUnload 
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    if (query != nil)
    {
        NSLog(@"Stopping iCloud query in AlbumContentsViewController\n");
        [query stopQuery];
    }
}


- (void)dealloc {
  
   
}

@end


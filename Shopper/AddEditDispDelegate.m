//
//  AddEditDispDelegate.m
//  Shopper
//
//  Created by Ninan Thomas on 3/5/16.
//
//

#import "AddEditDispDelegate.h"
#import "AppDelegate.h"
#import "common/textdefs.h"

@implementation AddEditDispDelegate

@synthesize pNewItem;

-(void) initializeNewItem
{
    pNewItem = [[LocalItem alloc] init];
    pNewItem.year = 3000;
    pNewItem.price = [NSNumber numberWithDouble:-2.0];
    pNewItem.area = [NSNumber numberWithDouble:-2.0];
    pNewItem.beds = [NSNumber numberWithDouble:-2.0];
    pNewItem.baths = [NSNumber numberWithDouble:-2.0];
    pNewItem.val2 = 0.0;
    return;
}

-(void) setAlbumNames:(NSString *)noStr fullName:(NSString *)urlStr
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    pNewItem.album_name = noStr;
    pDlg.pAlName = urlStr;
    return;
}

-(void) deleteEditItem
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pDlg.dataSync deletedItem:pDlg.editItem];
}

-(void) setEditAlbumNames:(NSString *)noStr fullName:(NSString *)urlStr
{
     AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    pDlg.editItem.album_name = noStr;
    pDlg.pAlName = urlStr;

}

-(void) setLocation:(double) lat longitude:(double) longtde
{
    pNewItem.latitude = lat;
    pNewItem.longitude = longtde;
    NSLog(@"Setting new item longitude=%f and latitude=%f\n", longtde, lat);
    return;
}

-(void) stopLocUpdate
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pDlg stopLocUpdate];
    return;
}

-(bool) updateAddress:(NSString *)street city:(NSString *)city state:(NSString *) state country:(NSString * )country zip:(NSString *)zip
{
    if ([pNewItem.street isEqualToString:street] && [pNewItem.city isEqualToString:city] && [pNewItem.state isEqualToString:state] &&[pNewItem.country isEqualToString:country] && [pNewItem.zip isEqualToString:zip])
    {
        NSLog (@"Addres did not change in updatePlaceMark not updating\n");
        return  false;
    }
    else
    {
        pNewItem.street = street;
        pNewItem.country =country;
        pNewItem.state = state;
        pNewItem.city = city;
        pNewItem.zip = zip;
    }
    return true;
}

-(void) incrementPicCnt
{
    ++pNewItem.pic_cnt;
    return;
}

-(void) saveQAdd:(NSInvocationOperation*) theOp
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pDlg.saveQ addOperation:theOp];
}

- (void) populateValues:(UITextField *)textField
{
    
    switch (textField.tag)
    {
        case HOUSE_NAME:
            pNewItem.name = textField.text;
            break;
            
        case HOUSE_PRICE:
        {
            
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet]];
            pNewItem.price = [NSNumber  numberWithDouble:strtod([pr UTF8String], NULL)];
            
        }
            break;
            
            
        case HOUSE_AREA:
        {
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet]];
            pNewItem.area = [NSNumber  numberWithDouble:strtod([pr UTF8String], NULL)];
        }
            break;
            
        case HOUSE_YEAR:
        {
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]];
            pNewItem.year = atoi([pr UTF8String]);
        }
            break;
            
        case HOUSE_BEDS:
        {
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet]];
            pNewItem.beds = [NSNumber  numberWithDouble:strtod([pr UTF8String], NULL)];
        }
            break;
            
        case HOUSE_BATHS:
        {
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet]];
            pNewItem.baths = [NSNumber  numberWithDouble:strtod([pr UTF8String], NULL)];
        }
            break;
            
        case HOUSE_STREET:
            pNewItem.street = textField.text;
            break;
            
        case HOUSE_CITY:
            pNewItem.city = textField.text;
            break;
            
        case HOUSE_STATE:
            pNewItem.state = textField.text;
            break;
            
        case HOUSE_RATINGS:
            pNewItem.str2 = textField.text;
            break;
            
        case HOUSE_COUNTRY:
            pNewItem.country = textField.text;
            break;
            
        case HOUSE_ZIP:
            pNewItem.zip = textField.text;
            break;
            
        default:
            break;
            
    }
}

-(NSString *) deleteButtonTitle
{
    return @"Delete House";
}

-(NSUInteger) getShareId
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [pDlg getShareId];
}

-(void) populateEditTextFields:(UITextField *) textField textField1:(UITextField *) textField1 row:(NSUInteger)row
{
     AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    switch (row)
    {
        case 2:
        {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            if ([pDlg.editItem.area  doubleValue] >= 0.0 )
            {
                char area1[64];
                sprintf(area1, "%.0f", [pDlg.editItem.area floatValue]);
                textField.text = [NSString stringWithUTF8String:area1];
            }
            textField.tag = HOUSE_AREA;
            
            if (pDlg.editItem.year != 3000)
            {
                char year1[64];
                sprintf(year1, "%d", pDlg.editItem.year);
                textField1.text = [NSString stringWithUTF8String:year1];
            }
            textField1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField1.tag = HOUSE_YEAR;
            
        }
            break;
            
        case 3:
        {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            if ([pDlg.editItem.beds  doubleValue] >= 0.0 )
            {
                char beds1[64];
                sprintf(beds1, "%.0f", [pDlg.editItem.beds floatValue]);
                textField.text = [NSString stringWithUTF8String:beds1];
            }
            textField.tag = HOUSE_BEDS;
            
            if ([pDlg.editItem.baths  doubleValue] >= 0.0 )
            {
                char baths1[64];
                sprintf(baths1, "%.1f", [pDlg.editItem.baths floatValue]);
                textField1.text = [NSString stringWithUTF8String:baths1];
            }
            textField1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField1.tag = HOUSE_BATHS;
        }
            break;
            
        case 0:
            textField.text = pDlg.editItem.name;
            textField.tag = HOUSE_NAME;
            break;
            
        case 1:
        {
            if ([pDlg.editItem.price  doubleValue] >= 0.0 )
            {
                char price1[64];
                sprintf(price1, "%.2f", [pDlg.editItem.price floatValue]);
                textField.text = [NSString stringWithUTF8String:price1];
            }
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField.tag = HOUSE_PRICE;
        }
            break;
            
        case 9:
            textField.text = pDlg.editItem.str2;
            textField.tag = HOUSE_RATINGS;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
            
        case 10:
            textField.text = pDlg.editItem.street;
            textField.tag = HOUSE_STREET;
            break;
            
        case 11:
        {
            textField.text = pDlg.editItem.city;
            textField.tag = HOUSE_CITY;
        }
            break;
            
        case 12:
            textField.text = pDlg.editItem.state;
            textField.tag = HOUSE_STATE;
            break;
        case 13:
            textField.text = pDlg.editItem.country;
            textField.tag = HOUSE_COUNTRY;
            break;
        case 14:
            textField.text = pDlg.editItem.zip;
            textField.tag = HOUSE_ZIP;
            break;
            

        default:
            break;
    }

    return;
}

-(NSString *) getName
{
    return pNewItem.name;
}

-(void) populateTextFields:(UITextField *) textField textField1:(UITextField *) textField1 row:(NSUInteger)row
{
    switch (row)
    {
        case 2:
        {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            if ([pNewItem.area floatValue] >= 0.0)
            {
                char area1[64];
                sprintf(area1, "%.2f", [pNewItem.area floatValue]);
                textField.text = [NSString stringWithUTF8String:area1];
            }
            textField.tag = HOUSE_AREA;
            
            if (pNewItem.year != 3000)
            {
                char year1[64];
                sprintf(year1, "%d", pNewItem.year);
                textField1.text = [NSString stringWithUTF8String:year1];
            }
            textField1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField1.tag = HOUSE_YEAR;
            
        }
            break;
            
        case 3:
        {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            if ([pNewItem.beds doubleValue] >= 0.0 )
            {
                char beds1[64];
                sprintf(beds1, "%.2f", [pNewItem.beds floatValue]);
                textField.text = [NSString stringWithUTF8String:beds1];
            }
            textField.tag = HOUSE_BEDS;
            
            if ([pNewItem.baths doubleValue] >= 0.0 )
            {
                char baths1[64];
                sprintf(baths1, "%.2f", [pNewItem.baths floatValue]);
                textField1.text = [NSString stringWithUTF8String:baths1];
            }
            textField1.tag = HOUSE_BATHS;
            
            textField1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        }
            break;
        case 0:
        {
            AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (pNewItem.name == nil)
            {
                NSString *pHseName = @"House";
                NSString *intStr = [[NSNumber numberWithLongLong:pDlg.COUNT+1] stringValue];
                pHseName = [pHseName stringByAppendingString:intStr];
                textField.text = pHseName;
                pNewItem.name = pHseName;
            }
            else
            {
                textField.text = pNewItem.name;
            }
            textField.tag = HOUSE_NAME;
            
        }
        break;
            
        case 1:
        {
            if ([pNewItem.price doubleValue] >= 0.0)
            {
                char price1[64];
                sprintf(price1, "%.2f", [pNewItem.price floatValue]);
                textField.text = [NSString stringWithUTF8String:price1];
                
            }
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField.tag = HOUSE_PRICE;
            
        }
            break;
            
        case 9:
            textField.text = pNewItem.str2;
            textField.tag = HOUSE_RATINGS ;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
            

            
        case 10:
            textField.text = pNewItem.street;
            textField.tag = HOUSE_STREET ;
            break;
            
        case 11:
        {
            textField.text = pNewItem.city;
            textField.tag = HOUSE_CITY ;
            NSLog(@"Setting city to %@\n", pNewItem.city);
        }
            break;
            
        case 12:
            textField.text = pNewItem.state;
            textField.tag = HOUSE_STATE ;
            break;
        case 13:
            textField.text = pNewItem.country;
            textField.tag = HOUSE_COUNTRY ;
            break;
        case 14:
            textField.text = pNewItem.zip;
            textField.tag = HOUSE_ZIP ;
            break;
            


            
        default:
            break;
    }


    return;
}

-(NSArray *) getFieldNames
{
    return [NSArray arrayWithObjects:@"Name", @"Price", @"Area", @"Beds", @"Camera", @"Check List",  @"Notes", @"Pictures", @"Map", @"Ratings",  @"Street", @"City", @"State", @"Country", @"Postal Code", nil];
}

-(NSArray *) getFieldDispNames
{
    return [NSArray arrayWithObjects:@"Name", @"Price", @"Area", @"Beds", @"Check List",  @"Notes", @"Pictures", @"Map", @"Ratings",  @"Street", @"City", @"State", @"Country", @"Postal Code", nil];
}

-(NSArray *) getSecondFieldNames
{
    return  [NSArray arrayWithObjects:@"Blank", @"Blank", @"Year", @"Baths", nil];
}

-(bool) isTwoFieldRow:(NSUInteger) row
{
    if (row ==2 || row == 3)
        return true;
    return false;
}

-(CGRect) getTextFrame
{
    return CGRectMake(75, 12, 85, 25);
}

-(UILabel *) getLabel
{
    return [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 75, 25)];
}

-(bool) isSingleFieldEditRow:(NSUInteger) row
{
    if(row < 2 || (row > 8 && row < 15 ))
        return true;
    return false;
}

-(bool) isSingleFieldRow:(NSUInteger) row
{
     if (row < 2 || row > 8)
      return true;
    return false;
}

-(void) incrementEditPicCnt
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ++pDlg.editItem.pic_cnt;
    return;
}

-(void) itemAddCancel
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pDlg itemAddCancel];
}

-(void) itemAddDone
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pDlg itemAddDone];
}

-(void) itemEditCancel
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pDlg itemEditCancel];
    return;
}

-(void) itemEditDone
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pDlg itemEditDone];
    return;
}

-(void) itemEdit
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [pDlg itemEdit];
    return;
}

-(NSString *) setTitle
{
    NSString *title = @"House Info";
    return  title;
}

-(NSString *) getEditItemTitle
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *title ;
    if (pDlg.editItem.street != nil)
        title = pDlg.editItem.street;
    else
        title = @" ";
    return title;
}

-(NSString *) getAlbumTitle;
{
    NSString *title ;
    if (pNewItem.street != nil)
        title = pNewItem.street;
    else
        title = @" ";
    return title;
}

-(NSString *) getNotes
{
    return pNewItem.notes;
}

-(NSString *) getEditNotes
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return pDlg.editItem.notes;
}

-(NSString *) getDispNotes
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return pDlg.selectedItem.notes;
}

-(bool) changeCharacters:(NSInteger) tag
{
    switch (tag)
    {
        case HOUSE_PRICE:
        case HOUSE_AREA:
        case HOUSE_BATHS:
        case HOUSE_BEDS:
        case HOUSE_YEAR:
            return false;
            break;
            
        default:
            return true;
        break;
    }

    return true;
}

-(bool) rangeFourTag:(NSInteger) tag
{
    if (tag == HOUSE_YEAR)
        return true;
    return false;
}
-(bool) ratingsTag:(NSInteger) tag
{
    return tag == HOUSE_RATINGS;
}

- (BOOL)characterChk:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"Text field should change character %s %ld %lu %lu\n", [textField.text UTF8String], (long)textField.tag, (unsigned long)range.location , (unsigned long)range.length);
    switch (textField.tag)
    {
        case HOUSE_PRICE:
        case HOUSE_AREA:
        case HOUSE_BATHS:
        case HOUSE_BEDS:
        case HOUSE_YEAR:
        case HOUSE_RATINGS:
            break;
            
        default:
            return YES;
            break;
    }
    
    static NSString *numbers = @"0123456789";
    static NSString *numbersPeriod = @"01234567890.";
    
    
    //NSLog(@"%d %d %@", range.location, range.length, string);
    if (range.length > 0 && [string length] == 0) {
        // enable delete
        return YES;
    }
    
    // NSString *symbol = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    NSString *symbol = @".";
    if (range.location == 0 && [string isEqualToString:symbol]) {
        // decimalseparator should not be first
        return NO;
    }
    NSCharacterSet *characterSet;
    if (textField.tag == HOUSE_YEAR)
    {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet].location != NSNotFound)
        {
            return NO;
        }
        NSString *proposedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (proposedText.length > 4)        {
            return NO;
        }
               characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbers] invertedSet];
    }
    else if (textField.tag == HOUSE_RATINGS)
    {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet].location != NSNotFound)
        {
            return NO;
        }
          NSString *proposedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (proposedText.length > 1)
        {
            return NO;
        }

        if ([proposedText intValue] < 0 || [proposedText intValue] >10)
            return NO;
        characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbers] invertedSet];
    }
    else
    {
        
        NSRange separatorRange = [textField.text rangeOfString:symbol];
        if (separatorRange.location == NSNotFound)
        {
            //  if ([symbol isEqualToString:@"."]) {
            characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbersPeriod] invertedSet];
        }
        else
        {
            // allow 2 characters after the decimal separator
            if (range.location > (separatorRange.location + 2))
            {
                return NO;
            }
            characterSet = [[NSCharacterSet characterSetWithCharactersInString:numbers] invertedSet];
        }
    }
    return ([[string stringByTrimmingCharactersInSet:characterSet] length] > 0);

    
}


-(bool) numbersTag:(NSInteger) tag;
{
    if (tag == HOUSE_YEAR)
        return true;
    return false;
}

-(double) getLongitude
{
    return pNewItem.longitude;
}

-(double) getEditLongitude
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return pDlg.editItem.longitude;
}

-(double) getEditLatitude
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return pDlg.editItem.latitude;
}

-(NSString *) getEditName
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return pDlg.editItem.name;
}

-(NSUInteger) getEditItemShareId
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return pDlg.editItem.share_id;
}

-(double) getDispLongitude
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return pDlg.selectedItem.longitude;
}

-(double) getDispLatitude
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return pDlg.selectedItem.latitude;
}

-(NSString *) getDispName
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return pDlg.selectedItem.name;
}

-(double) getLatitude
{
    return pNewItem.latitude;
}

- (void) populateEditValues:(UITextField *)textField
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    switch (textField.tag)
    {
        case HOUSE_NAME:
            pDlg.editItem.name = textField.text;
            break;
            
        case HOUSE_PRICE:
        {
            
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet]];
            pDlg.editItem.price = [NSNumber  numberWithDouble:strtod([pr UTF8String], NULL)];
            
        }
            break;
            
            
        case HOUSE_AREA:
        {
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet]];
            pDlg.editItem.area = [NSNumber  numberWithDouble:strtod([pr UTF8String], NULL)];
        }
            break;
            
        case HOUSE_YEAR:
        {
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]];
            pDlg.editItem.year = atoi([pr UTF8String]);
        }
            break;
            
        case HOUSE_BEDS:
        {
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet]];
            pDlg.editItem.beds = [NSNumber  numberWithDouble:strtod([pr UTF8String], NULL)];
        }
            break;
            
        case HOUSE_BATHS:
        {
            NSString *pr = [textField.text stringByTrimmingCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet]];
            pDlg.editItem.baths = [NSNumber  numberWithDouble:strtod([pr UTF8String], NULL)];
        }
            break;
            
        case HOUSE_STREET:
            pDlg.editItem.street = textField.text;
            break;
            
        case HOUSE_CITY:
            pDlg.editItem.city = textField.text;
            break;
            
        case HOUSE_RATINGS:
            pDlg.editItem.str2 = textField.text;
            break;

            
        case HOUSE_STATE:
            pDlg.editItem.state = textField.text;
            break;
            
        case HOUSE_COUNTRY:
            pDlg.editItem.country = textField.text;
            break;
            
        case HOUSE_ZIP:
            pDlg.editItem.zip = textField.text;
            break;
            
        default:
            break;
            
    }
}

-(NSString *) getDispItemTitle
{
    NSString *title ;
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (pDlg.selectedItem.street != nil)
        title = pDlg.selectedItem.street;
    else
        title = @" ";
    return title;
}

-(void) populateDispTextFields:(UILabel *) textField textField1:(UILabel *) textField1 row:(NSUInteger)row
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
            
            
        case 8:
            textField.text = pDlg.selectedItem.str2;
            break;
            
        case 9:
            textField.text = pDlg.selectedItem.street;
            break;
            
        case 10:
            textField.text = pDlg.selectedItem.city ;
            break;
            
        case 11:
            textField.text = pDlg.selectedItem.state;
            break;
            
        case 12:
            textField.text = pDlg.selectedItem.country;
            break;
        case 13:
            textField.text = pDlg.selectedItem.zip;
            break;
            

        default:
            break;
    }
    

    return;
}

-(void ) setAddNotes:(NSString *)notes
{
    pNewItem.notes = notes;
    NSLog(@"Setting notes in add item %@", notes);
}

-(void) setEditNotes: (NSString *)notes
{
    AppDelegate *pDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    pDlg.editItem.notes = notes;
    
}

-(bool) isSingleFieldDispRow:(NSUInteger) row
{
    if (row < 2 || row > 7)
        return true;
    return false;
}

@end

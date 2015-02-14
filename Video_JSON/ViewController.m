//
//  ViewController.m
//  Video_JSON
//
//  Created by Nathan Poag on 12/1/14.
//  Copyright (c) 2014 Nathan Poag. All rights reserved.
//

#import "ViewController.h"
#import "Place.h"
#import "placeTableCell.h"

#import <QuartzCore/QuartzCore.h>
#import "UIImage+ImageEffects.h"
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]
@interface ViewController ()

@end

@implementation ViewController{
    CLLocationManager *locationManager;
}
@synthesize autocompleteTextField, autocompletePlaces, pastPlaces, placesAsProperties, autocompleteTableView,posts, placesAsPropertiesTemp, rawDetails, place_id_storage, placeDetails, placeDetailsTemp, refreshControl, favorites_manager, currentLatitude, currentLongitude, googlePowered, currentSection, finishedLoadingData, cellHeight;
int i = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self CurrentLocationIdentifier];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]];
    // Do any additional setup after loading the view, typically from a nib.
   //[self.view setBackgroundColor:[UIColor clearColor]];
    self.finishedLoadingData = NO;
    self.googlePowered.image = [UIImage imageNamed:@"Image"];
    self.googlePowered.contentMode = UIViewContentModeCenter;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    float scaleFactor = [[UIScreen mainScreen] scale];
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat widthInPixel = screen.size.width * scaleFactor;
    CGFloat heightInPixel = screen.size.height * scaleFactor;
    self.view.frame = CGRectMake(0, 0, widthInPixel, heightInPixel);
    //self.view.userInteractionEnabled = NO;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    UIView *blurredView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImage *image = [UIImage imageNamed:@"ios7_BG.png"];
    image = [image applyBlurWithRadius:1 tintColor:[UIColor colorWithWhite:1.0 alpha:0.3] saturationDeltaFactor:2.4 maskImage:nil];
    [blurredView setBackgroundColor:[UIColor colorWithPatternImage:image]];
    //[self addBlurToView:blurredView];
    [self.view insertSubview:blurredView atIndex:0];
    //self.view.backgroundColor =  [UIColor colorWithPatternImage:image];//[UIColor colorWithPatternImage:image];
    
    self.cellHeight = 205;
    self.view.userInteractionEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
    self.tableView.scrollsToTop = YES;
    self.prefs = [NSUserDefaults standardUserDefaults];
    self.autocompletePlaces = [[NSMutableArray alloc] init];
    self.pastPlaces = [[NSMutableArray alloc] init];
    self.placesAsProperties = [[NSMutableArray alloc] init];
    self.placesAsPropertiesTemp = [[NSMutableArray alloc] init];
    self.placeDetailsTemp = [[NSMutableArray alloc] init];
    self.placeDetails = [[NSMutableArray alloc] init];
    self.posts = [[NSMutableDictionary alloc] init];
    self.rawDetails = [[NSMutableDictionary alloc] init];
    self.place_id_storage = [[NSMutableArray alloc] init];
    [self.place_id_storage addObjectsFromArray:[self.prefs arrayForKey:@"place_id_favorites"]];
    //autocompleteTextField = [[UITextField alloc] initWithFrame:CGRectMake(0,80, 900, 120)];
    self.autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,58, 420, 120)];
    self.autocompleteTableView.delegate = self;
    self.autocompleteTextField.delegate = self;
    self.autocompleteTextField.placeholder=@"Search for a place";
    self.autocompleteTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.autocompleteTextField.returnKeyType = UIReturnKeyDone;
    self.autocompleteTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocompleteTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.autocompleteTableView.dataSource = self;
    self.autocompleteTableView.scrollEnabled = YES;
    self.autocompleteTableView.hidden = YES;
    self.autocompleteTableView.backgroundColor = [UIColor clearColor];
   // self.autocompleteTableView.opaque = YES;
    self.favorites_manager = [[UITableViewController alloc] init];
    [self.view addSubview:self.autocompleteTableView];
    [self.autocompleteTableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
    [autocompleteTextField addTarget:self
                              action:@selector(textFieldDidChange:)
                    forControlEvents:UIControlEventEditingChanged];
    
    self.favorites_manager.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.favorites_manager.refreshControl = self.refreshControl;
    if(self.place_id_storage.count > 0)
        [self createFavoritePlaces];
    self.tableView.opaque = NO;
     self.tableView.backgroundColor = [UIColor clearColor];
    
   // [self.tableView setBackgroundColor:UIColorFromRGB(0x2E3E51)];
    //[self.view setBackgroundColor:[UIColor blackColor]];//UIColorFromRGB(0x2E3E51)];
//    [self.view setBackgroundColor:UIColorFromRGB(0x2E3E51)];
     //[self addBlurToView:self.view];
    }

//-(void)imageSelected
//{
//    [self.view endEditing:YES];
//    NSLog(@"Selected an Image");
//}
- (void)hideKeyboard {
    self.autocompleteTableView.hidden = YES;
    self.autocompleteTextField.text = @"";
    [self.view endEditing:YES];
}
- (IBAction)didReceiveValue:(id)sender {
    NSLog(@"GOT TOUCHED");
}

-(void)CurrentLocationIdentifier
{
    //---- For getting current gps location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    //------
    NSLog(@"HELLO THIS IS A TEST %@",[locationManager location]);
}

- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
        return [tableView isEqual:self.tableView];
    
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSLog(@"INDEX PATH SECTION %lu",indexPath.section);
        [self.place_id_storage removeObjectAtIndex:indexPath.section];
        [self.prefs setObject:self.place_id_storage forKey:@"place_id_favorites"];
         [self.placeDetails removeObjectAtIndex:indexPath.section];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]withRowAnimation:UITableViewRowAnimationFade];
       
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        self.currentLongitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        self.currentLatitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
}


-(void)getJSONData: (NSString *) input completion:(void (^)(void))dataReceived
{
    NSLog(@"getJSONData");
    NSString *urlMod = [input stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSLog(@"LATITUDE: %@ and LONGITUDE: %@ ",self.currentLatitude, self.currentLongitude);
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%@,%@&radius=500&key=AIzaSyD9CaxjnEVMMKNYKAlP0houvQpMXi9VYIM",urlMod,self.currentLatitude,self.currentLongitude];
    NSLog(@"THI IS URL: %@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         if(error){
             NSLog(@"%@",[error localizedDescription]);
         }
         else{
             self.posts = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 
                 
                 if (dataReceived != nil)
                     dataReceived();
             }];
             
         }
         
     }];
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    CGRect frame = self.autocompleteTableView.frame;
    frame.size = self.autocompleteTableView.contentSize;
    self.autocompleteTableView.frame = frame;
}

- (void)refresh:(id)sender
{
    [self.favorites_manager.refreshControl beginRefreshing];
    if(self.place_id_storage.count > 0)
        [self createFavoritePlaces];
    else
        [self didReceiveData];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // done button was pressed - dismiss keyboard
    [textField resignFirstResponder];
    self.autocompleteTableView.hidden = YES;
    self.autocompleteTextField.text = @"";
    return YES;
}



-(void)getJSONPlaceDetails:(NSString *) place_id{
    NSLog(@"getJSONPlaceDetails");
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyD9CaxjnEVMMKNYKAlP0houvQpMXi9VYIM",place_id];
    Place *individualPlace = [[Place alloc] init];
    static NSURLSession* sharedSessionMainQueue = nil;
    if(!sharedSessionMainQueue){
        sharedSessionMainQueue = [NSURLSession sessionWithConfiguration:nil delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSLog(@"RIGHT BEFORE CONNECTION");
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error){
             NSLog(@"%@",[error localizedDescription]);
         }
         else{
             self.rawDetails = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
             NSDictionary *placeInfo = self.rawDetails[@"result"];
             
             //            NSLog(@"current place_id %@",placeInfo[@"place_id"]);
             
             NSLog(@"getJSONPlaceDetails 2");
             individualPlace.name = placeInfo[@"name"];
             //            NSLog(@"this is the placeInfo %@",placeInfo[@"name"]);
             individualPlace.address = placeInfo[@"formatted_address"];
             individualPlace.location = CLLocationCoordinate2DMake([placeInfo[@"geometry"][@"location"][@"lat"] doubleValue], [placeInfo[@"geometry"][@"location"][@"lng"] doubleValue]);
             //             NSLog(@"%s\n", object_getClassName([[individualPlace hasHours] class]));
             individualPlace.hasHours = !(placeInfo[@"opening_hours"][@"open_now"] == nil);
             if(individualPlace.hasHours)
               individualPlace.placeHours = placeInfo[@"opening_hours"][@"weekday_text"];
                 
                     
             

             //    NSLog(@"printing before %d",[individualPlace.hasHours ]);
             
             // NSLog(@"ALL KEYS %d",[photoDict isKindOfClass:[NSArray class]]);
             
             if(placeInfo[@"photos"] != nil)
             {
                 
                 individualPlace.hasPhotos = YES;
                 
                 //  NSLog(@"being run %@",self.rawDetails[@"result"][@"photos"][@"photo_reference"]);
                 
                 
                 NSDictionary *photoDict = [[placeInfo objectForKey:@"photos"] objectAtIndex:0];
    
                 NSString *photoRef = [photoDict objectForKey:@"photo_reference"];
                 
                 
                 individualPlace.urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?photoreference=%@&key=AIzaSyD9CaxjnEVMMKNYKAlP0houvQpMXi9VYIM&sensor=false&maxwidth=600", photoRef];
                 NSLog(@"URL TO TEST %@", individualPlace.urlString);
                 individualPlace.url = [NSURL URLWithString:individualPlace.urlString];
             }
             else
                 individualPlace.hasPhotos = NO;
             id rawIsOpen = placeInfo[@"opening_hours"][@"open_now"];
             individualPlace.isOpen = [rawIsOpen boolValue];
             individualPlace.place_id = placeInfo[@"place_id"];
             NSLog(@"REACHING BOOLEAN");
             if(individualPlace.hasPhotos)
             {
                 NSLog(@"HAS PHOTOS");
                 NSURLSessionDataTask *dataTask =
                 [sharedSessionMainQueue dataTaskWithURL:individualPlace.url completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
                     //now will be on main thread
                     individualPlace.imgData = data;
                     BOOL hasData = individualPlace.imgData;
                     NSLog(@"RAW DATA %d",hasData);
                     
                     //NSString *temp =
                     //individualPlace.base64Encoded = [individualPlace.imgData base64EncodedDataWithOptions:0];//[temp dataUsingEncoding:NSUTF8StringEncoding];
                     
                     // [self didReceiveData];
                     [self.placeDetails addObject:individualPlace];
                     
                     i+=1;
                     NSLog(@"RAN METHOD getJSONDetails");
                     if(i<self.place_id_storage.count)
                     {
                         NSLog(@"adding other places %d",i);
                         [self getJSONPlaceDetails:self.place_id_storage[i]];
                         
                     }
                     else
                     {
                         
                         i = 0;
                         [self didReceiveData];
                     }
                 }];
                 [dataTask resume];
                 
             }
             else
             {
                 NSLog(@"DOESNT HAVE IMAGE");
                 [self.placeDetails addObject:individualPlace];
                 
                 i+=1;
                 NSLog(@"RAN METHOD i:%d and p_id:%lu",i,self.place_id_storage.count);
                 if(i<self.place_id_storage.count)
                 {
                     [self getJSONPlaceDetails:self.place_id_storage[i]];
                     
                     NSLog(@"RUN METHOD AFTERWARDS first %d",i);
                }
                 else
                 {
                     
                     i = 0;
                     [self didReceiveData];
                 }
             }
             
             
         }
         NSLog(@"EDGE OF BLOCK");
     }];
    NSLog(@"AFTER URL");
}



-(void)didReceiveData{
    
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.finishedLoadingData = YES;
        NSLog(@"PERFORMING RELOAD");
        [self.tableView reloadData];
        int64_t delayInSeconds = 1.0f;
        dispatch_time_t popTime =
        dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (self.refreshControl) {
                NSLog(@"IT FINISHED REFRESHING");
                [self.favorites_manager.refreshControl endRefreshing];
            }
        });
    }];
    
}
-(void)createFavoritePlaces
{
    NSLog(@"createFavoritePlaces");
    [self.placeDetails removeAllObjects];
    self.rawDetails = nil;
    [self getJSONPlaceDetails:self.place_id_storage[0]];
    NSLog(@"RUN METHOD AFTERWARDS 2");
}

-(void)textFieldDidChange:(UITextField *)input{
    [self getJSONData:input.text completion:^{
        
        NSArray *place = posts[@"predictions"];
        
        [self.placesAsPropertiesTemp removeAllObjects];
        for(NSDictionary *value in place)
        {
            
            Place *individualPlace = [[Place alloc] init];
            individualPlace.name = value[@"description"];
            individualPlace.location = CLLocationCoordinate2DMake([value[@"geometry"][@"location"][@"lat"] doubleValue], [value[@"geometry"][@"location"][@"lng"] doubleValue]);
            individualPlace.isOpen = value[@"opening_hours"][@"open_now"];
            individualPlace.place_id = value[@"place_id"];
            [self.placesAsPropertiesTemp addObject:individualPlace];
        }
        
        
        self.placesAsProperties = self.placesAsPropertiesTemp;
        [self.autocompleteTableView reloadData];
        
        
        if(autocompleteTextField.text && autocompleteTextField.text.length > 0)
        {
            //NSLog(@"THIS IS TO SEE IF IT ACTUALLY WORKS");
            self.autocompleteTableView.hidden = NO;
        }
        else{
            self.autocompleteTableView.hidden = YES;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"CELL FOR ROW");
    //for autocomplete tableView formatting
    if([tableView isEqual:self.autocompleteTableView])
    {
        NSLog(@"INDEX PATH ROW: %lu",indexPath.row);
        NSLog(@"PAS P %lu",self.placesAsProperties.count);
        UITableViewCell *cell = nil;
        
        static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
            
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
        }
        // NSLog(@"this is a test of 3.0 status %lu",indexPath.row);
//        cell.opaque = YES;
        
        cell.shouldIndentWhileEditing = YES;
        cell.backgroundColor = [UIColor clearColor];
            cell.imageView.frame = CGRectOffset(cell.frame, 90, 90);
        NSLog(@"BEFORE METHOD RUN");
        cell.textLabel.text = [[self.placesAsProperties objectAtIndex:indexPath.row] name];
        NSLog(@"AFTER METHOD RUN");
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            cell.preservesSuperviewLayoutMargins = NO;
        UIToolbar *translucentView = [[UIToolbar alloc] initWithFrame:CGRectZero];

        cell.backgroundView = translucentView;
        
        return cell;
    }
    else if(self.place_id_storage.count > 0){
        
        static NSString *simpleTableIdentifier = @"placeTableCell";
        placeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if(!cell)
        {
            [tableView registerNib:[UINib nibWithNibName:@"placeTableCell" bundle:nil] forCellReuseIdentifier:@"placeTableCell"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"placeTableCell"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            self.tableView.allowsSelection = NO;
            self.tableView.rowHeight = UITableViewAutomaticDimension;
            self.tableView.estimatedRowHeight = 205.0;
            
        }
        NSLog(@"CELL FOR ROW END");
        cell.hidden = YES;
        return cell;
    }
    
    return nil;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![tableView isEqual:self.autocompleteTableView])
        return 205;//self.cellHeight;
    else
        return 44;
//    return UITableViewAutomaticDimension;
    
}

-(void)didReceiveTap:(UITapGestureRecognizer *)gesture
{
    UIView *labelView = gesture.view;
    UILabel *label = (UILabel *)labelView;
    CGPoint buttonPosition = [label convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    placeTableCell *cell= (placeTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString *placeHoursString = [[self.placeDetails[indexPath.section] placeHours] componentsJoinedByString:@"\n"];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setFirstWeekday:1]; // Sunday == 1, Saturday == 7
    NSUInteger adjustedWeekdayOrdinal = [gregorian ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:[NSDate date]];
    //int weekday = (int)[comps weekday];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [self.view.layer addAnimation:transition forKey:nil];

    if(cell.placeHours.hidden)
    {
        NSLog(@"adjustedWeekdayOrdinal %lu",adjustedWeekdayOrdinal);
        NSLog(@"firstWeekday %lu",gregorian.firstWeekday);
//         if(adjustedWeekdayOrdinal < 7 && adjustedWeekdayOrdinal > 1)
//        cell.placeDescription.text = placeHoursTemp[adjustedWeekdayOrdinal-2];
//        else if(adjustedWeekdayOrdinal < 2)
//            cell.placeDescription.text = placeHoursTemp[6];
//        else
//            cell.placeDescription.text = placeHoursTemp[5];
        NSLog(@"THIS IS NAME: %@",cell.placeName.text);
        NSLog(@"THIS IS TAG: %lu",cell.noImageIndicator.tag);
        
               cell.placeImage.hidden = YES;
        cell.noImageIndicator.hidden = YES;
        cell.placeHours.hidden = NO;
       // cell.placeHours.text = placeHoursString;
        
        if(placeHoursString == nil)
            cell.placeHours.text = @"No Data";
//        else
//        {
//            self.cellHeight = 290;
//            [self.tableView beginUpdates];
//            [self.tableView endUpdates];
//        }
        
    }
    else
    {
        if(cell.noImageIndicator.tag == 1)
            cell.noImageIndicator.hidden = NO;
        cell.placeHours.hidden = YES;
        cell.placeImage.hidden = NO;
//        self.cellHeight = 205;
//        [self.tableView beginUpdates];
//        [self.tableView endUpdates];
        
    }
    
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(placeTableCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"WILL DISPLAY CELL START");
    if(![tableView isEqual:self.autocompleteTableView]&&self.finishedLoadingData){
//        cell.placeDescription.hidden = NO;
//        cell.placeName.hidden = NO;
//        cell.placeImage.hidden = NO;
//        cell.isOpenLabel.hidden = NO;
        cell.hidden = NO;
        //        NSLog(@"this is a test of 2.0 status %lu",indexPath.row);
        //        CGRect frame = CGRectOffset([tableView rectForRowAtIndexPath:indexPath], 0.0, 90.8);
        //    cell.backgroundColor = [[UIView alloc] initWithFrame: frame ];
        cell.isOpenLabel.textAlignment = NSTextAlignmentCenter;
        NSLog(@"FIRST BREAKPOINT");
        NSLog(@"placeDetails size: %lu and %lu and %lu",self.placeDetails.count,indexPath.section, self.place_id_storage.count);
        
        if([[self.placeDetails objectAtIndex:indexPath.section] isOpen]==YES)
        {
            NSLog(@"SECOND BREAKPOINT");
            cell.isOpenLabel.backgroundColor = UIColorFromRGB(0x39FF14);//[UIColor colorWithRed:57
//        green:255
//        blue:20
//        alpha:.9];//0x84E80C);
//            cell.isOpenLabel.textAlignment = NSTextAlignmentCenter;
            cell.isOpenLabel.text = @"OPEN";
//            CGFloat width =  ceil([cell.isOpenLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:21.0]}].width);
           // cell.isOpenLabel.frame = CGRectMake(275,142, width,10);



        }
        else if(([[self.placeDetails objectAtIndex:indexPath.section] isOpen]==NO)&&([[self.placeDetails objectAtIndex:indexPath.section] hasHours]==YES))
        {
            NSLog(@"THIRD BREAKPOINT");
            cell.isOpenLabel.backgroundColor = UIColorFromRGB(0xff0000);//[UIColor colorWithRed:204
//                                                               green:73
//                                                                blue:87
//                                                              alpha:.8];////0xFF6853);
//            cell.isOpenLabel.textAlignment = NSTextAlignmentCenter;
            cell.isOpenLabel.text = @"CLOSED";
//            CGFloat width =  ceil([cell.isOpenLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:21.0]}].width);
//            cell.isOpenLabel.frame = CGRectMake(275,142, width,21);
        }
        else
        {
            NSLog(@"FOURTH BREAKPOINT");
            cell.isOpenLabel.backgroundColor = UIColorFromRGB(0xC0C0C0);//[UIColor colorWithRed:192
//                                                               green:192
//                                                                blue:192
//                                                               alpha:.65];
            
            cell.isOpenLabel.text = @"NO DATA";
//            CGFloat width =  ceil([cell.isOpenLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:21.0]}].width);
//            cell.isOpenLabel.frame = CGRectMake(275,142, width,21);
        }
        NSLog(@"FIFTH BREAKPOINT");
        self.currentSection = indexPath.section;
         cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.65];
        cell.placeName.text = [[self.placeDetails objectAtIndex:indexPath.section] name];
        [cell.placeName setPreferredMaxLayoutWidth:200.0];
        UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveTap:)];
        tapped.delegate = self;
        tapped.numberOfTapsRequired = 1;
        [cell.isOpenLabel setUserInteractionEnabled:YES];
        [cell addGestureRecognizer:tapped];
         NSLog(@"SIXTH BREAKPOINT");
         [tapped setCancelsTouchesInView:NO];
        cell.placeImage.clipsToBounds = YES;
        cell.placeHours.text = [[self.placeDetails[indexPath.section] placeHours] componentsJoinedByString:@"\n"];
        cell.placeHours.hidden = YES;
        cell.placeHours.adjustsFontSizeToFitWidth = YES;
        cell.displayingHours = NO;
        cell.placeDescription.text = (NSString *)[[self.placeDetails objectAtIndex:indexPath.section] address];
        cell.placeHours.backgroundColor = [cell.isOpenLabel.backgroundColor colorWithAlphaComponent:0.5f];

       
        if([[self.placeDetails objectAtIndex:indexPath.section] imgData]!=nil)
        {
            NSLog(@"if placeDetails %@",[[self.placeDetails objectAtIndex:indexPath.section] name]);
            cell.placeImage.image = [UIImage imageWithData:[[self.placeDetails objectAtIndex:indexPath.section] imgData]];
            cell.placeImage.hidden = NO;
            cell.noImageIndicator.hidden = YES;
            cell.noImageIndicator.tag = 0;
        }
        else
        {
//            cell.placeImage.image = nil;
//            cell.placeImage.hidden = YES;
            cell.placeImage.image = [self imageWithColor:[UIColor clearColor]];
            cell.noImageIndicator.text = [[self.placeDetails objectAtIndex:indexPath.section] name];
            cell.noImageIndicator.adjustsFontSizeToFitWidth = YES;
            cell.noImageIndicator.hidden = NO;
            cell.noImageIndicator.tag = 1;
            cell.noImageIndicator.backgroundColor = [cell.isOpenLabel.backgroundColor colorWithAlphaComponent:0.5f];
        }
        //        if(!cell.placeImage.image)

    }
    if(self.googlePowered.hidden == YES)
        self.googlePowered.hidden = NO;
    NSLog(@"WILL DISPLAY CELL END");
}


- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    //this is the space
    // NSLog(@"THIS IS THE SECTION VALUE: %lu",section);
    if(section != 0 && [tableView isEqual:self.tableView])
        return 50;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}



-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
//    if([tableView isEqual:self.autocompleteTableView])
//        return [self.placesAsProperties count];
//    else if(self.placeDetails.count>0)
//        return 1;
//    else
//        return 0;
    
    
    if([tableView isEqual:self.autocompleteTableView])
        return [self.placesAsProperties count];
    else if(self.placeDetails.count>0)
        return 1;
    else
        return 0;
    
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    if([tableView isEqual:self.autocompleteTableView])
        return 1;
    else
        return self.place_id_storage.count;
    
//    if([tableView isEqual:self.autocompleteTableView])
//        return 1;
//    else if(self.placeDetails.count>0)
//        return self.place_id_storage.count;
//    else
//        return 0;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath{
    NSLog(@"RECEIVED TAP 2.0");
    if([tableView isEqual:self.autocompleteTableView]){
      //  UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
        if(![self.place_id_storage containsObject:[[self.placesAsProperties objectAtIndex:indexPath.row] place_id]]){
            [self.place_id_storage insertObject:[[self.placesAsProperties objectAtIndex:indexPath.row] place_id] atIndex:0];
            self.autocompleteTextField.text = @"";
            [self.prefs setObject:self.place_id_storage forKey:@"place_id_favorites"];
            [self createFavoritePlaces];
        }
        self.autocompleteTableView.hidden = YES;
        
        
    }
}


@end

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
@synthesize autocompleteTextField, autocompletePlaces, pastPlaces, placesAsProperties, autocompleteTableView,posts, placesAsPropertiesTemp, rawDetails, place_id_storage, placeDetails, placeDetailsTemp, refreshControl, favorites_manager, currentLatitude, currentLongitude, googlePowered, currentSection, finishedLoadingData, cellHeight, footerView, privacyPolicy;
int i = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self CurrentLocationIdentifier];
    self.finishedLoadingData = NO;
    self.googlePowered.image = [UIImage imageNamed:@"Image"];
    self.googlePowered.contentMode = UIViewContentModeCenter;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    float scaleFactor = [[UIScreen mainScreen] scale];
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat widthInPixel = screen.size.width * scaleFactor;
    CGFloat heightInPixel = screen.size.height * scaleFactor;
    self.view.frame = CGRectMake(0, 0, widthInPixel, heightInPixel);
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    UIView *blurredView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImage *image = [UIImage imageNamed:@"ios7_BG.png"];
    image = [image applyBlurWithRadius:1 tintColor:[UIColor colorWithWhite:1.0 alpha:0.3] saturationDeltaFactor:2.4 maskImage:nil];
    [blurredView setBackgroundColor:[UIColor colorWithPatternImage:image]];
    [self.view insertSubview:blurredView atIndex:0];
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
    NSString *html = [NSString stringWithFormat:
                      @" \
                      \
                      <h2> \
                      Mobile application Terms and Conditions of Use \
                      </h2> \
                      \
                      <h3> \
                      1. Terms \
                      </h3> \
                      \
                      <p> \
                      By accessing this mobile application, you are agreeing to be bound by these  \
                      mobile application Terms and Conditions of Use, all applicable laws and regulations,  \
                      and agree that you are responsible for compliance with any applicable local  \
                      laws. If you do not agree with any of these terms, you are prohibited from  \
                      using or accessing this site. The materials contained in this mobile application are  \
                      protected by applicable copyright and trade mark law. \
                      </p> \
                      \
                      <h3> \
                      2. Use License \
                      </h3> \
                      \
                      <ol type=\"a\"> \
                      <li> \
                      Permission is granted to temporarily download one copy of the materials  \
                      (information or software) on Open Place's mobile application for personal,  \
                      non-commercial transitory viewing only. This is the grant of a license,  \
                      not a transfer of title, and under this license you may not: \
                      \
                      <ol type=\"i\"> \
                      <li>modify or copy the materials;</li> \
                      <li>use the materials for any commercial purpose, or for any public display (commercial or non-commercial);</li> \
                      <li>attempt to decompile or reverse engineer any software contained on Open Place's mobile application;</li> \
                      <li>remove any copyright or other proprietary notations from the materials; or</li> \
                      <li>transfer the materials to another person or \"mirror\" the materials on any other server.</li> \
                      </ol> \
                      </li> \
                      <li> \
                      This license shall automatically terminate if you violate any of these restrictions and may be terminated by Open Place at any time. Upon terminating your viewing of these materials or upon the termination of this license, you must destroy any downloaded materials in your possession whether in electronic or printed format. \
                      </li> \
                      </ol> \
                      \
                      <h3> \
                      3. Disclaimer \
                      </h3> \
                      \
                      <ol type=\"a\"> \
                      <li> \
                      The materials on Open Place's mobile application are provided \"as is\". Open Place makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties, including without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights. Further, Open Place does not warrant or make any representations concerning the accuracy, likely results, or reliability of the use of the materials on its Internet mobile application or otherwise relating to such materials or on any sites linked to this site. \
                      </li> \
                      </ol> \
                      \
                      <h3> \
                      4. Limitations \
                      </h3> \
                      \
                      <p> \
                      In no event shall Open Place or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption,) arising out of the use or inability to use the materials on Open Place's Internet site, even if Open Place or a Open Place authorized representative has been notified orally or in writing of the possibility of such damage. Because some jurisdictions do not allow limitations on implied warranties, or limitations of liability for consequential or incidental damages, these limitations may not apply to you. \
                      </p> \
                      \
                      <h3> \
                      5. Revisions and Errata \
                      </h3> \
                      \
                      <p> \
                      The materials appearing on Open Place's mobile application could include technical, typographical, or photographic errors. Open Place does not warrant that any of the materials on its mobile application are accurate, complete, or current. Open Place may make changes to the materials contained on its mobile application at any time without notice. Open Place does not, however, make any commitment to update the materials. \
                      </p> \
                      \
                      <h3> \
                      6. Links \
                      </h3> \
                      \
                      <p> \
                      Open Place has not reviewed all of the sites linked to its Internet mobile application and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by Open Place of the site. Use of any such linked mobile application is at the user's own risk. \
                      </p> \
                      \
                      <h3> \
                      7. Site Terms of Use Modifications \
                      </h3> \
                      \
                      <p> \
                      Open Place may revise these terms of use for its mobile application at any time without notice. By using this mobile application you are agreeing to be bound by the then current version of these Terms and Conditions of Use. \
                      </p> \
                      <p> \
                      Users are also bound by <a href=\"https://www.google.com/intl/en/policies/terms/\">Google's Terms of Service</a> \
                      </p> \
                      \
                      <h3> \
                      8. Governing Law \
                      </h3> \
                      \
                      <p> \
                      Any claim relating to Open Place's mobile application shall be governed by the laws of the State of Texas without regard to its conflict of law provisions. \
                      </p> \
                      \
                      <p> \
                      General Terms and Conditions applicable to Use of a mobile application. \
                      </p> \
                      \
                      \
                      \
                      <h2> \
                      Privacy Policy \
                      </h2> \
                      \
                      <p> \
                      Your privacy is very important to us. Accordingly, we have developed this Policy in order for you to understand how we collect, use, communicate and disclose and make use of personal information. The following outlines our privacy policy. \
                      </p> \
                      \
                      <ul> \
                      <li> \
                      Google Place's API is integrated into Open Place's mobile application and we must provide a reference to <a href=\"https://www.google.com/policies/privacy/\">Google's Privacy Policy</a> \
                      </li> \
                      \
                      <li> \
                      Before or at the time of collecting personal information, we will identify the purposes for which information is being collected. \
                      </li> \
                      <li> \
                      We will collect and use of personal information solely with the objective of fulfilling those purposes specified by us and for other compatible purposes, unless we obtain the consent of the individual concerned or as required by law.		 \
                      </li> \
                      <li> \
                      We will only retain personal information as long as necessary for the fulfilment of those purposes.  \
                      </li> \
                      <li> \
                      We will collect personal information by lawful and fair means and, where appropriate, with the knowledge or consent of the individual concerned.  \
                      </li> \
                      <li> \
                      Personal data should be relevant to the purposes for which it is to be used, and, to the extent necessary for those purposes, should be accurate, complete, and up-to-date.  \
                      </li> \
                      <li> \
                      We will protect personal information by reasonable security safeguards against loss or theft, as well as unauthorized access, disclosure, copying, use or modification. \
                      </li> \
                      <li> \
                      We will make readily available to customers information about our policies and practices relating to the management of personal information.  \
                      </li> \
                      </ul> \
                      \
                      <p> \
                      We are committed to conducting our business in accordance with these principles in order to ensure that the confidentiality of personal information is protected and maintained.  \
                      </p>		 \
                      \
                      \
                      "];
    [privacyPolicy setOpaque:NO];
    [privacyPolicy loadHTMLString:html baseURL:nil];
    
   
    }


- (void)hideKeyboard {
    self.autocompleteTableView.hidden = YES;
    self.autocompleteTextField.text = @"";
    [self.view endEditing:YES];
}

- (void)dealloc
{
    [self.autocompleteTableView removeObserver:self forKeyPath:@"contentSize"];
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
    NSString *urlMod = [input stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%@,%@&radius=500&key=AIzaSyD9CaxjnEVMMKNYKAlP0houvQpMXi9VYIM",urlMod,self.currentLatitude,self.currentLongitude];
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



-(void)getJSONPlaceDetails:(NSString *) place_id
{

    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyD9CaxjnEVMMKNYKAlP0houvQpMXi9VYIM",place_id];
    Place *individualPlace = [[Place alloc] init];
    static NSURLSession* sharedSessionMainQueue = nil;
    if(!sharedSessionMainQueue){
        sharedSessionMainQueue = [NSURLSession sessionWithConfiguration:nil delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error){
             NSLog(@"%@",[error localizedDescription]);
         }
         else{
             self.rawDetails = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
             NSDictionary *placeInfo = self.rawDetails[@"result"];
             individualPlace.name = placeInfo[@"name"];
             individualPlace.address = placeInfo[@"formatted_address"];
             individualPlace.location = CLLocationCoordinate2DMake([placeInfo[@"geometry"][@"location"][@"lat"] doubleValue], [placeInfo[@"geometry"][@"location"][@"lng"] doubleValue]);
             individualPlace.hasHours = !(placeInfo[@"opening_hours"][@"open_now"] == nil);
             if(individualPlace.hasHours)
               individualPlace.placeHours = placeInfo[@"opening_hours"][@"weekday_text"];
             
             if(placeInfo[@"photos"] != nil)
             {
                 
                 individualPlace.hasPhotos = YES;
                 
                 NSDictionary *photoDict = [[placeInfo objectForKey:@"photos"] objectAtIndex:0];
    
                 NSString *photoRef = [photoDict objectForKey:@"photo_reference"];
                 
                 
                 individualPlace.urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?photoreference=%@&key=AIzaSyD9CaxjnEVMMKNYKAlP0houvQpMXi9VYIM&sensor=false&maxwidth=600", photoRef];
                 individualPlace.url = [NSURL URLWithString:individualPlace.urlString];
             }
             else
                 individualPlace.hasPhotos = NO;
             id rawIsOpen = placeInfo[@"opening_hours"][@"open_now"];
             individualPlace.isOpen = [rawIsOpen boolValue];
             individualPlace.place_id = placeInfo[@"place_id"];
             if(individualPlace.hasPhotos)
             {
                 NSURLSessionDataTask *dataTask =
                 [sharedSessionMainQueue dataTaskWithURL:individualPlace.url completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
                     //now will be on main thread
                     individualPlace.imgData = data;
                     BOOL hasData = individualPlace.imgData;
                     [self.placeDetails addObject:individualPlace];
                     
                     i+=1;
                     if(i<self.place_id_storage.count)
                     {
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
                 [self.placeDetails addObject:individualPlace];
                 
                 i+=1;
                 if(i<self.place_id_storage.count)
                 {
                     [self getJSONPlaceDetails:self.place_id_storage[i]];
                }
                 else
                 {
                     
                     i = 0;
                     [self didReceiveData];
                 }
             }
             
             
         }
     }];
}

-(IBAction) performUnwind: (UIStoryboardSegue *)segue{
    
}

-(void)didReceiveData{
    
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.finishedLoadingData = YES;
        [self.tableView reloadData];
        int64_t delayInSeconds = 1.0f;
        dispatch_time_t popTime =
        dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (self.refreshControl) {
                [self.favorites_manager.refreshControl endRefreshing];
            }
        });
    }];
    
}
-(void)createFavoritePlaces
{
    [self.placeDetails removeAllObjects];
    self.rawDetails = nil;
    [self getJSONPlaceDetails:self.place_id_storage[0]];
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

    //for autocomplete tableView formatting
    if([tableView isEqual:self.autocompleteTableView])
    {
        UITableViewCell *cell = nil;
        
        static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
            
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
        }
        
        cell.shouldIndentWhileEditing = YES;
        cell.backgroundColor = [UIColor clearColor];
            cell.imageView.frame = CGRectOffset(cell.frame, 90, 90);
        cell.textLabel.text = [[self.placesAsProperties objectAtIndex:indexPath.row] name];
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
        if(indexPath.section == self.place_id_storage.count-1)
        cell.hidden = YES;
        return cell;
    }
    
    return nil;
    
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    if([tableView isEqual:self.tableView])
//    {
//        if(footerView == nil) {
//            //allocate the view if it doesn't exist yet
//            footerView  = [[UIView alloc] init];
//            
//            //we would like to show a gloosy red button, so get the image first
//            UIImage *image = [[UIImage imageNamed:@"button_red.png"]
//                              stretchableImageWithLeftCapWidth:8 topCapHeight:8];
//            
//            //create the button
//            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            [button setBackgroundImage:image forState:UIControlStateNormal];
//            
//            //the button should be as big as a table view cell
//            [button setFrame:CGRectMake(10, 3, 300, 44)];
//            
//            //set title, font size and font color
//            [button setTitle:@"Remove" forState:UIControlStateNormal];
//            [button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
//            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            
//            //set action of the button
//            [button addTarget:self action:@selector(removeAction:)
//             forControlEvents:UIControlEventTouchUpInside];
//            
//            //add the button to the view
//            [footerView addSubview:button];
//        }
//        
//        //return the view for the footer
//        return footerView;
//    }
//    
//    return nil;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![tableView isEqual:self.autocompleteTableView])
        return 205;
    else
        return 44;
    
}

-(void)didReceiveTap:(UITapGestureRecognizer *)gesture
{
    UIView *labelView = gesture.view;
    UILabel *label = (UILabel *)labelView;
    CGPoint buttonPosition = [label convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    placeTableCell *cell= (placeTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString *placeHoursString = [[self.placeDetails[indexPath.section] placeHours] componentsJoinedByString:@"\n"];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [self.view.layer addAnimation:transition forKey:nil];

    if(cell.placeHours.hidden)
    {
        
        cell.placeImage.hidden = YES;
        cell.noImageIndicator.hidden = YES;
        cell.placeHours.hidden = NO;
        
        if(placeHoursString == nil)
            cell.placeHours.text = @"No Data";
        
    }
    else
    {
        if(cell.noImageIndicator.tag == 1)
            cell.noImageIndicator.hidden = NO;
        cell.placeHours.hidden = YES;
        cell.placeImage.hidden = NO;
        
    }
    
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(placeTableCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    if(![tableView isEqual:self.autocompleteTableView]&&self.finishedLoadingData){
        cell.hidden = NO;
        cell.isOpenLabel.textAlignment = NSTextAlignmentCenter;
        
        
        if([[self.placeDetails objectAtIndex:indexPath.section] isOpen]==YES)
        {
            
            cell.isOpenLabel.backgroundColor = UIColorFromRGB(0x39FF14);//[UIColor colorWithRed:57
            cell.isOpenLabel.text = @"OPEN";

        }
        else if(([[self.placeDetails objectAtIndex:indexPath.section] isOpen]==NO)&&([[self.placeDetails objectAtIndex:indexPath.section] hasHours]==YES))
        {
            cell.isOpenLabel.backgroundColor = UIColorFromRGB(0xff0000);
            cell.isOpenLabel.text = @"CLOSED";

        }
        else
        {
            cell.isOpenLabel.backgroundColor = UIColorFromRGB(0xC0C0C0);
            
            cell.isOpenLabel.text = @"NO DATA";
        }
        self.currentSection = indexPath.section;
         cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.65];
        cell.placeName.text = [[self.placeDetails objectAtIndex:indexPath.section] name];
        [cell.placeName setPreferredMaxLayoutWidth:200.0];
        UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didReceiveTap:)];
        tapped.delegate = self;
        tapped.numberOfTapsRequired = 1;
        [cell.isOpenLabel setUserInteractionEnabled:YES];
        [cell addGestureRecognizer:tapped];
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
            cell.placeImage.image = [UIImage imageWithData:[[self.placeDetails objectAtIndex:indexPath.section] imgData]];
            cell.placeImage.hidden = NO;
            cell.noImageIndicator.hidden = YES;
            cell.noImageIndicator.tag = 0;
        }
        else
        {

            cell.placeImage.image = [self imageWithColor:[UIColor clearColor]];
            cell.noImageIndicator.text = [[self.placeDetails objectAtIndex:indexPath.section] name];
            cell.noImageIndicator.adjustsFontSizeToFitWidth = YES;
            cell.noImageIndicator.hidden = NO;
            cell.noImageIndicator.tag = 1;
            cell.noImageIndicator.backgroundColor = [cell.isOpenLabel.backgroundColor colorWithAlphaComponent:0.5f];
        }

    }
    if(self.googlePowered.hidden == YES)
        self.googlePowered.hidden = NO;
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
    
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath{
    if([tableView isEqual:self.autocompleteTableView]){
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

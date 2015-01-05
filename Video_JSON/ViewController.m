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
#import "DetailCell.h"
#import <QuartzCore/QuartzCore.h>
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]
@interface ViewController ()

@end

@implementation ViewController
@synthesize autocompleteTextField, autocompletePlaces, pastPlaces, placesAsProperties, autocompleteTableView,posts, placesAsPropertiesTemp, rawDetails, place_id_storage, placeDetails, placeDetailsTemp, refreshControl, favorites_manager;
int i = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]];
    // Do any additional setup after loading the view, typically from a nib.
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
    self.autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,50, 420, 120)];
    self.autocompleteTableView.delegate = self;
    self.autocompleteTextField.delegate = self;
    self.autocompleteTextField.placeholder=@"Search for a place";
    self.autocompleteTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.autocompleteTextField.returnKeyType = UIReturnKeyDone;
    self.autocompleteTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocompleteTableView.dataSource = self;
    self.autocompleteTableView.scrollEnabled = YES;
    self.autocompleteTableView.hidden = YES;
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
    [self.tableView setBackgroundColor:UIColorFromRGB(0x2E3E51)];
    [self.view setBackgroundColor:[UIColor blackColor]];//UIColorFromRGB(0x2E3E51)];
    }


-(void)getJSONData: (NSString *) input completion:(void (^)(void))dataReceived
{
    NSString *urlMod = [input stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=30.29128,-97.73858&radius=500&key=AIzaSyD9CaxjnEVMMKNYKAlP0houvQpMXi9VYIM",urlMod];
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
    [self createFavoritePlaces];
    
}

-(void)getJSONPlaceDetails:(NSString *) place_id{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyD9CaxjnEVMMKNYKAlP0houvQpMXi9VYIM",place_id];
    NSLog(@"URL TO TEST %@", urlString);
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
             
             //            NSLog(@"current place_id %@",placeInfo[@"place_id"]);
             
             
             individualPlace.name = placeInfo[@"name"];
             //            NSLog(@"this is the placeInfo %@",placeInfo[@"name"]);
             individualPlace.address = placeInfo[@"formatted_address"];
             individualPlace.location = CLLocationCoordinate2DMake([placeInfo[@"geometry"][@"location"][@"lat"] doubleValue], [placeInfo[@"geometry"][@"location"][@"lng"] doubleValue]);
             //             NSLog(@"%s\n", object_getClassName([[individualPlace hasHours] class]));
             individualPlace.hasHours = !(placeInfo[@"opening_hours"][@"open_now"] == nil);
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
             if(individualPlace.hasPhotos)
             {
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
                     NSLog(@"RAN METHOD");
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
                 NSLog(@"RAN METHOD");
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



-(void)didReceiveData{
    
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
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
    //for autocomplete tableView formatting
    if([tableView isEqual:self.autocompleteTableView])
    {
        NSLog(@"INDEX PATH ROW: %lu",indexPath.row);
        NSLog(@"PAS P %lu",self.placesAsProperties.count);
        UITableViewCell *cell = nil;
        if(indexPath.row < self.placesAsProperties.count-1)
        {
        static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
        cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
            
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
        }
        // NSLog(@"this is a test of 3.0 status %lu",indexPath.row);
            cell.imageView.frame = CGRectOffset(cell.frame, 90, 90);
        cell.textLabel.text = [[self.placesAsProperties objectAtIndex:indexPath.row] name];
            cell.preservesSuperviewLayoutMargins = NO;
            if (indexPath.row == self.placesAsProperties.count-2) {
//                cell.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.tableView.bounds)/2.0, 0, CGRectGetWidth(self.tableView.bounds)/2.0);
//                cell.layer.shadowOffset = CGSizeMake(1, 0);
//                cell.layer.shadowColor = [[UIColor blackColor] CGColor];
//                cell.layer.shadowRadius = 5;
//                cell.layer.shadowOpacity = .25;
//                
//                
//                CGRect shadowFrame = cell.layer.bounds;
//                CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
//                cell.layer.shadowPath = shadowPath;
            }
        return cell;
        }
        else if(indexPath.row == (self.placesAsProperties.count-1))
        {
            NSLog(@"CELL INDEX %lu",indexPath.row);
            UITableViewCell *cell = nil;
            static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
            cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
            if(cell == nil){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
            }
            // NSLog(@"this is a test of 3.0 status %lu",indexPath.row);
            //cell.textLabel.text = [[self.placesAsProperties objectAtIndex:indexPath.row] name];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powered-by-google-on-white@2x.png"]];
            cell.accessoryView = imageView;
            cell.imageView.frame = CGRectOffset(cell.frame, 10, 10);
            return cell;
        }
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
            self.tableView.estimatedRowHeight = 187.0;
            
        }
        
        return cell;
    }
    
    return nil;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![tableView isEqual:self.autocompleteTableView])
        return 187;
    else
        return 44;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(placeTableCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(![tableView isEqual:self.autocompleteTableView]){
        //        NSLog(@"this is a test of 2.0 status %lu",indexPath.row);
        //        CGRect frame = CGRectOffset([tableView rectForRowAtIndexPath:indexPath], 0.0, 90.8);
        //    cell.backgroundColor = [[UIView alloc] initWithFrame: frame ];
        if([[self.placeDetails objectAtIndex:indexPath.section] isOpen]==YES)
        {
            cell.isOpenLabel.backgroundColor = UIColorFromRGB(0x39FF14);//0x84E80C);
            cell.isOpenLabel.text = @"OPEN";
            CGFloat width =  ceil([cell.isOpenLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:17.0]}].width);
            cell.isOpenLabel.frame = CGRectMake(275,142, width,21);



        }
        else if(([[self.placeDetails objectAtIndex:indexPath.section] isOpen]==NO)&&([[self.placeDetails objectAtIndex:indexPath.section] hasHours]==YES))
        {
            cell.isOpenLabel.backgroundColor = UIColorFromRGB(0xff0000);//0xFF6853);
            cell.isOpenLabel.text = @"CLOSED";
            CGFloat width =  ceil([cell.isOpenLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:17.0]}].width);
            cell.isOpenLabel.frame = CGRectMake(275,142, width,21);
        }
        else
        {
            cell.isOpenLabel.backgroundColor = UIColorFromRGB(0xC0C0C0);
            cell.isOpenLabel.text = @"NO DATA";
            CGFloat width =  ceil([cell.isOpenLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:17.0]}].width);
            cell.isOpenLabel.frame = CGRectMake(275,142, width,21);
        }
        [cell.contentView.layer setBorderColor:[UIColor redColor].CGColor];
        [cell.contentView.layer setBorderWidth:1.0f];
        cell.placeName.text = [[self.placeDetails objectAtIndex:indexPath.section] name];
        cell.placeDescription.text = [[self.placeDetails objectAtIndex:indexPath.section] address];
                cell.placeImage.image = [UIImage imageWithData:[[self.placeDetails objectAtIndex:indexPath.section] imgData]];
    }
}

- (double)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    //this is the space
   // NSLog(@"THIS IS THE SECTION VALUE: %lu",section);
    if(section != self.place_id_storage.count-1)
        return 50;
    else
        return 0;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
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
    
    
    NSLog(@"NUMBER OF ROWS");
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
    if([tableView isEqual:self.autocompleteTableView]){
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
        self.autocompleteTextField.text = selectedCell.textLabel.text;
        if(![self.place_id_storage containsObject:[[self.placesAsProperties objectAtIndex:indexPath.row] place_id]]){
            [self.place_id_storage addObject:[[self.placesAsProperties objectAtIndex:indexPath.row] place_id]];
            [self.prefs setObject:self.place_id_storage forKey:@"place_id_favorites"];
            [self createFavoritePlaces];
        }
        self.autocompleteTableView.hidden = YES;
        
        
    }
}


@end

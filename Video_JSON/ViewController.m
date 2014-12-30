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
    // Do any additional setup after loading the view, typically from a nib.
    self.paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentsDirectory = [self.paths objectAtIndex:0];
    self.filePath = [[NSBundle mainBundle] pathForResource:@"PLACE_ID_STORAGE"
                                                    ofType:@"plist"];
    self.autocompletePlaces = [[NSMutableArray alloc] init];
    self.pastPlaces = [[NSMutableArray alloc] init];
    self.placesAsProperties = [[NSMutableArray alloc] init];
    self.placesAsPropertiesTemp = [[NSMutableArray alloc] init];
    self.placeDetailsTemp = [[NSMutableArray alloc] init];
    self.placeDetails = [[NSMutableArray alloc] init];
    self.posts = [[NSMutableDictionary alloc] init];
    self.rawDetails = [[NSMutableDictionary alloc] init];
    self.place_id_storage = [[NSMutableArray alloc] initWithContentsOfFile:self.filePath];
    NSLog(@"TO SEE IF THERE %@",self.place_id_storage);
    //autocompleteTextField = [[UITextField alloc] initWithFrame:CGRectMake(0,80, 900, 120)];
    self.autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,80, 420, 120)];
    self.autocompleteTableView.delegate = self;
    self.autocompleteTextField.delegate = self;
    self.autocompleteTextField.placeholder=@"Type a name";
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
    NSLog(@"IT IS CALLING IT");
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
   
    if([tableView isEqual:self.autocompleteTableView])
    {
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
       // NSLog(@"this is a test of 3.0 status %lu",indexPath.row);
    cell.textLabel.text = [[self.placesAsProperties objectAtIndex:indexPath.row] name];
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(DetailCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(![tableView isEqual:self.autocompleteTableView]){
//        NSLog(@"this is a test of 2.0 status %lu",indexPath.row);
//        CGRect frame = CGRectOffset([tableView rectForRowAtIndexPath:indexPath], 0.0, 90.8);
//    cell.backgroundColor = [[UIView alloc] initWithFrame: frame ];
        
        if([[self.placeDetails objectAtIndex:indexPath.row] isOpen]==YES)
            cell.backgroundColor = UIColorFromRGB(0x84E80C);
        else if(([[self.placeDetails objectAtIndex:indexPath.row] isOpen]==NO)&&([[self.placeDetails objectAtIndex:indexPath.row] hasHours]==YES))
            cell.backgroundColor = UIColorFromRGB(0xFF6853);
        else
            cell.backgroundColor = UIColorFromRGB(0x808080);
            
    cell.placeName.text = [[self.placeDetails objectAtIndex:indexPath.row] name];
  
        cell.placeDescription.text = [[self.placeDetails objectAtIndex:indexPath.row] address];
        cell.placeImage.image = [UIImage imageWithData:[[self.placeDetails objectAtIndex:indexPath.row] imgData]];
        
}
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([tableView isEqual:self.autocompleteTableView])
        return [self.placesAsProperties count];
    else
        return self.place_id_storage.count;

}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
        return 1;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath{
    if([tableView isEqual:self.autocompleteTableView]){
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath];
    self.autocompleteTextField.text = selectedCell.textLabel.text;
    if(![self.place_id_storage containsObject:[[self.placesAsProperties objectAtIndex:indexPath.row] place_id]]){
        [self.place_id_storage addObject:[[self.placesAsProperties objectAtIndex:indexPath.row] place_id]];
        NSLog(@"BEING WRITTEN %@",self.place_id_storage);
        [self.place_id_storage writeToFile:self.filePath atomically:YES];
        
        [self createFavoritePlaces];
    }
    self.autocompleteTableView.hidden = YES;
        
    
   }
}


@end

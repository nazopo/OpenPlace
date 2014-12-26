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
@interface ViewController ()

@end

@implementation ViewController
@synthesize autocompleteTextField, autocompletePlaces, pastPlaces, placesAsProperties, autocompleteTableView,posts, placesAsPropertiesTemp, rawDetails, place_id_storage, placeDetails, placeDetailsTemp;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.autocompletePlaces = [[NSMutableArray alloc] init];
    self.pastPlaces = [[NSMutableArray alloc] init];
    self.placesAsProperties = [[NSMutableArray alloc] init];
    self.placesAsPropertiesTemp = [[NSMutableArray alloc] init];
    self.placeDetailsTemp = [[NSMutableArray alloc] init];
    self.placeDetails = [[NSMutableArray alloc] init];
    self.posts = [[NSMutableDictionary alloc] init];
    self.rawDetails = [[NSMutableDictionary alloc] init];
    self.place_id_storage = [[NSMutableArray alloc] init];
    //autocompleteTextField = [[UITextField alloc] initWithFrame:CGRectMake(0,80, 900, 120)];
    self.autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,80, 380, 120)];
    self.autocompleteTableView.delegate = self;
    self.autocompleteTextField.delegate = self;
    self.autocompleteTextField.placeholder=@"Type a name";
    self.autocompleteTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.autocompleteTextField.returnKeyType = UIReturnKeyDone;
    self.autocompleteTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocompleteTableView.dataSource = self;
    self.autocompleteTableView.scrollEnabled = YES;
    self.autocompleteTableView.hidden = YES;
    [self.view addSubview:self.autocompleteTableView];
    [self.autocompleteTableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
    [autocompleteTextField addTarget:self
                              action:@selector(textFieldDidChange:)
                    forControlEvents:UIControlEventEditingChanged];
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

-(void)getJSONPlaceDetails:(NSString *) place_id completion:(void (^)(void))dataReceived{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyD9CaxjnEVMMKNYKAlP0houvQpMXi9VYIM",place_id];
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
             
             Place *individualPlace = [[Place alloc] init];
             individualPlace.name = placeInfo[@"name"];
             //            NSLog(@"this is the placeInfo %@",placeInfo[@"name"]);
             individualPlace.address = placeInfo[@"formatted_address"];
             individualPlace.location = CLLocationCoordinate2DMake([placeInfo[@"geometry"][@"location"][@"lat"] doubleValue], [placeInfo[@"geometry"][@"location"][@"lng"] doubleValue]);
             individualPlace.isOpen = placeInfo[@"opening_hours"][@"open_now"];
             individualPlace.place_id = placeInfo[@"place_id"];
             [self.placeDetails addObject:individualPlace];
             
             
             //NSLog(@"THIS IS THE TRUTH VALUE %@",individualPlace.place_id);
             
             
             //            NSLog(@"THIS IS CALLING THE SIZE IN THE METHOD %lu",self.placeDetails.count);
             //
             //            NSLog(@"THIS IS THE SIZE THAT the array is %lu",self.placeDetails.count);
             //            NSLog(@"THESE ARE THE KEYS THAT RAE THE RESULT %@",self.place_id_storage);
             //            for(int i = 0; i<self.placeDetails.count; i++){
             //                NSLog(@"%@",[self.placeDetails[i] name]  );
             //            }
             //            NSLog(@"Array Size %lu",self.placeDetails.count);
             //            NSLog(@"end of array");
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                 NSLog(@"THIS IS TO SEE WHEN IT FINISHES %@",self.rawDetails);
                              if (dataReceived != nil)
                     dataReceived();
                 
             }];
             
         }
     }];
}

-(void)createFavoritePlaces
{
    for(int i = 0; i<self.placeDetails.count; i++){
        NSLog(@"%@",[self.placeDetails[i] name]  );
    }
   // NSLog(@"Array Size %lu",self.placeDetails.count);
//    NSLog(@"end of array beforehand");
    [self.placeDetails removeAllObjects];
//    NSLog(@"END OF LOOP");
//    NSLog(@"THIS IS THE ENTIRE BATCH OF PLACEID %@",self.place_id_storage);
    for(int i = 0; i<self.place_id_storage.count; i++)
    {
//        NSLog(@"THIS IS THE PLACEID FOR THE SPECIFIC INDEX %@",self.place_id_storage[i]);
        self.rawDetails = nil;
        [self getJSONPlaceDetails:self.place_id_storage[i] completion:^void {
             NSLog(@"PLACEID SPECIFIC INDEX inside %@ and current index %d",self.place_id_storage[i],i);
            NSLog(@"MAIN OUTPUT TO WORRY ABOUT %@",self.rawDetails);
            
           
            if(i==self.place_id_storage.count - 1){
                [self.tableView reloadData];}
        }];
        
    }
   
    
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
        }
    
        return cell;
    }
    
        return nil;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(DetailCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(![tableView isEqual:self.autocompleteTableView]){
//        NSLog(@"this is a test of 2.0 status %lu",indexPath.row);
    
    cell.placeName.text = [[self.placeDetails objectAtIndex:indexPath.row] name];
  
        cell.placeDescription.text = [[self.placeDetails objectAtIndex:indexPath.row] address];
}
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([tableView isEqual:self.autocompleteTableView]){
       
        return [self.placesAsProperties count];
    }
    else if(self.place_id_storage.count>0){
        return self.placeDetails.count;
}
    return 0;
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
        [self createFavoritePlaces];
    }
    self.autocompleteTableView.hidden = YES;
        NSLog(@"THIS IS AN OUTPUT TRIIGER");
    
   }
}


@end

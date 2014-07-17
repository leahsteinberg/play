//
//  friendsViewController.m
//  money
//
//  Created by Leah Steinberg on 7/16/14.
//  Copyright (c) 2014 LeahSteinberg. All rights reserved.
//

#import "friendsViewController.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import <AFNetworking/AFNetworking.h>
#import "Friend.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSArray+LinqExtensions.h"
#import "moneyTableViewCell.h"

@interface friendsViewController ()
@property (strong, nonatomic) NSArray *allFriends;
@property(strong, nonatomic) NSMutableArray *leftFriends;
@property(strong, nonatomic) NSMutableArray *rightFriends;
@property(strong, nonatomic) NSMutableArray *middleFriends;
@property CGFloat leftOffset;
@property CGFloat middleOffset;
@property CGFloat rightOffset;


//@property (strong, nonato)

@end

@implementation friendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {


        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.allFriends = [[NSArray alloc] init];
    self.leftFriends = [[NSMutableArray alloc] init];
    self.rightFriends = [[NSMutableArray alloc] init];
    self.middleFriends = [[NSMutableArray alloc] init];

    [[[self getFriendsSignal]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSArray * jsonFriendArray){
         NSArray *friendsArray = [jsonFriendArray linq_select:^id(id friend){
             return [Friend initWithDictionary:friend];
         }];
         [self divideFriends:friendsArray];


     }error:^(NSError *error) {
         NSLog(@"An error occurred: %@", error);
     }];
    _leftTable.dataSource = self;
    _leftTable.delegate = self;
    _rightTable.delegate = self;
    _rightTable.dataSource = self;
    _middleTable.delegate = self;
    _middleTable.dataSource = self;
    self.leftOffset = self.leftTable.contentOffset.y;
    self.middleOffset = self.middleTable.contentOffset.y;
    self.rightOffset = self.rightTable.contentOffset.y;
    [self.leftTable setShowsVerticalScrollIndicator:NO];
    [self.middleTable setShowsVerticalScrollIndicator:NO];
    [self.rightTable setShowsVerticalScrollIndicator:NO];
    
    RACSignal *scrollSignal = [self rac_signalForSelector:@selector(scrollViewDidScroll:) fromProtocol:@protocol(UIScrollViewDelegate)];
    [[scrollSignal throttle:.01]
      subscribeNext:^(RACTuple * scrollTuple){
        UIScrollView *scrollView = [scrollTuple first];
        CGFloat scrollOffset = scrollView.contentOffset.y;
        if(scrollView == self.leftTable){
            CGFloat displacement = scrollOffset - self.leftOffset;
            self.leftOffset = scrollOffset;
            // try RAC() to set content offset
            [self scrollOppositeDirectionWithTable:self.middleTable AndOffset:displacement];
            [self scrollSameDirectionWithTable:self.rightTable AndOffset:displacement];
        }
        else if(scrollView == self.rightTable){
            CGFloat displacement = scrollOffset - self.rightOffset;
            self.rightOffset = scrollOffset;
            [self scrollOppositeDirectionWithTable:self.middleTable AndOffset:displacement];
            [self scrollSameDirectionWithTable:self.leftTable AndOffset:displacement];
        }
        else if (scrollView == self.middleTable){
            CGFloat displacement = scrollOffset - self.middleOffset;
            self.middleOffset = scrollOffset;
            [self scrollOppositeDirectionWithTable:self.leftTable AndOffset:displacement];
            [self scrollOppositeDirectionWithTable:self.rightTable AndOffset:displacement];
        }
    }];

   
}
- (void)scrollOppositeDirectionWithTable:(UITableView *)table AndOffset:(CGFloat)offset
{
    CGFloat newPlacement = table.contentOffset.y-offset;
    if((newPlacement>-3) && newPlacement < table.contentSize.height){
        [table setContentOffset:CGPointMake(0, newPlacement) animated:NO];
    }
}

- (void) scrollSameDirectionWithTable:(UITableView *)table AndOffset:(CGFloat)offset
{
    CGFloat newPlacement = table.contentOffset.y+offset;
    if((newPlacement>-165) && newPlacement < table.contentSize.height){
        [table setContentOffset:CGPointMake(0, newPlacement) animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if(tableView == self.leftTable){
    return [self.leftFriends count];
   }
   else if(tableView == self.rightTable){
       return [self.rightFriends count];
    }
   else{
       return [self.middleFriends count];
   }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"emojiCell";
    moneyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if(cell == nil){
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
    Friend *friend;
    if(tableView == self.leftTable){
        friend = [self.leftFriends objectAtIndex:indexPath.row];
    }
    else if (tableView == self.rightTable){
        friend = [self.rightFriends objectAtIndex:indexPath.row];
    }
    else{
        friend = [self.middleFriends objectAtIndex:indexPath.row];
    }
    cell.emojiLabel.text = friend.emoji;
    cell.emojiLabel.textAlignment = NSTextAlignmentCenter;
    cell.firstNameLabel.text = friend.firstName;
    cell.lastNameLabel.text = friend.lastName;
    return cell;
}


#pragma mark - RAC methods

- (RACSignal *)getFriendsSignal
{
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        VENSession *session = [[Venmo sharedInstance] session];
        NSString *getFriendsURL =[NSString stringWithFormat:@"https://api.venmo.com/v1/users/%@/friends?access_token=%@&limit=10000",session.user.externalId, session.accessToken];
        [manager GET:getFriendsURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            [subscriber sendNext:responseObject[@"data"]];
            [subscriber sendCompleted];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            [subscriber sendError:error];
        }];
        return [RACDisposable disposableWithBlock:^{
        }];
    }];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{

}

- (void)divideFriends:(NSArray *)friends
{
    self.allFriends = friends;
    NSUInteger count = [self.allFriends count];
    for (NSUInteger i =0; i<[self.allFriends count]; i++){
        if(i< count/3){
            [self.leftFriends addObject:[self.allFriends objectAtIndex:i]];
        }
        else if(i> count/3 && i<((count/3)*2)){
            [self.middleFriends addObject:[self.allFriends objectAtIndex:i]];
        }
        else{
            [self.rightFriends addObject:[self.allFriends objectAtIndex:i]];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.leftTable reloadData];
        //[self.rightTable reloadData];
        //[self.middleTable reloadData];
    });
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

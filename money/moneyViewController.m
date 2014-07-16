//
//  moneyViewController.m
//  money
//
//  Created by Leah Steinberg on 7/16/14.
//  Copyright (c) 2014 LeahSteinberg. All rights reserved.
//

#import "moneyViewController.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface moneyViewController ()
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation moneyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.signInButton setTitle:@"💰" forState:UIControlStateNormal];
    [self.signInButton setBounds:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 100, 400)];
    [[self.signInButton titleLabel] setFont:[UIFont systemFontOfSize:100]];
    
    [[self.signInButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [[self signInVenmo] subscribeCompleted:^{
            NSLog(@"bla");
        }];
    }];

	// Do any additional setup after loading the view, typically from a nib.
}

-(RACSignal *)signInVenmo{
    NSLog(@"in sign in venmo");
    return [RACSignal createSignal:^RACDisposable*(id<RACSubscriber> subscriber){
        [[Venmo sharedInstance] requestPermissions:@[VENPermissionMakePayments, VENPermissionAccessFriends]
                             withCompletionHandler:^(BOOL success, NSError *error){
                                 if (success){
                                     [subscriber sendCompleted];
                                     
                                 } else {
                                     [subscriber sendError:error];
                                 }
                             }];
        
        return nil;
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

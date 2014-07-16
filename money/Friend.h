//
//  Friend.h
//  money
//
//  Created by Leah Steinberg on 7/16/14.
//  Copyright (c) 2014 LeahSteinberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friend : NSObject
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *friendID;
@property (strong, nonatomic) NSString *emoji;

+ (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

//
//  RubyRideSummaryInstance.h
//  RubyRide
//
//  Created by Anjani Mittal on 9/9/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RubyRideSummaryInstance : NSObject

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int starPoints;

+ (RubyRideSummaryInstance *)sharedInstance;

@end

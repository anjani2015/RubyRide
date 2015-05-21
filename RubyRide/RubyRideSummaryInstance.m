//
//  RubyRideSummaryInstance.m
//  RubyRide
//
//  Created by Anjani Mittal on 9/9/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import "RubyRideSummaryInstance.h"

@implementation RubyRideSummaryInstance

+ (RubyRideSummaryInstance *)sharedInstance
{
    static RubyRideSummaryInstance *singletonInstance = nil;
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        singletonInstance = [[super alloc] init];
    });
    
    return singletonInstance;
}

- (id) init
{
    if (self = [super init]) {
        // Init
        _score = 0;
        _starPoints = 0;
        
        // Load game state
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id score = [defaults objectForKey:@"score"];
        if (score) {
            _score = [score intValue];
        }
        id starPoints = [defaults objectForKey:@"starPoints"];
        if (starPoints) {
            _starPoints = [starPoints intValue];
        }
    }
    return self;
}

- (void) saveState
{
    // Update highScore if the current score is greater
    //_highScore = MAX(_score, _highScore);
    
    // Store in user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:_score] forKey:@"score"];
    [defaults setObject:[NSNumber numberWithInt:_starPoints] forKey:@"starPoints"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end

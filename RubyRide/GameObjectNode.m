//
//  GameObjectNode.m
//  RubyRide
//
//  Created by Anjani Mittal on 9/10/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import "GameObjectNode.h"

@implementation GameObjectNode

- (BOOL) collisionWithPlayer:(SKNode *)player
{
    return NO;
}

- (void) checkNodeRemoval:(CGFloat)playerY
{
    if (playerY > self.position.y + 300.0f) {
        [self removeFromParent];
    }
}


@end

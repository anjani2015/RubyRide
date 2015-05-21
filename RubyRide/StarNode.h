//
//  StarNode.h
//  RubyRide
//
//  Created by Anjani Mittal on 9/10/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import "GameObjectNode.h"

typedef NS_ENUM(int, StarType) {
    STAR_NORMAL,
    STAR_SPECIAL,
};

@interface StarNode : GameObjectNode

@property (nonatomic, assign) StarType starType;

@end

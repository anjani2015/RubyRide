//
//  RubyRideViewController.m
//  RubyRide
//
//  Created by Anjani Mittal on 9/8/14.
//  Copyright (c) 2014 SAP. All rights reserved.
//

#import "RubyRideViewController.h"
#import "RubyRideMyScene.h"

@implementation RubyRideViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
//        skView.showsFPS = YES;
//        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        SKScene * scene = [RubyRideMyScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end

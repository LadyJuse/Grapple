//
//  ViewController.m
//  Grapple
//
//  Created by Colt King on 2018-02-16.
//  Copyright © 2018 Penguin Interactive. All rights reserved.
//

#import "ViewController.h"
#import "Game.h"

@interface ViewController (){
    Game *gm;
    Renderer* glesRenderer;
    HighScores* HS;
}

@property (weak, nonatomic) IBOutlet UILabel *Score;
@property (weak, nonatomic) IBOutlet UIView *PauseMenu;
@property (strong, nonatomic) IBOutlet UILabel *Multiplier;
@property (strong, nonatomic) IBOutlet UIView *GameOver;
@property (strong, nonatomic) IBOutlet UILabel *EndScore;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Setup the renderer object
    glesRenderer = [[Renderer alloc] init];
    
    GLKView* view = (GLKView*)self.view;
    [glesRenderer setup:view];
    
    gm = [[Game alloc] init];

    HS = [[HighScores alloc] init];
    [_PauseMenu setHidden:true];
    [_GameOver setHidden:true];
    [gm setIsPaused:false];
    
    [gm startGame:glesRenderer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Pause:(id)sender
{
    [gm pause];
    [_PauseMenu setHidden:![_PauseMenu isHidden]];
}


- (void)update
{
    //Pass update call onto Renderer
    if(![gm isPaused]){
        [gm update];
        if([gm Losing]){
            [gm pause];
            [_GameOver setHidden:false];
            
        }
        _Score.text= [NSString stringWithFormat:@"%d",[gm playerScore]];
        _Multiplier.text=[NSString stringWithFormat:@"%c%i",'x',[gm mult]];
        _EndScore.text = [NSString stringWithFormat:@"%d",[gm playerScore]];
    }
    
}

- (IBAction)tap:(UITapGestureRecognizer *)sender
{
    //NSLog(@"Tap");
    
    //NSLog(@"PRESS BEGAN");
    if(![gm isPaused])
    {
        CGPoint point = [sender locationInView:self.view];
        //NSLog(@"Tap X = %f Y = %f", point.x, point.y);
        [gm fireTongue:point.x yPos:point.y];
    }
}

- (IBAction)CG:(id)sender {
    //[gm collectGrapple];
    
}


- (IBAction)DS:(id)sender {
    //[gm grappleSpawn];
}


@end


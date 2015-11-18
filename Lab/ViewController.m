//
//  ViewController.m
//  Lab
//
//  Created by Juan Pablo Marzetti on 11/12/15.
//  Copyright © 2015 Juan Pablo Marzetti. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *trayView;
@property (nonatomic, assign) CGPoint trayOriginalCenter;

@property (nonatomic, assign) CGPoint trayOpenCenter;

@property (nonatomic, assign) CGPoint trayClosedCenter;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;

@property (nonatomic, strong) UIImageView *newlyCreatedFace;
@property (nonatomic, assign) CGPoint newFaceOriginalCenter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trayOpenCenter = self.trayView.center;
    self.trayClosedCenter = CGPointMake(self.trayView.center.x, self.trayView.center.y + 154);
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onTapTrayGesture:(UIPanGestureRecognizer *)sender {
    if (self.trayView.center.x == self.trayClosedCenter.x && self.trayView.center.y == self.trayClosedCenter.y) {
        [UIView animateWithDuration:.3 animations:^{
            self.trayView.center = self.trayOpenCenter;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.1 animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(0);
            }];
        }];
    } else {
        [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0 animations:^{
            self.trayView.center = self.trayClosedCenter;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.1 animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        }];
    }
    
}

- (IBAction)onPanTrayGesture:(UIPanGestureRecognizer *)sender {
    // Absolute (x,y) coordinates in parentView
    CGPoint location = [sender locationInView:self.view];
    CGPoint translation = [sender translationInView:self.trayView.superview];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Gesture began at: %@", NSStringFromCGPoint(location));
        self.trayOriginalCenter = self.trayView.center;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Gesture changed at: %@", NSStringFromCGPoint(location));
        if ((translation.y + self.trayOriginalCenter.y < self.trayOpenCenter.y)) {
            self.trayView.center = self.trayOpenCenter;
        } else {
            self.trayView.center = CGPointMake(self.trayOriginalCenter.x,
                                               self.trayOriginalCenter.y + translation.y);
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Gesture ended at: %@", NSStringFromCGPoint(location));
        CGPoint velocity = [sender velocityInView:self.trayView];
        if (velocity.y < 0) {
            [UIView animateWithDuration:.3 animations:^{
                self.trayView.center = self.trayOpenCenter;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.1 animations:^{
                    self.arrowImage.transform = CGAffineTransformMakeRotation(0);
                }];
            }];
        } else {
            [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:0 animations:^{
                self.trayView.center = self.trayClosedCenter;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.1 animations:^{
                    self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                }];
            }];
        }
    }
}
- (void)onPanNewImageGesture:(UIPanGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.view];
    CGPoint translation = [sender translationInView:self.trayView.superview];
    UIImageView *imageView = (UIImageView *)sender.view;

    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Gesture began at: %@", NSStringFromCGPoint(location));
        self.newFaceOriginalCenter = imageView.center;

        imageView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Gesture changed at: %@", NSStringFromCGPoint(location));
        imageView.center = CGPointMake(self.newFaceOriginalCenter.x + translation.x,
                                       self.newFaceOriginalCenter.y + translation.y);
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Gesture ended at: %@", NSStringFromCGPoint(location));
        imageView.transform = CGAffineTransformMakeScale(1, 1);
    }

}

- (void) onPinchNewImageGesture:(UIPinchGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.view];
    UIImageView *imageView = (UIImageView *)sender.view;
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Gesture changed at: %@", NSStringFromCGPoint(location));
        
        imageView.transform = CGAffineTransformMakeScale(sender.scale, sender.scale);
    }
}


- (IBAction)onPanImageGesture:(UIPanGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        // Gesture recognizers know the view they are attached to
        UIImageView *imageView = (UIImageView *)sender.view;
        
        
        // Create a new image view that has the same image as the one currently panning
        self.newlyCreatedFace = [[UIImageView alloc] initWithImage:imageView.image];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanNewImageGesture:)];

        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinchNewImageGesture:)];
        
        self.newlyCreatedFace.userInteractionEnabled = YES;
        
        [self.newlyCreatedFace addGestureRecognizer:panRecognizer];
        [self.newlyCreatedFace addGestureRecognizer:pinchRecognizer];

        // Add the new face to the tray's parent view.
        [self.view addSubview:self.newlyCreatedFace];
        
        // Initialize the position of the new face.
        self.newlyCreatedFace.center = imageView.center;
        
        // Since the original face is in the tray, but the new face is in the
        // main view, you have to offset the coordinates
        CGPoint faceCenter = self.newlyCreatedFace.center;
        self.newlyCreatedFace.center = CGPointMake(faceCenter.x,
                                                   faceCenter.y + self.trayView.frame.origin.y);
        self.newFaceOriginalCenter = self.newlyCreatedFace.center;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:self.trayView.superview];
        self.newlyCreatedFace.center = CGPointMake(self.newFaceOriginalCenter.x + translation.x,
                                                   self.newFaceOriginalCenter.y + translation.y);

        
    }
}


@end

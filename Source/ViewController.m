//
//  ViewController.m
//  Picsyou
//
//  Created by Frédéric Sagnes on 27/09/12.
//  Copyright (c) 2012 teapot apps. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *coinImage;

- (IBAction)takePicture;
- (void)processImage:(UIImage *)image;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // We use a JPG image to reduce file size, but still want a transparent background.
    // Create a coin image with a transparent background by removing the white parts of the image.
    // A pixel is considered white if all its red, green and blue components are between 230 and 255 in value.
    UIImage *coinImage = [UIImage imageNamed:@"Coin.jpg"];
    CGImageRef coinImageWithTransparentBackground = CGImageCreateWithMaskingColors(coinImage.CGImage, (const CGFloat[]){230.0, 255.0, 230.0, 255.0, 230.0, 255.0});

    self.coinImage = [UIImage imageWithCGImage:coinImageWithTransparentBackground];
    CGImageRelease(coinImageWithTransparentBackground);

    // Show a default image when loading the app
    [self processImage:[UIImage imageNamed:@"Fred.jpg"]];

    // Use a classy pattern for the background, see http://iphonedevwiki.net/index.php/UIColor
    self.view.backgroundColor = [UIColor performSelector:@selector(noContentLightGradientBackgroundColor)];
}

- (IBAction)takePicture {
    NSLog(@"I should take a picture");
}

- (void)processImage:(UIImage *)image {
    UIImage *coinImage = self.coinImage;
    CGSize coinSize = coinImage.size;
    CGSize imageViewSize = self.imageView.bounds.size;
    double ratio = MIN((double)imageViewSize.width / coinSize.width, (double)imageViewSize.height / coinSize.height);
    CGContextRef context = NULL;

    UIGraphicsBeginImageContextWithOptions(imageViewSize, NO, 0.0);
    context = UIGraphicsGetCurrentContext();

    // Center and resize the coin to make it full screen
    CGContextTranslateCTM(context,
                          ((double)imageViewSize.width - ratio * coinSize.width) / 2.0,
                          ((double)imageViewSize.height - ratio * coinSize.height) / 2.0);
    CGContextScaleCTM(context, ratio, ratio);
    [coinImage drawAtPoint:CGPointMake(0.0f, 0.0f) blendMode:kCGBlendModeOverlay alpha:1.0f];
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end

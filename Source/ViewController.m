//
//  ViewController.m
//  Picsyou
//
//  Created by Frédéric Sagnes on 27/09/12.
//  Copyright (c) 2012 teapot apps. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>

#import "ViewController.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) UIImage *coinImage;

- (IBAction)takePicture;
- (IBAction)tweet;
- (void)processImage:(UIImage *)image;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // We use a JPG image to reduce file size, but still want a transparent background
    // Create a coin image with a transparent background by removing the white parts of the image
    {
        // A pixel is considered white if all its red, green and blue components are between 230 and 255 in value
        UIImage *coinImage = [UIImage imageNamed:@"Coin.jpg"];
        CGImageRef coinImageWithTransparentBackground = CGImageCreateWithMaskingColors(coinImage.CGImage, (const CGFloat[]){230.0, 255.0, 230.0, 255.0, 230.0, 255.0});

        self.coinImage = [UIImage imageWithCGImage:coinImageWithTransparentBackground];
        CGImageRelease(coinImageWithTransparentBackground);
    }

    // Show a default image when loading the app
    [self processImage:[UIImage imageNamed:@"Fred.jpg"]];

    // Use a classy gradient image for the background
    {
        NSArray *colors = @[(__bridge id)[[UIColor whiteColor] CGColor], (__bridge id)[[UIColor colorWithWhite:0.8f alpha:1.0f] CGColor]];
        CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, (CGFloat[]){0.0f, 1.0f});
        CGSize size = self.view.bounds.size;

        UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);

        // Origin is top left, draw the gradient from top to bottom
        CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, size.height), 0);
        CGGradientRelease(gradient);

        // Set the image as the background view's layer
        self.view.layer.contents = (__bridge id)[UIGraphicsGetImageFromCurrentImageContext() CGImage];
        UIGraphicsEndImageContext();
    }

    // Remove the camera button if the device does not have a camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.navigationBar.topItem.rightBarButtonItem = nil;
    }
}

- (IBAction)takePicture {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];

    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.allowsEditing = YES;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:^{}];
}

- (IBAction)tweet {
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];

    [tweetViewController setInitialText:@"My Taylor Is Rich!"];
    [tweetViewController addImage:self.imageView.image];
    [self presentViewController:tweetViewController animated:YES completion:^{}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [self processImage:image];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)processImage:(UIImage *)image {
    UIImage *coinImage = self.coinImage;
    CGSize size = self.imageView.bounds.size;
    CGRect drawRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    CGFloat margin = 11.0f;

    // Create an image that has transparency and uses the current device's scale
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);

    // Draw the shadow at the bottom of the coin
    // The context scaling is an advanced technique, comment the block if it bothers you
    {
        CGFloat shadowMargin = 10.0f;
        CGFloat scale = 1.0f - 2.0f * shadowMargin / size.width;

        // Add margins to the context to make sure we do not draw the shadow outside of it
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), shadowMargin, shadowMargin);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
        CGContextSaveGState(UIGraphicsGetCurrentContext());
        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(2.0f, 3.0f), 7.0f, [[UIColor blackColor] CGColor]);

        // The coin does not quite get to the border of the context,
        // add a pixel of margin to avoid drawin a black border
        [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(drawRect, 1.0f, 1.0f)] fill];

        CGContextRestoreGState(UIGraphicsGetCurrentContext());
    }

    // Draw the coin as the background
    [coinImage drawInRect:drawRect];

    // Draw the face centered within the coin, with a margin on each side
    drawRect = CGRectInset(drawRect, margin, margin);

    // Clip to a circle Set the mask to remove parts of the face that are outside the coin's center
    [[UIBezierPath bezierPathWithOvalInRect:drawRect] addClip];

    // Make the face image black and white to get the nice blending effect
    {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef context = CGBitmapContextCreate(NULL, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
        CGRect imageDrawRect = CGRectMake(0, 0, image.size.width, image.size.height);

        // Draw the image in a black and white context to make it gray scale
        CGContextDrawImage(context, imageDrawRect, image.CGImage);
        CGImageRef cgImage = CGBitmapContextCreateImage(context);
        image = [UIImage imageWithCGImage:cgImage];

        // Clean up the context
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        CGImageRelease(cgImage);
    }

    // Draw the face in the clipped context, use the multiply blend mode to mix the images
    [image drawInRect:drawRect blendMode:kCGBlendModeMultiply alpha:1.0f];

    // Get the generated image and clean up the context
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end

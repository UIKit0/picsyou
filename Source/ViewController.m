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

    // We use a JPG image to reduce file size, but still want a transparent background
    // Create a coin image with a transparent background by removing the white parts of the image
    // A pixel is considered white if all its red, green and blue components are between 230 and 255 in value
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

    // Draw the face centered within the coin, with a margin on each side.
    drawRect = CGRectInset(drawRect, margin, margin);

    // Set the mask to remove parts of the face that are outside the coin's center
    {
        UIImage *circleMaskImage = nil;
        CGRect maskDrawRect = CGRectMake(0, 0, drawRect.size.width, drawRect.size.height);

        // We need to create an image that will act as a mask
        // Every white pixel within this image will be "pass-through"
        UIGraphicsBeginImageContextWithOptions(maskDrawRect.size, YES, 0.0);

        // Draw the oval mask shape with a white color
        [[UIColor whiteColor] setFill];
        [[UIBezierPath bezierPathWithOvalInRect:maskDrawRect] fill];

        circleMaskImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        // Apply the mask image to the coin graphics context
        CGContextClipToMask(UIGraphicsGetCurrentContext(), drawRect, circleMaskImage.CGImage);
    }

    // Make the face image black and white to get the nice blending effect
    {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef context = CGBitmapContextCreate(NULL, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
        CGRect imageDrawRect = CGRectMake(0, 0, image.size.width, image.size.height);

        // Draw the image in a black and white context to make it gray scale
        CGContextDrawImage(context, imageDrawRect, image.CGImage);
        image = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];

        // Clean up the context
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
    }

    // Draw the face in the mask, use the multiply blend mode to mix the images
    [image drawInRect:drawRect blendMode:kCGBlendModeMultiply alpha:1.0f];

    // Get the generated image and clean up the context
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

@end

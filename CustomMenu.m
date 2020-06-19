#import "CustomMenu.h"
#import <Cephei/HBPreferences.h>


//needed to compile without iOS 13 SDK
typedef enum UISceneActivationState : NSInteger {
    UISceneActivationStateUnattached = -1,
    UISceneActivationStateForegroundActive,
    UISceneActivationStateForegroundInactive,
    UISceneActivationStateBackground
} UISceneActivationState;

@interface UIScene : NSObject
@property(nonatomic, readonly) UISceneActivationState activationState;
@end

@interface UIApplication ()
-(id)connectedScenes;
@end

@interface UIWindowScene : UIScene
@end

@interface UIWindow ()
@property(nonatomic, weak) UIWindowScene *windowScene;
@end



// custom view controller to disable landscape rotation of subviews on iOS 13
@interface CustomMenuViewController : UIViewController
@end
@implementation CustomMenuViewController
-(BOOL)shouldAutorotate{
    return NO;
}
@end


@implementation CustomMenu

-(id)init { 
    CGRect screen = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:CGRectMake(10, screen.size.height - 115, screen.size.width - 20, 70)];

    if (self) {
        CGRect menuLocation = [self frame];

        controller = [[CustomMenuViewController alloc] init]; //use our own ViewController
        [self setRootViewController:controller];
        [self setWindowLevel:9998];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setHidden:YES];
        [self makeKeyAndVisible];
        [self.layer setCornerRadius:8]; 
        [self.layer setBorderWidth:1];
        [self.layer setBorderColor:[[UIColor blackColor]CGColor]];

        segment = [[UISegmentedControl alloc] initWithFrame:CGRectMake(15, menuLocation.size.height - 40, menuLocation.size.width - 30, 30)];
        [segment removeAllSegments];
        [segment insertSegmentWithTitle:@"Allow" atIndex:0 animated:NO];
        [segment insertSegmentWithTitle:@"Block URL" atIndex:1 animated:NO];
        [segment insertSegmentWithTitle:@"Block Domain" atIndex:2 animated:NO];
        [segment addTarget:self action:@selector(onButtonTab:) forControlEvents:UIControlEventValueChanged];
        [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} forState:UIControlStateNormal]; // better readable on iOS 13

        infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, menuLocation.size.height - 70, menuLocation.size.width - 30, 30)];
        [infoLabel setText:@"This webpage wants to open a new tab..."];
        [infoLabel setTextAlignment:NSTextAlignmentCenter];
        [infoLabel setAdjustsFontSizeToFitWidth:YES];
        infoLabel.textColor = [UIColor blackColor];// to make it readable on iOS 13
        [self addSubview:segment];
        [self addSubview:infoLabel];

        [self hideMenu];
    }
    return self;
}

-(void)hideMenu{ 
    [segment setSelectedSegmentIndex:-1];
    [self setHidden:YES];
}

-(void)showMenu:(NSString *)cleanURL domain:(NSString*)cleanDomain{ 
    [self setHidden:NO]; 

    //on iOS 13 UIWindows need a  UIWindowScene to show https://stackoverflow.com/questions/57134259/how-to-resolve-keywindow-was-deprecated-in-ios-13-0
    if(kCFCoreFoundationVersionNumber >= 1665.15) {
        if(!self.windowScene || self.windowScene.activationState != UISceneActivationStateForegroundActive) {
            NSSet *connectedScenes = [UIApplication sharedApplication].connectedScenes;
            for(UIScene *scene in connectedScenes) {
               if(scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[NSClassFromString(@"UIWindowScene") class]]) {
                   self.windowScene = (UIWindowScene *)scene;
                   break;
                }
            }
        }
    }

    url = [[NSString alloc] initWithString:cleanURL];
    domain = [[NSString alloc] initWithString:cleanDomain];
} 

#define ALLOW_URL 0 
#define BLOCK_URL 1
#define BLOCK_DOMAIN 2 

-(void)onButtonTab:(UISegmentedControl *)sender {
    if (sender){  
        HBPreferences *prefrences = [[HBPreferences alloc] initWithIdentifier:@"com.droomone.tabblocker"];   
        switch([segment selectedSegmentIndex])
        {
            case ALLOW_URL: 
                NSLog(@"Adding [%@] to whitelisted domains", domain);
                NSString * whitelistdomain = [[prefrences objectForKey:@"whitelistdomain"] stringValue];
                [prefrences setObject:[[NSString alloc] initWithFormat:@"%@;%@", whitelistdomain, domain] forKey:@"whitelistdomain"];
                break; 
            case BLOCK_DOMAIN:
                NSLog(@"Adding [%@] to blocked domains", domain);
                NSString * blacklistdomain = [[prefrences objectForKey:@"blacklistdomain"] stringValue];
                [prefrences setObject:[[NSString alloc] initWithFormat:@"%@;%@", blacklistdomain, domain] forKey:@"blacklistdomain"];
                break; 
            case BLOCK_URL: 
                NSLog(@"Adding [%@] to blocked URL's", url);
                NSString * blacklisturl = [[prefrences objectForKey:@"blacklisturl"] stringValue];
                [prefrences setObject:[[NSString alloc] initWithFormat:@"%@;%@", blacklisturl, url] forKey:@"blacklisturl"];
                break; 
        } 
        [self hideMenu];
    }
}



@end
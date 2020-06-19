#import <Foundation/Foundation.h>
#import "CustomMenu.h"
#import <Cephei/HBPreferences.h>


//- Opzetten omgeving
//- Vinden bronnen (google dorks)
//- basics 
//  - Logging
//  - Vinden van functies
//  - Xcode
//  - UIMenu popup
//  - Maken preference bundle
//  - Communiceren met die bundle

static CustomMenu * menu; 
static NSArray * blockedURLs;
static NSArray * blockedDomains;
static NSArray * allowedDomains;
static bool nodialog;  
static id tabController;

@interface TabDocument
- (NSString *)URLString; 
@end

@interface TabController
@property(strong) CustomMenu *m; // UIWindow needs strong reference to show on iOS 13
-(id)parentTabDocumentForBackClosesSpawnedTab; //method to get originalTab
@end


void updatePrefs(){ 
    // Getting settings from plist
    HBPreferences *preference = [[HBPreferences alloc] initWithIdentifier:@"com.droomone.tabblocker"];
    NSString * whitelistdomain = [[preference objectForKey:@"whitelistdomain"] stringValue];
    NSString * blacklisturl = [[preference objectForKey:@"blacklisturl"] stringValue];
    NSString * blacklistdomain = [[preference objectForKey:@"blacklistdomain"] stringValue];
    nodialog = [[preference objectForKey:@"nodialog"] boolValue];

    // Converting to array's
    blockedURLs = [blacklisturl componentsSeparatedByString:@";"];
    blockedDomains = [blacklistdomain componentsSeparatedByString:@";"];
    allowedDomains = [whitelistdomain componentsSeparatedByString:@";"];
}


%group iOS12
%hook TabController   



- (void)insertNewTabDocument:(id)arg1 openedFromTabDocument:(id)document inBackground:(_Bool)arg3 animated:(_Bool)arg4{
	updatePrefs();
    TabDocument *originalTab = document;
    tabController = self; 
    
    if ([originalTab URLString]){
        NSURL * originURL = [[NSURL alloc] initWithString:[originalTab URLString]]; 

        // Cleaning URL from safari! 
        NSString * cleanDomain = [[originURL host] stringByReplacingOccurrencesOfString:@"www." withString:@""]; 
        NSString * cleanURL = [[originURL resourceSpecifier] stringByReplacingOccurrencesOfString:@"//" withString:@""];
        cleanURL = [cleanURL stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        cleanURL = [cleanURL stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        cleanURL = [cleanURL stringByReplacingOccurrencesOfString:@"www." withString:@""];
    
        if ([allowedDomains containsObject:cleanDomain]){
            NSLog(@"Allowed new tab from: [%@] - specified in whitelisted domains", cleanDomain);
            return %orig;
        }
        
        if ([blockedDomains containsObject:cleanDomain]){ 
            NSLog(@"Blocked new tab from: [%@] - specified in blacklisted domains", cleanDomain);
            return;
        }  
    
        for (id blockedURL in blockedURLs){
            // Cleaning URL input by user
            NSString * cleanBlockedURL = [blockedURL stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            cleanBlockedURL = [cleanBlockedURL stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            cleanBlockedURL = [cleanBlockedURL stringByReplacingOccurrencesOfString:@"www." withString:@""]; 

            if ([cleanBlockedURL isEqualToString:cleanURL]){
                NSLog(@"Blocked new tab from: [%@] - specified in blacklisted URL's", cleanURL);
                return;
            }
        }

        // Nothing happend, must be a new website! Showing userdialog :)
        if (!nodialog) {  
            [menu showMenu:cleanURL domain:cleanDomain]; 
            return; 
        }
    }
	return %orig;	 
} 
%end
%end


 
%group iOS13
%hook TabController
// UIWindow needs strong reference to show on iOS 13
%property(strong) CustomMenu *m;

-(id)initWithBrowserController:(id)arg1{
    self.m = [[CustomMenu alloc] init];
    return %orig;
}

-(void)insertNewTabDocumentWithDefaultOrdering:(id)arg1 inBackground:(BOOL)arg3 animated:(BOOL)arg4{
    updatePrefs();

    TabDocument *originalTab = [arg1 parentTabDocumentForBackClosesSpawnedTab];
    tabController = self;


    if ([originalTab URLString]){
        NSURL * originURL = [[NSURL alloc] initWithString:[originalTab URLString]];

        // Cleaning URL from safari!
        NSString * cleanDomain = [[originURL host] stringByReplacingOccurrencesOfString:@"www." withString:@""];
        NSString * cleanURL = [[originURL resourceSpecifier] stringByReplacingOccurrencesOfString:@"//" withString:@""];
        cleanURL = [cleanURL stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        cleanURL = [cleanURL stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        cleanURL = [cleanURL stringByReplacingOccurrencesOfString:@"www." withString:@""];

        if ([allowedDomains containsObject:cleanDomain]){
            NSLog(@"Allowed new tab from: [%@] - specified in whitelisted domains", cleanDomain);
            return %orig;
        }

        if ([blockedDomains containsObject:cleanDomain]){
            NSLog(@"Blocked new tab from: [%@] - specified in blacklisted domains", cleanDomain);
            return;
        }

        for (id blockedURL in blockedURLs){
            // Cleaning URL input by user
            NSString * cleanBlockedURL = [blockedURL stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            cleanBlockedURL = [cleanBlockedURL stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            cleanBlockedURL = [cleanBlockedURL stringByReplacingOccurrencesOfString:@"www." withString:@""];

            if ([cleanBlockedURL isEqualToString:cleanURL]){
                NSLog(@"Blocked new tab from: [%@] - specified in blacklisted URL's", cleanURL);
                return;
            }
        }

        // Nothing happend, must be a new website! Showing userdialog :)
        if (!nodialog) {
            [self.m showMenu:cleanURL domain:cleanDomain];
            return;
        }
    }
    return %orig;
}
%end
%end

%ctor{ 
    updatePrefs();
    if(kCFCoreFoundationVersionNumber >= 1665.15){
        %init(iOS13);
    }else{
        menu = [[CustomMenu alloc] init];
        %init(iOS12);
    }
}
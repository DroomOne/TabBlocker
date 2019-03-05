#include "Settings.h"

@implementation Settings

-(NSString *)GetGlobalSettingsByKey: (NSString *)key{
	NSString * path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/com.droomone.tabblockerpreferencebundle.plist"];
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:path];
	/*url_list*/ NSString * result = [[prefs objectForKey:key] stringValue];
	NSLog(@"Global Settings [%@]: %@", key, result);
	return result;
}
-(NSString *)GetLocalSettingsByKey: (NSString *)key{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *documentsPath = [documentsDirectory stringByAppendingPathComponent:@"tabblocker.plist"];
	NSLog(@"Reading local settings [%@]", documentsPath);
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:documentsPath];
	NSString * result = [[prefs objectForKey:key] stringValue];
	NSLog(@"Local Settings [%@]: %@", key, result);
	return result;
}

@end
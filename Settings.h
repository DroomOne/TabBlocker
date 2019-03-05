@interface Settings : NSObject { 
}
-(NSString *)GetGlobalSettingsByKey: (NSString *)key;
-(NSString *)GetLocalSettingsByKey: (NSString *)key;
@end
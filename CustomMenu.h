@interface CustomMenu : UIWindow {
    UIViewController *controller;
    UISegmentedControl *segment; 
    UILabel *infoLabel;
    NSString *url;
    NSString *domain; 
}
-(void)hideMenu;
-(void)showMenu:(NSString*)cleanURL domain:(NSString*)cleanDomain; 
@end
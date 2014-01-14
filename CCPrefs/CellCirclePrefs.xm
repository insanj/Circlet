#import "../SBHeads.h"
#import "../ORLogger.h"
#import "../ORPuller.h"
#import "../ORProvider.h"

@interface PSViewController : UIViewController
-(id)initForContentSize:(CGSize)contentSize;
-(void)setPreferenceValue:(id)value specifier:(id)specifier;
@end

@interface PSListController : PSViewController {
	NSArray *_specifiers;
}

-(void)loadView;
-(void)reloadSpecifier:(PSSpecifier*)specifier animated:(BOOL)animated;
-(void)reloadSpecifier:(PSSpecifier*)specifier;
-(NSArray *)loadSpecifiersFromPlistName:(NSString *)name target:(id)target;
-(PSSpecifier*)specifierForID:(NSString*)specifierID;
@end

@interface PSTableCell : UITableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;
@end

@interface ORPreferencesListController: PSListController <UIAlertViewDelegate> {
	ORLogger *logger;
}

-(void)shareTapped:(UIBarButtonItem *)sender;
@end

@implementation ORPreferencesListController
static NSString *prevName, *prevInterval;

-(void)loadView {
	logger = [[ORLogger alloc] initFromSource:@"ORPreferences.xm"];
	UIBarButtonItem *heart = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/ORPreferences.bundle/heart.png"] style:UIBarButtonItemStylePlain target:self action:@selector(shareTapped:)];
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), NO, 0.0);
	UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[heart setBackgroundImage:blank forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	self.navigationItem.rightBarButtonItem = heart;

	prevName = [[NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.orangered.plist"]] objectForKey:@"usernameText"];
	[super loadView];
}

-(void)shareTapped:(UIBarButtonItem *)sender {
	NSString *text = @"I'll never miss a Reddit message again with #Orangered by @insanj! ";
	NSString *urlString = @"http://insanj.com/orangered/";
	NSURL *url = [NSURL URLWithString:urlString];

	if (%c(TWTweetComposeViewController) && [TWTweetComposeViewController canSendTweet]) {
		TWTweetComposeViewController *viewController = [[TWTweetComposeViewController alloc] init];
		viewController.initialText = text;
		[viewController addURL:url];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	}

	else if (%c(UIActivityViewController)) {
		UIActivityViewController *viewController = [[%c(UIActivityViewController) alloc] initWithActivityItems:[NSArray arrayWithObjects:text, url, nil] applicationActivities:nil];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	}

	else {
		text = [text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@%@", text, urlString]]];
	}
}//end sharetapped

-(id)specifiers {

	if(!_specifiers)
		_specifiers = [self loadSpecifiersFromPlistName:[[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/libactivator.list"]?@"ORPreferences":@"ORAntiPreferences" target:self];

	return _specifiers;
}//end specifiers

-(void)save{
	[self.view endEditing:YES];
	[logger log:@"checking inbox from Settings..."];

	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"ORNotFirstSave"]){
		[[[UIAlertView alloc] initWithTitle:@"Orangered" message:@"If you haven't already, make sure to enable Badges and Sounds in the Notification settings!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ORNotFirstSave"];
	}

	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.orangered.plist"]];
	NSString *savedName = [settings objectForKey:@"usernameText"];
	NSString *savedPass = [settings objectForKey:@"passwordText"];
	NSString *savedInterval = [settings objectForKey:@"intervalText"];

	if (!savedName || [savedName isEmpty] || !savedPass || [savedPass isEmpty]){
		[[[UIAlertView alloc] initWithTitle:@"Orangered" message:@"You need a valid Reddit username and password to use Orangered!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
		return;
	}//end if not user/pass

	else if(![prevName isEqualToString:savedName] && ![prevName isEmpty]){
		[[[UIAlertView alloc] initWithTitle:@"Orangered" message:@"Sorry, you need to respring to switch users in this release!" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Now", nil] show];
		return;
	}

	if([savedInterval floatValue] < 1 && savedInterval){
		[[[UIAlertView alloc] initWithTitle:@"Orangered" message:@"The interval you attempted to set was invalid. Make sure it's not below 1, and only contains numbers!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
		PSSpecifier* intervalSpecifier = [self specifierForID:@"NumberField"];
		[self setPreferenceValue:prevInterval specifier:intervalSpecifier];
		[self reloadSpecifier:intervalSpecifier animated:YES];
		[[NSUserDefaults standardUserDefaults] synchronize];
		return;
	}//end if interval not set

	else if(![prevInterval isEqualToString:savedInterval] && savedInterval)
		prevInterval = savedInterval;

	NSDictionary *sentDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Orangered", @"title", @"checking for new messages...", @"message", @"wait", @"label", [NSNumber numberWithBool:YES], @"show", nil];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"ORGivenNotification" object:nil userInfo:sentDictionary];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"ORTimerNotification" object:nil];
}//end save

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 1)
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"ORRespringNotification" object:nil];
}

-(void)twitter:(PSSpecifier *)specifier{
	NSString *label = [specifier.properties objectForKey:@"label"];
	NSString *_user = [label substringFromIndex:1];

	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:_user]]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:_user]]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:_user]]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:_user]]];

	else 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:_user]]];
}//end twitter

-(void)mail{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:me%40insanj.com?subject=Orangered%20(1.0)%20Support"]];//
}
@end

@interface ORAboutListController : PSListController
-(void)twitter:(PSSpecifier *)specifier;
@end

@implementation ORAboutListController
-(id)specifiers {
	if(!_specifiers)
		_specifiers = [self loadSpecifiersFromPlistName:@"ORAbout" target:self];

	return _specifiers;
}//end specifiers

-(void)twitter:(PSSpecifier *)specifier{
	NSString *label = [specifier.properties objectForKey:@"label"];
	NSString *user = [label substringFromIndex:1];

	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];

	else 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
}//end twitter
@end

@interface ORHelpListController : PSListController
@end

@implementation ORHelpListController
-(id)specifiers {
	if(!_specifiers)
		_specifiers = [self loadSpecifiersFromPlistName:@"ORHelp" target:self];

	return _specifiers;
}//end specifiers
@end
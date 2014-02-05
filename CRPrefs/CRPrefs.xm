#import "../CRHeaders.h"
#import <UIKit/UIActivityViewController.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#include <notify.h>

#define URL_ENCODE(string) [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8) autorelease]
#define CRTINTCOLOR [UIColor blackColor]

@interface CRListItemsController : PSListItemsController
@end

@implementation CRListItemsController
-(void)viewWillAppear:(BOOL)animated{
	//self.view.tintColor = CRTINTCOLOR;
    self.navigationController.navigationBar.tintColor = CRTINTCOLOR;
}

-(void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];

	//self.view.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
}
@end

@interface CRPrefsListController : PSListController <MFMailComposeViewControllerDelegate>
@end

@implementation CRPrefsListController

-(void)viewDidLoad{
	[super viewDidLoad];
	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = CRTINTCOLOR;
	[UISegmentedControl appearanceWhenContainedIn:self.class, nil].tintColor = CRTINTCOLOR;
}


-(void)loadView{
	[super loadView];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)];
}

-(NSArray *)specifiers{
	if(!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"CRPrefs" target:self] retain];

	return _specifiers;
}

-(void)viewWillAppear:(BOOL)animated{
    [(UITableView *)self.view deselectRowAtIndexPath:((UITableView *)self.view).indexPathForSelectedRow animated:YES];

	self.view.tintColor = CRTINTCOLOR;
    self.navigationController.navigationBar.tintColor = CRTINTCOLOR;

	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.insanj.circlet.plist"]];
	
	if(![settings objectForKey:@"signalSize"]){
		PSSpecifier *signalSizeSpecifier = [self specifierForID:@"SignalSize"];
		[self setPreferenceValue:@(5.0) specifier:signalSizeSpecifier];
		[self reloadSpecifier:signalSizeSpecifier];
	}

	if(![settings objectForKey:@"wifiSize"]){
		PSSpecifier *wifiSizeSpecifier = [self specifierForID:@"WifiSize"];
		[self setPreferenceValue:@(5.0) specifier:wifiSizeSpecifier];
		[self reloadSpecifier:wifiSizeSpecifier];
	}

	if(![settings objectForKey:@"batterySize"]){
		PSSpecifier *batterySizeSpecifier = [self specifierForID:@"BatterySize"];
		[self setPreferenceValue:@(5.0) specifier:batterySizeSpecifier];
		[self reloadSpecifier:batterySizeSpecifier];
	}
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	self.view.tintColor = nil;
	self.navigationController.navigationBar.tintColor = nil;
}

-(void)shareTapped:(UIBarButtonItem *)sender{
	NSString *text = @"Life has never been simpler than with #Circlet by @insanj.";
	NSURL *url = [NSURL URLWithString:@"http://insanj.com/circlet"];

	if(%c(UIActivityViewController)){
		UIActivityViewController *viewController = [[[%c(UIActivityViewController) alloc] initWithActivityItems:[NSArray arrayWithObjects:text, url, nil] applicationActivities:nil] autorelease];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	} else if (%c(TWTweetComposeViewController) && [TWTweetComposeViewController canSendTweet]) {
		TWTweetComposeViewController *viewController = [[[TWTweetComposeViewController alloc] init] autorelease];
		viewController.initialText = text;
		[viewController addURL:url];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@%%20%@", URL_ENCODE(text), URL_ENCODE(url.absoluteString)]]];
	}
}

-(void)respring{
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"CRPromptRespring" object:nil];
}

-(void)twitter{
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/insanj"]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitterrific:///profile?screen_name=insanj"]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetings:///user?screen_name=insanj"]];

	else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=insanj"]];

	else 
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/insanj"]];
}

-(void)mail{
	NSURL *helpurl = [NSURL URLWithString:@"mailto:me%40insanj.com?subject=Circlet%20(1.0)%20Support"];
	if([MFMailComposeViewController canSendMail]){
		MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
		[composeViewController setMailComposeDelegate:self];
		[composeViewController setToRecipients:@[@"me@insanj.com"]];
		[composeViewController setSubject:@"Circlet (1.0) Support"];
		[self presentViewController:composeViewController animated:YES completion:nil];
	}
		
	else if ([[UIApplication sharedApplication] canOpenURL:helpurl])
		[[UIApplication sharedApplication] openURL:helpurl];
		
	else
		[[[UIAlertView alloc] initWithTitle:@"Contact Developer" message:@"Shoot an email to me@insanj.com, or talk to me on twitter (@insanj) if you have any problems, requests, or ideas!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil] show];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end


@interface CRCreditsCell : PSTableCell
@end

@implementation CRCreditsCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if(self){
		self.textLabel.numberOfLines = 0;
	    self.textLabel.font = [UIFont systemFontOfSize:14.0];
	    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
   	}

   	return self;
}//end init

@end
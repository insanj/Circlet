#import "CRHeaders.h"
#import "CRView.h"

@interface SpringBoard (Circlet)
-(void)circlet_generateCirclesFresh:(id)listener;
-(void)circlet_saveCircle:(CRView *)circle toPath:(NSString *)path withWhite:(UIColor *)white black:(UIColor *)black count:(int)count;
-(BOOL)circlet_saveCircle:(CRView *)circle toPath:(NSString *)path withName:(NSString *)name;
@end
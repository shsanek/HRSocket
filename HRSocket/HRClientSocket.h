//
//  HRClientSocket.h
//  HRLog
//
//  Created by Alexander Shipin on 28/02/16.
//  Copyright © 2016 Alexander Shipin. All rights reserved.
//

#import "HRSocket.h"

@interface HRClientSocket : HRSocket

- (void) connectIP:(NSString*) ip port:(NSInteger) port;

@end

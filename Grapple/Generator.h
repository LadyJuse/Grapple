//
//  Generator.h
//  Grapple
//
//  Created by BCIT Student on 2018-02-25.
//  Copyright © 2018 Penguin Interactive. All rights reserved.
//

#ifndef Generator_h
#define Generator_h
#import "Renderer.h"

@interface Generator : NSObject

-(void)setup:(Renderer*)renderer;
-(void)Generate:(float)deltaTime;

@end

#endif /* Generator_h */

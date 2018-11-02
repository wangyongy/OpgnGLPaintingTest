//  OpgnGLPaintingTest
//
//  Created by 王勇 on 2018/10/30.
//  Copyright © 2018年 王勇. All rights reserved.
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGLIOSurface.h>
#import <GLKit/GLKit.h>

#import "PaintingView.h"
#import "shaderUtil.h"
#import "fileUtil.h"
#import "debug.h"
#import "WYMain.h"
//CONSTANTS:

#define kBrushPixelStep		1
// Shaders
enum {
    PROGRAM_POINT,
    NUM_PROGRAMS
};

enum {
	UNIFORM_MVP,
    UNIFORM_POINT_SIZE,
    UNIFORM_VERTEX_COLOR,
    UNIFORM_TEXTURE,
	NUM_UNIFORMS
};

enum {
	ATTRIB_VERTEX,
	NUM_ATTRIBS
};

typedef struct {
	char *vert, *frag;
	GLint uniform[NUM_UNIFORMS];
	GLuint id;
} programInfo_t;

programInfo_t program[NUM_PROGRAMS] = {
    { "point.vsh",   "point.fsh" },     // PROGRAM_POINT
};


// Texture
typedef struct {
    GLuint id;
    GLsizei width, height;
} textureInfo_t;

@interface PaintingView()
{
	// The pixel dimensions of the backbuffer
	GLint _backingWidth;
	GLint _backingHeight;
	
	EAGLContext *_context;
	
	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint _viewRenderbuffer, _viewFramebuffer;
    
    // OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
    GLuint _depthRenderbuffer;
	
	textureInfo_t _brushTexture;     // brush texture
    GLfloat _brushColor[4];          // brush color

    GLuint _vboId;
    
    BOOL _initialized;
    
    NSTimer * _showTimer;
}
/** 当前选择的线条宽度 */
@property (nonatomic, copy) CGFloat (^lineWidthBlock)(void);

/** 当前选择的线条颜色 */
@property (nonatomic, copy) UIColor * (^lineColorBlock)(void);

/** 当前选择的画笔类型 */
@property (nonatomic, copy) BOOL (^isEraserBlock)(void);

/** 当前选是否是橡皮擦 */
@property (nonatomic, copy) DrawPenType (^drawPenTypeBlock)(void);

/**  画板上所有点的集合  */
@property (nonatomic, strong) NSMutableArray<DrawModel *>* pointsArray;

@end

@implementation PaintingView

// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class)layerClass
{
	return [CAEAGLLayer class];
}

#pragma mark - openGL init
// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.
-(void)layoutSubviews
{
    [self setupLayer];
    
    [self setupContext];
    
    [self setupBuffer];
    
    [self setupShaders];

    if (!_initialized) {
        _initialized = [self render];
    }
    else {
        [self resizeFromLayer:(CAEAGLLayer*)self.layer];
    }
}
- (void)setupLayer
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    // In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    //设置放大倍数
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
}

- (void)setupContext
{
    // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!_context || ![EAGLContext setCurrentContext:_context]) {
        
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        
        exit(1);
    }
}

- (void)setupBuffer
{
    glDeleteFramebuffers(1, &_viewFramebuffer);
    
    _viewRenderbuffer = 0;
    
    glDeleteRenderbuffers(1, &_viewRenderbuffer);
    
    _viewRenderbuffer = 0;

    glGenFramebuffers(1, &_viewFramebuffer);
    
    glGenRenderbuffers(1, &_viewRenderbuffer);

    glBindFramebuffer(GL_FRAMEBUFFER, _viewFramebuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _viewRenderbuffer);
    
    // 为 颜色缓冲区 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _viewRenderbuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}
- (void)setupShaders
{
	for (int i = 0; i < NUM_PROGRAMS; i++)
	{
		char *vsrc = readFile(pathForResource(program[i].vert));
		char *fsrc = readFile(pathForResource(program[i].frag));
		GLsizei attribCt = 0;
		GLchar *attribUsed[NUM_ATTRIBS];
		GLint attrib[NUM_ATTRIBS];
		GLchar *attribName[NUM_ATTRIBS] = {
			"inVertex",
		};
		const GLchar *uniformName[NUM_UNIFORMS] = {
			"MVP", "pointSize", "vertexColor", "texture",
		};
		
		// auto-assign known attribs
		for (int j = 0; j < NUM_ATTRIBS; j++)
		{
			if (strstr(vsrc, attribName[j]))
			{
				attrib[attribCt] = j;
				attribUsed[attribCt++] = attribName[j];
			}
		}
		
		glueCreateProgram(vsrc, fsrc,
                          attribCt, (const GLchar **)&attribUsed[0], attrib,
                          NUM_UNIFORMS, &uniformName[0], program[i].uniform,
                          &program[i].id);
		free(vsrc);
		free(fsrc);
        
        // Set constant/initalize uniforms
        if (i == PROGRAM_POINT)
        {
            glUseProgram(program[PROGRAM_POINT].id);
            
            // the brush texture will be bound to texture unit 0
            glUniform1i(program[PROGRAM_POINT].uniform[UNIFORM_TEXTURE], 0);
            
            // viewing matrices
            GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, _backingWidth, 0, _backingHeight, -1, 1);
            GLKMatrix4 modelViewMatrix = GLKMatrix4Identity; // this sample uses a constant identity modelView matrix
            GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
            
            glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
        
            // point size
            glUniform1f(program[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], _brushTexture.width / 12 * self.lineWidthBlock());
            
            // initialize brush color
            glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, _brushColor);
        }
	}
    
    glError();
}

// Create a texture from an image
- (textureInfo_t)textureFromName:(NSString *)name
{
    CGImageRef		brushImage;
	CGContextRef	brushContext;
	GLubyte			*brushData;
	size_t			width, height;
    GLuint          texId;
    textureInfo_t   texture;
    
    // First create a UIImage object from the data in a image file, and then extract the Core Graphics image
    brushImage = [UIImage imageNamed:name].CGImage;
    
    // Get the width and height of the image
    width = CGImageGetWidth(brushImage);
    height = CGImageGetHeight(brushImage);
    
    // Make sure the image exists
    {
        // Allocate  memory needed for the bitmap context
        brushData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
        // Use  the bitmatp creation function provided by the Core Graphics framework.
        brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
        // After you create the context, you can draw the  image to the context.
        CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
        // You don't need the context at this point, so you need to release it to avoid memory leaks.
        CGContextRelease(brushContext);
        // Use OpenGL ES to generate a name for the texture.
        glGenTextures(1, &texId);
        // Bind the texture name.
        glBindTexture(GL_TEXTURE_2D, texId);
        // Set the texture parameters to use a minifying filter and a linear filer (weighted average)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        // Specify a 2D texture image, providing the a pointer to the image data in memory
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
        // Release  the image data; it's no longer needed
        free(brushData);
        
        texture.id = texId;
        texture.width = (int)width;
        texture.height = (int)height;
    }
    
    return texture;
}
- (BOOL)render
{

    // Setup the view port in Pixels
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    // Create a Vertex Buffer Object to hold our data
    glGenBuffers(1, &_vboId);
    
    // Load the brush texture
    _brushTexture = [self textureFromName:@"Particle.png"];
    
    // Enable blending and set a blending function appropriate for premultiplied alpha pixel data
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
 
    return YES;
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
	// Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, _viewRenderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
        NSLog(@"Failed to make complete framebuffer objectz %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    // Update projection matrix
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, _backingWidth, 0, _backingHeight, -1, 1);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity; // this sample uses a constant identity modelView matrix
    GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    glUseProgram(program[PROGRAM_POINT].id);
    glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
    
    // Update viewport
    glViewport(0, 0, _backingWidth, _backingHeight);
	
    return YES;
}

// Releases resources when they are not longer needed.
- (void)dealloc
{
    // Destroy framebuffers and renderbuffers
	if (_viewFramebuffer) {
        glDeleteFramebuffers(1, &_viewFramebuffer);
        _viewFramebuffer = 0;
    }
    if (_viewRenderbuffer) {
        glDeleteRenderbuffers(1, &_viewRenderbuffer);
        _viewRenderbuffer = 0;
    }
	if (_depthRenderbuffer)
	{
		glDeleteRenderbuffers(1, &_depthRenderbuffer);
		_depthRenderbuffer = 0;
	}
    // texture
    if (_brushTexture.id) {
		glDeleteTextures(1, &_brushTexture.id);
		_brushTexture.id = 0;
	}
    // vbo
    if (_vboId) {
        glDeleteBuffers(1, &_vboId);
        _vboId = 0;
    }
    
    // tear down context
	if ([EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
    
    [_showTimer invalidate];
    
    _showTimer = nil;
}

#pragma mark - public
- (instancetype)initWithFrame:(CGRect)frame lineColorBlock:(UIColor *(^)(void))lineColorBlock lineWidthBlock:(CGFloat(^)(void))lineWidthBlock isEraserBlock:(BOOL(^)(void))isEraserBlock drawPenTypeBlock:(DrawPenType(^)(void))drawPenTypeBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.masksToBounds = YES;
        
        self.userInteractionEnabled = YES;
        
        _lineColorBlock = lineColorBlock;
        
        _lineWidthBlock = lineWidthBlock;
        
        _isEraserBlock = isEraserBlock;
        
        _drawPenTypeBlock = drawPenTypeBlock;
        
         self.pointsArray = [NSMutableArray array];
        
        WS(weakSelf)
        
        UITapGestureRecognizer * tap = [UITapGestureRecognizer initWithBlockAction:^(UIGestureRecognizer *sender) {
            
            weakSelf.isDrawing = !weakSelf.isDrawing;
        }];
        
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)undo
{
    if (!self.pointsArray.count) return;
    
    [self.pointsArray removeLastObject];
    
    [self showLines];
}
// Erases the screen
- (void)clearLines
{
    [self.pointsArray removeAllObjects];
    
    self.image = nil;
    
    [EAGLContext setCurrentContext:_context];
    
    // Clear the buffer
    glBindFramebuffer(GL_FRAMEBUFFER, _viewFramebuffer);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Display the buffer
    glBindRenderbuffer(GL_RENDERBUFFER, _viewRenderbuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}
- (void)showLines
{
    [EAGLContext setCurrentContext:_context];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _viewFramebuffer);
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    NSInteger totalCount = 0;
    
    for (NSInteger i = 0; i < self.pointsArray.count; i++) {
        
        DrawModel * model = self.pointsArray[i];
        
        UIColor * currentColor = model.lineColor;
        
        [self setBrushColorWithRed:[currentColor.RGBArray[0] floatValue] green:[currentColor.RGBArray[1] floatValue] blue:[currentColor.RGBArray[2] floatValue] alpha:[currentColor.RGBArray[3] floatValue]];
        
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        
        // point size
        glUniform1f(program[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], _brushTexture.width / 12 * model.lineWidth);
        
        if (model.isEraser) {
            
            [self setIsEraser:model.isEraser];
        }
        
        if (model.pointsArray.count >= 2) {
            
            if (model.penType == kDrawPenTypeCurve || model.isEraser) {
                
                for (NSInteger j = 0; j < model.pointsArray.count - 1; j++) {
                    
                    DrawPointModel * pointModel1 = model.pointsArray[j];
                    
                    DrawPointModel * pointModel2 = model.pointsArray[j + 1];
                    
                    CGPoint start = CGPointMake(pointModel1.x, pointModel1.y);
                    
                    CGPoint end = CGPointMake(pointModel2.x, pointModel2.y);
                    
                    totalCount += [self readyRenderLineFromPoint:start toPoint:end];
                }
                
            }else{
                
                DrawPointModel * pointModel1 = model.pointsArray.firstObject;
                
                DrawPointModel * pointModel2 = model.pointsArray.lastObject;
                
                CGPoint start = CGPointMake(pointModel1.x, pointModel1.y);
                
                CGPoint end = CGPointMake(pointModel2.x, pointModel2.y);
                
                switch (model.penType) {
                        
                    case kDrawPenTypeStraight:
                    {
                        totalCount += [self readyRenderLineFromPoint:start toPoint:end];
                    }
                        break;
                    case kDrawPenTypeRectangle:
                    {
                        totalCount += [self readyRenderRectangleFromPoint:start toPoint:end];
                    }
                        break;
                    case kDrawPenTypeCircular:
                    {
                        totalCount += [self readyRenderCircularFromPoint:start toPoint:end];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
    
    // Display the buffer
    glBindRenderbuffer(GL_RENDERBUFFER, _viewRenderbuffer);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    NSLog(@"totalCount: %zd",totalCount);
}
#pragma mark - setting

- (void)setIsEraser:(BOOL)isEraser
{
    if (isEraser) {
        
        [self setBrushColorWithRed:0 green:0 blue:0 alpha:0];
        
        // 设置绘画模式
        glBlendFunc(GL_ONE, GL_ZERO);
        
    }else{
        
        UIColor * currentColor = self.lineColorBlock();
        
        [self setBrushColorWithRed:[currentColor.RGBArray[0] floatValue] green:[currentColor.RGBArray[1] floatValue] blue:[currentColor.RGBArray[2] floatValue] alpha:[currentColor.RGBArray[3] floatValue]];
        
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    }
}

- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    // Update the brush color
    _brushColor[0] = red ;
    _brushColor[1] = green ;
    _brushColor[2] = blue ;
    _brushColor[3] = alpha;
    
    if (_initialized) {
        glUseProgram(program[PROGRAM_POINT].id);
        // 设置画笔颜色
        glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, _brushColor);
    }
}
- (void)setIsDrawing:(BOOL)isDrawing
{
    _isDrawing = isDrawing;
    
    if (self.isDrawingBlock) {
        
        self.isDrawingBlock(_isDrawing);
    }
}
#pragma mark - painting
// Drawings a line onscreen based on where the user touches
- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
{
    [EAGLContext setCurrentContext:_context];
    glBindFramebuffer(GL_FRAMEBUFFER, _viewFramebuffer);
    
    [self readyRenderLineFromPoint:start toPoint:end];
    
    glBindRenderbuffer(GL_RENDERBUFFER, _viewRenderbuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}
- (NSInteger)readyRenderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
{
    static GLfloat*        vertexBuffer = NULL;
    static NSUInteger    vertexMax = 64;
    NSUInteger            vertexCount = 0,
    count,
    i;
    
    // Convert locations from Points to Pixels
    CGFloat scale = self.contentScaleFactor;
    start.x *= scale;
    start.y *= scale;
    end.x *= scale;
    end.y *= scale;
    
    // Allocate vertex array buffer
    if(vertexBuffer == NULL)
        vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
    
    // Add points to the buffer so there are drawing points every X pixels
    count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
    for(i = 0; i < count; ++i) {
        if(vertexCount == vertexMax) {
            vertexMax = 2 * vertexMax;
            vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
        }
        
        vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
        vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
        vertexCount += 1;
    }
    
    // Load data to the Vertex Buffer Object
    glBindBuffer(GL_ARRAY_BUFFER, _vboId);
    glBufferData(GL_ARRAY_BUFFER, vertexCount*2*sizeof(GLfloat), vertexBuffer, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    // Draw
    glUseProgram(program[PROGRAM_POINT].id);
    glDrawArrays(GL_POINTS, 0, (int)vertexCount);
    
    return vertexCount;
}
- (NSInteger)readyRenderRectangleFromPoint:(CGPoint)start toPoint:(CGPoint)end
{
    CGPoint point2 = CGPointMake(start.x, end.y);
    
    CGPoint point3 = CGPointMake(end.x, start.y);
    
    NSInteger totalCount = 0;
    
    totalCount += [self readyRenderLineFromPoint:start toPoint:point2];
    
    totalCount += [self readyRenderLineFromPoint:point2 toPoint:end];
    
    totalCount += [self readyRenderLineFromPoint:end toPoint:point3];
    
    totalCount += [self readyRenderLineFromPoint:point3 toPoint:start];
    
    return totalCount;
}
- (NSInteger)readyRenderCircularFromPoint:(CGPoint)start toPoint:(CGPoint)end
{
    GLfloat radius = sqrt(pow((start.x - end.x), 2) + pow((start.y - end.y), 2))/2;     //半径
    
    CGPoint center = CGPointMake((start.x + end.x)/2, (start.y + end.y)/2);             //圆心
    
    GLfloat pointCount = 100;
    
    GLfloat delta = 2.0*M_PI/pointCount;
    
    NSString * lastPoint = nil;
    
    CGPoint firstPoint = CGPointZero;
    
    CGFloat totalCount = 0;
    
    for (NSInteger i = 0; i < pointCount; i++) {
        
        GLfloat x = radius * cos(delta * i) + center.x;
        
        GLfloat y = radius * sin(delta * i) + center.y;
        
        CGPoint currentPoint = CGPointMake(x, y);
        
        if (i == 0) {
            
            firstPoint = currentPoint;
        }
        
        if (lastPoint != nil) {
            
            totalCount += [self readyRenderLineFromPoint:CGPointFromString(lastPoint) toPoint:currentPoint];
        }
        
        lastPoint = NSStringFromCGPoint(currentPoint);
        
        if (i == pointCount - 1) {
            
            totalCount += [self readyRenderLineFromPoint:CGPointFromString(lastPoint) toPoint:firstPoint];
        }
    }
    
    return totalCount;
}
#pragma mark - touch
// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [_showTimer setFireDate:[NSDate distantFuture]];
    
	CGRect				bounds = [self bounds];
    
    UITouch*            touch = [[event touchesForView:self] anyObject];
    
    [self setIsEraser:self.isEraserBlock()];
    
    // point size
    glUniform1f(program[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], _brushTexture.width / 12 * self.lineWidthBlock());
    
	// Convert touch point from UIView referential to OpenGL one (upside-down flip)
	CGPoint location = [touch locationInView:self];
    
	location.y = bounds.size.height - location.y;
    
    DrawModel * model = [[DrawModel alloc] init];
    
    model.lineWidth = self.lineWidthBlock();
    
    model.lineColor = self.lineColorBlock();
    
    model.penType = self.drawPenTypeBlock();
    
    model.isEraser = self.isEraserBlock();
    
    DrawPointModel *pointModel = [[DrawPointModel alloc] initWithDrawModel:model];
    
    pointModel.x = location.x;
    
    pointModel.y = location.y;
    
    pointModel.pointStatus = kDrawPointStatusStart;
    
    [model.pointsArray addObject:pointModel];
    
    [self.pointsArray addObject:model];
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.isDrawing = YES;
    
	CGRect				bounds = [self bounds];
	UITouch*			touch = [[event touchesForView:self] anyObject];
		
	// Convert touch point from UIView referential to OpenGL one (upside-down flip)
    CGPoint location = [touch locationInView:self];
    
    location.y = bounds.size.height - location.y;
    
    CGPoint previousLocation = [touch previousLocationInView:self];
    
    previousLocation.y = bounds.size.height - previousLocation.y;
    
    DrawModel *model = self.pointsArray.lastObject;
    
    DrawPointModel *pointModel = [[DrawPointModel alloc] initWithDrawModel:model];
    
    pointModel.x = location.x;
    
    pointModel.y = location.y;
    
    if (touch.phase == UITouchPhaseMoved) {
        
        pointModel.pointStatus = kDrawPointStatusMove;
        
    } else {
        
        pointModel.pointStatus = kDrawPointStatusEnd;
    }
    
    DrawPointModel *lastPointModel = model.pointsArray.lastObject;
    
    [model.pointsArray addObject:pointModel];

    if (model.penType == kDrawPenTypeCurve || model.isEraser) {
        
        [self renderLineFromPoint:CGPointMake(lastPointModel.x, lastPointModel.y) toPoint:CGPointMake(pointModel.x, pointModel.y)];
        
    }else{
        
        [self showLines];
    }
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesMoved:touches withEvent:event];
    
    if (self.isDrawing == NO) return;
    
    WS(weakSelf)
    
    _showTimer = [NSTimer homedScheduledTimerWithTimeInterval:0.5 repeats:NO block:^(NSTimer *timer) {
        
        weakSelf.isDrawing = NO;
    }];
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	// If appropriate, add code necessary to save the state of the application.
	// This application is not saving state.
    NSLog(@"cancell");
}
#pragma mark -
- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
#pragma clang diagnostic pop

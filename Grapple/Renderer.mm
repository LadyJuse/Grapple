//
//  Renderer.m
//  Grapple
//
//  Created by Colt King on 2018-02-23.
//  Copyright © 2018 Penguin Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Renderer.h"
#import <GLKit/GLKit.h>
#include "GLESRenderer.hpp"

enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_PASSTHROUGH,
    UNIFORM_SHADEINFRAG,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

float cameraDistance = 5.0f;
float fov = 80.0f;
float frontClip = 1.0f;
float backClip = 20.0f;

@interface Renderer ()
{
    GLKView* myView;
    GLuint programObject;
    GLESRenderer gles;
    
    //Product of the model, view, and projection matrices
    GLKMatrix4 vp;
    GLKMatrix3 normalMatrix;
    
    float *vertices, *normals, *texCoords;
    int *indices, numIndices;
}

@end

@implementation Renderer

- (void)setup:(GLKView*)view
{
    //Give the view a OpenGL 3.0 context
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if(!view.context)
    {
        //Perhaps check for 2.0 later
        NSLog(@"Failed to create the context");
    }
    
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    //Store the view and link its context to OpenGL
    myView = view;
    [EAGLContext setCurrentContext:view.context];
    
    //Setup the shaders
    if(![self setupShaders])
    {
        NSLog(@"Failed to setup shaders");
        return;
    }
    
    //Makes the default background color red
    glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
    
    //Enables the depth test
    glEnable(GL_DEPTH_TEST);
    
    //Perspective Transformations
    vp = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -cameraDistance);
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(vp), NULL);
}

- (void)update
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //Get the apect ratio of the window
    float aspect = (float)myView.drawableWidth / (float)myView.drawableHeight;
    GLKMatrix4 perspective = GLKMatrix4MakePerspective(fov * M_PI /180.0f, aspect, frontClip, backClip);
    
    vp = GLKMatrix4Multiply(perspective, vp);
}

- (void)render:(Model*)m
{
    //Multiply model matrix with view perspective matrix
    GLKMatrix4 mvp = GLKMatrix4Multiply(vp, m.mMatrix);
    
    //Updates the uniform values based on the matrices
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, FALSE, (const float*)mvp.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    glUniform1i(uniforms[UNIFORM_PASSTHROUGH], false);
    glUniform1i(uniforms[UNIFORM_SHADEINFRAG], true);
    
    //Sets the boundaries of the viewport
    glViewport(0, 0, (int)myView.drawableWidth, (int)myView.drawableHeight);

    //Gives OpenGL the program object
    glUseProgram(programObject);
    
    float *vertices, *texCoords, *normals;
    int *indices;
    int numIndices;
    
    //Get the info from the obj file
    numIndices = [self readModel:m vert:&vertices tex:&texCoords norm:&normals ind:&indices];
    
    //Attribute 0: Vertices
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), vertices);
    glEnableVertexAttribArray(0); //Enable array
    
    //Attribute 1: Colour?
    glVertexAttrib4f(1, 1.0f, 0.0f, 0.0f, 1.0f);
    
    //Attribute 2: Normals
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 3*sizeof(GLfloat), normals);
    glEnableVertexAttribArray(2); //Enable array
    
    //Draw the indices and fill the triangles between them
    glDrawElements(GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, indices);
}

- (int)readModel:(Model*)m vert:(float**)vertices tex:(float**)texCoords norm:(float**)normals ind:(int**)indices
{
    return 1;
}

- (bool)setupShaders
{
    // Load shaders
    char *vShaderStr = gles.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"Shader.vsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"Shader.vsh"] pathExtension]] cStringUsingEncoding:1]);
    char *fShaderStr = gles.LoadShaderFile([[[NSBundle mainBundle] pathForResource:[[NSString stringWithUTF8String:"Shader.fsh"] stringByDeletingPathExtension] ofType:[[NSString stringWithUTF8String:"Shader.fsh"] pathExtension]] cStringUsingEncoding:1]);
    programObject = gles.LoadProgram(vShaderStr, fShaderStr);
    if (programObject == 0)
        return false;
    
    // Set up uniform variables
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(programObject, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(programObject, "normalMatrix");
    uniforms[UNIFORM_PASSTHROUGH] = glGetUniformLocation(programObject, "passThrough");
    uniforms[UNIFORM_SHADEINFRAG] = glGetUniformLocation(programObject, "shadeInFrag");
    
    return true;
}



@end

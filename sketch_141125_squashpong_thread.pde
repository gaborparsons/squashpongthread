int config = 1; // 0 for racked moved by mouse / 1 for racked moved by pingpong racket

//New
ArrayList<MyBall> ballList = new ArrayList<MyBall>();

PFont myFont;
// Image
PImage parquet;

//Sound
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer player1;
AudioPlayer player2;

//Video

import processing.video.*;

Capture video;
color trackColor; 

float gravity = 0.50; //0.50
float deceleration = 0.995; //0.995
float rebond = 1; //1

int rebondLift = 27;
int rebondSlice = 20;
int rebondLiftHaut = -17;
int rebondSliceHaut = -10;

// XY coordinate of closest color
int closestX = 0;
int closestY = 0;

float d, dc; 
int i = 0, k = 0, avant = 0, apres = 0, bool = 0, missed = 0;

// end of variables

void setup() {

  myFont = loadFont("AGaramondPro-Italic-48.vlw");
  parquet = loadImage("parquet.png");
  //Video
  size (960, 720, P3D);
  video = new Capture(this, width, height, 15);
  //          video.start();
  trackColor = color(201, 28, 75);

  //Sound
  minim = new Minim(this);
  player1 = minim.loadFile("lift.mp3", 1024);
  player2 = minim.loadFile("slice.mp3", 1024);
 
  //NEW
  ballList.add(new MyBall(120, 140, 1, 3, 19, 2, 3, 26));
  
  smooth();
}

void draw() {
    fill(0);
    background(parquet);

    // Video capture was here
    // Call the thread instead
    if(config == 1){
      thread("checkPixels");
    }

    // box setup

    // background square
    lights();

    stroke(191, 87, 52);
    strokeWeight(6);

    line(0, 0, -700, width, 0, -700);
    line(0, height*3/4, -700, width, height*3/4, -700);
    line(0, height, -700, width, height, -700);
    stroke(150);
    strokeWeight(1);
    line(0, 0, -700, 0, height, -700);
    line(width, height, -700, width, 0, -700);

    // perspective lines
    stroke(191, 87, 52);
    strokeWeight(6);
    line(0, 0, -700, 0, 0, 0);
    line(width, 0, -700, width, 0, 0);
    stroke(150);
    strokeWeight(1);
    line(0, height, -700, 0, height, 0);
    line(width, height, -700, width, height, 0);

    fill(204);
    // racket setup
    stroke(150);
    strokeWeight(5);
    
    fill(100, 50);
    if (config ==1) {
      ellipse(width-closestX, closestY, 220, 220);
    }
    else {
      ellipse(mouseX, mouseY, 220, 220);
    }
    noFill();
    
    //NEW
    for(MyBall b : ballList){ //for every MyCircle object, loop in here - we use an interator instead of an int
      b.draw(); //we call draw for each object
    }

}

public class MyBall {
  float xPos;
  float yPos;
  float zPos;
  
  float ySpeedInt;
  float zSpeedInt;
  
  float xSpeed;
  float ySpeed;
  float zSpeed;

  public MyBall(float _xPos, float _yPos, float _zPos, float _ySpeedInt, float _zSpeedInt, float _xSpeed, float _ySpeed, float _zSpeed){ //constructor
    xPos = _xPos;
    yPos = _yPos;
    zPos = _zPos;
    ySpeedInt = _ySpeedInt;
    zSpeedInt = _zSpeedInt;
    xSpeed = _xSpeed;
    ySpeed = _ySpeed;
    zSpeed = _zSpeed;
  }
  public void draw(){//this behavior will do the things we were doing in draw before - void tells us what the behavior is
  
  //If you miss the ball
  if (missed == 1) {
    k=k+1;
    println("Missed Shot");
    fill(255, 30);
    rect(0, 0, 960, 720);
    fill(191, 87, 52);
    textFont(myFont, 38);
    text("Missed Shot", 400, 380);
    xPos=120;
    yPos=140;
    zPos=1;
    ySpeed = ySpeedInt;
    zSpeed = zSpeedInt;
    if (k==70) {
      missed = 0;
      k=0;
    }
  }
  //If the ball is still in game, do all the following
  else {
  // inital ball set up

  // stroke(245,255,100);
    stroke(0);
    strokeWeight(1);
    pushMatrix();
    translate (xPos, yPos, -zPos);
    fill(0);
    sphere(21);
    noFill();
    popMatrix();

    zSpeed = zSpeed*deceleration;
    ySpeed = ySpeed+gravity;
    if (zSpeed >=0) {
      rebond = 1-zSpeed*2/100;
    }
    else {
      rebond = 1+zSpeed*2/100;
    }

    // motion setup
    xPos = xPos + xSpeed; 
    yPos = yPos + ySpeed;
    zPos = zPos + zSpeed;

    if (xPos>width-50) {
      xSpeed=-xSpeed;
      xPos=width-50;
    }
    if (yPos>height-50) {
      ySpeed=-ySpeed*rebond;
      yPos=height-50;
    }
    if (yPos>height-50 && yPos>height*2/3) {
    }
    if (zPos>500) {
      zSpeed=-zSpeed*rebond;
      zPos=500;
    }
    if (xPos<50) {
      xSpeed=-xSpeed;
      xPos = 50;
    }
    if (yPos<50) {
      ySpeed=-ySpeed*rebond;
      yPos = 50;
    }
    if (config ==1) {
      d = dist(xPos, yPos, width-closestX, closestY);
    }
    else {
      d = dist(xPos, yPos, mouseX, mouseY);
    }

    if (zPos<0) {   
      if (d<=170) { 
        zSpeed = -zSpeed;
        if (config ==1) {
          avant = closestY;
        }
        else {
          avant = mouseY;
        }
        bool = 1;
      }
      else {
        missed = 1;
      }
    } 
    if (bool==1) {
      i=i+1;
    }
    if (i==6) {
      if (config ==1) {
        apres = closestY;
      }
      else {
        apres = mouseY;
      }
      bool=0;
      i=0;
      //Slice
      if (apres >= avant) {
        ySpeed = rebondSliceHaut;
        zSpeed = rebondSlice; 
        player2.play(0);
      }
      //Lift
      if (apres < avant) {
        ySpeed = rebondLiftHaut;
        zSpeed = rebondLift; 
        player1.play(0);
      }
    }//End of i=6 loop

    int apav = apres-avant;  
//    println("Rebond = " + rebond + " / zSpeed = " + zSpeed + " / zPos = " + zPos);
  }//end of else loop  
    
  }
}

//This is the thread for the pixels in the video
void checkPixels(){
  
  if (video.available()) {
      video.read();
      video.loadPixels();
      //image(video,0,0);

      // Before we begin searching, the "high number" for closest color is set to a high number that is easy for the first pixel to beat.
      float highNumber = 500; 
      
      // Begin loop to walk through every pixel
      for (int x = 0; x < video.width; x ++ ) {
        for (int y = 0; y < video.height; y ++ ) {
          int loc = x + y*video.width;
          // What is current color
          color currentColor = video.pixels[loc];
          float r1 = red(currentColor);
          float g1 = green(currentColor);
          float b1 = blue(currentColor);
          float r2 = red(trackColor);
          float g2 = green(trackColor);
          float b2 = blue(trackColor);

          // Using euclidean distance to compare colors
          dc = dist(r1, g1, b1, r2, g2, b2); // We are using the dist( ) function to compare the current color with the color we are tracking.

          // If current color is more similar to tracked color than
          // closest color, save current location and current difference
          if (dc < highNumber) {
            highNumber = dc;
            closestX = x;
            closestY = y;
          }
        }
      }
    }
}


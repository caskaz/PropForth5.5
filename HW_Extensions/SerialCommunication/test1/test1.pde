import processing.serial.*;

Serial Port;
int x;

void setup(){
  size(256,256);
  background(255);
  Port = new Serial(this, "COM12", 9600);
  frameRate(1);
}

void draw(){
  ellipse(x,100,50,50);  
}

void serialEvent(Serial p) {
  x=Port.read();
  println(x);
}


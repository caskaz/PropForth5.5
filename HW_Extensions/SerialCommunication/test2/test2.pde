import processing.serial.*;

Serial Port;
int x;

void setup(){
  size(256,256);
  
  Port = new Serial(this, "COM5", 9600);
  frameRate(1);
}

void draw(){
  background(255);
  ellipse(x,100,50,50);  
}

void serialEvent(Serial p) {
  x=Port.read();
  println(x);
}

void mousePressed() {
  Port.clear();
  Port.write(65);
}


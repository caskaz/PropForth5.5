import processing.serial.*;

Serial Port;
int x;
int anykey=0;

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
  println(anykey);
  if (anykey == 255) {
    Port.write(66);
  }
}

void mousePressed() {
  Port.clear();
  Port.write(65);
}

void keyPressed() {
   anykey = 255;
}


import processing.serial.*;

Serial Port;
int x,sign, num;
int anykey=0;

void setup(){
  size(256,256);
  
  Port = new Serial(this, "COM5", 9600);
  textSize(40);
}

void draw(){
  background(0);
  num=x;
  if (sign == 1) {
      num=-x;
  }  
  text(num,0 ,50);
  if (anykey == 255) {
    Port.write(66);
    exit();
  }
}

void serialEvent(Serial p) {
  if(Port.available()> 1) {    
  sign=Port.read();
  x=Port.read();
  }
//  println(x);
//  println(sighn);
}

void mousePressed() {
  Port.clear();
  Port.write(65);
}

void keyPressed() {
   anykey = 255;
}


import processing.serial.*;

Serial Port;

int a,b,c,value,min,max,d,e,distance;
int num = 220;
int[] ele = new int[num]; 
int anykey = 0;
int x0 = 80;
int y0 = 50;

void ver_axis() {
  stroke(255);
  line(x0,y0,x0,250);
  // title
  textSize(15);
  text("Intensity",0,30);
  // intensity
  textSize(20);
  text(max,0,60);
  text(min,0,250);
}

void hor_axis() {
  stroke(255);
  line(x0,250,300,250);
  // title
  textSize(15);
  text("element",160,280);
  // element number
  textSize(20);
  text(1,x0,270);
  text(220,270,270);
}
  
void message() {
  textSize(15);
  text("DISTANCE[mm]=",120,25);
}

void sort(int data) {
  if (max < data) {
    max = data;
  } else if (min > data) {
    min = data;
  }
}

int calc(int data) {
  int d;
  if (data > 0) {    
    d = 200 * data/(max - min);
  } else {
    d = 0;
  }
  return(d);  
}

void setup(){
  size(350,300);
  Port = new Serial(this, "COM5", 9600);
  min = 0;
  max = 0;
  frameRate(1);
}

void draw(){
  background(0);
  fill(255);
  ver_axis();
  hor_axis();
  message();
  
  for (int i=0; i<num; i++) {
    if (i == 0) {
      max = ele[0];
      min = ele[0];
    }      
    sort(ele[i]);    
  }
  stroke(255,0,0);
  strokeWeight(3);
  for (int i=0; i<num; i++) {
    point(i+x0,250-map(calc(ele[i]),0,200,0,200));
  }
  stroke(255,255,255);
  strokeWeight(1);
  
  textSize(15);
  text(distance,250,25);
}

void serialEvent(Serial p) {
//  if(Port.available()> num*3-1) {
  if(Port.available()> num*3+1) {  
    for (int i=0; i<num; i++) {
      a = Port.read();
      b = Port.read();
      c = Port.read();
      value = a + (b<<8) + (c<<16);
//      println(value);      
      ele[i] = (c<<16) + (b<<8) + a;
    }
    d = Port.read();
    e = Port.read();
//    println(d,e);
    distance = d + (e<<8);
  }
  if (Port.available() == 0) {
    Port.write(65);
  }
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


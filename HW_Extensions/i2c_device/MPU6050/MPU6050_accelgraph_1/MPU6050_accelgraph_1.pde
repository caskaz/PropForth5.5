import processing.serial.*;
Serial Port;

Graph graph;

int t=0;
int s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11;
int accl_x,accl_y,accl_z;
int anykey=0;

void screen() {
  background(255);
  strokeWeight( 0 );
  line(0,250,1200,250);
}

void setup(){
  size(1200,500);
  screen();
  Port = new Serial(this, "COM5", 9600);
  graph=new Graph();
//  frameRate(10);
}


void draw(){
  strokeWeight( 2 );
  graph.update_x();
  graph.update_y();
  graph.update_z();
  
  t = (t+1) % width;
  if (t == 0) {
      screen();
  }
  if (anykey == 255) {
    Port.write(66);
    exit();

  }
//  println(t);
}




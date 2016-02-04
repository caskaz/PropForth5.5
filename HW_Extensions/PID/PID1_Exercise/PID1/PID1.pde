import processing.serial.*;
Serial Port;

int t=0;
int s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14;
int[] data;
int setpoint,Kp,Ki,Kd,input,output,auto;
int anykey=0;
int maxSP=2500;

void ver_axis() {
  stroke(0);
  line(50,50,50,550);
  // title
  textSize(15);
  fill(0);
  text("Rotation",5,30);
  // Rotation
  textSize(15);
  text(maxSP,5,50);
  text(setpoint,5,550-int(setpoint*500/maxSP));
  text("0",30,550);
}

void hor_axis() {
  stroke(0);
  line(50,550,700,550);
}

void valueTitle() {
  stroke(0);
  textSize(15);
  fill(0);
  text("Setpoint:",80,30);
  text("Kp:",200,30);
  text("Ki:",260,30);
  text("Kd:",320,30);
  text("Actual:",380,30);
  text("Output:",500,30);
  
  textSize(15);
  text(setpoint,145,30);
  text(Kp,225,30);
  text(Ki,280,30);
  text(Kd,345,30);
  text(input,430,30);
  text(output,560,30);
  if (auto == 1) {
    text("PID-ON",80,50); 
  } else {
    text("PID-OFF",80,50); 
  }
    
}

void setup(){
  size(700,600);
  data= new int[width];
  background(255);
  Port = new Serial(this, "COM5", 9600);
  // 20 for 1second
  frameRate(20);
  // 50 for 1second
//  frameRate(50);
}

void draw(){
  background(255);
  valueTitle();
  strokeWeight( 2 );
  ver_axis();
  hor_axis();
  
  for (int i=1; i<width-50; i++){
    data[i-1]=data[i];
  }
  data[width-51]=input;
  for(int i=1; i<width-50; i++){
    stroke(255,0,0);
    point(i+50,550-int(data[i]*500/maxSP));
  }
  
  if (anykey == 255) {
    Port.write(66);
    exit();

  }
//  println(t);
}


void serialEvent(Serial p) {
  if(Port.available()> 14) {
    s0=Port.read();
    s1=Port.read();
    s2=Port.read();
    s3=Port.read();
    s4=Port.read();
    s5=Port.read();
    s6=Port.read();
    s7=Port.read();
    s8=Port.read();
    s9=Port.read();
    s10=Port.read();
    s11=Port.read();
    s12=Port.read();
    s13=Port.read();
    s14=Port.read();
    setpoint=(s1<<8)+s0;
    Kp=(s3<<8)+s2;
    Ki=(s5<<8)+s4;
    Kd=(s7<<8)+s6;
    input=(s9<<8)+s8;
    output=(s13<<24)+(s12<<16)+(s11<<8)+s10;
    auto=s14;
    println(input);
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


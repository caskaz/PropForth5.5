void serialEvent(Serial p) {
  if(Port.available()> 11) {
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
    accl_z=(s3<<24)+(s2<<16)+(s1<<8)+s0;
    accl_y=(s7<<24)+(s6<<16)+(s5<<8)+s4;
    accl_x=(s11<<24)+(s10<<16)+(s9<<8)+s8;
    println(accl_x+" "+accl_y+" "+accl_z);
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


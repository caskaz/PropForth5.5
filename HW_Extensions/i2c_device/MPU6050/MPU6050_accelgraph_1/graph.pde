class Graph {
  Graph() {
  }
  void update_x() {
    stroke(255,0,0);
    point(t,250-int(float(accl_x*250/20000)));
  }
  void update_y() {
    stroke(0,255,0);
    point(t,250-int(float(accl_y*250/20000)));
  }
  void update_z() {
    stroke(0,0,255);
    point(t,250-int(float(accl_z*250/20000)));
  }
}

import processing.serial.*;

Serial myPort;
String filename = "photo.jpg";
byte count = 0;
byte[] photo = {
};
Boolean readData = false;
PImage captureImage;

void setup()
{
  size(640,480);
  println( Serial.list() );
  myPort = new Serial( this, "COM12", 38400 );
}

void draw()
{
  byte[] buffer = new byte[4096];
  if( readData )
  {
    while( myPort.available() > 0 )
    {
      int readBytes = myPort.readBytes( buffer );
      print( "Read " );
      print( readBytes );
      println( " bytes ..." );
      for( int i = 0; i < readBytes; i++ )
      {
        photo = append( photo, buffer[i] );
      }
    }
  }
  else
  {
    while( myPort.available() > 0 )
    {
      print( "COM Data: " );
      println( myPort.readString() );
    }
  }
}

void keyPressed()
{
  if( photo.length > 0 ) {
    readData = false;
    print( "Writing to disk " );
    print( photo.length );
    println( " bytes ..." );
    filename = "photo" + count + ".jpg";
    saveBytes( filename, photo );
    println( "DONE!" );
    photo = new byte[0];
    captureImage = loadImage(filename);
    image(captureImage, 0, 0);
    count++;
  }
  else {
    readData = true;
    myPort.write(65);
    println( "Waiting for data ..." );
  }
}

void mousePressed() {
  myPort.clear();
  myPort.write(66);
}


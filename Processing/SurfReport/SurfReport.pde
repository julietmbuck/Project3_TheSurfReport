

/*
The Surf Report
by Juliet Buck

  Expects a string of comma-delimted Serial data from Arduino:
  ** field is 0 or 1 as a string (switch)
  ** second field is 0-4095 (potentiometer)
  ** third field is 0-4095 (LDR) 
  
*/

//*****************************************sound file
import processing.sound.*;
SoundFile sound;

// Importing the serial library to communicate with the Arduino 
import processing.serial.*;    

// Initializing a vairable named 'myPort' for serial communication
Serial myPort;      

// Data coming in from the data fields
// data[0] = "1" or "0"                  -- BUTTON
// data[1] = 0-4095, e.g "2049"          -- POT VALUE
String [] data;

//data coming in from the data fields
int switchValue = 0; //index from data fields
int ldrValue = 0;
int potValue = 0; 
int minLDRValue = 400; 
int maxLDRValue = 1700; 


// Change to appropriate index in the serial list — YOURS MIGHT BE DIFFERENT
int serialIndex = 2;

// potentiometer values

int minPotValue = 0;
int maxPotValue = 4095;    // will be 1023 on other systems
int volumeMax = 1;
int volumeMin = 0;


//initialize arrays for forecast
String[] surfHeight = {"3-4", "2-3", "4-5"};
String[] tide = {"4.3", "2.6"};
String[] wind = {"5", "4", "3", "8"};
String[] swells = {"1.1ft at 15s", "2.3ft at 11s", "3ft at 7s", "0.9ft at 14s"};
String[] waterTemp = {"65-68ºf", "62-65ºf"};
String[] weather = {"67ºf", "66ºf", "70ºf"};

////initialize states as false
boolean forecast = false; 
boolean stateSurfSpots = false; 
boolean statePipesForecast = false;
boolean stateSwamisForecast = false;
boolean stateGeorgesForecast = false;
boolean stateGrandviewForecast = false;
boolean stateCardiffForecast = false;
boolean stateBlacksForecast = false;
boolean stateNoWaves = false; 
boolean stateItsRip = false; 


//initialize button pressed states
boolean buttonPressed = false; 
boolean buttonReleased = false; 

//initialize cam gifs
AnimatedPNG pipes; 
AnimatedPNG blacks; 
AnimatedPNG cardiff; 
AnimatedPNG georges; 
AnimatedPNG swamis; 
AnimatedPNG grandview; 

//initialize good or bad gifs
AnimatedPNG noWaves; 
AnimatedPNG itsRip;

//timer
int frameNum;    // we use this for determining when to release a projectile
int frameTimeMS = 300;

//initialize images 
PImage titleScreen;
PImage forecastHighTide; 
PImage forecastLowTide; 
PImage surfSpots; 
PFont BentonSans; 

//forecast X + Y 
int forecastTopY = 580; 
int forecastBottomY =740; 
int surfHeightX = 100; 
int swellsX = 140; 
int tideX = 405; 
int waterTempX = 425;
int windX= 755;
int weatherX= 755;



void setup() {
  size(1000, 800); 
  
  BentonSans = loadFont("data/BentonSansComp-Light-48.vlw");
  textFont(BentonSans); 
  
  // List all the available serial ports
  printArray(Serial.list());
  
  // Set the com port and the baud rate according to the Arduino IDE
  myPort  =  new Serial (this, "/dev/cu.SLAB_USBtoUART",  115200); 
  
  //attribute variables to images
  titleScreen = loadImage("img/thesurfreport.png");
  forecastHighTide = loadImage("img/forecast_hightide.png"); 
  forecastLowTide = loadImage("img/forecast_lowtide.png"); 
  surfSpots = loadImage("img/surfspots.png");
  
  //load animated PNG files
  pipes = new AnimatedPNG(); 
  blacks = new AnimatedPNG(); 
  cardiff = new AnimatedPNG(); 
  georges = new AnimatedPNG(); 
  swamis = new AnimatedPNG(); 
  grandview = new AnimatedPNG(); 
  noWaves = new AnimatedPNG(); 
  itsRip  = new AnimatedPNG(); 
  
  //animations
  pipes.load("surfcams/pipes", frameTimeMS); 
  blacks.load("surfcams/blacks", frameTimeMS);
  cardiff.load("surfcams/cardiff", frameTimeMS);
  georges.load("surfcams/georges", frameTimeMS);
  swamis.load("surfcams/swamis", frameTimeMS);
  grandview.load("surfcams/grandview", frameTimeMS);
  noWaves.load("img/nowaves", frameTimeMS);
  itsRip.load("img/itsrip", frameTimeMS);
  
 //************************************ Load a soundfile from the /data folder of the sketch and play it back
  
  sound = new SoundFile(this, "walkdontrun.mp3");
  sound.play();
  

  
}

void drawSong() {

 float amp  = map(potValue, minPotValue, maxPotValue, volumeMin, volumeMax);
 sound.amp(amp);
 
  
}


// We call this to get the data 
void checkSerial() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();  
    
    print(inBuffer);
    
    // This removes the end-of-line from the string 
    inBuffer = (trim(inBuffer));
    
    // This function will make an array of TWO items, 1st item = switch value, 2nd item = potValue
    data = split(inBuffer, ',');
   
   // we have TWO items — ERROR-CHECK HERE
   if( data.length >= 2 ) {
      switchValue = int(data[0]);           // first index = switch value 
      potValue = int(data[1]);               // second index = pot value
   }
  }
} 

void draw() {
    background(255); 
    checkSerial();
    theSurfReport(); 
    buttonMechanics();
    keyIsPressed();
    states();


}

//states function
void states() {
  
  if (stateItsRip == true) {
    itsRipping(); 
  }
  
  if (stateNoWaves == true) {
    noWavesToday(); 
}

 if (stateGeorgesForecast == true && forecast==true) {
   forecastHighTide();
   georgesForecast(); 
   
 }
 
 if (stateGrandviewForecast == true && forecast==true) {
   forecastLowTide();
   grandviewForecast(); 
   
 }
 
 if (statePipesForecast == true && forecast==true) {
   forecastLowTide();
   pipesForecast(); 
 }
 
  if (stateSwamisForecast == true &&   forecast==true) {
    forecastHighTide();
    swamisForecast();
  
 }
 
  if (stateBlacksForecast == true &&   forecast==true) {
    forecastHighTide();
     blacksForecast(); 
 }
 
   if (stateCardiffForecast == true && forecast==true) {
     forecastLowTide();
     cardiffForecast(); 
 }
 
 
}



void swamisForecast() {
    textSize(45); 
    fill(255); 
    text((surfHeight[0]) + "ft", surfHeightX, forecastTopY);
    text((tide[0]) + "ft", tideX, forecastTopY); 
    text((wind[2]) + "kts", windX, forecastTopY); 
    text((swells[1]), swellsX, forecastBottomY); 
    text((waterTemp[0]), waterTempX, forecastBottomY); 
    text((weather[2]), weatherX, forecastBottomY); 
    
    swamis.draw(46, 155); 
    
  
}

void georgesForecast() {
    text((surfHeight[2]) + "ft", surfHeightX, forecastTopY);
    text((tide[0]) + "ft", tideX, forecastTopY); 
    text((wind[1]) + "kts", windX, forecastTopY); 
    text((swells[2]), swellsX, forecastBottomY); 
    text((waterTemp[1]), waterTempX, forecastBottomY); 
    text((weather[2]), weatherX, forecastBottomY); 
    
    georges.draw(46, 155); 
}

void cardiffForecast() {
    text((surfHeight[0]) + "ft", surfHeightX, forecastTopY);
    text((tide[1]) + "ft", tideX, forecastTopY); 
    text((wind[0]) + "kts", windX, forecastTopY); 
    text((swells[1]), swellsX, forecastBottomY); 
    text((waterTemp[1]), waterTempX, forecastBottomY); 
    text((weather[0]), weatherX, forecastBottomY); 
    
     cardiff.draw(46, 155); 
}


 
void blacksForecast() {
    text((surfHeight[1]) + "ft", surfHeightX, forecastTopY);
    text((tide[0]) + "ft", tideX, forecastTopY); 
    text((wind[3]) + "kts", windX, forecastTopY); 
    text((swells[2]), swellsX, forecastBottomY); 
    text((waterTemp[2]), waterTempX, forecastBottomY); 
    text((weather[0]), weatherX, forecastBottomY); 
    
    blacks.draw(46, 155); 
}

void pipesForecast() {
    text((surfHeight[0]) + "ft", surfHeightX, forecastTopY);
    text((tide[0]) + "ft", tideX, forecastTopY); 
    text((wind[2]) + "kts", windX, forecastTopY); 
    text((swells[1]), swellsX, forecastBottomY); 
    text((waterTemp[0]), waterTempX, forecastBottomY); 
    text((weather[2]), weatherX, forecastBottomY); 
    
    pipes.draw(46, 155); 
    

   
}

void grandviewForecast() {
      text((surfHeight[1]) + "ft", surfHeightX, forecastTopY);
    text((tide[1]) + "ft", tideX, forecastTopY); 
    text((wind[0]) + "kts", windX, forecastTopY); 
    text((swells[3]), swellsX, forecastBottomY); 
    text((waterTemp[0]), waterTempX, forecastBottomY); 
    text((weather[2]), weatherX, forecastBottomY); 
    
    grandview.draw(46, 155); 
}


//start app 
void buttonMechanics() {
    if (switchValue == 1) {
      buttonPressed = true; 
    }
    
    if (buttonPressed==true) {
      surfSpots(); 
      surfSpotsText(); 
    }
}

void noWavesToday() {
  background(40); 
  noWaves.draw(40,20);   
  textSize(25); 
  fill(255); 
  textAlign(CENTER, CENTER); 
  text("CLICK TO SEE THE FORECAST", width/2, 700);
  



}

void itsRipping() {
  background(255); 
  itsRip.draw(40,20); 
  textSize(25); 
  fill(0); 
  textAlign(CENTER, CENTER); 
  text("CLICK TO SEE THE FORECAST", width/2, 700); 
  
}

void theSurfReport() {
image(titleScreen, 0, 0); 
}

void forecastHighTide() {
  image(forecastHighTide, 0, 0); 
}


void forecastLowTide() {
  image(forecastLowTide, 0, 0); 
}

void surfSpots() {
  image(surfSpots, 0, 0); 
}


void surfSpotsText() {
  textSize(20); 
  text("Press 'S' to Check", 155, 380);
  text("Press 'P' to Check", 155, 520);
  text("Press 'G' to Check", 155, 670);
  text("Press 'R' to Check", 618, 380);
  text("Press 'C' to Check", 618, 520);
  text("Press 'B' to Check", 618, 670); 
  
}

void mousePressed() {
  forecast=true; 
}

void keyIsPressed() {
  
  if (keyPressed) {
    if (key == 's' || key == 'S') {
      stateItsRip = true; 
      stateSwamisForecast = true;
    }
  }
  
   if (keyPressed) {
    if (key == 'p' || key == 'P') {
      stateNoWaves = true; 
      statePipesForecast = true;
    }
  }
  
     if (keyPressed) {
    if (key == 'g' || key == 'G') {
      stateItsRip = true; 
      stateGeorgesForecast = true;
    }
  }
  
     if (keyPressed) {
    if (key == 'r' || key == 'R') {
      stateNoWaves = true; 
      stateGrandviewForecast = true;
    }
  }
  
       if (keyPressed) {
    if (key == 'c' || key == 'C') {
      stateItsRip = true; 
      stateCardiffForecast = true;
    }
  }
  
       if (keyPressed) {
    if (key == 'b' || key == 'B') {
      stateNoWaves = true; 
      stateBlacksForecast = true;
    }
  }
  
}

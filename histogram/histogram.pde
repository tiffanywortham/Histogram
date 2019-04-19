/* This program calculates red, green, and blue histograms
   and graphs them.
*/
//Define arrays for red, green, and blue counts
int[] rCounts = new int[256];  //bins for red histogram
int[] gCounts = new int[256];  //bins for green histogram
int[] bCounts = new int[256];  //bins for blue histogram
int posR = 10, posG = 275, posB = 541;
int textX = 50, textY = 75;  //Position for hist value display
String fname = "washedout.jpg";
PFont f;
PImage img, stretchImg, dimg, currentImg; //Original, brightened, darkened, current
boolean showHists = false;  //Display image by default
int startX, startY;


void setup() {
  size(400, 400);
  surface.setResizable(true);
  img = loadImage(fname);
  surface.setSize(img.width, img.height);
  stretchImg = stretchHist(img);
  currentImg = img;
  strokeWeight(1);  //Lines 1 pixel wide (this is the default)
  f = createFont("Arial", 48);
  textFont(f);  //Set f to be the current font
  stroke(255, 0, 0);
  rectMode(CORNERS);
  noFill();
}
void draw() {
  if (showHists) {
    int edge = 0;  //Reference point for start of histogram
    displayHists();
    fill(255, 255, 0);  //Text color
    if (mouseX > posR && mouseX < posR + rCounts.length) {
      edge = posR;  //index relative to red hist
    } else if (mouseX > posG && mouseX < posG + gCounts.length) {
      edge = posG;  //index relative to green hist
    } else if (mouseX > posB && mouseX < posB + bCounts.length) {
      edge = posB;  //index relative to blue hist
    }
    if (edge > 0) {  //If edge is 0, mouse is not above any hist
      int i = mouseX - edge;
      String s = str(i) + ":  " + str(rCounts[mouseX - edge]);
      text(s, textX, textY);
    }
  } else {
    image(currentImg, 0, 0);
    if (mousePressed) rect(startX, startY, mouseX, mouseY);
  }
}
void calcHists(PImage img) {
  //Calculate red, green, & blue histograms
  //First initialize rCounts, gCounts, and bCounts to all 0
  for (int i = 0; i < rCounts.length; i++) {
    rCounts[i] = 0; gCounts[i] = 0; bCounts[i] = 0;
  }
    /*For each pixel, get the red, green, and blue values as ints.
    Increment the counts for the red, green, and blue values.
    For example, if the red value is 25, the green value is 110,
    and the blue value is 42, increment rCounts[25], gCounts[110],
    and bCounts[42].
  */
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      color c = img.get(x, y);
      int r = int(red(c)), g = int(green(c)), b = int(blue(c));
      rCounts[r] += 1;
      gCounts[g] += 1;
      bCounts[b] += 1;
    }
  }
}
void displayHists() {
  background(0);  //Clear the screen and set to black
  //Put code here to draw histograms
  //First, find max value for scaling; assumes hists are not empty
  int maxval = 0;
  for (int i = 0; i < rCounts.length; i++) {
    if (rCounts[i] > maxval) maxval = rCounts[i];
    if (gCounts[i] > maxval) maxval = gCounts[i];
    if (bCounts[i] > maxval) maxval = bCounts[i];
  }
  //Draw all hists in one loop; this works because all are the same len
  //Use map() to scale line values; scale to height/2
  for (int i = 0; i < rCounts.length; i++) {
    stroke(255, 0, 0);  //Red lines for red hist
    int val = int(map(rCounts[i], 0, maxval, 0, height/2));
    line(i + posR, height, i + posR, height - val);
    stroke(0, 255, 0);  //Green lines for green hist
    val = int(map(gCounts[i], 0, maxval, 0, height/2));
    line(i + posG, height, i + posG, height - val);
    stroke(0, 0, 255);  //Blue lines for blue hist
    val = int(map(bCounts[i], 0, maxval, 0, height/2));
    line(i + posB, height, i + posB, height - val);
  }
}
void printHists() {
  //Use a for (int i...) loop to println i, rCounts[i], gCounts[i], and bCounts[i]
  for (int i = 0; i < rCounts.length; i++) {
    println(i, rCounts[i], gCounts[i], bCounts[i]);
  }
}

int calcMin(int[] counts){
  int min = 0;
  int i = 0;
  
  while (min == 0) {
    min = counts[i];
    i++;
  }
  return i;
}

int calcMax(int[] counts){
  int max = 0;
  int i = counts.length - 1;
  
  while (max == 0) {
    max = counts[i];
    i--;
  }
  return i;
}

PImage stretchHist(PImage img){
  
  PImage newImg = img.get();
  calcHists(newImg);
  
  float rMinval = calcMin(rCounts);
  float gMinval = calcMin(gCounts);
  float bMinval = calcMin(bCounts);
      
  float rMaxval = calcMax(rCounts);
  float gMaxval = calcMax(gCounts);
  float bMaxval = calcMax(bCounts);
  
   for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      color c = newImg.get(x, y);
      float r = red(c), g = green(c), b = blue(c);
      
      r = ((r - rMinval) / (rMaxval - rMinval)) * 255;
      g = ((g - gMinval) / (gMaxval - gMinval)) * 255;
      b = ((b - bMinval) / (bMaxval - bMinval)) * 255;
      //println("modified: ", r);  
      r = constrain(r, 0, 255);
      g = constrain(g, 0, 255);
      b = constrain(b, 0, 255);
          
      newImg.set(x, y, color(r, g, b));
    }
  }
  return newImg;
}

int[] calcPMF(int[] counts){
  
  int[] pmfCounts = new int[255]; 
  int totalPixels = currentImg.height * currentImg.width;
  for (int i = 0; i < pmfCounts.length; i++){
    int pmf = counts[i] / totalPixels;
    pmfCounts[i] = pmf;
  }
  return pmfCounts;
}

int[] calcCDF(int[] pmfCounts){
  
  int[] cdfCounts = new int[255]; 
  for (int i = 0; i < pmfCounts.length; i++){
    int cdf = pmfCounts[i] + pmfCounts[i + 1];
    cdfCounts[i] = cdf;
  }
  return cdfCounts;
}

/*PImage equalizeHist(PImage img){
  
} */

void mousePressed() {
  startX = mouseX;
  startY = mouseY;
  currentImg = img;
}
void mouseReleased() {
  int endX, endY;
  if (mouseX < startX) {
    endX = startX;
    startX = mouseX;
  } else {
    endX = mouseX;
  }
  if (mouseY < startY) {
    endY = startY;
    startY = mouseY;
  } else {
    endY = mouseY;
  }
  
  //grayImg = grayscale(img, startX, startY, endX, endY);
  //currentImg = grayImg;
}

void keyReleased() {
  if (key == '1') {
    currentImg = img;
    showHists = false;
    surface.setSize(currentImg.width, currentImg.height);
  } else if (key == '2') {
    currentImg = stretchImg;
    showHists = false;
    surface.setSize(currentImg.width, currentImg.height);
  } else if (key == '3') {
    currentImg = dimg;
    showHists = false;
    surface.setSize(currentImg.width, currentImg.height);
  } else if (key == 'h') {
    calcHists(img);
    showHists = true;
    surface.setSize(posB + bCounts.length, img.height);
  } else if (key == 's') {
    calcHists(stretchImg);
    showHists = true;
    surface.setSize(posB + bCounts.length, stretchImg.height);
  } else if (key == 'd') {
    calcHists(dimg);
    showHists = true;
    surface.setSize(posB + bCounts.length, dimg.height);
  }
}

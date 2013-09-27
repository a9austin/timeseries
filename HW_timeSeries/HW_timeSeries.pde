// full dataset
FloatTable data;
float dataMin, dataMax;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;
float barWidth = 4;

int rowCount;
int currentColumn = 0;
int columnCount;
int volumeInterval = 10;
int volumeIntervalMinor = 5;

int yearMin, yearMax;
int[] years;
int yearInterval = 10;

int pressed = 0;

PFont plotFontTitle;
PFont plotFontAxis;

float[] tabLeft, tabRight; 
float tabTop, tabBottom;
float tabPad = 10;

Integrator[] interpolators;

// setup loop (runs once)
void setup() {
  size(720, 405);
  //size(2000, 1000);
  // import data
  data = new FloatTable("milk-tea-coffee.tsv");
  columnCount = data.getColumnCount();
  rowCount = data.getRowCount();
  
  // Year info
  years = int(data.getRowNames());
  yearMin = years[0];
  yearMax = years[years.length - 1];

  // assign data variables
  dataMin = 0;
  dataMax = ceil(data.getTableMax() / volumeInterval) * volumeInterval;

  // Corners of the plotted time series
  plotX1 = 120;
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height - 25;

  //plotFont = createFont("SansSerif", 20);
  //plotFont = createFont("Georgia", 20);
  //textFont(plotFont);

  smooth();
  
  interpolators = new Integrator[rowCount];
  for (int row = 0; row < rowCount; row++){
    float initialValue = data.getFloat(row, 0);
    interpolators[row] = new Integrator(initialValue);
    interpolators[row].attraction = 0.1;
  }
}

void keyPressed() {
  if (key == '[') {
    currentColumn--;
    if (currentColumn < 0) {
      currentColumn = columnCount - 1;
    }
  } 
  else if (key == ']') {
    currentColumn++;
    if (currentColumn == columnCount) {
      currentColumn = 0;
    }
  }
  else if (key == '1'){
    pressed = 1;
  }
  else if (key == '2'){
    pressed = 2;
  }
  else if (key == '3'){
    pressed = 3;
  }
  else if (key == '4'){
    pressed = 4;
  }
}

void drawPointsEvent(){
    background(255);
    strokeWeight(5);
    drawDataPoints(currentColumn);
    
}


// draw loop (runs infinitely)
void draw() {
  // background color (light-grey)
  background(255);

  // show the plot area as a white box
  //fill(255);
  //rectMode(CORNERS);
  //noStroke();
  //rect(plotX1, plotY1, plotX2, plotY2);

  //strokeWeight(5);
  // Draw the data for the first column
  //stroke(#5679C2);
  //drawDataPoints(0);

  //drawDataPoints(currentColumn);
  //noFill();
  //drawDataLine(currentColumn);
  drawTitle();
  drawAxisLabels();
  drawVolumeLabels();
  
  //strokeWeight(5);
  //drawDataPoints(currentColumn);
  //stroke(#5679C1);
  
 // noStroke();
  //fill(#5679C1);
  //drawDataBars(currentColumn);
  //drawDataArea(currentColumn);
  
  drawYearLabels();
  drawTitleTabs();
  
  drawDataHighlight(currentColumn);
  
  // If 1 is pressed show dots
  if (pressed == 1)
  {  
    strokeWeight(5);
    // Draw the data for the first column
    stroke(#5679C2);
    drawDataPoints(currentColumn);
  }
  else if (pressed == 2){
    // Draws dots
    strokeWeight(5);
    // Draw the data for the first column
    stroke(#5679C2);
    drawDataPoints(currentColumn);
    
    // draws line
    noFill();
    strokeWeight(1);
    drawDataLine(currentColumn);
  }
  else if (pressed == 3){
    noFill();
    stroke(#5679C2);
    strokeWeight(7);
    drawDataLine(currentColumn);
  }
  else if (pressed == 4){
   fill(#5679C1);
  //drawDataBars(currentColumn);
   drawDataArea(currentColumn);
  }
  else{
    strokeWeight(5);
    // Draw the data for the first column
    stroke(#5679C2);
    drawDataPoints(currentColumn);
  }
  
  for (int row = 0; row < rowCount; row++){
    interpolators[row].update();
  }
  
}

void drawAxisLabels() {
  fill(0);
  textSize(10); // Personal Change
  textLeading(15);
  textAlign(CENTER, CENTER);
  // Use \n (aka enter or linefeed) to break the text into separate lines
  textAlign(CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);
  plotFontAxis = createFont("Georgia", 10);
  textFont(plotFontAxis);
  
  //rotate((PI/2));
  //translate(25, 0, 0);
  text("Gallons\nconsumerd\nper capita", labelX, (plotY1+plotY2)/2);
}


void drawDataPoints(int col) {
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      //float value = interpolators[row].value;
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      point(x, y);
    }
  }
}

void drawYearLabels() {
  //int rowCount = data.getRowCount();
  fill(0);
  textSize(10);
  textAlign(CENTER, TOP);

  // Use thin, gray lines to draw the grid
  stroke(224);
  strokeWeight(1);

  for (int row = 0; row < rowCount; row++) {
    if (years[row] % yearInterval == 0) {
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row], x, plotY2 + 10);
      //line(x, plotY1, x, plotY2);
    }
  }
}

void drawTitle() {
  fill(0);
  textSize(30); // Personal Choice
  textAlign(LEFT);
  String title = data.getColumnName(currentColumn);
  text(title, plotX1, plotY1-10);
  plotFontTitle = createFont("Verdana", 20);
  textFont(plotFontTitle);
}

void drawVolumeLabels() {
  fill(0);
  textSize(10);
  stroke(128);
  strokeWeight(1);

  float dataFirst = dataMin + volumeInterval;

  for (float v = dataMin; v <= dataMax; v+= volumeIntervalMinor) { 
      if (v % volumeIntervalMinor == 0) {
        float y = map(v, dataMin, dataMax, plotY2, plotY1);      
        if (v % volumeInterval == 0){
          if (v == dataMin) {
            textAlign(RIGHT);
          } 
          else if (v == dataMax) {
            textAlign(RIGHT, TOP);
          } 
          else {
            textAlign(RIGHT, CENTER);
          }
          text(floor(v), plotX1-10, y);
          line(plotX1 - 4, y, plotX1, y); // Major Tick
      }
      else {
        line(plotX1 - 2, y, plotX1, y); // Minor Tick
      }
    }
  }
}

void drawDataLine(int col){
  beginShape();
  int rowCount = data.getRowCount();
  for (int row = 0; row < rowCount; row++){
    if (data.isValid(row,col)){
      float value = data.getFloat(row,col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      vertex(x,y);
    }
  }
  endShape();
}

void drawDataHighlight(int col){
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row,col)){
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      if (dist(mouseX, mouseY, x, y) < 3){
        strokeWeight(10);
        point(x,y);
        fill(0);
        plotFontAxis = createFont("Georgia", 10);
        textFont(plotFontAxis);
        textSize(10);
        textAlign(CENTER);
        text(nf(value, 0, 2) + " (" + years[row] + ")", x, y-8);
      } 
    }
  }
}

void drawDataCurve(int col){
  beginShape();
  for (int row = 0; row < rowCount; row++){
    if (data.isValid(row, col)){
      float value = data.getFloat(row,col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      
      curveVertex(x,y);
      // Double the cuve points for start and stop
      if ((row == 0) || (row == rowCount-1)){
        curveVertex(x,y);
      }
    }
  }
  endShape();
}

void drawDataArea(int col){
  beginShape();
  for (int row = 0; row < rowCount; row++){
    if (data.isValid(row, col)){
      float value = data.getFloat(row,col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      vertex(x,y);
    }
  }
  vertex(plotX2, plotY2);
  vertex(plotX1, plotY2);
  endShape(CLOSE);
}

void drawDataBars(int col) {
 noStroke();
 rectMode(CORNERS);
 
 for (int row = 0; row < rowCount; row++){
   if (data.isValid(row,col)){
     float value = data.getFloat(row, col);
     float x = map(years[row],yearMin,yearMax,plotX1,plotX2);
     float y = map(value, dataMin, dataMax, plotY2, plotY1);
     rect(x-barWidth/2, y, x+barWidth/2, plotY2);
   }
 } 
}

void drawTitleTabs(){
  rectMode(CORNERS);
  noStroke();
  textSize(20);
  textAlign(LEFT);
  
  if (tabLeft == null){
    tabLeft = new float[columnCount];
    tabRight = new float[columnCount];
  }
  
  float runningX = plotX1;
  tabTop = plotY1 - textAscent() - 15;
  tabBottom = plotY1;
  
  for (int col = 0; col < columnCount; col++){
    String title = data.getColumnName(col);
    tabLeft[col] = runningX;
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] + tabPad + titleWidth + tabPad;
    
    fill(col == currentColumn ? 255 : 224);
    rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    
    fill(col == currentColumn ? 0 : 65);
    text(title, runningX + tabPad, plotY1 - 10);
    
    runningX = tabRight[col];
  }
}

void mousePressed(){
  if (mouseY > tabTop && mouseY < tabBottom){
    for (int col = 0; col < columnCount; col++){
      if (mouseX > tabLeft[col] && mouseX < tabRight[col]){
        setColumn(col);
      }
    }
  }
}

void setColumn(int col){
  if (col != currentColumn){
    currentColumn = col;
  }
}


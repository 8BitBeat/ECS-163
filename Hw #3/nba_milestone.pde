Table table;
int backgroundH = 900;
int backgroundW = 1600;
Slider slider;
BallPosition ballPos;
Ball bBall;
ArrayList <BallPosition> ballPosArray;
boolean sliderOver = false;
float diameter = 70;

class BallPosition{ //player position
  float XPos, YPos;
  BallPosition(float x, float y){
    XPos = x;
    YPos = y;
  }
}

class Ball{
  float xPos, yPos;
  Ball(float x, float y){
    strokeWeight(3);
    fill(259, 159, 0);
    ellipse(x + 800, y + 450, diameter, diameter);  
  }
  
}

class Slider{
  int ticks;
  int sliderLength;
  float sliderX;
  int arrayIndex;
  float rangePerTick;
  
  Slider(int numTicks){
    sliderX = 50;
    sliderLength = backgroundW - 100;
    ticks = numTicks;
    rangePerTick = 1500.0/ticks;
    strokeWeight(4);
    line(50,backgroundH - 100,backgroundW - 50,backgroundH - 100);
    fill(255,0,0);
    ellipse(50,backgroundH - 100, 60,60);
    arrayIndex = 0;
    
  }
  void update(){
    sliderX = constrain(mouseX, 50, 1549);
    strokeWeight(4);
    line(50,backgroundH - 100,backgroundW - 50,backgroundH - 100);
    fill(255,0,0);
    ellipse(sliderX,backgroundH - 100, 60,60);

    arrayIndex = int((sliderX - 50) / rangePerTick); 
  }
}
  

void setup() {
 
  size(1600, 900);
  background(185,158,107);
  
  //String path = "C:/Users/ccch/Desktop/nba1/games/0041400101";
  //File f = new File(path);
  //String[] files = f.list();
  String lines[] = loadStrings("C:/Users/ccch/Desktop/nba1/games/0041400101/2.csv");
  
  Table table = new Table();
  table.addColumn("GameID", Table.INT);
  table.addColumn("TeamID", Table.INT);
  table.addColumn("PlayerID", Table.INT);
  table.addColumn("XPos", Table.FLOAT);
  table.addColumn("YPos", Table.FLOAT);
  table.addColumn("Height", Table.FLOAT);
  table.addColumn("Moment", Table.INT);
  table.addColumn("GameClock", Table.FLOAT);
  table.addColumn("ShotClock", Table.FLOAT);
  table.addColumn("Period", Table.INT);

  for(String line : lines){
    TableRow newRow= table.addRow();
    String[] lineData = line.split(",");
    newRow.setInt("GameID", Integer.parseInt(lineData[0]));
    newRow.setInt("TeamID", Integer.parseInt(lineData[1]));
    newRow.setInt("PlayerID", Integer.parseInt(lineData[2]));
    newRow.setFloat("XPos", Float.parseFloat(lineData[3]));
    newRow.setFloat("YPos", Float.parseFloat(lineData[4]));
    newRow.setFloat("Height", Float.parseFloat(lineData[5]));
    newRow.setInt("Moment", Integer.parseInt(lineData[6]));
    newRow.setFloat("GameClock", Float.parseFloat(lineData[7]));
    newRow.setFloat("ShotClock", Float.parseFloat(lineData[8]));
    newRow.setInt("Period", Integer.parseInt(lineData[9]));  
  } // parse the data to events, change this to an arraylist for dynamic

  ballPosArray = new ArrayList<BallPosition>();

  for(TableRow row : table.findRows("-1" ,"TeamID")){
    ballPos = new BallPosition(row.getFloat("XPos"), row.getFloat("YPos"));
    ballPosArray.add(ballPos);
  }
  slider = new Slider(ballPosArray.size());
  bBall = new Ball(ballPosArray.get(0).XPos, ballPosArray.get(0).YPos);

}

void draw(){
  background(185,158,107);
  update();
  
}

void update(){
  strokeWeight(4);
  line(50,backgroundH - 100,backgroundW - 50,backgroundH - 100);
  fill(255,0,0);
  ellipse(slider.sliderX,backgroundH - 100, 60,60);
  strokeWeight(3);
  fill(259, 159, 0);
  ellipse(ballPosArray.get(slider.arrayIndex).XPos + 800, ballPosArray.get(slider.arrayIndex).YPos + 450, diameter, diameter); 


}

boolean overSlider(float x, float y){
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  }
  else{
    return false;
  }
}

void mouseDragged(){
  if(overSlider(mouseX, mouseY)){
    slider.update();
  }
}
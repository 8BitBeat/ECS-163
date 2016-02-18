import controlP5.*;
import java.util.*;
 
Table table;
Table playersTable;
Table gamesTable;
Table teamsTable;

int backgroundH = 1080;
int backgroundW = 1920;

Object lastGameSelected;
Object lastPlayerSelected;

Slider slider;
BallPosition ballPos;
Ball bBall;
PShape court;

String[] gamesList;
TreeMap gamesDropdownMap = new TreeMap<String, String>();

ArrayList <BallPosition> ballPosArray;
boolean sliderOver = false;

float diameter = 25;
float scale = 12; //12 inches in a foot

ControlP5 gamesDropdownMenu;

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
  float sliderLength;
  float sliderX;
  int arrayIndex;
  float rangePerTick;
  
  Slider(int numTicks){
    sliderX = 50;
    sliderLength = backgroundW - 100;
    ticks = numTicks;
    rangePerTick = sliderLength/ticks;
    strokeWeight(4);
    line(sliderX,backgroundH - 100,backgroundW - 50,backgroundH - 100);
    fill(255,0,0);
    ellipse(50,backgroundH - 100, 60,60);
    arrayIndex = 0;
    
  }
  void update(){
    sliderX = constrain(mouseX, 50, backgroundW - 50);
    strokeWeight(4);
    line(50,backgroundH - 100,backgroundW - 50,backgroundH - 100);
    fill(255,0,0);
    ellipse(sliderX,backgroundH - 100, 60,60);

    arrayIndex = constrain(int((sliderX - 50) / rangePerTick), 0 , ballPosArray.size()-1);
    
  }
}

void dropdownSetupGames(){
  PFont pfont = createFont("Helvetica",16,false);
  ControlFont font = new ControlFont(pfont,20);
  gamesDropdownMenu = new ControlP5(this);
  
  File f = new File(dataPath("games/"));
  gamesList = f.list();
  

  String homeTeam = null;
  String visitorTeam = null; 
  
  gamesTable = loadTable(dataPath("games.csv"), "header");

  for(TableRow row : gamesTable.rows()) {
    int gameid = row.getInt("gameid");
    String gamedate = row.getString("gamedate");
    int hometeamid = row.getInt("hometeamid");
    int visitorteamid = row.getInt("visitorteamid");
  }
  
  for(TableRow row : gamesTable.rows()) {
    for(TableRow teamRow : teamsTable.findRows(""+row.getInt("hometeamid"), "teamid")) {
      homeTeam = teamRow.getString("abbreviation");
    }
    for(TableRow teamRow : teamsTable.findRows(""+row.getInt("visitorteamid"), "teamid")) {
      visitorTeam = teamRow.getString("abbreviation");
    }
    println(row.getString("gameid"), (row.getString("gamedate") + " " + visitorTeam + " vs " + homeTeam));
    gamesDropdownMap.put((row.getString("gamedate") + " " + visitorTeam + " vs " + homeTeam), row.getString("gameid"));
  }
  
  
  gamesDropdownMenu.addScrollableList("Games")
   .setPosition(1400, 100)
   .setSize(400, 250)
   .setBarHeight(50)
   .setItemHeight(50)
   .addItems(gamesDropdownMap);
  
  
  gamesDropdownMenu.setFont(font);
  
  gamesDropdownMenu.getController("Games")
     .getCaptionLabel()
     .setFont(font)
     .toUpperCase(true)
     .setSize(20);
}

void parsePlayers(){
  playersTable = loadTable(dataPath("players.csv"), "header");

  for (TableRow row : playersTable.rows()) {
    int playerid = row.getInt("playerid");
    String firstname = row.getString("firstname");
    String lastname = row.getString("lastname");
    int jerseynumber = row.getInt("jerseynumber");
    String position = row.getString("position");
    int teamid = row.getInt("teamid");
  } 
}

void parseTeams(){
  teamsTable = loadTable("team.csv", "header");
  for (TableRow row : teamsTable.rows()) {
    int teamid = row.getInt("teamid");
    String name = row.getString("name");
    String abbrv = row.getString("abbreviation");
  } 
}

void extractCsvData(){
  parsePlayers();
  parseTeams();
}

void setup() {
  size(1920, 1080);
  background(185,158,107);
  
  extractCsvData();
  
  dropdownSetupGames();
  String lines[] = loadStrings(dataPath("games/0041400101/2.csv"));

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
  court = loadShape("fullcourt.svg");
}

void draw(){
  background(185,158,107);
  shape(court, 100, 100, scale * 94, scale *50);
  update();
  
}

void update(){
  strokeWeight(4);
  line(50,backgroundH - 100,backgroundW - 50,backgroundH - 100);
  fill(255,0,0);
  ellipse(slider.sliderX,backgroundH - 100, 60,60);
  strokeWeight(3);
  fill(259, 159, 0);
  ellipse((ballPosArray.get(slider.arrayIndex).XPos * scale) + 100, (ballPosArray.get(slider.arrayIndex).YPos * scale) + 100, diameter, diameter); 
    
  
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

void Games(int n){
  println(gamesDropdownMenu.get(ScrollableList.class, "Games").getItem(n)); 
}
import controlP5.*;
import java.util.*;

//global vars
Table playersTable;
Table gamesTable;
Table teamsTable;

int backgroundH = 1600;
int backgroundW = 1920;

Slider slider;
PShape court;

PFont pfont;
ControlFont font;

String[] gamesList;
String[] eventsList;
Player playerInfo; //need to instantiate this for every table row
ArrayList<Player> playerInfoList = new ArrayList<Player>();
HashMap<String, ArrayList<Player>> playerInfoMap = new HashMap<String, ArrayList<Player>>();
TreeMap gamesDropdownMap = new TreeMap<String, String>();
TreeMap gameData = new TreeMap<String, ArrayList<Player> >();

boolean sliderOver = false;
boolean showNames = false;
boolean play = false;

float diameter = 40;
float ballDiameter = 30;
float scale = 12; //12 inches in a foot

ControlP5 gamesDropdownMenu;
ControlP5 eventsDropdownMenu;

String currentGameDirectory = null;
String csvFile = null;

int team1 = -2;
int team2 = -2;
//end global vars

///////////////////////////////////////////////////////////////////////////classes///////////////////////////////////////////////////////
class Player {
  float xPos;
  float yPos;
  int playerId;
  int teamId;
  float height;
  float gameClock;
  float shotClock;
  String playerFirstName = null;
  String playerLastName = null;
  
  double totalDistance;

  
  Player(float x, float y, int pid, int tid, float h, float gc, float sc){
    this.xPos = x;
    this.yPos = y;
    this.playerId = pid;
    this.teamId = tid;
    this.height = h;
    this.gameClock = gc;
    this.shotClock = sc;
    
    if(this.playerId != -1){
      TableRow playerRow = playersTable.findRow(Integer.toString(playerId), "playerid");
      this.playerFirstName = playerRow.getString("firstname");
      this.playerLastName = playerRow.getString("lastname");
    }
    
  }
  
  Player(Player copy){
    this.xPos = copy.xPos;
    this.yPos = copy.yPos;
    this.playerId = copy.playerId;
    this.teamId = copy.teamId;
    this.height = copy.height;
    this.gameClock = copy.gameClock;
    this.shotClock = copy.shotClock;
    this.playerFirstName = copy.playerFirstName;
    this.playerLastName = copy.playerLastName;
    this.totalDistance = copy.totalDistance;
  }
        
  void update(){
    strokeWeight(3);
    if(this.teamId == team1)
      fill(255,0,0,150);
    else if(this.teamId == team2)
      fill(0,0,255,150);
    else
      fill(259, 159, 0); 
    
    if(this.playerId == -1)
      ellipse((this.xPos * scale) + 100, (this.yPos * scale) + 100, ballDiameter, ballDiameter);
    else
      ellipse((this.xPos * scale) + 100, (this.yPos * scale) + 100, diameter, diameter);
    
    if(showNames == true){
      if(this.playerId != -1){
        fill(0,0,0);
        textSize(20);
        text((this.playerFirstName + " " + this.playerLastName), (this.xPos * scale) + 125, (this.yPos * scale) + 90);
      }
    }
  }
    
  void updateStats(int iter){
    textSize(30);
    if(this.teamId == team1){
      fill(255,0,0,150);
      text((this.playerFirstName + " " + this.playerLastName + ":  " + this.totalDistance + " ft travelled" ), 100, 900 + iter*50);
    }
    else if(this.teamId == team2){
      fill(0,0,255,150);
      text((this.playerFirstName + " " + this.playerLastName + ":  " + this.totalDistance + " ft travelled" ), 900, 900 + iter*50 - 250); //really hacky
    }
  }
    
  
  
  void calculateTotalDistance(Player prevPlayer){
    float tempX = this.xPos - prevPlayer.xPos;
    float tempY = this.yPos - prevPlayer.yPos;
    this.totalDistance = Math.sqrt((tempY)*(tempY) +(tempX)*(tempX)) + prevPlayer.totalDistance;
  }
}

class Slider {
  int ticks;
  float sliderLength;
  float sliderX;
  int arrayIndex;
  float rangePerTick;

  Slider() {
    sliderX = 50;
    sliderLength = backgroundW - 100;
    strokeWeight(4);
    line(sliderX, backgroundH - 100, backgroundW - 50, backgroundH - 100);
    fill(255, 0, 0);
    ellipse(50, backgroundH - 100, 60, 60);
    arrayIndex = 0;
  }
  void update(float sliderPos) {
    sliderX = constrain(sliderPos, 50, backgroundW - 50);
    strokeWeight(4);
    line(50, backgroundH - 100, backgroundW - 50, backgroundH - 100);
    fill(255, 0, 0);
    ellipse(sliderX, backgroundH - 100, 60, 60);
    rangePerTick = sliderLength/playerInfoMap.size(); 
    arrayIndex = constrain(int((sliderX - 50) / rangePerTick), 0, playerInfoMap.size() - 1);
  }
  
  int getMoment(){
    return arrayIndex;   
  }
  
  void updateTicks(int numEvents){
    sliderX = 50;
    rangePerTick = sliderLength/numEvents;
    this.arrayIndex = 0;
  }//called when CSV is selected
}
//////////////////////////////////////////////////////////////////End Classes///////////////////////////////////////////////

void initGamesDropdownMenu() {
  File f = new File(dataPath("games/"));
  gamesList = f.list();
  
  gamesDropdownMenu = new ControlP5(this);

  String homeTeam = null;
  String visitorTeam = null; 

  gamesTable = loadTable(dataPath("games.csv"), "header");

  //for (TableRow row : gamesTable.rows()) {
  //  int gameid = row.getInt("gameid");
  //  String gamedate = row.getString("gamedate");
  //  int hometeamid = row.getInt("hometeamid");
  //  int visitorteamid = row.getInt("visitorteamid");
  //}

  for (TableRow row : gamesTable.rows()) {
    for (TableRow teamRow : teamsTable.findRows(""+row.getInt("hometeamid"), "teamid")) {
      homeTeam = teamRow.getString("abbreviation");
    }
    for (TableRow teamRow : teamsTable.findRows(""+row.getInt("visitorteamid"), "teamid")) {
      visitorTeam = teamRow.getString("abbreviation");
    }
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

void initEventsDropdownMenu() {
  eventsDropdownMenu.addScrollableList("Events")
    .setPosition(1400, 450)
    .setSize(400, 250)
    .setBarHeight(50)
    .setItemHeight(50);

  eventsDropdownMenu.setFont(font);

  eventsDropdownMenu.getController("Events")
    .getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setSize(20);
} //gets list of games and places them into events dropdown menu

void dropdownSetupGames() {
  pfont = createFont("Helvetica", 16, false);//font for menus
  font = new ControlFont(pfont, 20);

  eventsDropdownMenu = new ControlP5(this);

  initGamesDropdownMenu();
  initEventsDropdownMenu();
} //setup dropdown menus

void parsePlayers() {
  playersTable = loadTable(dataPath("players.csv"), "header");
}

void parseTeams() {
  teamsTable = loadTable("team.csv", "header");
}

void extractCsvData() {
  parsePlayers();
  parseTeams();
}//was planning to place more than one line in each individual function (ran out of time)

void setup() {
  size(1920, 1600);
  //background(185, 158, 107);
  background(225);
  court = loadShape("fullcourt.svg");
  slider = new Slider();

  currentGameDirectory = dataPath("games/0041400132");
  csvFile = currentGameDirectory + "\\" + "1.csv";

  extractCsvData();
  dropdownSetupGames();
  loadEvents();
  loadGame();

}

void draw() {
  //background(185, 158, 107);
  background(225);
  shape(court, 100, 100, scale * 94, scale *50);
  drawToggleNamesButton();
  drawPlayPauseButton();
  update();
}

void drawToggleNamesButton(){
  fill(0,0,0);
  rect(100, 750, 250, 50);
  textSize(20);
  fill(255,255,255);
  text("Display/Undisplay Names", 100, 780 );

}

void drawPlayPauseButton(){
  fill(0,0,0);
  rect(400, 750, 110, 50);
  textSize(20);
  fill(255,255,255);
  text("Play/Pause", 400, 780 );
}

void update() {
  strokeWeight(4);
  line(50, backgroundH - 100, backgroundW - 50, backgroundH - 100);
  fill(255, 0, 0);
  ellipse(slider.sliderX, backgroundH - 100, 60, 60);
  if(play == true){
    slider.update(min(slider.sliderX + 1, 1850)); 
  }
  drawPlayers();
}


//////////////////////////////////////////////////////////////////////Funcs that get called when click occurs/////////////////////////////////////////
void mouseClicked(){
  if(mouseX >100 && mouseX <350 && mouseY >750 && mouseY < 800){
    showNames = !showNames;
  }//clicked display names
  
  if(mouseX>400 && mouseX < 510 && mouseY >750 && mouseY < 800){
    play = !play; 
  }
  
  
}

boolean overSlider(float x, float y) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

void mouseDragged() {
  if (overSlider(mouseX, mouseY)) {
    slider.update(constrain(mouseX, 50, backgroundW - 50));
  }
}

void loadEvents() {
  File gamesFolder = new File(currentGameDirectory);
  eventsList = gamesFolder.list();

  eventsDropdownMenu.get(ScrollableList.class, "Events").clear();
  eventsDropdownMenu.get(ScrollableList.class, "Events").setItems(eventsList);
}//loads list of events from the chosen game folder



void drawPlayers(){
  int temp = 0;
  for(Player bBallPlayer : playerInfoMap.get(Integer.toString(slider.getMoment())) ){ //this line is causing errors when we switch csvs when slider !=0
    bBallPlayer.update();
    if(bBallPlayer.playerId != -1){
      bBallPlayer.updateStats(temp);
      temp++;
    }
  }
}

void loadGame(){
  //load all the rows into an arraylist of arraylist of player objects, where the index is the moment.
  String dataTableLines[] = loadStrings(csvFile);
  playerInfoMap.clear();
  
  team1 = -2;
  team2 = -2; //reset the teams
    
  for (String line : dataTableLines) {
    String[] lineData = line.split(",");
    float sc ;
    int tid = Integer.parseInt(lineData[1]);
    int pid = Integer.parseInt(lineData[2]);
    float x = Float.parseFloat(lineData[3]);
    float y = Float.parseFloat(lineData[4]);
    float h = Float.parseFloat(lineData[5]);
    float gc = Float.parseFloat(lineData[7]);
    if(lineData[8].equals("None"))
      sc = 0;
    else
      sc = Float.parseFloat(lineData[8]);
    String moment = lineData[6];
    
    if(team1 == -2 && tid != -1){
      team1 = tid; 
    }
    else if(tid != team1 && team2 == -2 && tid != -1){
      team2 = tid;
    }// determine teams playing
    
    playerInfo = new Player(x, y, pid, tid, h, gc, sc);
    
    if(moment.equals("0")){
      playerInfo.totalDistance = 0;
    }
    else{
      int previousMoment = Integer.parseInt(moment) - 1;
      String previousMomentStr = Integer.toString(previousMoment);
      ArrayList <Player> previousArr = playerInfoMap.get(previousMomentStr);
      for(Player p: previousArr){
        if(playerInfo.playerId == p.playerId){
          playerInfo.calculateTotalDistance(p);
        }
      }
    }
      
         
    if(playerInfoMap.containsKey(moment) == false){
      playerInfoList.clear();
      playerInfoList.add(playerInfo);
      playerInfoMap.put(moment, playerInfoList);
    }// if the key doesn't exist, meaning we've encountered a new moment
    else{
      ArrayList<Player> updatedArr = new ArrayList<Player>();
      ArrayList<Player> tempArr = playerInfoMap.get(moment);
      for(Player p : tempArr){
        Player temp = new Player(p);
        updatedArr.add(temp);
    }
      updatedArr.add(playerInfo);
      playerInfoMap.put(moment, updatedArr);
    } //if it does exist, make a deep copy of the array at that moment and add in the new info then replace it in the map
  } // parse the data to events, change this to an arraylist for dynamic
  slider.updateTicks(playerInfoMap.size());  
  drawPlayers();
} //should only be called in Events and Setup

void Games(int n) {
  String gameFolder = (gamesDropdownMenu.get(ScrollableList.class, "Games").getItem(n).get("value")).toString();
  currentGameDirectory = dataPath("games/" + "00" + gameFolder);
  loadEvents();
}//called when a button from the games dropdown menu is pressed

void Events(int n) {
  play = false;
  csvFile = currentGameDirectory + "\\" + eventsDropdownMenu.get(ScrollableList.class, "Events").getItem(n).get("name").toString();
  println(csvFile);
  loadGame();
}// called when a button from the events dropdown menu is pressed.
// X:Site Points Machine VERSION 0.2
// Changes:
//     option to change number of teams added - max still 5 (numberOfTeams.txt)
//     improved code comments
//     option to change full screen number or windowed resolution from a file (fullscreen.txt)

Table teamInfo;
int numberOfTeams;

final char animationHotkey = ' ';
final char doAllHotkey = 'a';
final char showNoneHotkey = 'n';

// LEAVE BELOW CODE ALONE

// Global Variables / Constants

// Grid sizes
int gridSizeWidth;
int gridSizeHeight;

// Maximum value for comparing heights
int maxScore;

// Random numbers
int[][] randomScores = new int[10][5];

// Chart Lines
// chartArea = {top, bottom, left, right}
float[] chartArea = new float[4];

// Teams showing
// if showTeam[team] == 0 then do not show, else use this score.
boolean[] showTeam;

void settings(){
  String[] fullscreenFile = loadStrings("fullscreen.txt"); //<>//
  
  String[] windowedResolution = match(fullscreenFile[0],"([0-9]+)x([0-9]+)");
  if (windowedResolution == null){
    int fullScreenNum = int(fullscreenFile[0]);
    fullScreen(fullScreenNum);
  } else {
    size(int(windowedResolution[1]), int(windowedResolution[2]));
  }
}

void setup() {
  //size(1024, 768);
  gridSizeWidth = width / 24;
  gridSizeHeight = height / 24;

  chartArea[0] = gridSizeHeight * 2;
  chartArea[1] = gridSizeHeight * 22;
  chartArea[2] = gridSizeWidth  * 1;
  chartArea[3] = gridSizeWidth  * 23;

  // get scores from disk
  teamInfo = loadTable("scores.csv", "header, csv");
  //access with teamInfo.getFloat(team, header) (also use getString or getInt with same syntax)

  // get number of teams to read
  String[] teamNumFile = loadStrings("numberOfTeams.txt");
  numberOfTeams = int(teamNumFile[0]);

  // get scores for teams from CSV
  int[] scores = new int[numberOfTeams];
  for (int team = 0; team < numberOfTeams; team++) {
    scores[team] = teamInfo.getInt(team, "Score");
  }
  // store max score for scale purposes
  maxScore = max(scores);

  // generate random numbers for animation
  for (int i = 0; i < 10; i++) {
    for (int j = 0; j < 5; j++) {
      // keep random numbers between halfway point and max score
      int score = int(random(maxScore/2, maxScore));
      randomScores[i][j] = score;
    }
  }
  
  showTeam = new boolean[numberOfTeams];
  for (int i = 0; i < numberOfTeams; i++) {
    showTeam[i] = false;
  }
}

// changing this to 0 triggers the animation. Use runAnimation() to trigger correctly.
// changing this to 10 goes to final state with any showTeam variables set to true.
int animationFrame = -1;

void draw() {
  drawBgChart();

  // if animation on, run through the animation
  if (animationFrame > -1 && animationFrame < 10) {
    for (int team = 0; team < numberOfTeams; team++) {
      drawBar(team, randomScores[animationFrame][team]);
    }
    // pause for a bit to let people see the change
    delay(200);
    // increase to next frame
    animationFrame++;
  }
  // else show final frame of animation, the showTeam listings.
  // runAnimation() will set showTeam to true as it enables the animation.
  else if (animationFrame >= 10) {
    for (int team = 0; team < numberOfTeams; team++) {
      if (showTeam[team]) { //<>//
        drawBar(team, teamInfo.getInt(team, "Score"));
      }
    }
  }
}

// draw the chart background
void drawBgChart() {
  background(255);

  // Draw lines
  // base line
  stroke(0);
  line(gridSizeWidth * 1, gridSizeHeight * 22, gridSizeWidth * 23, gridSizeHeight * 22);

  // left line
  line(chartArea[2], chartArea[0], chartArea[2], chartArea[1]);

  noStroke();
};

// common function for drawing a bar
void drawBar(int team, int score) {
  // Left to right positions
  float[] barOffsets5 = {gridSizeWidth * 3, gridSizeWidth * 7, gridSizeWidth * 11, gridSizeWidth * 15, gridSizeWidth * 19};

  float[] barOffsets = new float[numberOfTeams];
  int firstDistance = 3;
  int maxDistance = 19;
  int difference = maxDistance - firstDistance; // 16
  int distanceBetween = difference / (numberOfTeams - 1);

  println(distanceBetween); //<>//

  for (int t=0; t < numberOfTeams; t++) {
    barOffsets[t] = gridSizeWidth * (firstDistance + (distanceBetween * t));
  }

  println(barOffsets);

  // Calculate max height
  float chartHeight = chartArea[1] - chartArea[0];

  // What height should the bar be at?
  float barHeight;
  float scoreRelative;

  if (score == maxScore) {
    // shortcut to final answer
    barHeight = chartHeight;
  } else {
    // we have to calculate
    scoreRelative = float(score) / float(maxScore);
    barHeight = scoreRelative * chartHeight;
  }

  color red = teamInfo.getInt(team, "Red");
  color green = teamInfo.getInt(team, "Green");
  color blue = teamInfo.getInt(team, "Blue");
  String name = teamInfo.getString(team, "Name");

  // Draw the bar and text labels
  rectMode(CORNER);
  fill(color(red, green, blue));
  // Bar
  rect(barOffsets[team], chartArea[1], gridSizeWidth * 1.5, -barHeight);
  // Text areas
  rectMode(CORNERS);
  // TODO - always centre on bar!
  textSize(gridSizeHeight);
  // score above
  text(score, barOffsets[team] + (gridSizeWidth/6), chartArea[1] - barHeight - (gridSizeWidth/4));
  // name below
  text(name, barOffsets[team], chartArea[1] + gridSizeHeight * 1);
}

void keyPressed() {
  // check which key has been pressed
  println(key);
  switch (key) {
  case animationHotkey:
    runAnimation();
    break;
  case doAllHotkey:
    setAllBars(true);
    animationFrame = 10;
    break;
  case showNoneHotkey:
    setAllBars(false); // so that toggling doesn't show all again
    animationFrame = -1;
  default:
    checkTeamHotkey();
  }
}

void checkTeamHotkey() {
  // is the key pressed a team hotkey?
  // if not, do nothing.
  int teamNumber = -1;
  for (int team = 0; team < numberOfTeams; team++) {
    String teamKey = teamInfo.getString(team, "Hotkey"); 
    if (teamKey.charAt(0) == key) {
      teamNumber = team;
      break;
    }
  }
  // if keypress is a team hotkey, toggle showing team colour 
  if (teamNumber != -1) {
    showTeam[teamNumber] = !showTeam[teamNumber];
    animationFrame = 10;
  }
}

void runAnimation() {
  animationFrame = 0;
  setAllBars(true);
}

void setAllBars(boolean value) {
  for (int team = 0; team < numberOfTeams; team++) {
    showTeam[team] = value;
  }
};

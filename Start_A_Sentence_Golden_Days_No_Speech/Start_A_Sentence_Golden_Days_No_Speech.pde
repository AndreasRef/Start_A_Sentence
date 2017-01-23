//Print import

import java.util.Calendar;
import java.net.*; 
import java.util.Map;
import java.util.Iterator;
import SimpleOpenNI.*;

//STT Auto variable
String talk_result = "";
int testCounter = -40;

// The URL for the XML document
String url = "http://suggestqueries.google.com/complete/search?output=toolbar&hl=en&q="; 


PFont font;

String result ="";
String displayString ="";
String queryString ="";

Node[] nodes = new Node[12];

Node selectedNode = null;

//d variabel - Bruges til dist
float d = 500;

//Distance (in milimeters) that determines how close you are have to be to the kinnect to be allowed to "grab" a node 
int handsCloseDistance = 2000;

PVector handVector;

SimpleOpenNI context;
int handVecListSize = 1;
Map<Integer, ArrayList<PVector>>  handPathList = new HashMap<Integer, ArrayList<PVector>>();
color[]       userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};

void setup() {
  size(displayWidth, displayHeight);
  font = createFont("Caviar_Dreams_Bold.ttf", 32);
  textFont(font);
  textAlign(CENTER);
  noCursor();
  smooth();

  // M_6_1_01 init nodes
  for (int i = 0; i < nodes.length; i++) {
    nodes[i] = new Node(width/2+random(-1, 1), height/2+random(-1, 1));
    nodes[i].setBoundary(5, 5, width-5, height-5);
  }

  ///SimpleOpenNI Hands3d Test SETUP
  handVector = new PVector(0, 0);

  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }   

  // enable depthMap generation 
  context.enableDepth();

  // disable mirror
  context.setMirror(true);

  // enable hands + gesture generation
  //context.enableGesture();
  context.enableHand();
  context.startGesture(SimpleOpenNI.GESTURE_WAVE);
}

void draw() {

  //Display begins
  background(0);
  strokeWeight(1);


  fill(255);
  text(talk_result, width/2, height - 30);

  ///SimpleOpenNI Hands3d Test DRAW
  // update the cam
  context.update();

  //image(context.depthImage(),0,0);

  boolean handIsClose = false;

  // draw the tracked hands
  if (handPathList.size() > 0)  
  {    
    Iterator itr = handPathList.entrySet().iterator();     
    while (itr.hasNext ())
    {
      Map.Entry mapEntry = (Map.Entry)itr.next(); 
      int handId =  (Integer)mapEntry.getKey();
      ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
      PVector p;
      PVector p2d = new PVector();
      fill(userClr[ (handId - 1) % userClr.length ]);
      strokeWeight(1);        
      Iterator itrVec = vecList.iterator(); 
      int vecCounter = 0;
      while ( itrVec.hasNext () ) 
      { 
        p = (PVector) itrVec.next();
        context.convertRealWorldToProjective(p, p2d);
        p2d.x = map(p2d.x, 0, context.depthWidth(), 0, width);
        p2d.y = map(p2d.y, 0, context.depthHeight(), 0, height);
        if (vecCounter == 0) {
          handVector = p2d;
          if (p.z < handsCloseDistance) {
            handIsClose = true;
          }
          if (handIsClose) {
            strokeWeight(8);

            //stroke(240, 0, 255, 255);
            stroke (20, 204, 165, 255); //Triad colour (green)
            //stroke (255); // Hvid
          } else {
            strokeWeight(4);
            //stroke(240, 0, 255, 150);
            //stroke (20, 204, 165, 150); //Triad colour (green)
            stroke (255, 100); // Hvid
          }
          //stroke(255);
          noFill();
          ellipse(handVector.x, handVector.y, 40, 40);

          ///Indsæt forloop der løber igennem noder og ser hvor langt væk vi er
          // Grab on to a node 
          selectedNode = null;
          if (handIsClose) {

            // Ignore anything greater than this distance
            float maxDist = 50;
            int selectedNodeIndex = -1;
            for (int i = 0; i < nodes.length; i++) {
              Node checkNode = nodes[i];

              float d = dist(handVector.x, handVector.y, checkNode.x, checkNode.y);

              if (d < maxDist) {
                selectedNode = checkNode;
                selectedNodeIndex = i;
                maxDist = d;
              }
            }

            if (selectedNode != null) {
              selectedNode.x = handVector.x;
              selectedNode.y = handVector.y;

              //Draw an X to indicate where to delete a sentence
              stroke (0);
              int xplus = 1200; 
              int yplus = 700; 
              int sletfelt = 15;
              float eraseDist= dist(handVector.x, handVector.y, xplus + 25, yplus + 25);
              float eraseDistMapped = map(eraseDist, 0, 1300, 255, 10);
              float eraseDistConstrain = constrain(eraseDistMapped, 10, 255);

              fill(240, 0, 255, eraseDistConstrain);
              //fill(255, 255, 255, eraseDistConstrain);
              ellipse (25 + xplus, 25 + yplus, 100, 100);

              //image(imgErase, xplus, yplus, 50, 50);
              strokeWeight (4);
              int xcross1 = xplus+5;
              int xcross2 = xplus+45;
              int ycross1 = yplus+5;
              int ycross2 = yplus+45;
              line (xcross1, ycross1, xcross2, ycross2);
              line (xcross2, ycross1, xcross1, ycross2);

              if (selectedNode.x > xplus - sletfelt && selectedNode.y > yplus - sletfelt) {

                Node[] newNodes = new Node[ nodes.length-1 ];

                int newArrayIndex = 0 ;

                for (int i = 0; i < nodes.length; i++) {
                  if (i != selectedNodeIndex) {
                    newNodes[newArrayIndex] = nodes[i];
                    newArrayIndex++;
                  }
                }
                nodes = newNodes;
              }
            }
          }
        }
        vecCounter++;
      }
    }
  }    

  fill(255);

  // Nodes repel, have velocity and are updated - let all nodes repel each other
  for (int j = 0; j < nodes.length; j++) {
    nodes[j].attract(nodes);
  } 
  // apply velocity vector and update position
  for (int j = 0; j < nodes.length; j++) {
    nodes[j].update();
  } 

  //  Lines between every node
  stroke(240, 0, 255, 130);
  strokeWeight(2);

  for (int i = 0; i < nodes.length-1; i++) {
    for (int j = nodes.length-1; j > 0; j--) {
      line(nodes[i].x, nodes[i].y, nodes[j].x, nodes[j].y);
    }
  } 

  // Textresults on every node
  for (int i = 0; i < nodes.length; i++) { 
    text("" + nodes[i].result, nodes[i].x, nodes[i].y);
  }
}

String getFirstSuggestion(String term) {

  if (term.length() > 0) {
    // Load the XML document
    try {
      //XML xml = loadXML(url + URLEncoder.encode(term, "UTF-8"));

      byte[] data = loadBytes(url + term);
      String decoded = new String(data, java.nio.charset.Charset.forName("ISO-8859-1"));

      XML xml = parseXML(decoded);

      // Grab the element we want
      XML firstSuggestion = xml.getChild("CompleteSuggestion/suggestion");

      if (firstSuggestion != null) {
        return firstSuggestion.getString("data");
      } else {
        return "";
      }
    }
    catch(Exception e) {
      e.printStackTrace();
      return "";
    }
  } else {
    return "";
  }
}

String[] getSuggestions(String term) {

  if (term.length() > 0) {
    try {
      //XML xml = loadXML(url + URLEncoder.encode(term, "UTF-8"));

      byte[] data = loadBytes(url + term);
      String decoded = new String(data, java.nio.charset.Charset.forName("ISO-8859-1"));

      XML xml = parseXML(decoded);

      XML[] children = xml.getChildren("CompleteSuggestion");

      String[] resultStrings = new String[children.length];

      for (int i = 0; i < children.length; i++) {
        XML suggestion = children[i].getChild("suggestion");
        //println(suggestion);
        resultStrings[i] = suggestion.getString("data");
      }

      return resultStrings;
    }
    catch(Exception e) {
      e.printStackTrace();
      return new String[1];
    }
  } else {
    return new String[1];
  }
}



void keyPressed() {

  // Print
  if (keyPressed) {
    if (key == TAB) {
      saveFrame(timestamp()+".png");
    }
  }

  if (key != CODED) {
    switch(key) {
    case BACKSPACE:
      talk_result = talk_result.substring(0, max(0, talk_result.length()-1));
      break;

    case ENTER:

      getSpeechAndUpdateNodes();
      //tryAgainText = false;
      testCounter = 0;
      break;
    case RETURN:
      if (talk_result.length() > 0) {
        getSpeechAndUpdateNodes();
        //tryAgainText = false;
      }
      break;
    case ESC:
    case DELETE:
      break;
    default:
      talk_result += key;
    }
  }
}

void getSpeechAndUpdateNodes() {
  nodes = new Node[1];
  nodes[0] = new Node(width/2+random(-1, 1), height/2+random(-1, 1));


  if (talk_result.length() > 0) {
    result = getFirstSuggestion(talk_result);
    String[] results = getSuggestions(talk_result);
    queryString = "";
    talk_result = "";

    background(255);

    nodes = new Node[results.length];

    for (int i = 0; i < results.length; i++) {
      nodes[i] = new Node(width/2+random(-5, 5), height/2+random(-5, 5));
      nodes[i].setBoundary(5, 5, width-5, height-5);
      nodes[i].result = results[i];
    }
  }
}


///SimpleOpenNI Hands3d Test
// hand events

void onNewHand(SimpleOpenNI curContext, int handId, PVector pos)
{

  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);

  handPathList.put(handId, vecList);
}

void onTrackedHand(SimpleOpenNI curContext, int handId, PVector pos)
{
  ArrayList<PVector> vecList = handPathList.get(handId);
  if (vecList != null)
  {
    vecList.add(0, pos);
    if (vecList.size() >= handVecListSize)
      // remove the last point 
      vecList.remove(vecList.size()-1);
  }
}

void onLostHand(SimpleOpenNI curContext, int handId)
{

  handPathList.remove(handId);
}

// -----------------------------------------------------------------
// gesture events

void onCompletedGesture(SimpleOpenNI curContext, int gestureType, PVector pos)
{
  //println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);

  int handId = context.startTrackingHand(pos);
  //println("hand stracked: " + handId);
}

// -----------------------------------------------------------------


//Print timestamp
String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}

//Kør skethchen i fuld skærm som default
boolean sketchFullScreen() {
  return true;
}


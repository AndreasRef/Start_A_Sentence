
import java.net.*;
String talk_result = "";

// The URL for the XML document
String url = "http://suggestqueries.google.com/complete/search?output=toolbar&hl=dk&q="; 

// GoogleSuggest Variabler
PFont font;

String displayString ="";
String queryString ="";
String[] results;

void setup() {
  size(600, 360);
  font = createFont("Merriweather-Light.ttf", 12);
  textFont(font);
  results = new String[1];

}

void draw() {
  background(255);
  fill(0);
  // Display all the stuff we want to display
  text("Input: " + talk_result, 10, 20);
  //text("Query: " + queryString, 10, 60);
  text("Output:" + queryString, 10, 60);

  for (int i = 0; i < results.length; i++) {
    if (results[i] != null) {
      text("" + results[i], 75, 60+(i*20));
    }
  }
}


String[] getSuggestions(String term) {

  if (term.length() > 0) {
    try {
      //XML xml = loadXML(url + URLEncoder.encode(term, "UTF-8"));
      XML xml = loadXML(url + java.net.URLEncoder.encode(term, "UTF-8"));
      //XML xml = loadXML(url + URLEncoder.encode(term, java.nio.charset.StandardCharsets.UTF_16.toString()));
      //XML xml = loadXML(url + term, java.nio.charset.StandardCharsets.UTF_8.toString());
      println(xml);
      XML[] children = xml.getChildren("CompleteSuggestion");

      String[] resultStrings = new String[children.length];

      for (int i = 0; i < children.length; i++) {
        XML suggestion = children[i].getChild("suggestion");
        println(suggestion);
        resultStrings[i] = suggestion.getString("data");
      }

      return resultStrings;
    }
    catch(Exception e) {
      e.printStackTrace();
      return new String[1];
    }
  }
  else {
    return new String[1];
  }
}




void keyPressed() {
  if (key != CODED) {
    switch(key) {
    case BACKSPACE:
      talk_result = talk_result.substring(0, max(0, talk_result.length()-1));
      break;
    case ENTER:
    case RETURN:
      if (talk_result.length() > 0) {
        results = getSuggestions(talk_result);
        queryString = "";
        talk_result = "";
      }
      break;
    case ESC:
    case DELETE:
      break;
    case TAB:

    default:
      talk_result += key;
    }
  }
}


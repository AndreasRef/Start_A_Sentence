import java.net.*;
String talk_result = "";
String url = "http://suggestqueries.google.com/complete/search?output=toolbar&hl=dk&q="; 
String[] results;

void setup() {
  results = new String[1];
}

void draw() {
}

String[] getSuggestions(String term) {
  if (term.length() > 0) {
    try {
      XML xml = loadXML(url + URLEncoder.encode(term, "UTF-8"));
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
  } else {
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
        talk_result = "";
      }
      break;
    default:
      talk_result += key;
      println(talk_result);
    }
  }
}


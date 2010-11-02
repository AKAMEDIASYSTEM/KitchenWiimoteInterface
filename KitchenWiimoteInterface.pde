/**
 *PRELIMINARY KITCHEN INTERFACE USING WIIMOTE
 *AKA
 
 Based on:
 * oscP5broadcastClient by andreas schlegel
 * an osc broadcast client.
 * an example for broadcast server is located in the oscP5broadcaster exmaple.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;
OscP5 oscP5;
/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation; 
String activeApplication = "VLC"; 
String MY_IP_ADDRESS = "192.168.10.28"; //CHANGE THIS!!
//this is where you fill in your own IP address

void setup() {
  size(100,100);
  frameRate(25);

  /* create a new instance of oscP5. 
   * 8050 is the port number you are listening for incoming osc messages.
   */
  oscP5 = new OscP5(this,8050);

  /* create a new NetAddress. a NetAddress is used when sending osc messages
   * with the oscP5.send method.
   */

  /* the address of the osc broadcast server */
  myBroadcastLocation = new NetAddress(MY_IP_ADDRESS,8000);
  OscMessage initMsg;
  initMsg = new OscMessage("/server/connect",new Object[0]);
  oscP5.flush(initMsg,myBroadcastLocation);
}


void draw() {
  background(0);
}


void mousePressed() {
  /* create a new OscMessage with an address pattern, in this case /test. */
  OscMessage myOscMessage = new OscMessage("/test");
  /* add a value (an integer) to the OscMessage */
  myOscMessage.add(100);
  /* send the OscMessage to a remote location specified in myNetAddress */
  oscP5.send(myOscMessage, myBroadcastLocation);
}


void keyPressed() {
  OscMessage m;
  switch(key) {
    case('c'):
    /* connect to the broadcaster */
    m = new OscMessage("/server/connect",new Object[0]);
    oscP5.flush(m,myBroadcastLocation);  
    break;
    case('d'):
    /* disconnect from the broadcaster */
    m = new OscMessage("/server/disconnect",new Object[0]);
    oscP5.flush(m,myBroadcastLocation);  
    break;
  }
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* get and print the address pattern and the typetag of the received OscMessage */
  println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  theOscMessage.print();

  //if the message was a B button press AND we just want o catch the downpress
  if(theOscMessage.checkAddrPattern("/wii/1/button/B") && theOscMessage.get(0).intValue()==1) {
    //toggle application behaviors between VLC and Firefox
    if(activeApplication == "/VLC") {
      activeApplication = "/Firefox";
      println(activeApplication);
    } 
    else {
      activeApplication = "/VLC";
      println(activeApplication);
    }
  }

  //otherwise, bounce it back to VLC with the appropriate address
  String oldPat = theOscMessage.getAddrPattern();
  println(activeApplication+oldPat);
  theOscMessage.setAddrPattern(activeApplication+oldPat);
  oscP5.send(theOscMessage, myBroadcastLocation);
  //send the original message back with an altered address indicating which app to target
}


package control;

import jess.*;

public class UserFunctions implements Userpackage {
    // The name method returns the name by which
    // the function will appear in Jess code.
    public void add(Rete engine){
    	engine.addUserfunction(new mountSystemCall());
    	engine.addUserfunction(new slackSystemCall());
    	engine.addUserfunction(new ssnSystemCall());
    	engine.addUserfunction(new updateRanking());
    }
  }
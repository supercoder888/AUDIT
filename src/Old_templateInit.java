import java.io.IOException;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.mysql.jdbc.Connection;
import com.mysql.jdbc.PreparedStatement;

import jess.*;

public class templateInit implements Userfunction {
    // The name method returns the name by which
    // the function will appear in Jess code.
    public String getName() { return "template-initialize"; }

    public Value call(ValueVector vv, Context context) throws JessException {
    	
        Rete engine = new Rete();
               
        Deftemplate tools = new Deftemplate("tools", "TOOLS", engine);
		
		tools.addSlot("ident", Funcall.NIL, "STRING");
		tools.addSlot("toolname", Funcall.NIL, "STRING");
		tools.addSlot("task", Funcall.NIL, "STRING");
		tools.addSlot("parameters", Funcall.NIL, "STRING");
		tools.addSlot("input", Funcall.NIL, "STRING");
		tools.addSlot("output", Funcall.NIL, "STRING");
		tools.addSlot("config", Funcall.NIL, "STRING");

		engine.addDeftemplate(tools);
		
		Deftemplate knowledge = new Deftemplate("knowledge", "KNOWLEDGE", engine);
		
		knowledge.addSlot("ident", Funcall.NIL, "STRING");
		knowledge.addSlot("usertype", Funcall.NIL, "STRING");
		knowledge.addSlot("fact", Funcall.NIL, "STRING");
		knowledge.addSlot("emp", Funcall.NIL, "STRING");

		engine.addDeftemplate(knowledge);
		
		java.sql.Connection con = null;
		java.sql.PreparedStatement pst = null;
		ResultSet rs = null;
		
		String url = "jdbc:mysql://localhost:3306/auditdb"; // check if the database is there: mysql -u root -p
		String user = "audituser";
		String password = "audit123";

		try {
		    
			//String author = "AuditTest";
		    con = DriverManager.getConnection(url, user, password);
		    pst = con.prepareStatement("SELECT * FROM TOOLS");
		    rs = pst.executeQuery();

		    String command;
			while (rs.next()) {
		        command = "(assert (tools (ident \"" + rs.getString(1) + "\") " 
		        		+ "(toolname \"" + rs.getString(2) + "\") " 
		        		+ "(task \"" + rs.getString(3) + "\") " 
		        		+ "(parameters \"" + rs.getString(4) + "\") " 
		        		+ "(input \"" + rs.getString(5) + "\") " 
		        		+ "(output \"" + rs.getString(6) + "\") " 
		        		+ "(config \"" + rs.getString(7) +"\")))";
				engine.eval(command);

		    }
		    
		    pst = con.prepareStatement("SELECT * FROM KNOWLEDGE");
		    rs = pst.executeQuery();

		    while (rs.next()) {
		        command = "(assert (knowledge (ident \"" + rs.getString(1) + "\") " 
		        		+ "(usertype \"" + rs.getString(2) + "\") " 
		        		+ "(fact \"" + rs.getString(3) + "\") " 
		        		+ "(emp \"" + rs.getString(4) + "\")))";
				engine.eval(command);
		    	/*Fact fact2 = new Fact("knowledge", engine);
				fact2.setSlotValue("ident", new Value(rs.getString(1), RU.STRING));
				fact2.setSlotValue("usertype", new Value(rs.getString(2), RU.STRING));
				fact2.setSlotValue("fact", new Value(rs.getString(3), RU.STRING));
				fact2.setSlotValue("emp", new Value(rs.getString(4), RU.STRING));
				engine.assertFact(fact2);*/
		    }
		    
		    engine.eval("(facts)");
		    
		} catch (SQLException ex) {
			Logger lgr = Logger.getLogger(templateInit.class.getName());
		    lgr.log(Level.SEVERE, ex.getMessage(), ex);

		} finally {

		    try {
		        if (pst != null) {
		            pst.close();
		        }
		        if (con != null) {
		            con.close();
		        }

		    } catch (SQLException ex) {
		    	Logger lgr = Logger.getLogger(templateInit.class.getName());
		        lgr.log(Level.SEVERE, ex.getMessage(), ex);
		    }
		}
        

		return new Value("", RU.STRING);
      }
  }
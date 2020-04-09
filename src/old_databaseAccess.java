import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

import jess.*;

public class databaseAccess implements Userfunction {
    // The name method returns the name by which
    // the function will appear in Jess code.
    public String getName() { return "get-database"; }

    public Value call(ValueVector vv, Context context) throws JessException {
    	Rete engine = new Rete();
        String command;
    	
    	String r1 = vv.get(1).stringValue(context);
        
        Connection con = null;
		PreparedStatement pst = null;
		ResultSet rs = null;
		
		String url = "jdbc:mysql://localhost:3306/auditdb";
		String user = "audituser";
		String password = "audit123";

        try {
            con = DriverManager.getConnection(url, user, password);
            pst = con.prepareStatement("SELECT * FROM TOOLS");
            rs = pst.executeQuery();

            while (rs.next()) {
                //System.out.println(rs.getString(1) + "\t" + rs.getString(2)+ "\t" + rs.getString(3)
                //					+ "\t" + rs.getString(4)+ "\t" + rs.getString(5) 
                //					+ "\t" + rs.getString(6)+ "\t" + rs.getString(7));
                command = "(assert (" + rs.getString(1) + " " 
                		+ rs.getString(2) + " " 
                		+ rs.getString(3) + " " 
                		+ rs.getString(4) + " " 
                		+ rs.getString(5) + " " 
                		+ rs.getString(6) + " " 
                		+ rs.getString(7) +"))";
				engine.eval(command);
				
				command = "(assert (tools (ident " + rs.getString(1) + ") (toolname " 
                		+ rs.getString(2) + ")))";
				System.out.println(command);
				engine.eval(command);
            }
            
        } catch (SQLException ex) {
        	Logger lgr = Logger.getLogger(databaseAccess.class.getName());
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
            	Logger lgr = Logger.getLogger(databaseAccess.class.getName());
                lgr.log(Level.SEVERE, ex.getMessage(), ex);
            }
        }
        
        return new Value(r1, RU.STRING);
      }
  }
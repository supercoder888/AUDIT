package control;

import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

import jess.*;

class updateRanking implements Userfunction {
    // The name method returns the name by which
    // the function will appear in Jess code.
    public String getName() { return "updateRanking"; }

    public Value call(ValueVector vv, Context context) throws JessException {
    	    	
    	//float r1 = (float) vv.get(1).floatValue(context);
    	String r1 = vv.get(1).stringValue(context);
    	String r2 = vv.get(2).stringValue(context);
        String r3 = vv.get(3).stringValue(context);
        
      //Connecting to the database and getting all the information from DB into KB
		////////////////////////////////////////////////////////////////////////////////
		
		Connection con = null;
		PreparedStatement pst = null;
		String url = "jdbc:mysql://localhost:3306/auditdbNew"; // check if the database is there: mysql -u root -p
		String user = "audituser";
		String password = "audit123";

        try {
            
        	//String author = "AuditTest";
            con = DriverManager.getConnection(url, user, password);
            pst = con.prepareStatement(r3);
            //pst.setFloat(1, r1);
            pst.setString(1, r1);
            pst.setString(2, r2);
            pst.executeUpdate();              
            
            pst.close();
            
        } catch (SQLException ex) {
        	Logger lgr = Logger.getLogger(updateRanking.class.getName());
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
            	Logger lgr = Logger.getLogger(updateRanking.class.getName());
                lgr.log(Level.SEVERE, ex.getMessage(), ex);
            }
        }
        ////////////////////////////////////////////////////////////////////////////////

        
        return new Value(r2, RU.STRING);
      }
  }
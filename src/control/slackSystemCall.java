package control;

import java.io.BufferedReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import jess.*;

class slackSystemCall implements Userfunction {
    // The name method returns the name by which
    // the function will appear in Jess code.
    public String getName() { return "my-system-blkls"; }

    public Value call(ValueVector vv, Context context) throws JessException {
    	InputStream is;
        InputStreamReader isr;
        BufferedReader br;                
        String line;
    	
    	String r1 = vv.get(1).stringValue(context);
        String r2 = vv.get(2).stringValue(context);
        String r3 = vv.get(3).stringValue(context);
        //String r4 = vv.get(4).stringValue(context);
        String r5 = vv.get(5).stringValue(context);
       
        System.out.println(r1+" "+r2+" "+r3);
        
        try {

	        String[] strArr1 = new String[] {r1, r2, r3};
	        ProcessBuilder probuilder = new ProcessBuilder( strArr1 );
	        Process process = probuilder.start();
	
	        //Read out dir output
	        is = process.getInputStream();
	        isr = new InputStreamReader(is);
	        br = new BufferedReader(isr);
	
	        FileWriter writeoutStream = new java.io.FileWriter(r5);
	
	        while ((line = br.readLine()) != null) {
	            writeoutStream.write(line);
	            writeoutStream.write('\n');
	        }
	        writeoutStream.close();
	        br.close();
	        isr.close();
	        is.close();
	        
	        //Wait to get exit value

            
        } catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        return new Value(r1, RU.STRING);
      }
  }
package control;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import jess.*;

class ssnSystemCall implements Userfunction {
    // The name method returns the name by which
    // the function will appear in Jess code.
    public String getName() { return "my-system-ssn"; }

    public Value call(ValueVector vv, Context context) throws JessException {
    	InputStream is;
        InputStreamReader isr;
        BufferedReader br;                
        int exitVal;
        String line;
    	
    	String r1 = vv.get(1).stringValue(context);
        String r2 = vv.get(2).stringValue(context);
        String r3 = vv.get(3).stringValue(context);
        String r4 = vv.get(4).stringValue(context);
        String r5 = vv.get(5).stringValue(context);
        String r6 = vv.get(6).stringValue(context);
        String r7 = vv.get(7).stringValue(context);
        String r8 = vv.get(8).stringValue(context);
        String r9 = vv.get(9).stringValue(context);

        System.out.println(r1+" "+r2+" "+r3+" "+r4+" "+r5+" "+r6+" "+r7+" "+r8+" "+r9);
        
        try {

	        String[] strArr1 = new String[] {r1, r2, r3, r4, r5, r6, r7, r8, r9};
	        ProcessBuilder probuilder = new ProcessBuilder( strArr1 );
	        Process process = probuilder.start();
	
	        //Read out dir output
	        is = process.getInputStream();
	        isr = new InputStreamReader(is);
	        br = new BufferedReader(isr);
	
	        while ((line = br.readLine()) != null) {
	            System.out.println(line);
	        }

	        br.close();
	        isr.close();
	        is.close();
	        
	        //Wait to get exit value
        
            exitVal = process.waitFor();
            
        } catch (InterruptedException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        return new Value(r1, RU.STRING);
      }
  }
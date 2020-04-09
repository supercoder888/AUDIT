package auditGUI;

import java.io.File;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

import jess.*;

import javax.swing.JFileChooser;
import javax.swing.JOptionPane;

import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;

public class audit {

	protected static final File[] NULL = null;
	protected Shell shlAuditAutomated;
	private Text inputFileNameText;
	private Text outputDirNameText;

	/**
	 * Launch the application.
	 * @param args
	 */
	public static void main(String[] args) {
		try {
			audit window = new audit();
			window.open();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Open the window.
	 */
	public void open() {
		Display display = Display.getDefault();
		createContents();
		shlAuditAutomated.open();
		shlAuditAutomated.layout();
		while (!shlAuditAutomated.isDisposed()) {
			if (!display.readAndDispatch()) {
				display.sleep();
			}
		}
	}

	/**
	 * Create contents of the window.
	 */
	protected void createContents() {
		shlAuditAutomated = new Shell(SWT.SHELL_TRIM & (~SWT.RESIZE));
		shlAuditAutomated.setLocation(-346, -56);
		shlAuditAutomated.setSize(520, 520);
		shlAuditAutomated.setText("AUDIT - Automated Disk Investigation Toolkit");
		
		
		inputFileNameText = new Text(shlAuditAutomated, SWT.BORDER);
		inputFileNameText.setText("/home/utk/part5.img");
		inputFileNameText.setBounds(28, 270, 349, 27);
		
		outputDirNameText = new Text(shlAuditAutomated, SWT.BORDER);
		outputDirNameText.setText("/home/utk/t1");
		outputDirNameText.setBounds(28, 345, 349, 27);
		
		final Button inputFileButton = new Button(shlAuditAutomated, SWT.NONE);
		inputFileButton.addSelectionListener(new SelectionAdapter() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				
				JFileChooser fc = new JFileChooser();
				
		        //Handle open button action.
		        if (e.getSource() == inputFileButton) {
		            int returnVal = fc.showOpenDialog(null);
		            
		            if (returnVal == JFileChooser.APPROVE_OPTION) {
		                File file = fc.getSelectedFile();
		                //This is where a real application would open the file.
		                inputFileNameText.setText(file.getAbsolutePath());
		            } else {
		                inputFileNameText.setText("Open command cancelled by user.");
		            }
		            //inputFileNameText.setCaretPosition(inputFileNameText.getSelection());
		        }
				
			}
		});
		inputFileButton.setBounds(400, 268, 91, 29);
		inputFileButton.setText("Browse");
		
		final Button ouputDirButton = new Button(shlAuditAutomated, SWT.NONE);
		ouputDirButton.addSelectionListener(new SelectionAdapter() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				
				JFileChooser dc = new JFileChooser(); // directory chooser
		        dc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
		        //
		        // disable the "All files" option.
		        //
		        dc.setAcceptAllFileFilterUsed(false);
		        
		        //Handle open button action.
		        if (e.getSource() == ouputDirButton) {
		            int returnVal = dc.showOpenDialog(null);
		            
		            if (returnVal == JFileChooser.APPROVE_OPTION) {
		                File file = dc.getSelectedFile();
		                //This is where a real application would open the file.
		                outputDirNameText.setText(file.getAbsolutePath());
		            } else {
		                outputDirNameText.setText("Open command cancelled by user.");
		            }
		            //outputDirNameTExt.setCaretPosition(outputDirNameTExt.getDocument().getLength());
		        }
			}
		});
		ouputDirButton.setBounds(400, 343, 91, 29);
		ouputDirButton.setText("Browse");
		
		Label lblPleaseSelectDisk = new Label(shlAuditAutomated, SWT.NONE);
		lblPleaseSelectDisk.setBounds(28, 247, 349, 17);
		lblPleaseSelectDisk.setText("Please select disk image to investigate.");
		
		Label lblPleaseSelectAn = new Label(shlAuditAutomated, SWT.NONE);
		lblPleaseSelectAn.setBounds(28, 322, 349, 17);
		lblPleaseSelectAn.setText("Please select an empty output directory for results.");
		
		Group grpWhatWouldYou = new Group(shlAuditAutomated, SWT.NONE);
		grpWhatWouldYou.setText("What would you like to perform?");
		grpWhatWouldYou.setBounds(28, 28, 238, 197);
		
		final Button btnGraphicSearch = new Button(grpWhatWouldYou, SWT.RADIO);
		btnGraphicSearch.setBounds(10, 77, 187, 24);
		btnGraphicSearch.setText("Graphics Search");
		
		final Button btnDocumentSearch = new Button(grpWhatWouldYou, SWT.RADIO);
		btnDocumentSearch.addSelectionListener(new SelectionAdapter() {
			@Override
			public void widgetSelected(SelectionEvent e) {
			}
		});
		btnDocumentSearch.setSelection(true);
		btnDocumentSearch.setBounds(10, 40, 170, 24);
		btnDocumentSearch.setText("Document Search");
		
		final Button btnCreditCardSSN = new Button(grpWhatWouldYou, SWT.RADIO);
		btnCreditCardSSN.setBounds(10, 114, 187, 24);
		btnCreditCardSSN.setText("Credit Card and SSN");
		
		final Button btnEmailSearch = new Button(grpWhatWouldYou, SWT.RADIO);
		btnEmailSearch.setBounds(10, 151, 114, 24);
		btnEmailSearch.setText("Email Search");
		
		Group grpLevelOfExpertise = new Group(shlAuditAutomated, SWT.NONE);
		grpLevelOfExpertise.setText("Level of Expertise");
		grpLevelOfExpertise.setBounds(305, 28, 144, 136);
		
		final Button btnNonExpert = new Button(grpLevelOfExpertise, SWT.RADIO);
		btnNonExpert.setSelection(true);
		btnNonExpert.setBounds(10, 37, 114, 24);
		btnNonExpert.setText("Non - Expert");
		
		Button btnExpert = new Button(grpLevelOfExpertise, SWT.RADIO);
		btnExpert.setBounds(10, 84, 114, 24);
		btnExpert.setText("Expert");
		
		Button btnStart = new Button(shlAuditAutomated, SWT.NONE);
		
		btnStart.addSelectionListener(new SelectionAdapter() {
			
			@Override
			public void widgetSelected(SelectionEvent e) {
				
				Rete engine = new Rete();
				Fact f = null;		
				boolean isExpert = false;
				int searchType = 1;
				String command;
				File outputDir = new File(outputDirNameText.getText());
				File inputFile = new File(inputFileNameText.getText());
				
				//check if input file and output directory are selected
				try {
					if (inputFile.isFile() && outputDir.isDirectory()) {

						engine.reset();

						if (btnNonExpert.getSelection() == false) {
							isExpert = true;
							// System.out.println("investigator is an expert");
							engine.eval("(assert (investigator is expert) (expert needs help))");
						} else {
							isExpert = false;
							// System.out.println("investigator is a non-expert");
							engine.eval("(assert (investigator is non-expert) (non-expert needs help))");
						}

						command = "(bind ?input \""
								+ inputFileNameText.getText() + "\")";
						// System.out.println(command);
						engine.eval(command);

						command = "(bind ?output \""
								+ outputDirNameText.getText() + "\")";
						// System.out.println(command);

						if (!outputDir.isDirectory()) {
							outputDir.mkdirs();
						}
						engine.eval(command);

						// pass the user selection to JESS

						if (btnDocumentSearch.getSelection() == true)
							searchType = 1;
						else if (btnGraphicSearch.getSelection() == true)
							searchType = 2;
						else if (btnCreditCardSSN.getSelection() == true)
							searchType = 3;
						else if (btnEmailSearch.getSelection() == true)
							searchType = 4;

						command = "(bind ?response " + searchType + ")";
						engine.eval(command);				
						
						Deftemplate tools = new Deftemplate("tools", "tools table", engine);
						tools.addSlot("ident", Funcall.NIL, "STRING");
						tools.addSlot("toolname", Funcall.NIL, "STRING");
						tools.addSlot("task", Funcall.NIL, "STRING");
						tools.addSlot("params", Funcall.NIL, "STRING");
						tools.addSlot("p_in", Funcall.NIL, "STRING");
						tools.addSlot("input", Funcall.NIL, "STRING");
						tools.addSlot("p_out", Funcall.NIL, "STRING");
						tools.addSlot("output", Funcall.NIL, "STRING");
						tools.addSlot("p_conf", Funcall.NIL, "STRING");
						tools.addSlot("config", Funcall.NIL, "STRING");
						tools.addSlot("S", Funcall.NIL, "INTEGER");
						tools.addSlot("F", Funcall.NIL, "INTEGER");
						tools.addSlot("R", Funcall.NIL, "FLOAT");
					    
						engine.addDeftemplate( tools );
						
						Deftemplate knowledge = new Deftemplate("knowledge", "knowledge table", engine);
						knowledge.addSlot("ident", Funcall.NIL, "STRING");
						knowledge.addSlot("usertype", Funcall.NIL, "STRING");
						knowledge.addSlot("fact", Funcall.NIL, "STRING");
						knowledge.addSlot("emp", Funcall.NIL, "STRING");
					    
						engine.addDeftemplate( knowledge );
						
						
						//Connecting to the database and getting all the information from DB into KB
						////////////////////////////////////////////////////////////////////////////////
						//engine.batch("src/auditInit.clp");
						
						Connection con = null;
						PreparedStatement pst = null;
						ResultSet rs = null;
						
						String url = "jdbc:mysql://localhost:3306/auditdbNew"; // check if the database is there: mysql -u root -p
						String user = "audituser";
						String password = "audit123";

				        try {
				            
				        	//String author = "AuditTest";
				            con = DriverManager.getConnection(url, user, password);
				            pst = con.prepareStatement("SELECT * FROM TOOLS");
				            rs = pst.executeQuery();
			            
				            //filling the tools template from database
				            while (rs.next()) {
				                command = "(assert (tools (ident \"" + rs.getString(1) + "\") " 
				                		+ "(toolname \"" + rs.getString(2) + "\") " 
				                		+ "(task \"" + rs.getString(3) + "\") " 
				                		+ "(params \"" + rs.getString(4) + "\") " 
				                		+ "(p_in \"" + rs.getString(5) + "\") " 
				                		+ "(input \"" + rs.getString(6) + "\") " 
				                		+ "(p_out \"" + rs.getString(7) + "\") "
				                		+ "(output \"" + rs.getString(8) + "\") "
				                		+ "(p_conf \"" + rs.getString(9) + "\") "
				                		+ "(config \"" + rs.getString(10) + "\") "
				                		+ "(S \"" + rs.getInt(11) + "\") "
				                		+ "(F \"" + rs.getInt(12) + "\") "
				                		+ "(R \"" + rs.getFloat(13) +"\")))";
								engine.eval(command);
				            }
				            
				            pst = con.prepareStatement("SELECT * FROM KNOWLEDGE");
				            rs = pst.executeQuery();
				            
				            //filling the knowledge template from database
				            while (rs.next()) { 
				                command = "(assert (knowledge (ident \"" + rs.getString(1) + "\") " 
				                		+ "(usertype \"" + rs.getString(2) + "\") " 
				                		+ "(fact \"" + rs.getString(3) + "\") " 
				                		+ "(emp \"" + rs.getString(4) + "\")))";
								engine.eval(command);
							}
				            
				            pst.close();
				            
				        } catch (SQLException ex) {
				        	Logger lgr = Logger.getLogger(audit.class.getName());
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
				            	Logger lgr = Logger.getLogger(audit.class.getName());
				                lgr.log(Level.SEVERE, ex.getMessage(), ex);
				            }
				        }
				        ////////////////////////////////////////////////////////////////////////////////
				        
						engine.batch("src/auditNew.clp");	// start the constructs
						
						//engine.eval("(facts)");
					
						// JOptionPane.showMessageDialog(null,"Just checking!","Checking!", JOptionPane.INFORMATION_MESSAGE);
						
					} else {
						JOptionPane
							.showMessageDialog(
							null,
							"Either file name or directory name is invalid or not entered!",
							"Error", JOptionPane.ERROR_MESSAGE);
					}
				} catch (JessException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
			}
		});
		
		btnStart.setBounds(286, 396, 91, 63);
		btnStart.setText("START");
		
		Button btnExit = new Button(shlAuditAutomated, SWT.NONE);
		btnExit.addSelectionListener(new SelectionAdapter() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				System.exit(0);
			}
		});
		btnExit.setBounds(400, 430, 91, 29);
		btnExit.setText("Exit");

	}
}

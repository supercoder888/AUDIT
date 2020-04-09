;;;======================================================
;;;   Disk Forensics Investigation Expert System
;;;
;;;     This expert system helps non-expert users to 
;;;     investigate a digital media.
;;;
;;;
;;;     To execute, merely load, reset and run.
;;;======================================================

;;;********************************************************
;;* GLOBAL VARIABLES *
;;;********************************************************

;(deftemplate tools 
;	(slot ident (type STRING))
;	(slot toolname (type STRING))
;	(slot task (type STRING))
;	(slot parameters (type STRING))
;    (slot input (type STRING))
;	(slot output (type STRING))
;	(slot config (type STRING)))	
;						
;						
;(deftemplate knowledge
;	(slot ident (type STRING))
;	(slot usertype (type STRING))
;	(slot fact (type STRING))
;	(slot emp (type INTEGER)))


(import java.awt.*)
(import java.awt.event.*)

(defglobal ?*searchType* = 0)
(defglobal ?*yesORno* = 0)

;; Create the widgets

(defglobal ?*f* = (new Frame "Button Demo"))
(defglobal ?*c* = (new Canvas))
(defglobal ?*b1* = (new Button "Yes"))
(defglobal ?*b2* = (new Button "No"))
(defglobal ?*l* = (new Label "Question"))

;;;********************************************************
;;* GUI INTERFACE *
;;;********************************************************

;; Add a listener to the button

(?*b1* addActionListener 
    (implement ActionListener using 
        (lambda (?name ?evt)
			(bind ?*yesORno* 1) ; clicked yes
            (set ?*f* visible FALSE)
            ;(bind ?yesORno 0) ; reset it for next time
        )
    )
)

(?*b2* addActionListener 
    (implement ActionListener using 
        (lambda (?name ?evt)
            (bind ?*yesORno* 2) ; clicked no
            (set ?*f* visible FALSE)
            ;(bind ?yesORno 0) ; reset it for next time
        )
    )
)

;; Add a WINDOW_CLOSING listener
(import java.awt.event.WindowEvent)
(?*f* addWindowListener  (implement WindowListener using (lambda (?name ?event)
    (if (= (?event getID) (WindowEvent.WINDOW_CLOSING)) then
        (exit)))))


(deffunction run_gui (?questionLabel)
    
	;; Assemble and display the GUI
	(?*f* add ?*b1*)
	(?*f* add ?*b2*)
    (?*f* add ?*l*)
	(?*f* add ?*c*) ; this canvas must be the last object added
	(?*f* pack)
	(?*f* setSize 491 247)
	(?*c* setSize 491 247)
	(?*b1* setBounds 143 179 91 29)
	(?*b2* setBounds 269 179 91 29)
    (?*l* setText ?questionLabel)
    (?*l* setBounds 23 57 443 57)
	(set ?*f* visible TRUE)
    
	
)

;;;********************************************************
;;* EXTERNAL FUNCTIONS FROM JAVA
;;;********************************************************

;(load-function slackSystemCall)
;(load-function ssnSystemCall)
;(load-function mountSystemCall)

(load-package control.UserFunctions)

;;;********************************************************
;;* DEFFUNCTIONS *
;;;********************************************************

(deffunction member()
    "Auto-generated")

(deffunction ask-question (?question $?allowed-values)
   (printout t ?question)
   (bind ?answer (read))
   (if (lexemep ?answer) 
       then (bind ?answer (lowcase ?answer)))
   (while (not (member ?answer ?allowed-values)) do
      (printout t ?question)
      (bind ?answer (read))
      (if (lexemep ?answer) 
          then (bind ?answer (lowcase ?answer))))
   ?answer)

(deffunction yes-or-no-p (?question)
   (bind ?response (ask-question ?question yes no y n))
   (if (or (eq ?response yes) (eq ?response y))
       then TRUE 
       else FALSE)
)

(deffunction gui-response (?text)

    (run_gui ?text)
    
    (while (= ?*yesORno* 0) 
       (bind ?dummy 0)
    ) ; infinite loop until gets response from user
    
    (if (= ?*yesORno* 1)
	then 
		(assert (evidence found yes))
	    (assert (recommend "Evidence is found, good by!!"))
	    (assert (clips-exit success on))
	else
		(printout t crlf)
		(assert (clips-exit failure on ))
	)
    
    (bind ?*yesORno* 0) ; reset it for next time
    
)

(deffunction run_tsk_recover (?parameter ?imagePath ?outputPath)
    (if (eq ?parameter "-a")
        then 
        	(printout t crlf "tsk_recover is run on File System Allocated Space!" crlf )
            (system tsk_recover ?parameter ?imagePath (str-cat ?outputPath "/tsk_recover/allocated/"))
            (assert (allocated space analyzed))
            ;(system nautilus (str-cat ?outputPath "/tsk_recover/allocated/"))
        else 
        (if (eq ?parameter "-e")
			then
				(printout t crlf "tsk_recover is run on File System Allocated and Unallocated Space!" crlf )
				(system tsk_recover ?parameter ?imagePath (str-cat ?outputPath "/tsk_recover/bothAllocUnalloc/"))
				(assert (bothAllocUnalloc space analyzed))
				;(system nautilus (str-cat ?outputPath "/tsk_recover/bothAllocUnalloc/"))
			else ; it's an empty parameter for unallocated space
				(printout t crlf "tsk_recover is run on File System Unallocated Space!" crlf )
				(system tsk_recover ?imagePath (str-cat ?outputPath "/tsk_recover/unallocated/"))
				(assert (unallocated space analyzed))
				;(system nautilus (str-cat ?outputPath "/tsk_recover/unallocated/"))
    	)
    )
)
       	   
(deffunction run_scalpel (?imagePath ?outputPath ?configuration)    
    (if (eq ?configuration 2)
    then 
    	(printout t crlf "Scalpel is running for carving graphic files!" crlf "Please be patient..." crlf)
       	(system scalpel ?imagePath "-o" (str-cat ?outputPath "/scalpelOut") "-c" "/etc/scalpel/scalpel_graphic.conf")
    else ; this is for document search and searchType = 1
      	(if (eq ?configuration 1) 
        then
     		(printout t crlf "Scalpel is run to perform data carving for documents!" crlf )
			(system scalpel ?imagePath "-o" (str-cat ?outputPath "/scalpelOut") "-c" "/etc/scalpel/scalpel_documents.conf")
        else
           	(if (eq ?configuration 3) 
	        then
	       		(printout t crlf "Scalpel is run to perform data carving for Credit Card and SSN!" crlf )
				(system scalpel ?imagePath "-o" (str-cat ?outputPath "/scalpelOut") "-c" "/etc/scalpel/scalpel_documents.conf")
	        else 
	           	(printout t crlf "Scalpel is run to perform data carving for email search!" crlf )
				(system scalpel ?imagePath "-o" (str-cat ?outputPath "/scalpelOut") "-c" "/etc/scalpel/scalpel_documents.conf")
	        )
        )
    )
    (printout t "Files are carved to " ?outputPath "/scalpelOut/" crlf crlf)
    (assert (data carving done))
    ;(system nautilus (str-cat ?outputPath "/scalpelOut"))
)

(deffunction run_blkls (?imagePath ?outputPath)  ; slack space analysis  
    (printout t crlf "blkls is run to extract the slack space of the disk image!" crlf)
    (system mkdir (str-cat ?outputPath "/slackSpace")) ; create a directory for results
    (my-system-blkls blkls -s ?imagePath  > (str-cat ?outputPath "/slackSpace/slack.dd"))
    ;(my-system 2 (str-cat "blkls" (str-cat " -s " (str-cat ?imagePath (str-cat " > " (str-cat ?outputPath "/slackSpace/slack.dd"))))))
    (assert (slack space analyzed))
    (printout t "Slack space is extracted to " ?outputPath "/slackSpace/slack.dd" crlf crlf)
	;(system nautilus (str-cat ?outputPath "/slackSpace"))	;open directory      
)

(deffunction run_find_ssns (?outputPath)
	; -a can be replaced by -s or -c for SSN or CC search only
    (printout t crlf  "Find_SSNs tool is called for SSN or CC search.")
    ;(system mkdir (str-cat ?outputPath "/mnt"))
    (my-system-ssn python "/home/utk/Desktop/find_ssns_source/Find_SSNs.pyw" -p ?outputPath -o ?outputPath -t html -a)
    ;(system python "/home/utk/Desktop/find_ssns_source/Find_SSNs.pyw")
    (assert (findSSN is called))
)


;;;****************************
;;;* INITIALIZATION RULES     *
;;;****************************


(defrule test-rule "template testing rule"
    (declare (salience 15))
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
	?allTools <- (tools )
    ?toolInfo <- (tools (toolname ?tName)(task "graphic_file_carving")(params ?params)(input ?in)(output ?out)(config ?config))
    =>
    ;(printout t (facts) crlf)    
    ;(printout t ?tName " " ?params " " ?in " " ?out " " ?config crlf crlf)
    ;(system ?tName " " ?params " " ?in " " ?out " " ?config)
    (updateRanking ?imagePath "?imagePath"  "UPDATE TOOLS SET input = ? WHERE input = ?")
    (updateRanking ?outputPath "?outputPath"  "UPDATE TOOLS SET output = ? WHERE output = ?")
    (modify ?allTools (S 3)) ; updates the running memory
    (updateRanking 3 "" "UPDATE TOOLS SET S = ? ?") ; updates the database
)


;;;****************************
;;;* INVESTIGATOR LEVEL RULES *
;;;****************************

(defrule investigator-is-expert1 ""
   (declare (salience 10))
   (investigator is expert)
   (expert needs no-help)
   =>
   (assert (recommend "No help is needed from us."))
   (assert (configuration not-needed))
   (assert (clips-exit failure on))
)

(defrule investigator-is-expert2 ""
   (declare (salience 10))
   (investigator is expert)
   (expert needs help)
   =>
   (assert (configuration needed)) 	     
)

(defrule investigator-is-non-expert ""
   (declare (salience 10))
   (investigator is non-expert)
   =>
   (assert (configuration needed))
)

(defrule tool-configuration-status ""
   (declare (salience 5))
   (configuration needed)
   =>
   (printout t "Required tools will be configured/parameterize" crlf)
   (printout t "when needed by AUDIT." crlf)
   (assert (run tsk_recover for allocated-space))
   (assert (run tsk_recover for unallocated-space))
   (assert (run blkls for slack-space))
   (assert (run scalpel for data-carving))
   (assert (configure scalpel for graphic-files))
   (assert (configure scalpel for document-files))
   (assert (configure mmc for smart-carving))
)

;;;********************************************************
;;;* TOOL INTEGRATION RULES *
;;;********************************************************



;;;********************************************************
;;; ANALYSES RULES ****************************************
;;;********************************************************

(defrule data-carving-analysis-rule "Data carving is performed"
    ?f2<-(evidence found no)
    ;(run scalpel for data-carving)
    ?fcarving<-(start data carver)
    ;(tsk-recover is unsuccessful)
    (unallocated space analyzed)
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    (search type  is ?*searchType*)
    =>
    (printout t crlf)
    (printout t "================================" crlf)
    (printout t "========= DATA CARVING =========" crlf)
    (printout t "================================" crlf)
        
    (run_scalpel ?imagePath ?outputPath ?*searchType*)
    
    (retract ?fcarving)
            
)
 
(defrule allocated-space-analysis-rule "Allocated space analysis is performed"
    ?falloc<-(start allocated space analysis)
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    (search type  is ?*searchType*) ; this will be used for database connection
    =>
    (printout t crlf)
    (printout t "================================" crlf)
    (printout t "=== ALLOCATED SPACE ANALYSIS ===" crlf)
    (printout t "================================" crlf)

    ;;call function for allocated space analysis by tsk_recover
    (run_tsk_recover "-a" ?imagePath ?outputPath)    
    
    (retract ?falloc) ; remove the analysis fact
    
    (printout t crlf)
)

(defrule unallocated-space-analysis-rule "Unallocated space analysis is performed"
    ?f1<-(evidence found no)
    ?funalloc<-(start unallocated space analysis)
    (or (allocated space analyzed) (allocated space not needed))
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    (search type  is ?*searchType*)
    =>
    (printout t crlf)
    (printout t "================================" crlf)    
    (printout t "== UNALLOCATED SPACE ANALYSIS ==" crlf)
    (printout t "================================" crlf)
        
    ;;call function for allocated space analysis by tsk_recover
    (run_tsk_recover "  " ?imagePath ?outputPath) 
    
    (retract ?funalloc)

)

(defrule slack-space-analysis-rule "Slack space analysis is performed"
    ;?f2<-(evidence found no)
    ?fslack<-(start slack space carver)
    ;(unallocated space analyzed)
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    (search type  is ?*searchType*)
    =>
    (printout t crlf)
    (printout t "================================" crlf)
    (printout t "===== SLACK SPACE ANALYSIS =====" crlf)
    (printout t "================================" crlf)
       
    (retract ?fslack)
   
    (run_blkls ?imagePath ?outputPath)
    
    (printout t crlf)
)

(defrule disk-mounting-rule "Disk mounting is performed"
    ?fmounting<-(start disk mounting)
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    =>
    (printout t crlf)
    (printout t "================================" crlf)
    (printout t "========= DISK MOUNTING ========" crlf)
    (printout t "================================" crlf)
        
    ;mounting for free space
    (system mkdir (str-cat ?outputPath "/mnt"))
    (my-system-mount gksudo mount ?imagePath (str-cat ?outputPath "/mnt"))
    ;(printout t "Mounting will be done here! " crlf)
    (retract ?fmounting)  
    (assert (disk mounting done))
    
)

(defrule find-cc-and-ssn "Search for CC and SSNs"
    ;?f1<-(start disk mounting)
    (output-path is ?outputPath)
    (allocated space analyzed)
    (unallocated space analyzed)
    (data carving done)
    (disk mounting done)
    (slack space analyzed)
    =>
    
    (run_find_ssns ?outputPath)
    
    (my-system-mount gksudo umount (str-cat ?outputPath "/mnt") "")
    (assert (disk unmounting done))
 
)

;;;********************************************************
;;; RULES FOR CHECKING EVIDENCE *************************** 
;;;********************************************************

(defrule is-document-evidence-found "Document Search Evidence found or not"
    (search type  is 1)
    (output-path is ?outputPath)
    (allocated space analyzed)
    (unallocated space analyzed)
    (data carving done)
    =>
    (system nautilus ?outputPath)	;open directory
    (gui-response "Any evidence found for your DOCUMENT file investigation (yes/no)?")
)

(defrule is-graphic-evidence-found "Graphic Search Evidence found or not"
    (search type  is 2)
    (output-path is ?outputPath)
    (allocated space analyzed)
    (unallocated space analyzed)
    (data carving done)
    =>
    (system nautilus ?outputPath)	;open directory
    (gui-response "Any evidence found for your GRAPHIC file investigation (yes/no)?")
)

(defrule is-ssn-evidence-found "SSN or CC Number Search Evidence found or not"
    (search type  is 3)
    (output-path is ?outputPath)
    (allocated space analyzed)
    (unallocated space analyzed)
    (data carving done)
    (disk mounting done)
    (disk unmounting done)
    (slack space analyzed)
    =>
    (system nautilus ?outputPath)	;open directory
    (gui-response "Any evidence found for your SSN/CC NUMBER investigation (yes/no)?")
)

(defrule is-email-evidence-found "Email Search Evidence found or not"
    (search type  is 4)
    (output-path is ?outputPath)
    (slack space analyzed)
    =>
    (system nautilus ?outputPath)	;open directory
    (gui-response "Any evidence found for your EMAIL investigation (yes/no)?")
)

;;;********************************************************
;;; USER SELECTED SEARCH TYPES **************************** 
;;;********************************************************

(defrule graphic-file-search "Graphic file search"
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    ?falloc<-(investigation-type is graphSearch)
    =>
    (printout t crlf)
    (printout t "================================" crlf)
    (printout t "===== Graphic Files Search =====" crlf)
    (printout t "================================" crlf)
    
    (assert (search type  is ?*searchType*))
    
    (assert (start allocated space analysis))
    (assert (start unallocated space analysis))
    (assert (start data carver))
    ; we may want to run photo_rec for graphic files recovery
    
    ;(retract ?falloc) ; get rid of the search type     
)

(defrule document-file-search "Document file search"
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    ?falloc<-(investigation-type is docSearch)
    =>
    (printout t crlf)
    (printout t "================================" crlf)
    (printout t "====  Document Files Search ====" crlf)
    (printout t "================================" crlf)
    
    (assert (search type  is ?*searchType*))
    
    (assert (start allocated space analysis))
    (assert (start unallocated space analysis))
    (assert (start data carver))
    ;(printout t (facts))
    ;(retract ?falloc) ; get rid of the search type
)

(defrule ccn-ssn-search "Credit card and SSN search"
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    ?falloc<-(investigation-type is ccSearch)
    =>
    (printout t crlf)
    (printout t "================================" crlf)
    (printout t "=== Credit Card & SSN Search ===" crlf)
    (printout t "================================" crlf)
    (printout t crlf "Find_SSNs is run on given disk image for sensitive numbers!" crlf )
    
    (printout t "The following areas on the disk will be analyzed:" crlf)
    (printout t "-> User created and used files and directories from obvious spaces," crlf)
    (printout t "-> User created and later deleted files from inconvenient spaces," crlf)
    (printout t "-> Deleted and only text containing files from whole disk," crlf)
    (printout t "-> Intentionally and technically hidden files from hidden areas." crlf crlf)
            
    (printout t crlf "Find_SSNs is run on given disk image!" crlf )
    
    (assert (search type  is ?*searchType*))
    
    (assert (start disk mounting))
    (assert (start allocated space analysis))
    (assert (start unallocated space analysis))
    (assert (start data carver))
    (assert (start slack space carver))
    
    ;(assert (allocated space not needed))
	
    ;(retract ?falloc) ; get rid of the search type
)

(defrule email-address-search "Email address search"
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    ?falloc<-(investigation-type is emailSearch)
    =>
    (printout t crlf)
    (printout t "================================" crlf)
    (printout t "=====  Email Address Search ====" crlf)
    (printout t "================================" crlf)
    
    (assert (search type  is ?*searchType*))
    (assert (start slack space carver))
        
    ;(retract ?falloc) ; get rid of the search type
)


;;;********************************************************
;; INVESTIGATION TYPE RULES *******************************
;;;********************************************************

(defrule determine-investigation-type ""
    (declare (salience 10))
    (not (investigation-type is ?))
    (configuration needed)
    =>
    (printout t crlf)
    
    (printout t "input file path - >> " ?input crlf)
    (assert (image-file-path is ?input))   
        
    (printout t "Output dir path - >> " ?output crlf)
     
    (assert (output-path is ?output))
    (printout t "" crlf)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (bind ?*searchType* ?response)
    
	(if (eq ?*searchType* 1) 
    then
	   	(assert (investigation-type is docSearch))
	   	(assert (recommend "Document file search will be performed!"))
  	else (if (eq ?*searchType* 2) 
         then 
			(assert (investigation-type is graphSearch))
			(assert (recommend "Graphic file search will be performed!"))
		 else (if (eq ?*searchType* 3) 
              then
				  (assert (investigation-type is ccSearch))
				  (assert (recommend "Credit card number search will be performed!"))
	          else (if (eq ?*searchType* 4) 
	               then
					  (assert (investigation-type is emailSearch))
					  (assert (recommend "Email search will be performed!"))
	       		   else
	       			  (printout t "Something is wrong" crlf)))))
    
    (assert (evidence found no)) ; start investigation w/o any evidence found
)

;;;********************************************************
;;;* STARTUP, EXIT AND RECOMMEND RULES *
;;;********************************************************

(defrule system-banner ""
  	(declare (salience 15))
  	=>
  	(printout t crlf crlf)
  	(printout t "* * * * * * * * * *   AUDIT  * * * * * * * * * * *" crlf crlf)
  	(printout t "* Automated Disk Forensics Investigation Toolkit *" crlf crlf)
  	(printout t "* * * * * * * * * * * * * * * * * * * * * * * * **" crlf crlf)
)

(defrule print-recommendation ""
  (declare (salience 15))
   ?f <-(recommend ?item)
  =>
  (printout t crlf crlf)
  (format t " %s%n%n%n" ?item)
  (retract ?f)
)

(defrule exit-clips-success ""
  (declare (salience -10))
  (clips-exit success on)
  =>
  (printout t crlf "===== HAPPY INVESTIGATION =====!" crlf crlf)
  
  (printout t (facts) crlf) 
    
  (run_gui "Would you like to start a new investigation (yes/no)? ")
    
    (while (= ?*yesORno* 0) 
       (bind ?dummy 0)
    ) ; infinite loop until gets response from user
    
    (if (= ?*yesORno* 1)
	then 
		(printout t crlf crlf "================================" crlf)
        (printout t "======= PROGRAM RESTARTED ======" crlf)
        (printout t "================================" crlf)
	else
        (printout t crlf crlf "================================" crlf)
        (printout t "====== PROGRAM TERMINATED ======" crlf)
        (printout t "================================" crlf)
		(exit)
	)
    (bind ?*yesORno* 0) ; reset it for next time
)

(defrule exit-clips-failure ""
  (declare (salience -10))
  (clips-exit failure on )
  =>
  (printout t crlf "No evidence found during all the processes!" crlf crlf)
  
  (printout t (facts) crlf)
    
  (run_gui "Would you like to start a new investigation (yes/no)? ")
    
    (while (= ?*yesORno* 0) 
       (bind ?dummy 0)
    ) ; infinite loop until gets response from user
    
    (if (= ?*yesORno* 1)
	then 
		(printout t crlf crlf "================================" crlf)
        (printout t "======= PROGRAM RESTARTED ======" crlf)
        (printout t "================================" crlf)
	else
        (printout t crlf crlf "================================" crlf)
        (printout t "====== PROGRAM TERMINATED ======" crlf)
        (printout t "================================" crlf)
		(exit)
	)
    (bind ?*yesORno* 0) ; reset it for next time
)

(run)

;;;********************************************************
;;;********************************************************


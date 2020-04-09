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
       else FALSE))

(deffunction run_tsk_recover (?parameter ?imagePath ?outputPath)
    (if (eq ?parameter "-a")
        then 
        	(printout t crlf "tsk_recover is run on File System Allocated Space!" crlf )
            (system tsk_recover ?parameter ?imagePath (str-cat ?outputPath "/tsk_recover/allocated/"))
            (assert (allocated space analyzed))
            (system nautilus (str-cat ?outputPath "/tsk_recover/allocated/"))
        else 
        (if (eq ?parameter "-e")
			then
				(printout t crlf "tsk_recover is run on File System Allocated and Unallocated Space!" crlf )
				(system tsk_recover ?parameter ?imagePath (str-cat ?outputPath "/tsk_recover/bothAllocUnalloc/"))
				(assert (bothAllocUnalloc space analyzed))
				(system nautilus (str-cat ?outputPath "/tsk_recover/bothAllocUnalloc/"))
			else ; it's an empty parameter for unallocated space
				(printout t crlf "tsk_recover is run on File System Unallocated Space!" crlf )
				(system tsk_recover ?imagePath (str-cat ?outputPath "/tsk_recover/unallocated/"))
				(assert (unallocated space analyzed))
				(system nautilus (str-cat ?outputPath "/tsk_recover/unallocated/"))
    	)
    )
)
       	   
(deffunction run_scalpel (?imagePath ?outputPath ?configuration) 
    
        (printout t "in callee ------ " ?imagePath "  " ?outputPath "  " ?configuration crlf crlf)
    
    (if (eq ?configuration "graphic")
        then 
        	(printout t crlf "Scalpel is run to perform data carving for graphics!" crlf )
        	(system scalpel ?imagePath "-o" (str-cat ?outputPath "/scalpelOut") "-c" "/etc/scalpel/scalpel_graphic.conf")
        	(assert (data carving done))
        	(system nautilus (str-cat ?outputPath "/scalpelOut"))
        else 
        	(printout t crlf "Scalpel is run to perform data carving for documents!" crlf )
			(system scalpel ?imagePath "-o" (str-cat ?outputPath "/scalpelOut") "-c" "/etc/scalpel/scalpel_documents.conf")
        	(assert (data carving done))
			(system nautilus (str-cat ?outputPath "/scalpelOut"))    	
    )
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
   (assert (configure mmc for smart-carving))
)


;;;********************************************************
;;;* TOOL INTEGRATION RULES *
;;;********************************************************

(deftemplate image-file-path
    "Auto-generated"
    (declare (ordered TRUE)))

(deftemplate output-path
    "Auto-generated"
    (declare (ordered TRUE)))

(defrule file-system-allocated-analysis ""
    ?falloc<-(run tsk_recover for allocated-space)
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    (investigation-type is docSearch)
    =>
    
    (printout t crlf)
    (printout t "================================" crlf)
    (printout t "=== ALLOCATED SPACE ANALYSIS ===" crlf)
    (printout t "================================" crlf)

    ;;call function for allocated space analysis by tsk_recover
    (run_tsk_recover "-a" ?imagePath ?outputPath)    
    
    (retract ?falloc)
    (printout t crlf)
    (if (yes-or-no-p "Is there any interesting file for your investigation (yes/no)? ") 
    then 
        (assert (evidence found yes))
        (assert (recommend "Evidence is found, good by!!"))
	    (assert (clips-exit success on))
    else
	    (printout t crlf)
        (assert (evidence found no))
    )
)

(defrule file-system-unallocated-analysis ""
    ?f1<-(evidence found no)
    ?funalloc<-(run tsk_recover for unallocated-space)
    (allocated space analyzed)
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    (investigation-type is docSearch)
    =>
    (printout t crlf)
    (printout t "================================" crlf)    
    (printout t "== UNALLOCATED SPACE ANALYSIS ==" crlf)
    (printout t "================================" crlf)
        
    ;;call function for allocated space analysis by tsk_recover
    (run_tsk_recover "  " ?imagePath ?outputPath) 
    
    (retract ?funalloc)
    
    (printout t crlf)

    (if (yes-or-no-p "Is there any interesting file for your investigation (yes/no)? ") 
    then 
      (assert (evidence found yes))
      (assert (recommend "Evidence is found, good by!!"))
      (retract ?f1)
      (assert (clips-exit success on))
      (assert (tsk-recover is successful))
    else
      (assert (tsk-recover is unsuccessful))
      (printout t crlf)
    )
)


(defrule data-carving-analysis ""
    ?f2<-(evidence found no)
    ?fcarving<-(run scalpel for data-carving)
    (tsk-recover is unsuccessful)
    (unallocated space analyzed)
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    (investigation-type is docSearch)
    =>
    (printout t crlf)
    (printout t "================================" crlf)
    (printout t "========= DATA CARVING =========" crlf)
    (printout t "================================" crlf)
    
    (printout t "in caller ------ " ?imagePath "  " ?outputPath crlf crlf)
    
    (run_scalpel ?imagePath ?outputPath "graphic")
    
    (retract ?fcarving)
    
    (printout t "Files are carved to " ?outputPath "/scalpelOut/" crlf crlf)
    
    (if (yes-or-no-p "Is there any interesting file for your investigation (yes/no)? ") 
    then 
        (assert (evidence found yes))
        (assert (recommend "Evidence is found, good by!!"))
        (retract ?f2)
	(assert (clips-exit success on))
    else
	(printout t crlf)
	(assert (clips-exit failure on))
    )
)

(defrule slack-space-analysis ""
    ?f2<-(evidence found no)
    ?fslack<-(run blkls for slack-space)
    (unallocated space analyzed)
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    (investigation-type is docSearch)
    =>
    (printout t crlf)
    (printout t "================================" crlf)
    (printout t "===== SLACK SPACE ANALYSIS =====" crlf)
    (printout t "================================" crlf)
    (printout t crlf "blkls is run to extract the Slack Space!" crlf)
    ;(system mkdir ?outputPath ""/slackSpace/")
    
	(system mkdir (str-cat ?outputPath "/slackSpace/"))
        
    (system blkls -s ?imagePath  > (str-cat ?outputPath "/slackSpace/slack.dd"))
    (assert (slack space analyzed))
    (retract ?fslack)
    (printout t "Slack space is extracted to " ?outputPath "/slackSpace/slack.dd" crlf crlf)
    
    (if (yes-or-no-p "Would you like to run a HEX editor on slack space (yes/no)? ") 
    then 
    	(printout t crlf "*** Please follow the steps below to search for a keyword on slack space!!! ***" crlf)
    	(printout t crlf "	   1- Right click on the dots on the RHS of HEX editor" crlf)
    	(printout t crlf "	   2- Type Ctrl+F " crlf)
    	(printout t crlf "	   3- Type the keyword will be searched on text box shown on the bottom" crlf)
    	(printout t crlf "	   4- Click on the bottom says Hexadecimal, then choose Text option" crlf)
    	(printout t crlf "	   5- Press Enter to start the search" crlf crlf)
    	(system "bless " ?outputPath "/slackSpace/slack.dd")    
    )
    (printout t crlf)
    (if (yes-or-no-p "Is there any interesting file for your investigation (yes/no)? ") 
    then 
        (assert (evidence found yes))
        (assert (recommend "Evidence is found, good by!!"))
        (retract ?f2)
	(assert (clips-exit success on))
    else
	(printout t crlf)
	(assert (clips-exit failure on))
    )
)


(defrule credit-card-search ""
    (image-file-path is ?imagePath)
    (output-path is ?outputPath)
    (investigation-type is ccSearch)
    =>
    (printout t crlf)
    (printout t "================================" crlf)
    (printout t "=== Credit Card & SSN Search ===" crlf)
    (printout t "================================" crlf)
    (printout t crlf "Find_SSNs is run on given disk image for sensitive numbers!" crlf )
    
    (printout t "The following areas on the disk will be analyzed:" crlf)
    (printout t "    User created and used files and directories from obvious spaces," crlf)
    (printout t "    User created and later deleted files from inconvenient spaces," crlf)
    (printout t "    Deleted and only text containing files from whole disk," crlf)
    (printout t "    Intentionally and technically hidden files from hidden areas." crlf crlf)
    
        
    (printout t crlf "Find_SSNs is run on given disk image!" crlf )
    (system mkdir (str-cat ?outputPath "/mnt/"))
    (system mkdir (str-cat ?outputPath "/mnt/image/"))
    (system sudo mount ?imagePath (str-cat ?outputPath "/mnt/image/"))
    ;(system "python /home/utk/Desktop/find_ssns_source/Find_SSNs.pyw -p " ?outputPath "/mnt/image -o "  ?outputPath  " -t html -a")
    
    (printout t crlf "blkls is run to extract the Slack Space!" crlf)
    (system mkdir (str-cat ?outputPath "/mnt/slackSpace/"))
    (system blkls -s ?imagePath > (str-cat ?outputPath "/mnt/slack.dd"))
    (system strings -1 (str-cat ?outputPath "/mnt/slack.dd > " ?outputPath "/mnt/slackSpace/dataInSlack.txt"))
    ;(system "python /home/utk/Desktop/find_ssns_source/Find_SSNs.pyw -p " ?outputPath "/slack_space -o "  ?outputPath  "/slack_space -t html -a")    
    
    ;;;;;;;;;;Files from Unallocated space
    (system mkdir (str-cat ?outputPath "/mnt/unallocated/"))
    (system tsk_recover (str-cat ?imagePath " " ?outputPath "/mnt/unallocated/")) 
    
    ;;;;;;;;;;Files from Unallocated space
    (system mkdir (str-cat ?outputPath "/mnt/carvedFiles/"))
    (printout t crlf crlf "Scalpel is run to perform data carving!" crlf )
    (system scalpel (str-cat ?imagePath " -o " ?outputPath "/mnt/carvedFiles/ -c /etc/scalpel/s_docs.conf"))
    
    ; -a can be replaced by -s or -c for SSN or CC search only
    (system python (str-cat "/home/utk/Desktop/find_ssns_source/Find_SSNs.pyw -p " ?outputPath "/mnt -o "  ?outputPath  " -t html -a"))
    
    (assert (ccSearch performed))
    (system nautilus ?outputPath)
    (printout t crlf)
    (if (yes-or-no-p "Is evidence found (yes/no)? ") 
    then 
        (assert (evidence found yes))
        (assert (recommend "Evidence is found, good by!!"))
	(assert (clips-exit success on))
    else
	(printout t crlf)
	(assert (clips-exit failure on))
    )
)

;;;********************************************************
;;; NEW RULES DESIGNED HERE
;;;********************************************************


;;;********************************************************
;; INVESTIGATION TYPE RULES*
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
    
	(if (eq ?response 1) 
    then
	   	(assert (investigation-type is docSearch))
	   	(assert (recommend "Document file search will be performed!"))
  	else (if (eq ?response 2) 
         then 
			(assert (investigation-type is graphSearch))
			(assert (recommend "Graphic file search will be performed!"))
		 else (if (eq ?response 3) 
              then
				  (assert (investigation-type is ccSearch))
				  (assert (recommend "Credit card number search will be performed!"))
	          else (if (eq ?response 4) 
	               then
					  (assert (investigation-type is emailSearch))
					  (assert (recommend "Email search will be performed!"))
	       		   else
	       			  (printout t "Something is wrong" crlf)))))
    
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
  (if (yes-or-no-p "Would you like to start a new investigation (yes/no)? ") 
      then 
          (reset)
	      (run)
		  (printout t crlf crlf "========================================================================" crlf)
          (printout t  "=========================== PROGRAM RESTARTED ==========================" crlf)
          (printout t  "========================================================================" crlf)
      else 
          (exit)
  )
)

(defrule exit-clips-failure ""
  (declare (salience -10))
  (clips-exit failure on )
  =>
  (printout t crlf "No evidence found during all the processes!" crlf crlf)
  
  (if (yes-or-no-p "Would you like to start a new investigation (yes/no)? ") 
      then 
      	  (reset)
	      (run)
		  (printout t crlf crlf "========================================================================" crlf)
          (printout t  "=========================== PROGRAM RESTARTED ==========================" crlf)
          (printout t  "========================================================================" crlf)
      else 
          (exit)
  )
)

(run)

;;;********************************************************
;;;********************************************************


(deftemplate tools 
	(slot ident (type STRING))
	(slot toolname (type STRING))
	(slot task (type STRING))
	(slot parameters (type STRING))
    (slot input (type STRING))
	(slot output (type STRING))
	(slot config (type STRING)))	
						
						
(deftemplate knowledge
	(slot ident (type STRING))
	(slot usertype (type STRING))
	(slot fact (type STRING))
	(slot emp (type INTEGER)))
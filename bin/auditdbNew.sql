DROP TABLE IF EXISTS KNOWLEDGE, TOOLS;

CREATE TABLE IF NOT EXISTS KNOWLEDGE (
    ident VARCHAR(20) NOT NULL PRIMARY KEY,
    usertype VARCHAR(50),
    fact VARCHAR(50),
    emp INT
)ENGINE=InnoDB;

INSERT INTO KNOWLEDGE(ident,usertype,fact,emp) VALUES('confnonex','nonexpert','Configuration Needed',1);
INSERT INTO KNOWLEDGE(ident,usertype,fact,emp) VALUES('runtskalloc','nonexpert','run tsk_recover for allocated space',1);
INSERT INTO KNOWLEDGE(ident,usertype,fact,emp) VALUES('runtskunalloc','nonexpert','run tsk_recover for unallocated space',1);
INSERT INTO KNOWLEDGE(ident,usertype,fact,emp) VALUES('runblklsslack','nonexpert','run blkls for slack space',1);
INSERT INTO KNOWLEDGE(ident,usertype,fact,emp) VALUES('runscalpeldc','nonexpert','run scalpel for data-carving',1);
INSERT INTO KNOWLEDGE(ident,usertype,fact,emp) VALUES('confex','expert','Configuration Needed',1);


CREATE TABLE IF NOT EXISTS TOOLS (
    ident VARCHAR(20) NOT NULL PRIMARY KEY,
    toolname VARCHAR(50),
    task VARCHAR(50),
    params VARCHAR(10),
	p_in VARCHAR(5),
    input VARCHAR(50),
	p_out VARCHAR(5),
    output VARCHAR(50),
	p_conf VARCHAR(5),
    config VARCHAR(50),
	S INTEGER(10),
	F INTEGER(10),
	R FLOAT(10)
)ENGINE=InnoDB;

INSERT INTO TOOLS(ident,toolname,task,params,p_in,input,p_out,output,p_conf,config,S,F,R) 
VALUES('tskRecAlloc','tsk_recover','allocated_space_recovery','-a ','','?imagePath','','?outputPath','','','0','0','0.0');

INSERT INTO TOOLS(ident,toolname,task,params,p_in,input,p_out,output,p_conf,config,S,F,R) 
VALUES('tskRecUnalloc','tsk_recover','unallocated_space_recovery',' ','','?imagePath','','?outputPath','','','0','0','0.0');

INSERT INTO TOOLS(ident,toolname,task,params,p_in,input,p_out,output,p_conf,config,S,F,R) 
VALUES('tskRecBoth','tsk_recover','alloc/unalloc space recovery','-e ','','?imagePath','','?outputPath','','','0','0','0.0');

INSERT INTO TOOLS(ident,toolname,task,params,p_in,input,p_out,output,p_conf,config,S,F,R) 
VALUES('scalGraphCarver','scalpel','graphic_file_carving',' ','-i','?imagePath','-o','?outputPath','-c','/etc/scalpel/graphic.conf','0','0','0.0');

INSERT INTO TOOLS(ident,toolname,task,params,p_in,input,p_out,output,p_conf,config,S,F,R) 
VALUES('scalDocsCarver','scalpel','document_file_carving',' ','-i','?imagePath','-o','?outputPath','-c','/etc/scalpel/document.conf','0','0','0.0');

INSERT INTO TOOLS(ident,toolname,task,params,p_in,input,p_out,output,p_conf,config,S,F,R) 
VALUES('findSsnCC','FindSSNs','credit_card_number_search','-s ','','?imagePath','','?outputPath','','','0','0','0.0');

INSERT INTO TOOLS(ident,toolname,task,params,p_in,input,p_out,output,p_conf,config,S,F,R) 
VALUES('findSsnSSN','FindSSNs','ssn_search','-c ','','?imagePath','','?outputPath','','','0','0','0.0');

INSERT INTO TOOLS(ident,toolname,task,params,p_in,input,p_out,output,p_conf,config,S,F,R) 
VALUES('blklsSlack','blkls','recovering_slack_space','-s ','','?imagePath','>','slackArea.dd','','','0','0','0.0');

INSERT INTO TOOLS(ident,toolname,task,params,p_in,input,p_out,output,p_conf,config,S,F,R) 
VALUES('mmcCarver','mmc','fragmented_file_carving',' ','','','','','','','0','0','0.0');

INSERT INTO TOOLS(ident,toolname,task,params,p_in,input,p_out,output,p_conf,config,S,F,R) 
VALUES('mmlsLayout','mmls','disk_volume_layout',' ','','?imagePath','>','layout.txt','','','0','0','0.0');

INSERT INTO TOOLS(ident,toolname,task,params,p_in,input,p_out,output,p_conf,config,S,F,R) 
VALUES('foreGraphCarver','foremost','graphic_file_carving',' ','-i','?imagePath','-o','?outputPath','-c','/etc/foremost_graphic.conf','0','0','0.0' );



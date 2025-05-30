# @(#)makefile.suite	2.1.8.1
################
## CHANGE NAME OF ANSI COMPILER HERE
################
# Current values for DATABASE are: INFORMIX, DB2, TDAT (Teradata)
#                                  SQLSERVER, SYBASE
# Current values for MACHINE are:  ATT, DOS, HP, IBM, ICL, MVS, 
#                                  SGI, SUN, U2200, VMS, LINUX
# Current values for WORKLOAD are:  SSBM, TPCH, TPCR
DATABASE=DB2 
MACHINE =LINUX
WORKLOAD =SSBM 
#
# add -EDTERABYTE if orderkey will execeed 32 bits (SF >= 300)
# and make the appropriate change in gen_schema() of runit.sh
CFLAGS	= -O -DDBNAME=\"dss\" -D$(MACHINE) -D$(DATABASE) -D$(WORKLOAD)
LDFLAGS = -O
# The OBJ,EXE and LIB macros will need to be changed for compilation under
#  Windows NT
OBJ     = .o
EXE     =
LIBS    = -lm
#
# NO CHANGES SHOULD BE NECESSARY BELOW THIS LINE
###############
TREE_ROOT=/tmp/tree
#
PROG1 = dbgen$(EXE)
PROG2 = qgen$(EXE)
PROGS = $(PROG1) $(PROG2)
#
HDR1 = dss.h rnd.h config.h dsstypes.h shared.h bcd2.h
HDR2 = tpcd.h permute.h
HDR  = $(HDR1) $(HDR2)
#
SRC1 = build.c driver.c bm_utils.c rnd.c print.c load_stub.c bcd2.c \
	speed_seed.c text.c permute.c
SRC2 = qgen.c varsub.c 
SRC  = $(SRC1) $(SRC2)
#
OBJ1 = build$(OBJ) driver$(OBJ) bm_utils$(OBJ) rnd$(OBJ) print$(OBJ) \
	load_stub$(OBJ) bcd2$(OBJ) speed_seed$(OBJ) text$(OBJ) permute$(OBJ)
OBJ2 = build$(OBJ) bm_utils$(OBJ) qgen$(OBJ) rnd$(OBJ) varsub$(OBJ) \
	text$(OBJ) bcd2$(OBJ) permute$(OBJ) speed_seed$(OBJ)
OBJS = $(OBJ1) $(OBJ2)
#
SETS = dists.dss 
DOC=README HISTORY PORTING.NOTES BUGS
DDL  = dss.ddl dss.ri
OTHER=makefile.suite $(SETS) $(DDL) 
# case is *important* in TEST_RES
TEST_RES = O.res L.res c.res s.res P.res S.res n.res r.res
#
DBGENSRC=$(SRC1) $(HDR1) $(OTHER) $(DOC) $(SRC2) $(HDR2) $(SRC3)
QD=1.sql 2.sql 3.sql 4.sql 5.sql 6.sql 7.sql 8.sql 9.sql 10.sql \
	11.sql 12.sql 13.sql 14.sql 15.sql 16.sql 17.sql 18.sql \
	19.sql 20.sql 21.sql 22.sql
VARIANTS= 8a.sql 12a.sql 13a.sql 14a.sql 15a.sql 
ANS   = 1.ans 2.ans 3.ans 4.ans 5.ans 6.ans 7.ans 8.ans 9.ans 10.ans 11.ans \
	12.ans 13.ans 14.ans 15.ans 16.ans 17.ans 18.ans 19.ans 20.ans \
	21.ans 22.ans
QSRC  = $(FQD) $(VARIANTS)
ALLSRC=$(DBGENSRC) 
TREE_DOC=tree.readme tree.changes appendix.readme appendix.version answers.readme queries.readme variants.readme
JUNK  = 
#
all: $(PROGS)
$(PROG1): $(OBJ1) $(SETS) 
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJ1) $(LIBS)
$(PROG2): permute.h $(OBJ2) 
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJ2) $(LIBS)
clean:
	rm -f $(PROGS) $(OBJS) $(JUNK)
lint:
	lint $(CFLAGS) -u -x -wO -Ma -p $(SRC1)
	lint $(CFLAGS) -u -x -wO -Ma -p $(SRC2)

tar: $(DBGENSRC) 
	tar cvhf $(PROG1).tar $(DBGENSRC) 
dbgenshar: $(DBGENSRC)
	shar -o dbgen.shar $(DBGENSRC)
zip: $(DBGENSRC)
	zip dbgen $(DBGENSRC)
tree: $(DBGENSRC) $(FQD) $(VARIANTS) $(TREE_DOC) $(ANS)
	rm -rf $(TREE_ROOT)
	mkdir $(TREE_ROOT) 
	mkdir $(TREE_ROOT)/appendix 
	mkdir $(TREE_ROOT)/appendix/queries 
	mkdir $(TREE_ROOT)/appendix/variants 
	mkdir $(TREE_ROOT)/appendix/dbgen 
	mkdir $(TREE_ROOT)/appendix/answers 
	cp tree.readme $(TREE_ROOT)/README
	cp appendix.readme $(TREE_ROOT)/appendix/README
	cp answers.readme $(TREE_ROOT)/appendix/answers/README
	cp queries.readme $(TREE_ROOT)/appendix/queries/README
	cp variants.readme $(TREE_ROOT)/appendix/variants/README
	cp tree.changes $(TREE_ROOT)/CHANGES
	cp appendix.version $(TREE_ROOT)/appendix/VERSION
	cp $(FQD) $(TREE_ROOT)/appendix/queries
	cp $(VARIANTS) $(TREE_ROOT)/appendix/variants
	cp $(DBGENSRC) $(TREE_ROOT)/appendix/dbgen
	cp $(ANS) $(TREE_ROOT)/appendix/answers
	(cd $(TREE_ROOT); tar chf - .) |compress > tree.tar.Z
	(cd $(TREE_ROOT); zip -r  - . )  > tree.zip
	date > tree.update
portable:
	@ for f in $(SRC) $(HDR) ; \
	do  \
	expand $$f > /tmp/$$f; \
	awk 'length > 72 { print FILENAME ":" NR " too long " }' /tmp/$$f ; \
        rm /tmp/$$f ; \
	done
release:
	@chkout $(SRC) $(HDR)
	@ for f in $(SRC) $(HDR) ; \
		do \
		expand $$f > /tmp/$$f ; \
		mv /tmp/$$f $$f ; \
		done
	@chkin $(SRC) $(HDR)

rnd$(OBJ): rnd.h
$(OBJ1): $(HDR1)
$(OBJ2): dss.h tpcd.h config.h
$(QSRC) $(ALLSRC): 
	get -r`cat .version` ./SCCS/s.$@

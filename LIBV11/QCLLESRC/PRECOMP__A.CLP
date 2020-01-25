             PGM        PARM(&OBJ &LIB &SRCFIL &SRCLIB &CPLTYP)
             DCL        VAR(&OBJ) TYPE(*CHAR) LEN(10)
             DCL        VAR(&LIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&TGTLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&SRCFIL) TYPE(*CHAR) LEN(10)
             DCL        VAR(&SRCLIB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&CPLTYP) TYPE(*CHAR) LEN(7)
             DCL        VAR(&OTTSFUNCT) TYPE(*CHAR) LEN(2) VALUE(' ')
             DCL        VAR(&RETCOD) TYPE(*CHAR) LEN(1) VALUE(' ')
             DCL        VAR(&NBACTIVE) TYPE(*DEC) LEN(5 0) VALUE(0)
             DCL        VAR(&APPID) TYPE(*CHAR) LEN(3)
             DCL        VAR(&CMD) TYPE(*CHAR) LEN(1000)
             DCL        VAR(&CMDSHORT) TYPE(*CHAR) LEN(50)
             DCL        VAR(&OTTSCMD) TYPE(*CHAR) LEN(500)
             CHGJOB     LOG(4 0 *SECLVL) LOGCLPGM(*YES)
             CHGVAR     VAR(&CMD) VALUE(%SST(*LDA 13 999))
             DSPDTAARA  DTAARA(*LDA) OUTPUT(*PRINT)
             RTVAPPID   LIB(&LIB) APPID(&APPID)
             MONMSG     MSGID(CPF0000)
             RTVAPPID   LIB(&SRCLIB) APPID(&APPID)
             MONMSG     MSGID(CPF0000)
             IF         COND(&OBJ = 'XXXXX' *OR &APPID *NE 'OXB') +
                          THEN(GOTO CMDLBL(FINEPROG))
             DSPOVR     OUTPUT(*PRINT)
             DSPOVR     LVL(*JOB) OUTPUT(*PRINT)
             RMVLIBLE   LIB(SET_CHANG)
             MONMSG CPF0000
             ADDLIBLE   LIB(SET_CHANG)
/* &NBACTIVE IS RETURNED NUMBER OF TIMES ARD003C0 IS PRESENT IN THE CALLING STACK */
             CHGVAR     VAR(&TGTLIB) VALUE(&LIB)
             CALL       PGM(ARC342R2) PARM('ARD003C0' '*PGM   ' &NBACTIVE)
             IF         COND(&NBACTIVE *NE 0) THEN(CHGVAR +
                          VAR(&TGTLIB) VALUE('QTEMP'))
             BRKMACCMD  MSG(&TGTLIB)
             CALL       PGM(OTTS) PARM(&TGTLIB &SRCFIL &OBJ &OTTSFUNCT &RETCOD)
             MONMSG     MSGID(CPF0000) EXEC(SNDPGMMSG MSGID(MSG0109) +
                          MSGF(ARMSGF) MSGTYPE(*ESCAPE))
             IF         COND(&RETCOD = 'N') THEN(SNDPGMMSG +
                          MSGID(MSG0109) MSGF(ARMSGF) MSGTYPE(*ESCAPE))
             DSPOVR     OUTPUT(*PRINT)
             DSPOVR     LVL(*JOB) OUTPUT(*PRINT)
             CRTDUPOBJ  OBJ(ARCCPLF1) FROMLIB(ARCAD_PRD) +
                          OBJTYPE(*FILE) TOLIB(QTEMP) +
                          NEWOBJ(ARCSETECI) DATA(*YES)
             OVRDBF     FILE(ARCCPLF1) TOFILE(ARCSETECI) OVRSCOPE(*JOB)
             CHGCPLATR  APPID(OXB) CPLTYP(*RPGLE) +
                          CPLATR('TEXT(''ARCAD:TEXT:QTEMP:OVRDBF:PREC+
                          OMP'')')
             CHGDTAARA  DTAARA(*LDA (13 500)) VALUE('DSPLIBL +
                          OUTPUT(*PRINT)')
             CRTARSRCPF SRCPF(QTEMP/&SRCFIL) REFOBJ(&SRCLIB/&SRCFIL)
  /*         ARCAD_ENG/CPYSRCF FROMFILE(&SRCLIB/&SRCFIL) +
                          TOFILE(QTEMP/&SRCFIL) FROMMBR(&OBJ)     */
             CRTDTAARA  DTAARA(QTEMP/ARCCMPDT01) TYPE(*CHAR) +
                          LEN(500) VALUE('CRTBNDRPG +
                          PGM(OXBM100A02/CCG3DSESCM) +
                          SRCFILE(OXBM100A02/QRPGLESRC) +
                          DFTACTGRP(*NO) ACTGRP(*CALLER) +
                          BNDDIR(OCSSTD) OPTION(*XREF *SHOWCPY +
                          *EXPDDS *EXT *SRCSTMT *SHOWSKP) +
                          DBGVIEW(*ALL) OPTIMIZE(*FULL) +
                          CVTOPT(*DATETIME) TGTRLS(V6R1M0)')
             RTVDTAARA  DTAARA(QTEMP/ARCCMPDT01 *ALL) RTNVAR(&OTTSCMD)
             GENOVRATR  CMD(&OTTSCMD) SRCMBR(&OBJ) +
                          SRCFILE(&SRCLIB/&SRCFIL) CPLTYP(&CPLTYP) +
                          TOSRCFILE(QTEMP/&SRCFIL)
             CHGVAR     VAR(&SRCLIB) VALUE('QTEMP')
 FINEPROG:   ENDPGM

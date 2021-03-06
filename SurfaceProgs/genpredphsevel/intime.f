      SUBROUTINE  INTIME(START,SAVETM,WRETM,WRDATE,TMNAME,TIMEM)
C
C PURPOSE     TO COMPUTE AND WRITE ELAPSED TIME
C
C             THIS PROGRAM GETS THE TIME WHEN IT IS CALLED, SAVES THAT
C             TIME, COMPUTES AND WRITES OUT THE ELAPSED TIME BETWEEN
C             TWO CALLS.
C
C SUBROUTINE REQUIRED - TIMER
C
      INTEGER  TIMEM
      REAL     TMNAME(2)
C*    LOGICAL  START,SAVETM,WRETM,WRDATE,FIRST/.TRUE./
      LOGICAL  START,SAVETM,WRETM,WRDATE,FIRST
C*    INTEGER  DAYPMO(12)/31,28,31,30,31,30,31,31,30,31,30,31/
      INTEGER DAYPMO(12)
      DATA  DAYPMO/31,28,31,30,31,30,31,31,30,31,30,31/
      START=.TRUE.
      SAVETM=.TRUE.
      WRETM=.TRUE.
      WRDATE=.TRUE.
      FIRST=.TRUE.
C
C GET THE TIME
C
      CALL  TIMER(ITIME,IDATE)
C
C COMPUTE THE ELAPSED TIME
C
      IF(.NOT.START)  JTIME=ITIME-TIMEM
C
      IF(.NOT.WRETM.AND..NOT.WRDATE)  GO TO  45
C
C SPLIT THE DATE AND TIME
C
      IF(.NOT.FIRST)  GO TO  30
      FIRST=.FALSE.
      KYR=IDATE/1000
      IF(MOD(KYR,4).EQ.0.AND.KYR.NE.0)  DAYPMO(2)=29
      KDA=IDATE-KYR*1000
      KMO=1
C
      DO  20  I=1,12
      IF(KDA.LE.DAYPMO(I))  GO TO  30
      KDA=KDA-DAYPMO(I)
      KMO=KMO+1
   20 CONTINUE
C
   30 CONTINUE
      KMN1=ITIME-KHR*360000
      KMN=KMN1/6000
      SEC=(KMN1-KMN*6000)/100.
      KHR=ITIME/360000
C
C WRITE OUT TIME
C
C*    IF((WRDATE.AND..NOT.WRETM)
C*   1WRITE(6,35)  KMO,KDA,KYR,KHR,KMN,SEC
C* 35 FORMAT(1H ,100X,'DATE 'I2,'/'I2,'/'I2,' TIME 'I2,'/'I2,'/'F5.2)
C* 35 FORMAT(1H ,10X,'DATE ',I2,'/',I2,'/',I2,' TIME ',I2,'/',I2,'/',F5.2)
C
      IF(.NOT.WRETM)  GO TO  45
      ETIME=JTIME/100.
c      WRITE(6,40)  TMNAME,ETIME,KMO,KDA,KYR,KHR,KMN,SEC
C* 40 FORMAT(1H ,74X,1H',2A4,3H' =F7.2,4H SEC,3X,
C*   1       'DATE 'I2,'/'I2,'/'I2,' TIME 'I2,'/'I2,'/'F5.2)
   40 FORMAT(1h  ',74X,1H',2A4,3H' =,F7.2,4H SEC,3X,
     1       'DATE ',I2,'/',I2,'/',I2,' TIME ',I2,'/',I2,'/',F5.2)
C
C SAVE INITIAL OR CURRENT TIME IN TIMEM
C
   45 CONTINUE
      IF(SAVETM.OR.START)  TIMEM=ITIME
      IF(.NOT.START.OR..NOT.SAVETM)  GO TO  100
      IF(WRETM.OR.WRDATE)  GO TO  100
c      WRITE(6,50)  TMNAME
   50 FORMAT(1H ,100X,7HTIMER ',2A4,10H' STARTED.)
C
  100 CONTINUE
      RETURN
      END

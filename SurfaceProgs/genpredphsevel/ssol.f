      SUBROUTINE  SSOL(Y,AK,BK,R,RH,EL,EM,WN,FRQ)
      REAL*8  GAA,AK,BK,R,RR,RH,EL,EM,WN,WN2,FRQ,FRQ2,RVP,P,W,XA,
     1        F,H,PHI1,PHI2,PSI1,PSI2,X,Y
      DIMENSION  X(2),Y(6,3)
C
C      SOLUTION FOR HOMOGENEOUS SPHERE
C      SPHEROIDAL OSCILLATION
C      SUBROUTINE REQUIRED - SPHERF
C
      GAA=RH*27.93923E-8
      RVP   =EL+2.0D+0*EM
      P=RVP/RH
      WN2   =WN*(WN+1.0D+0)
      FRQ2=FRQ*FRQ
      RR=R*R
      W     =2.0D+0*WN+3.0D+0
      IF(EM.EQ.0.0)  GO TO  650
C
C      SOLID LAYER
C
      X(1)=AK
      X(2)=BK
      DO  610  NS=1,2
      XA=X(NS)*RR
      F=X(NS)*EM-FRQ2*RH
      H     =F-(WN+1.0D+0)*RH*GAA
      CALL  SPHERF(PHI1,PHI2,PSI1,PSI2,WN,XA,20)
      Y(1,NS)=-RR*(0.5D+0*WN*H*PSI1+F*PHI2)/W
      Y(2,NS)=R*(-WN*(WN-1.0D+0)*EM*H*PSI1/W-RVP*F*PHI1
     1       +2.0D+0*EM*(2.0D+0*F+WN2*RH*GAA)*PHI2/W)
      Y(3,NS)=RR*(-0.5D+0*H*PSI1+RH*GAA*PHI2)/W
      Y(4,NS)=R*EM*(-(WN-1.0D+0)*H*PSI1/W+RH*GAA*PHI1
     1       -2.0D+0*(F+RH*GAA)*PHI2/W)
      Y(5,NS)=R*(P*F-(WN+1.0D+0)*EM*GAA-1.5D+0*RR*F*GAA*PSI1/W)
      Y(6,NS)=(2.0D+0*WN+1.0D+0)*Y(5,NS)/R+1.5D+0*WN*RR*H*GAA*PSI1/W
  610 CONTINUE
C
      Y(1,3)=WN
      Y(3,3)=1.0D+0
      Y(4,3)=2.0D+0*(WN-1.0D+0)*EM/R
      Y(2,3)=WN*Y(4,3)
      Y(5,3)=R*(WN*GAA-FRQ2)
      Y(6,3)=2.0D+0*WN*(WN-1.0D+0)*GAA-(2.0D+0*WN+1.0D+0)*FRQ2
      GO TO  1000
C
C      LIQUID LAYER
C
  650 CONTINUE
      XA=AK*RR
      CALL  SPHERF(PHI1,PHI2,PSI1,PSI2,WN,XA,20)
      F=AK*EM-FRQ2*RH
      H     =F-(WN+1.0D+0)*RH*GAA
      Y(1,1)=-RR*(0.5D+0*WN*H*PSI1+F*PHI2)/W
      Y(2,1)=R*(-EL*F*PHI1)
      Y(3,1)=R*(P*F-1.5D+0*RR*F*GAA*PSI1/W)
      Y(4,1)=(2.0D+0*WN+1.0D+0)*Y(3,1)/R+1.5D+0*WN*RR*H*GAA*PSI1/W
C
      Y(1,2)=WN
      Y(2,2)=0.0
      Y(3,2)=R*(WN*GAA-FRQ2)
      Y(4,2)=2.0D+0*WN*(WN-1.0D+0)*GAA-(2.0D+0*WN+1.0D+0)*FRQ2
      GO TO  1000
C
C EXIT
C
 1000 CONTINUE
      RETURN
      END

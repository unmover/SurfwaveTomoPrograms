c  resvldanisoavgs.f  finds average anisocoefficients and standard deviations  
c  over specified depth ranges, assuming pre-determined ranges based on  
c  resolving length and covariance matrices already calculated.  
c  ./resvldanisoavgs < resvldanisoavg.inp
        real*4 bot(50),top(50),weight(50),covarcs(50,50),covarsn(50,50)
	real*4 thick(50),dens(50),beta(50), limitmoho,lon,lat
	real*4 cos2theta(50),sin2theta(50)
	character*70 shvelmodel, covmatout,crustthick
	character*70 outputfile,outptrectangles
	character*70 dummyc
	read(*,*) shvelmodel
	read(*,*) covmatout
	read(*,*) outputfile
	read(*,*) outptrectangles
	open(10,file = shvelmodel)
	open(11,file = covmatout)
	open(13, file = outputfile)
	open(14, file = outptrectangles)
c  dampmin is the minimum length damping term (a priori standard deviation of
c  starting model) that was used in the velocity inversion
	read(*,*) dampmin, limitmoho, ioptrect
c  limitmoho is the maximum depth moho for which a moho to bot(1) average velocity
c  is computed
c  ioptrect optionally outputs rectangles of 95% velocity uncertainty for input
c  to plotting routines if .eq.1
	covdamp = dampmin**2
	read(*,*) nrlayers
c  specify top and bottom layers to be included in averages, based on 
c  resolution of a typical point.  For useful lateral comparisons, these
c  averages all need to be over same depth range despite laterally varying
c  resolution
c
c  top for first layer is depth limit for moho to calculate a shallow 
c  lithospheric average - NOT USED FOR ANISO  an average is computed from Moho to bottom(1),
c  but only if Moho shallower than top(1)
	do i = 1, nrlayers
	  read(*,*) top(i),bot(i)
	enddo
	read(10,*) beglat,endlat,dlat,beglon,endlon,dlon
c	write(90,*) beglat,endlat,dlat,beglon,endlon,dlon
	nlat = (endlat-beglat)/dlat +1.01
        nlon = (endlon-beglon)/dlon + 1.01
        nxy = nlat*nlon
	write(13,*) beglat,endlat,dlat,beglon,endlon,dlon
	do inxy = 1, nxy
	   nrrlayers = nrlayers
	   read(10,*) lon, lat
	   write(13,*) lon,lat
	   if (ioptrect.eq.1) write(14,*) lon,lat
	   read(10,*) nlay
	   do i = 1, nlay
	     read(10,*) thick(i),cos2theta(i),sin2theta(i)
	   enddo
           read(11,*) ii
           read(11,*) dummyc
	   do i = 1, nlay
c  only lower triangle of symmetric cos2theta covariance matrix is stored.
	     do j = 1,i
	       read(11,*) iii,jjj,covarcs(i,j)
	       covarcs(j,i) = covarcs(i,j)
	     enddo
c  correct diagonal elements for influence of a priori damping
             if (covarcs(i,i).lt.covdamp) then
               covarcs(i,i) = 1.0/(1.0/covarcs(i,i)-1.0/covdamp)
	     else
	       covarcs(i,i) = 1.0
	     endif
	   enddo
           read(11,*) ii
           read(11,*) dummyc
	   do i = 1, nlay
c  only lower triangle of symmetric sin2theta covariance matrix is stored.
	     do j = 1,i
	       read(11,*) iii,jjj,covarsn(i,j)
	       covarsn(j,i) = covarsn(i,j)
	     enddo
c  correct diagonal elements for influence of a priori damping
             if (covarsn(i,i).lt.covdamp) then
               covarsn(i,i) = 1.0/(1.0/covarsn(i,i)-1.0/covdamp)
	     else
	       covarsn(i,i) = 1.0
	     endif
	   enddo
c  find model layers in depth range specified for each resolution range
           do irlay = 1, nrlayers
	     cumldepth = 0.0
	     indtop = 0
	     indbot = 0
	     iskip = 0
	     realtop = top(irlay)
	     do j = 1, nlay
	       cumldepth = cumldepth + thick(j)
	       if ((cumldepth.gt.top(irlay)).and.(indtop.eq.0)) then
	         indtop = j
c  fraction of top layer to be used in average
		 fractop = (cumldepth-top(irlay))/thick(j)
c  check whether this layer is crustal.  If so, skip.
c                 if (dens(j).lt.3.1) then
c		   indtop = 0
c	         endif
c  check whether too little of layer used
                 if (fractop.lt.0.25) then
		   indtop = 0
		 endif
c  correct fractop if top of range was in previous crustal layer
                 if (fractop.gt.1.0) then
		   fractop = 1.0
		   realtop = cumldepth-thick(j)
c  if top layer too thin (i.e., top of mantle gt limitmoho) then skip
		   if ((realtop.gt.limitmoho).and.(irlay.eq.1)) then
		     nrrlayers = nrlayers - 1
		     iskip = 1
		     go to 2000
		   endif 
		 endif
	       endif
c  fraction of bottom layer to be used in average -allow for roundoff errors
	       if (((cumldepth.ge.bot(irlay)).and.(indbot.eq.0))
     1       .or.((j.eq.nlay).and.(irlay.eq.nrlayers))) then
                 indbot = j
		 fracbot = (thick(j)-(cumldepth-bot(irlay)))/thick(j)
c  check whether too little of layer used - if so, revert back to layer above as bottom
                 if (fracbot.lt.0.25) then
		   indbot = j-1
		   fracbot = 1.0
		 endif
	       endif
	     enddo
c	     cumlvel = 0.0
	     cumlcs2 = 0.0
	     cumlsn2 = 0.0
	     cumlvar = 0.0
	     cumlvarcs = 0.0
	     cumlvarsn = 0.0
             sumweight = 0.0
	     sumthick = 0.0	     
	     do i = indtop,indbot
	       fract = 1.0
	       if (i.eq.indtop) fract = fractop
	       if (i.eq.indbot) fract = fracbot
c  weights for averages are fine, but covariances get screwed up when fractional
c  layers are used, as off-diagional terms are based on trade-offs between whole 
c  layers with no accounting for thickness.  (can even get negative cumulative variance
c  in extreme cases).  So base uncertainty estimates on whole layers
	       weight(i) = fract*thick(i)
	       sumweight = sumweight + weight(i)
	       sumthick = sumthick + thick(i)
	     enddo
	     do i = indtop,indbot
c	       cumlvel = cumlvel + weight(i)*beta(i)
	       cumlcs2 = cumlcs2 + weight(i)*cos2theta(i)
	       cumlsn2 = cumlsn2 + weight(i)*sin2theta(i)
	       do j = indtop,indbot
	         cumlvarcs = cumlvarcs + thick(i)*thick(j)*covarcs(i,j)
	         cumlvarsn = cumlvarsn + thick(i)*thick(j)*covarsn(i,j)
	       enddo
	     enddo
	     avgvelcs2 = cumlcs2/(sumweight)
	     covavgcs = cumlvarcs/(sumthick)**2
             stdavgcs = sqrt(covavgcs)
	     avgvelsn2 = cumlsn2/(sumweight)
	     covavgsn = cumlvarsn/(sumthick)**2
             stdavgsn = sqrt(covavgsn)
	     if (irlay.eq.1) write (13,*) nrrlayers
	     write(13,2001) realtop,bot(irlay),avgvelcs2,stdavgcs,
     1                      avgvelsn2,stdavgsn
c             if (ioptrect.eq.1) then
c  double for ~95% confidence limits
c	     std2avg = 2.0*sqrt(covavg)
c	       v1 = avgvel-2.0*stdavg
c	       v2 = avgvel+2.0*stdavg
c	       write(14,2002) v1,realtop
c	       write(14,2002) v2,realtop
c	       write(14,2002) v2,bot(irlay)
c	       write(14,2002) v1,bot(irlay)
c	       write(14,2002) v1,realtop
c	       write(14,2003) '>'
c	     endif
2000         continue
           if ((irlay.eq.1).and.(iskip.eq.1)) write (13,*) nrrlayers
2001       format(2f8.1,4f 8.3)
2002       format(f6.3,2x,f6.1)
2003       format(a1)
	   enddo 
	 enddo
	 close(10)
	 close(11)
	 close(12)
	 close(13)
	 close(14)
	 end
	 
	    
	       	

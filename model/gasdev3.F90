!
!
      FUNCTION gasdev3()
       use ifport !for use with ifort
! Joel: Modified from Gasdev. Ran has problem
      REAL gasdev3
      INTEGER iset
      REAL fac,gset,rsq,v1,v2,r1,r2 !use ran() intrinsic
      logical first
      SAVE iset,gset,first
      DATA iset/0/
      data first/.true./
      if(first) then
          call random_seed()  !For use with latest version of PGI. Static seed
          first=.false.
      endif
      if (iset.eq.0) then
1       call random_number(r1)  !new version for latest PGI FORTRAN Compiler
        call random_number(r2)
        v1=2.*r1-1.
        v2=2.*r2-1.
        rsq=v1**2+v2**2
        if(rsq.ge.1..or.rsq.eq.0.)goto 1
        fac=sqrt(-2.*log(rsq)/rsq)
        gset=v1*fac
        gasdev3=v2*fac
        iset=1
      else
        gasdev3=gset
        iset=0
      endif
      return
      END
!  (C) Copr. 1986-92 Numerical Recipes Software 2*$.
!
!

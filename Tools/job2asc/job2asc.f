************************************************************************
* This file is part of OpenMolcas.                                     *
*                                                                      *
* OpenMolcas is free software; you can redistribute it and/or modify   *
* it under the terms of the GNU Lesser General Public License, v. 2.1. *
* OpenMolcas is distributed in the hope that it will be useful, but it *
* is provided "as is" and without any express or implied warranties.   *
* For more details see the full text of the license in the file        *
* LICENSE or in <http://www.gnu.org/licenses/>.                        *
************************************************************************
      PROGRAM JOB2ASC
C SVC 20071004
C convert JOBIPH to a formatted file FMTIPH
C with some additional explanation.
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER FMTIPH

#include "rasdim.fh"
#include "rasscf.fh"
#include "WrkSpc.fh"
#include "general.fh"

      CALL INIT_LINALG
      CALL PrgmInit('Job2Asc')

      JOBIPH=15
      JOBIPH=isFreeUnit(JOBIPH)
      CALL DANAME(JOBIPH,'JOBIPH')

      FMTIPH=JOBIPH+1
      FMTIPH=isFreeUnit(FMTIPH)
      CALL MOLCAS_OPEN(FMTIPH,'FMTIPH')

      IAD15=0
      CALL IDAFILE(JOBIPH,2,IADR15,30,IAD15)
      WRITE(FMTIPH,*) 'print out of IADR15: '
      WRITE(FMTIPH,'(15I10)') (IADR15(I), I=1,30)

      nName=4*2*mxOrb
      nHeader=144
      nTitle=4*18*mxTit

      IAD15=IADR15(1)
      CALL WR_RASSCF_Info(JOBIPH,2,IAD15,NACTEL,ISPIN,NSYM,LSYM,
     &            NFRO,NISH,NASH,NDEL,NBAS,MxSym,
     &            NAME,nName,NCONF,HEADER,nHeader,
     &            TITLE,nTitle,POTNUC,LROOTS,NROOTS,
     &            IROOT,MxRoot,NRS1,NRS2,NRS3,
     &            NHOLE1,NELEC3,IPT2,WEIGHT)

 100  FORMAT(I10)
 200  FORMAT(2X,10I10)
 300  FORMAT(A)
 400  FORMAT(E20.12)
 500  FORMAT(2X,5E20.12)
 510  FORMAT(2X,6E20.12)
      WRITE(FMTIPH,*) 'number of active electrons'
      WRITE(FMTIPH,100) nActEl
      WRITE(FMTIPH,*) 'spin of the wave function'
      WRITE(FMTIPH,100) iSpin
      WRITE(FMTIPH,*) 'number of irreps'
      WRITE(FMTIPH,100) nSym
      WRITE(FMTIPH,*) 'irrep of the wave function'
      WRITE(FMTIPH,100) lSym
      WRITE(FMTIPH,*) 'number of frozen orbitals'
      WRITE(FMTIPH,200) (nFro(I), I=1,MxSym)
      WRITE(FMTIPH,*) 'number of inactive orbitals'
      WRITE(FMTIPH,200) (nISh(I), I=1,MxSym)
      WRITE(FMTIPH,*) 'number of active orbitals'
      WRITE(FMTIPH,200) (nASh(I), I=1,MxSym)
      WRITE(FMTIPH,*) 'number of deleted orbitals'
      WRITE(FMTIPH,200) (nDel(I), I=1,MxSym)
      WRITE(FMTIPH,*) 'number of basis functions'
      WRITE(FMTIPH,200) (nBas(I), I=1,MxSym)
      WRITE(FMTIPH,*) 'number of configurations'
      WRITE(FMTIPH,100) nConf
      WRITE(FMTIPH,*) 'Header'
      WRITE(FMTIPH,'(36A)') (Header(I), I=1,72)
      WRITE(FMTIPH,*) 'Title'
      WRITE(FMTIPH,'(80A)') (Title(I), I=1,9)
      WRITE(FMTIPH,*) 'nuclear potential energy'
      WRITE(FMTIPH,400) PotNuc
      WRITE(FMTIPH,*) 'number of roots in the small CI'
      WRITE(FMTIPH,100) lRoots
      WRITE(FMTIPH,*) 'number of roots in the averaging'
      WRITE(FMTIPH,100) nRoots
      WRITE(FMTIPH,*) 'rootnumbers'
      WRITE(FMTIPH,200) (iRoot(I), I=1,MxRoot)
      WRITE(FMTIPH,*) 'number of RAS1 orbitals'
      WRITE(FMTIPH,200) (nRS1(I), I=1,MxSym)
      WRITE(FMTIPH,*) 'number of RAS2 orbitals'
      WRITE(FMTIPH,200) (nRS2(I), I=1,MxSym)
      WRITE(FMTIPH,*) 'number of RAS3 orbitals'
      WRITE(FMTIPH,200) (nRS3(I), I=1,MxSym)
      WRITE(FMTIPH,*) 'max number of holes in RAS1'
      WRITE(FMTIPH,100) nHole1
      WRITE(FMTIPH,*) 'max number of electrons in RAS3'
      WRITE(FMTIPH,100) nElec3
      WRITE(FMTIPH,*) 'iPT2'
      WRITE(FMTIPH,100) iPT2
      WRITE(FMTIPH,*) 'weight of the roots in the averaging'
      WRITE(FMTIPH,500) (Weight(I), I=1,MxRoot)

      NTOT=0
      NTOT2=0
      NASHT=0
      NTOT3=0
      NFOCK=0
      DO ISYM=1,NSYM
         NTOT=NTOT+nBas(ISYM)
         NTOT2=NTOT2+nBas(ISYM)**2
         NASHT=NASHT+nASh(ISYM)
         nOrb(iSym)=nBas(iSym)-nFro(iSym)-nDel(iSym)
         NTOT3=NTOT3+nOrb(iSym)*(nOrb(iSym)+1)/2
         NFOCK=NFOCK+(nISh(ISYM)+nASh(ISYM))**2
      END DO
      NACPAR=NASHT*(NASHT+1)/2
      NACPR2=NACPAR*(NACPAR+1)/2

      WRITE(FMTIPH,*) 'basis function labels and type'
      WRITE(FMTIPH,300) (Name(I), I=1,NTOT)

      IAD15=IADR15(2)
      CALL GETMEM('ADR1','ALLO','REAL',LADR1,NTOT2)
      CALL GETMEM('ADR2','ALLO','REAL',LADR2,NTOT)
      CALL DDAFILE(JOBIPH,2,WORK(LADR1),NTOT2,IAD15)
      CALL DDAFILE(JOBIPH,2,WORK(LADR2),NTOT,IAD15)
      WRITE(FMTIPH,*) 'average orbitals'
      WRITE(FMTIPH,*) 'MO coefficients'
      WRITE(FMTIPH,*) 'length = ', NTOT2
      WRITE(FMTIPH,500) (WORK(LADR1+I-1), I=1,NTOT2)
      WRITE(FMTIPH,*) 'occupation numbers'
      WRITE(FMTIPH,*) 'length = ', NTOT
      WRITE(FMTIPH,500) (WORK(LADR2+I-1), I=1,NTOT)
      CALL GETMEM('ADR1','FREE','REAL',LADR1,NTOT2)
      CALL GETMEM('ADR2','FREE','REAL',LADR2,NTOT)

      IAD15=IADR15(3)
      CALL GETMEM('ADR1','ALLO','REAL',LADR1,NACPAR)
      CALL GETMEM('ADR2','ALLO','REAL',LADR2,NACPR2)
      WRITE(FMTIPH,*) 'density matrices for the active orbitals'
      Do I = 1,LROOTS
      WRITE(FMTIPH,*) 'root = ', I
        WRITE(FMTIPH,*) 'D  : one-body density matrix'
        WRITE(FMTIPH,*) 'length = ', NACPAR
        Call DDafIle(JOBIPH,2,WORK(LADR1),NACPAR,IAD15)
        WRITE(FMTIPH,500) (WORK(LADR1+J-1), J=1,NACPAR)
        WRITE(FMTIPH,*) 'DS : spin density matrix'
        WRITE(FMTIPH,*) 'length = ', NACPAR
        Call DDafIle(JOBIPH,2,WORK(LADR1),NACPAR,IAD15)
        WRITE(FMTIPH,500) (WORK(LADR1+J-1), J=1,NACPAR)
        WRITE(FMTIPH,*) 'P  : symmetric two-body density matrix'
        WRITE(FMTIPH,*) 'length = ', NACPR2
        Call DDafIle(JOBIPH,2,WORK(LADR2),NACPR2,IAD15)
        WRITE(FMTIPH,500) (WORK(LADR2+J-1), J=1,NACPR2)
        WRITE(FMTIPH,*) 'PA : antisymmetric two-body density matrix'
        WRITE(FMTIPH,*) 'length = ', NACPR2
        Call DDafIle(JOBIPH,2,WORK(LADR2),NACPR2,IAD15)
        WRITE(FMTIPH,500) (WORK(LADR2+J-1), J=1,NACPR2)
      ENDDO
      CALL GETMEM('ADR1','FREE','REAL',LADR1,NACPAR)
      CALL GETMEM('ADR2','FREE','REAL',LADR2,NACPR2)

      IAD15=IADR15(4)
      CALL GETMEM('ADR','ALLO','REAL',LADR,NCONF)
      WRITE(FMTIPH,*) 'CI coefficients'
      Do I = 1,LROOTS
      WRITE(FMTIPH,*) 'root = ', I
      WRITE(FMTIPH,*) 'length = ', NCONF
        Call DDafIle(JOBIPH,2,WORK(LADR),NCONF,IAD15)
        WRITE(FMTIPH,500) (WORK(LADR+J-1), J=1,NCONF)
      ENDDO
      CALL GETMEM('ADR','FREE','REAL',LADR,NCONF)

      IAD15=IADR15(5)
      CALL GETMEM('ADR','ALLO','REAL',LADR,NFOCK)
      CALL DDAFILE(JOBIPH,2,WORK(LADR),NFOCK,IAD15)
      WRITE(FMTIPH,*) 'Fock matrix for the occupied orbitals'
      WRITE(FMTIPH,*) 'length = ', NFOCK
      WRITE(FMTIPH,500) (WORK(LADR+I-1), I=1,NFOCK)
      CALL GETMEM('ADR','FREE','REAL',LADR,NFOCK)

      IAD15=IADR15(6)
      CALL GETMEM('ADR','ALLO','REAL',LADR,mxRoot*mxIter)
      CALL DDAFILE(JOBIPH,2,WORK(LADR),mxRoot*mxIter,IAD15)
      WRITE(FMTIPH,*) 'energies from array ENER(mxRoot,mxIter)'
      WRITE(FMTIPH,*) 'length = ', mxRoot*mxIter
      WRITE(FMTIPH,500) (WORK(LADR+I-1), I=1,mxRoot*mxIter)
      CALL GETMEM('ADR','FREE','REAL',LADR,mxRoot*mxIter)

      IAD15=IADR15(7)
      CALL GETMEM('ADR','ALLO','REAL',LADR,6*mxIter)
      CALL DDAFILE(JOBIPH,2,WORK(LADR),6*mxIter,IAD15)
      WRITE(FMTIPH,*) 'convergence parameters from array CONV(6,mxIter)'
      WRITE(FMTIPH,*) 'length = ', 6*mxIter
      WRITE(FMTIPH,510) (WORK(LADR+I-1), I=1,6*mxIter)
      CALL GETMEM('ADR','FREE','REAL',LADR,6*mxIter)

      IAD15=IADR15(9)
      CALL GETMEM('ADR','ALLO','REAL',LADR,NTOT2)
      CALL DDAFILE(JOBIPH,2,WORK(LADR),NTOT2,IAD15)
      WRITE(FMTIPH,*) 'final canonical MOs written in FCKPT2'
      WRITE(FMTIPH,*) 'length = ', NTOT2
      WRITE(FMTIPH,500) (WORK(LADR+I-1), I=1,NTOT2)
      CALL GETMEM('ADR','FREE','REAL',LADR,NTOT2)

      IAD15=IADR15(10)
      CALL GETMEM('ADR','ALLO','REAL',LADR,NTOT3)
      CALL DDAFILE(JOBIPH,2,WORK(LADR),NTOT3,IAD15)
      WRITE(FMTIPH,*) 'inactive Fock matrix FI for CASPT2 in MO basis'
      WRITE(FMTIPH,*) 'length = ', NTOT3
      WRITE(FMTIPH,500) (WORK(LADR+I-1), I=1,NTOT3)
      CALL DDAFILE(JOBIPH,2,WORK(LADR),NTOT3,IAD15)
      WRITE(FMTIPH,*) 'CASPT2 Fock matrix FP'
      WRITE(FMTIPH,*) 'length = ', NTOT3
      WRITE(FMTIPH,500) (WORK(LADR+I-1), I=1,NTOT3)
      CALL GETMEM('ADR','FREE','REAL',LADR,NTOT3)

      IAD15=IADR15(11)
      CALL GETMEM('ADR','ALLO','REAL',LADR,NORBT)
      CALL DDAFILE(JOBIPH,2,WORK(LADR),NORBT,IAD15)
      WRITE(FMTIPH,*) 'diagonal of the CASPT2 Fock matrix FP'
      WRITE(FMTIPH,*) 'length = ', NORBT
      WRITE(FMTIPH,500) (WORK(LADR+I-1), I=1,NORBT)
      CALL GETMEM('ADR','FREE','REAL',LADR,NORBT)

      IAD15=IADR15(12)
      CALL GETMEM('ADR1','ALLO','REAL',LADR1,NTOT2)
      CALL GETMEM('ADR2','ALLO','REAL',LADR2,NTOT)
      WRITE(FMTIPH,*) 'natural orbitals for the final wave functions'
      DO I = 1,LROOTS
      WRITE(FMTIPH,*) 'root = ', I
        WRITE(FMTIPH,*) 'MO coefficients'
        WRITE(FMTIPH,*) 'length = ', NTOT2
        CALL DDAFILE(JOBIPH,2,WORK(LADR1),NTOT2,IAD15)
        WRITE(FMTIPH,500) (WORK(LADR1+J-1), J=1,NTOT2)
        WRITE(FMTIPH,*) 'occupation numbers'
        WRITE(FMTIPH,*) 'length = ', NTOT
        CALL DDAFILE(JOBIPH,2,WORK(LADR2),NTOT,IAD15)
        WRITE(FMTIPH,500) (WORK(LADR2+J-1), J=1,NTOT)
      ENDDO
      CALL GETMEM('ADR1','FREE','REAL',LADR1,NTOT2)
      CALL GETMEM('ADR2','FREE','REAL',LADR2,NTOT)

      IAD15=IADR15(14)
      CALL GETMEM('ADR1','ALLO','REAL',LADR1,NTOT2)
      CALL GETMEM('ADR2','ALLO','REAL',LADR2,NTOT)
      WRITE(FMTIPH,*) 'spin orbitals for the final wave functions'
      Do I=1,LROOTS
      WRITE(FMTIPH,*) 'root = ', I
        WRITE(FMTIPH,*) 'MO coefficients'
        WRITE(FMTIPH,*) 'length = ', NTOT2
        CALL DDAFILE(JOBIPH,2,WORK(LADR1),NTOT2,IAD15)
        WRITE(FMTIPH,500) (WORK(LADR1+J-1), J=1,NTOT2)
        WRITE(FMTIPH,*) 'occupation numbers'
        WRITE(FMTIPH,*) 'length = ', NTOT
        CALL DDAFILE(JOBIPH,2,WORK(LADR2),NTOT,IAD15)
        WRITE(FMTIPH,500) (WORK(LADR2+J-1), J=1,NTOT)
      End Do
      CALL GETMEM('ADR1','FREE','REAL',LADR1,NTOT2)
      CALL GETMEM('ADR2','FREE','REAL',LADR2,NTOT)

      IAD15=IADR15(17)
      CALL GETMEM('ADR','ALLO','REAL',LADR,LROOTS**2)
      WRITE(FMTIPH,*) 'effective hamiltonian from MS-CASPT2'
      WRITE(FMTIPH,*) 'length = ', LROOTS**2
      CALL DDAFILE(JOBIPH,2,WORK(LADR),LROOTS**2,IAD15)
      WRITE(FMTIPH,500) (WORK(LADR+J-1), J=1,LROOTS**2)
      CALL GETMEM('ADR','FREE','REAL',LADR,LROOTS**2)

      CALL DACLOS(JOBIPH)
      CLOSE(FMTIPH)

      END

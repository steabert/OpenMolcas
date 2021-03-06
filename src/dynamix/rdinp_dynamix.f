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
C   . |  1    .    2    .    3    .    4    .    5    .    6    .    7 |  .    8
      SUBROUTINE RdInp_Dynamix(LuSpool,Task,nTasks,mTasks)
      IMPLICIT REAL*8 (a-h,o-z)
#include "MD.fh"
#include "stdalloc.fh"
#include "dyn.fh"
#include "constants2.fh"
      INTEGER Task(nTasks),maxHop, nIsotope, n
      INTEGER VelVer, VV_First, VV_Second, Gromacs, VV_Dump
      PARAMETER(VelVer=1,VV_First=2,VV_Second=3,Gromacs=4,VV_Dump=5)
      LOGICAL lHop, lIsotope
      REAL*8, ALLOCATABLE ::    dIsotopes(:)

C
C     Define local variables
C
      CHARACTER*180  Key, Line
      CHARACTER*180  Get_Ln
      EXTERNAL       Get_Ln
C
C   . |  1    .    2    .    3    .    4    .    5    .    6    .    7 |  .    8
C
      CALL qEnter('RdInp')
      mTasks=0
C
C     Start of input
C
      REWIND(LuSpool)
      CALL RdNLst(LuSpool,'Dynamix')

  999 CONTINUE
      Key = Get_Ln(LuSpool)
      Line = Key
      CALL UpCase(Line)
*
      IF (Line(1:4).eq.'TITL') GOTO 1100
      IF (Line(1:4).eq.'PRIN') GOTO 1101
      IF (Line(1:4).EQ.'VV_F') GOTO 1102
      IF (Line(1:4).EQ.'VV_S') GOTO 1103
      IF (Line(1:4).EQ.'VV_D') GOTO 1104
      IF (Line(1:4).EQ.'THER') GOTO 1105
      IF (Line(1:4).EQ.'VELO') GOTO 1106
      IF (Line(1:2).EQ.'DT')   GOTO 1107
      IF (Line(1:4).EQ.'GROM') GOTO 1108
      IF (Line(1:4).EQ.'TIME') GOTO 1109
      IF (Line(1:4).EQ.'VELV') GOTO 1110
      IF (Line(1:3).EQ.'HOP')  GOTO 1111
      IF (Line(1:4).EQ.'REST') GOTO 1112
      IF (Line(1:4).EQ.'TEMP') GOTO 1113
      IF (Line(1:4).EQ.'ISOT') GOTO 1114
      IF (Line(1:4).EQ.'H5RE') GOTO 1115
      IF (Line(1:3).EQ.'END')  GOTO 9000

*>>>>>>>>>>>>>>>>>>>> TITL <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1100 CONTINUE
      Line = Get_Ln(LuSpool)
      CALL Get_S(1,Title,72)
      GOTO 999
*>>>>>>>>>>>>>>>>>>>> PRIN <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1101 CONTINUE
      Line = Get_Ln(LuSpool)
      CALL Get_I(1,iPrint,1)
*>>>>>>>>>>>>>>>>>>>> VV_First <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1102 CONTINUE
      WRITE(6,*) ' VV_First 1'
      mTasks = mTasks + 1
      Task(mTasks) = VV_First
      WRITE(6,*) ' VV_First 2'
      GOTO 999
*>>>>>>>>>>>>>>>>>>>> VV_Second <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1103 CONTINUE
      mTasks = mTasks + 1
      Task(mTasks) = VV_Second
      GOTO 999
*>>>>>>>>>>>>>>>>>>>> VV_Dump <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1104 CONTINUE
      mTasks = mTasks + 1
      Task(mTasks) = VV_Dump
      GOTO 999
*>>>>>>>>>>>>>>>>>>>> THERmostat <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1105 CONTINUE
#ifdef _DEBUG_
      WRITE(6,*) ' Dynamix starts reading THERMO.'
#endif
      Line = Get_Ln(LuSpool)
      CALL Get_I(1,THERMO,1)
#ifdef _DEBUG_
      WRITE(6,*) ' Dynamix ends reading THERMO.'
#endif
      GOTO 999
*>>>>>>>>>>>>>>>>>>>> VELOcities <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1106 CONTINUE
#ifdef _DEBUG_
      WRITE(6,*) ' Dynamix starts reading VELO.'
#endif
      Line = Get_Ln(LuSpool)
      CALL Get_I(1,VELO,1)
#ifdef _DEBUG_
      WRITE(6,*) ' Dynamix ends reading VELO.'
#endif
      GOTO 999
*>>>>>>>>>>>>>>>>>>>> DT   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1107 CONTINUE
#ifdef _DEBUG_
      WRITE(6,*) ' Dynamix starts reading DT.'
#endif
      Line = Get_Ln(LuSpool)
      CALL Get_F(1,DT,1)
      CALL Put_dScalar('Timestep',DT)
#ifdef _HDF5_
      call mh5_put_dset(dyn_dt,DT)
#endif
#ifdef _DEBUG_
      WRITE(6,*) ' Dynamix ends reading DT.'
#endif
      GOTO 999
*>>>>>>>>>>>>>>>>>>>> GROM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1108 CONTINUE
      mTasks = mTasks + 1
      Task(mTasks) = Gromacs
      GOTO 999
*>>>>>>>>>>>>>>>>>>>> TIME <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1109 CONTINUE
      Line = Get_Ln(LuSpool)
      CALL Get_F(1,TIME,1)
      GOTO 999
*>>>>>>>>>>>>>>>>>>>> VelVer <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1110 CONTINUE
C     This is the keyword for Velocity Verlet algorithm
      mTasks = mTasks + 1
      Task(mTasks) = VelVer
      GOTO 999
*>>>>>>>>>>>>>>>>>>>> Hop    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1111 CONTINUE
      Line = Get_Ln(LuSpool)
      CALL Get_I(1,maxHop,1)
      lHop=.FALSE.
      CALL qpg_iScalar('MaxHops',lHop)
      IF (.NOT.lHop) THEN
         CALL Put_iScalar('MaxHops',maxHop)
      END IF
#ifdef _DEBUG_
      WRITE(6,*) ' lHop = ',lHop,'maxHop = ',maxHop
#endif
      GOTO 999
*>>>>>>>>>>>>>>>>>>>> Restart <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1112 CONTINUE
      Line = Get_Ln(LuSpool)
#ifdef _DEBUG_
      WRITE(6,*) ' Dynamix starts reading RESTART.'
#endif
      CALL Get_F(1,RESTART,1)
      GOTO 999
#ifdef _DEBUG_
      WRITE(6,*) ' Dynamix ends reading RESTART.'
#endif

*>>>>>>>>>>>>>>>>>>>> TEMPERATURE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1113 CONTINUE
#ifdef _DEBUG_
      WRITE(6,*) ' Dynamix starts reading Temperature.'
#endif
      Line = Get_Ln(LuSpool)
      CALL Get_F(1,TEMP,1)
#ifdef _DEBUG_
      WRITE(6,*) ' Dynamix ends reading Temperature.'
#endif
      GOTO 999
*>>>>>>>>>>>>>>>>>>>> Isotope <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 1114 CONTINUE
C     The isotope keyword allows to change the mass of any atom
C
C     to change the mass of atom 3 to 5.0 Da and atom 4 to 9.0 Da:
C
C     ISOTOPE
C      2          * nIsotope
C      3 5.0      * isoatom(1)
C      4 9.0      * isoatom(2)
C
C     note masses are input in u (= Da), but stored in a.u.
C
      Line = Get_Ln(LuSpool)
      lIsotope=.TRUE.
C     Get the total number of isotopes
      CALL Get_I(1,nIsotope,1)
C     Get the total number of atoms and allocate memory
      CALL Get_nAtoms_All(natom)
      CALL mma_allocate(dIsotopes,natom)
      WRITE(6,*) ' Manual isotopes defined '
      DO n=1, natom
         dIsotopes(n)=0.0D0
      END DO
C     Read the first line with isotope information
      DO n=1, nIsotope
         Line = Get_Ln(LuSpool)
         CALL Get_I(1,isoatom,1)
         CALL Get_F(2,dIsotopes(isoatom),1)
         dIsotopes(isoatom)=dIsotopes(isoatom)*uToau
      END DO
C     Save it on RunFile and free memory
      CALL Put_dArray('Isotopes',dIsotopes,natom)
#ifdef _HDF5_
      call mh5_put_dset(dyn_iso,dIsotopes)
#endif
      CALL mma_deallocate(dIsotopes)
      GOTO 999
c      Write (6,*) 'Unknown keyword:', Key
c      CALL Abend()
*>>>>>>>>>>>>>>>>>>>> Restart from HDF5 file <<<<<<<<<<<<<<<<<<<<<<<<<
 1115 CONTINUE
#ifdef _HDF5_
      lH5Restart = .True.
      Line = Get_Ln(LuSpool)
      CALL Get_S(1,FILE_H5RES,1)
#else
      write (6,*) 'The user asks to restart the dynamics calculation '
      write (6,*) 'from a HDF5 file, but this is not supported in this'
      write (6,*) 'installation.'
      call Quit_OnUserError()
#endif
      GOTO 999
*>>>>>>>>>>>>>>>>>>>> END <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 9000 CONTINUE
      WRITE (6,*)
      CALL qExit('RdInp')
*
      RETURN
*
      END

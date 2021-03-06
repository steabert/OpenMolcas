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
      SubRoutine Langevin(h1,TwoHam,D,RepNuc,nh1,First,Dff)
      Implicit Real*8 (A-H,O-Z)
      Real*8 h1(nh1), TwoHam(nh1), D(nh1)
#include "itmax.fh"
#include "info.fh"
#include "print.fh"
#include "real.fh"
#include "rctfld.fh"
#include "WrkSpc.fh"
      Logical First, Dff, Exist
      Save nAnisopol,nPolComp
*
      nElem(ixyz) = (ixyz+1)*(ixyz+2)/2


      iRout = 1
      iPrint = nPrint(iRout)
      Call qEnter('Langevin')

*                                                                      *
************************************************************************
*                                                                      *
*---- Generate list of all atoms
*
*     Cord: list of all atoms
*     Atod: associated effective atomic radius
*

      mdc = 0
      MaxAto=0
      Do iCnttp = 1, nCnttp
         nCnt = nCntr(iCnttp)
         Do iCnt = 1, nCnt
            mdc = mdc + 1
            MaxAto = MaxAto + nIrrep/nStab(mdc)
         End Do
      End Do
*
      Call GetMem('Cord','Allo','Real',ipCord,3*MaxAto)
      Call GetMem('Chrg','Allo','Real',ipChrg,MaxAto)
      Call GetMem('Atod','Allo','Real',ipAtod,MaxAto)
*
      ndc = 0
      nc = 1
      Do jCnttp = 1, nCnttp
         Z = Charge(jCnttp)
         mCnt = nCntr(jCnttp)
         jxyz = ipCntr(jCnttp)
         If (iAtmNr(jCnttp).ge.1) Then
*            Atod = CovRad (iAtmNr(jCnttp))
             Atod = CovRadT(iAtmNr(jCnttp))
         Else
             Atod = Zero
         End If
         Do jCnt = 1, mCnt
            ndc = ndc + 1
            x1 = Work(jxyz)
            y1 = Work(jxyz+1)
            z1 = Work(jxyz+2)
            Do i = 0, nIrrep/nStab(ndc) - 1
               iFacx=iPhase(1,iCoset(i,0,ndc))
               iFacy=iPhase(2,iCoset(i,0,ndc))
               iFacz=iPhase(3,iCoset(i,0,ndc))
               Work(ipCord+(nc-1)*3) =   x1*DBLE(iFacx)
               Work(ipCord+(nc-1)*3+1) = y1*DBLE(iFacy)
               Work(ipCord+(nc-1)*3+2) = z1*DBLE(iFacz)
               Work(ipAtod+(nc-1)) = Atod
               Work(ipChrg+(nc-1)) = Z
*              Write (*,*) 'Z=',Z
               nc = nc + 1
            End Do
            jxyz = jxyz + 3
         End Do
      End Do
*
      If(LGridAverage) Then
         nAv=nGridAverage
         If(nGridSeed.eq.0) Then
            iSeed=0
         ElseIf(nGridSeed.eq.-1) Then
            iSeed=0
*     Use system_clock only for some systems
c            Call System_clock(iSeed,j,k)
         Else
            iSeed=nGridSeed
         EndIf
      Else
         nAv=1
      EndIf
      sumRepNuc=Zero
      sumRepNuc2=Zero

      Do iAv=1,nAv
         If(LGridAverage) Then
            cordsi(1,1)=Random_Molcas(iSeed)
            cordsi(2,1)=Random_Molcas(iSeed)
            cordsi(3,1)=Random_Molcas(iSeed)
            rotAlpha=Random_Molcas(iSeed)*180.0D0
            rotBeta=Random_Molcas(iSeed)*180.0D0
            rotGamma=Random_Molcas(iSeed)*180.0D0
            write(6,'(a,i4,a,6f10.4)')'GRID NR',iAv,': ',cordsi(1,1),
     &           cordsi(2,1),cordsi(3,1),rotAlpha,rotBeta,rotGamma
            Done_Lattice=.False.
            RepNuc = Zero
         EndIf

      If (.Not.Done_Lattice) Then
         lFirstIter=.True.
         Done_Lattice=.True.
         if(iXPolType.eq.2) Then
            nAnisopol = nXF
            nPolComp = 6
         Else
            nAnisopol = 0
            nPolComp = 1
         EndIf
*
*
*------- Compute Effective Polarizabilities on the Langevin grid,
*        flag also if points on the grid are excluded.
*        This information is computed once!
*
*        Grid : The Langevin grid
*        PolEf: Effective Polarizability on grid
*        DipEf: Effective Dipole moment on grid
*
         nGrid_Eff=0
*        Both these subroutines can increase nGrid_Eff
         If(iXPolType.gt.0) Then
            Call lattXPol(Work(ipGrid),nGrid,nGrid_Eff,
     &           Work(ipPolEf),Work(ipDipEf),Work(ipXF),nXF,
     &           nOrd_XF,nPolComp)
         EndIf
         If(lLangevin) Then
*            Note: Gen_Grid is now a part of the lattcr subroutine
c            Call Gen_Grid(Work(ipGrid+3*nGrid_Eff),nGrid-nGrid_Eff)
            Call lattcr(Work(ipGrid),nGrid,nGrid_Eff,
     &           Work(ipPolEf),Work(ipDipEf),
     &           Work(ipCord),maxato,Work(ipAtod),nPolComp,
     &           Work(ipXF),nXF,nOrd_XF,iWork(ipXEle),iXPolType)
         EndIf
         Write(6,*) 'nGrid,  nGrid_Eff', nGrid,  nGrid_Eff

*
      End If
*
*                                                                      *
************************************************************************
*                                                                      *
*---- Compute Electric Field from the Quantum Chemical System on the
*     Langevin grid.
*
*     cavxyz: MM expansion of the total charge of the QM system
*     ravxyz: scratch
*     dField: EF on Langevin grid due to QM system
*
*     Get the total 1st order AO density matrix
*
      Call Get_D1ao(ipD1ao,nDens)
      If (nDens.ne.nh1) Then
         Call WarningMessage(2,'Langevin: nDens.ne.nh1')
         Write (6,*) 'nDens,nh1=',nDens,nh1
         Call Abend()
      End If
*
*     Save field from permanent multipoles for use in ener
      Call GetMem('pField','Allo','Real',ippField,nGrid_Eff*4)
      Call GetMem('tmpField','Allo','Real',iptmpField,nGrid_Eff*4)

      Call FZero(Work(ippField ),nGrid_Eff*4)




      Call eperm(Work(ipD1ao),nh1,Work(ipRavxyz),Work(ipCavxyz),nCavxyz,
     &           Work(ipdField),Work(ipGrid),nGrid_Eff,Work(ipCord),
     &           MaxAto,Work(ipChrg),Work(ippField))

*                                                                      *
************************************************************************
*                                                                      *
*---- Save system info, to be used by visualisation program            *

      Lu=21
      Call OpnFl('LANGINFO',Lu,Exist)
      If(.not.Exist) Then
      Write(Lu,*)nc-1
      do i=0,nc-2
         Write(Lu,11)INT(Work(ipChrg+i)),Work(ipAtod+i),
     &        (Work(ipCord+i*3+j),j=0,2)
 11      format(i3,f10.4,3f16.8)
      enddo
      Write(Lu,*)nXF
      Inc = 3
      Do iOrdOp = 0, nOrd_XF
         Inc = Inc + nElem(iOrdOp)
      End Do
      If(iXPolType.gt.0) Inc = Inc + 6
      Do iXF=1,nXF
         xa=Work(ipXF+(iXF-1)*Inc)
         ya=Work(ipXF+(iXF-1)*Inc+1)
         za=Work(ipXF+(iXF-1)*Inc+2)
         If(iWork(ipXEle+iXF-1).le.0) Then
            atrad=DBLE(-iWork(ipXEle+iXF-1))/1000.0D0
            iele=0
         Else
            iele=iWork(ipXEle+iXF-1)
            atrad=CovRadT(iele)
         EndIf
         Write(Lu,11)iele,atrad,xa,ya,za
      EndDo
      Write(Lu,*)nGrid_eff,nAnisopol
      do i=0,nGrid_eff-1
         Write(Lu,12)(Work(ipGrid+i*3+j),j=0,2),
     &        Work(ipPolEf+i),Work(ipDipEf+i),
     &        (Work(ipdField+i*4+j),j=0,2),(Work(ippField+i*4+j),j=0,2)
 12      format(11f20.10)
      enddo
      Write(Lu,*)polsi,dipsi,scala,One/tK/3.1668D-6
      Write(Lu,*)(cordsi(k,1),k=1,3)
      Write(Lu,*)rotAlpha, rotBeta, rotGamma
      Write(Lu,*)radlat,nSparse,distSparse
      Write(Lu,*)lDamping, dipCutoff
      Endif
      Close(Lu)

      call dcopy_(nGrid_Eff*4,Work(ipdField),1,Work(iptmpField),1)

      If(lDiprestart .or. lFirstIter) Then
         Call FZero(Work(ipField ),nGrid*4)
         Call FZero(Work(ipDip   ),nGrid*3)
         Call FZero(Work(ipDavxyz),nCavxyz)
      EndIf

*---- Subtract the static MM from the previous iteration
*     from the static MM of this iteration, and save the
*     untouched static MM of this iteration into Work(ipDavxyz)
*     for use in the next iteration. Work(ipRavxyz) is
*     just a temporary array

      call dcopy_(nCavxyz,Work(ipCavxyz),1,Work(ipRavxyz),1)
      Call DaXpY_(nCavxyz,-One,Work(ipDavxyz),1,Work(ipCavxyz),1)
      call dcopy_(nCavxyz,Work(ipRavxyz),1,Work(ipDavxyz),1)





*                                                                      *
************************************************************************
*                                                                      *
*---- Equation solver: compute the Langevin dipole moments and the
*                      counter charge on the boundary of the cavity.
*
*     Field : total EF of the Langevin grid
*     Dip   : dipole momement on the Langevin grid
*
      Call edip(Work(ipRavxyz),
     &          Work(ipCavxyz),lmax,
     &          Work(ipField),
     &          Work(ipDip),Work(ipdField),
     &          Work(ipPolEf),Work(ipDipEf),
     &          Work(ipGrid),nGrid_Eff,nPolComp,nAnisopol,
     &          nXF,iXPolType,nXMolnr,iWork(ipXMolnr))

*                                                                      *
************************************************************************
*                                                                      *
*---- Compute contributions to RepNuc, h1, and TwoHam
*
      Call Ener(h1,TwoHam,D,RepNuc,nh1,First,Dff,Work(ipD1ao),
     &          Work(ipGrid),nGrid_Eff,Work(ipDip), Work(ipField),
     &          Work(ipDipEf),Work(ipPolEf),Work(ipCord),MaxAto,
     &          Work(ipChrg),nPolComp,nAnisopol,Work(ippField),
     &     Work(iptmpField))


*     Subtract the static field from the self-consistent field
*     This gives the field from the induced dipoles (saved
*     in Work(ipField), to be used in the next iteration if
*     not DRES has been requested

      Call DaXpY_(nGrid*4,-One,Work(iptmpField),1,Work(ipField),1)
      lFirstIter=.False.


      Call GetMem('pField','Free','Real',ippField,nGrid_Eff*4)
      Call GetMem('tmpField','Free','Real',iptmpField,nGrid_Eff*4)
      If(LGridAverage) Then
         Write(6,'(a,i4,a,f18.10)')'Solvation energy (Grid nr. ',iAv,
     &        '):',RepNuc
         sumRepNuc = sumRepNuc + RepNuc
         sumRepNuc2 = sumRepNuc2 + RepNuc**2
      EndIf
      EndDo
      If(LGridAverage) Then
         Write(6,'(a,f18.10,f18.10)')
     &        'Average solvation energy and stdev: ',
     &        sumRepNuc/DBLE(nAv),
     &        sqrt(sumRepNuc2/DBLE(nAv)-(sumRepNuc/DBLE(nAv))**2)
      EndIf
      Call GetMem('Atod','Free','Real',ipAtod,MaxAto)
      Call GetMem(' D1ao','Free','Real',ipD1ao,nDens)
      Call GetMem('Chrg','Free','Real',ipChrg,MaxAto)
      Call GetMem('Cord','Free','Real',ipCord,3*MaxAto)

*                                                                      *
************************************************************************
*                                                                      *
      Call qExit('Langevin')
      Return
      End

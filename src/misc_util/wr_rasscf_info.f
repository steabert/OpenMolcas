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
      Subroutine WR_RASSCF_Info(Lu,iOpt,iDisk,
     &                          NACTEL,ISPIN,NSYM,LSYM,
     &                          NFRO,NISH,NASH,NDEL,NBAS,mxSym,
     &                          NAME,nName,NCONF,HEADER,nHeader,
     &                          TITLE,nTitle,POTNUC,LROOTS,NROOTS,
     &                          IROOT,mxRoot,NRS1,NRS2,NRS3,
     &                          NHOLE1,NELEC3,IPT2,WEIGHT)
      Implicit Real*8 (a-h,o-z)
#include "SysDef.fh"
      Integer nFro(MxSym), nISh(MxSym), nASh(MxSym), nDel(MxSym),
     &        nBas(MxSym), iRoot(MxRoot),
     &        nRS1(MxSym), nRS2(MxSym), nRS3(MxSym)
      Character Name(nName)*1, Header(nHeader)*1, Title(nTitle)*1
      Real*8 Weight(MxRoot)
*
      Call iDaFile(Lu,iOpt, nActEl, 1,      iDisk)
      Call iDaFile(Lu,iOpt, iSpin,  1,      iDisk)
      Call iDaFile(Lu,iOpt, nSym,   1,      iDisk)
      Call iDaFile(Lu,iOpt, lSym,   1,      iDisk)
      Call iDaFile(Lu,iOpt, nFro,   MxSym,  iDisk)
      Call iDaFile(Lu,iOpt, nISh,   MxSym,  iDisk)
      Call iDaFile(Lu,iOpt, nASh,   MxSym,  iDisk)
      Call iDaFile(Lu,iOpt, nDel,   MxSym,  iDisk)
      Call iDaFile(Lu,iOpt, nBas,   MxSym,  iDisk)
      Call cDaFile(Lu,iOpt, Name,   nName,  iDisk)
      Call iDaFile(Lu,iOpt, nConf,  1,      iDisk)
      Call cDaFile(Lu,iOpt, Header, nHeader,iDisk)
      Call cDaFile(Lu,iOpt, Title,  nTitle, iDisk)
      Call dDaFile(Lu,iOpt, PotNuc, 1,      iDisk)
      Call iDaFile(Lu,iOpt, lRoots, 1,      iDisk)
      Call iDaFile(Lu,iOpt, nRoots, 1,      iDisk)
      Call iDaFile(Lu,iOpt, iRoot,  MxRoot, iDisk)
      Call iDaFile(Lu,iOpt, nRS1,   MxSym,  iDisk)
      Call iDaFile(Lu,iOpt, nRS2,   MxSym,  iDisk)
      Call iDaFile(Lu,iOpt, nRS3,   MxSym,  iDisk)
      Call iDaFile(Lu,iOpt, nHole1, 1,      iDisk)
      Call iDaFile(Lu,iOpt, nElec3, 1,      iDisk)
      Call iDaFile(Lu,iOpt, iPT2,   1,      iDisk)
      Call dDaFile(Lu,iOpt, Weight, MxRoot, iDisk)
*
      Return
      End

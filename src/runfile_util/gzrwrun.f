************************************************************************
* This file is part of OpenMolcas.                                     *
*                                                                      *
* OpenMolcas is free software; you can redistribute it and/or modify   *
* it under the terms of the GNU Lesser General Public License, v. 2.1. *
* OpenMolcas is distributed in the hope that it will be useful, but it *
* is provided "as is" and without any express or implied warranties.   *
* For more details see the full text of the license in the file        *
* LICENSE or in <http://www.gnu.org/licenses/>.                        *
*                                                                      *
* Copyright (C) 2009, Per-Olof Widmark                                 *
************************************************************************
************************************************************************
*                                                                      *
* This routine reads or writes a record from/to the runfile.           *
*                                                                      *
*----------------------------------------------------------------------*
*                                                                      *
* Author:  Per-Olof Widmark                                            *
*          Lund university, Sweden                                     *
* Written: December 2009                                               *
*                                                                      *
************************************************************************
      Subroutine gzRWRun(Lu,icXX,Data,nData,iDisk,RecTyp)
#include "runinfo.fh"
#include "runtypes.fh"
*----------------------------------------------------------------------*
* Declare arguments                                                    *
*----------------------------------------------------------------------*
      Integer       Lu
      Integer       icXX
      Character*(*) Data
      Integer       nData
      Integer       iDisk
      Integer       RecTyp
*----------------------------------------------------------------------*
* Read/write data from/to runfile.                                     *
*----------------------------------------------------------------------*
      If(RecTyp.eq.TypInt) Then
         Call iDaFile(Lu,icXX,Data,nData,iDisk)
      Else If(RecTyp.eq.TypDbl) Then
         Call dDaFile(Lu,icXX,Data,nData,iDisk)
      Else If(RecTyp.eq.TypStr) Then
         Call cDaFile(Lu,icXX,Data,nData,iDisk)
      Else If(RecTyp.eq.TypLgl) Then
         Call SysAbendMsg('gzRWRun',
     &                    'Records of logical type not implemented',
     &                    'Aborting')
      Else
         Call SysAbendMsg('gzRWRun',
     &                    'Argument RecTyp is of wrong type',
     &                    'Aborting')
      End If
*----------------------------------------------------------------------*
*                                                                      *
*----------------------------------------------------------------------*
      Return
      End

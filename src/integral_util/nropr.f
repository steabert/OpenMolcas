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
* Copyright (C) 1990, IBM                                              *
************************************************************************
      Integer Function NrOpr(iOp,iOper,nIrrep)
************************************************************************
*                                                                      *
* Object: to return the order index of a symmetry operator.            *
*                                                                      *
************************************************************************
      Integer iOper(0:nIrrep-1)
      NrOpr=-1
      Do 10 iIrrep = 0, nIrrep - 1
         If (iOp.eq.iOper(iIrrep)) NrOpr=iIrrep
 10   Continue
      Return
      End

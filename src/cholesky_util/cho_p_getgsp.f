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
      SubRoutine Cho_P_GetGSP(nGSP)
C
C     Purpose: get global number of contributing shell pairs.
C
      Implicit None
      Integer nGSP
#include "cho_para_info.fh"

      If (Cho_Real_Par) Then
         Call Cho_P_GetGSP_P(nGSP)
      Else
         Call Cho_P_GetGSP_S(nGSP)
      End If

      End
      SubRoutine Cho_P_GetGSP_P(nGSP)
      Implicit None
      Integer nGSP
#include "choglob.fh"

      nGSP = nnShl_G

      End
      SubRoutine Cho_P_GetGSP_S(nGSP)
      Implicit None
      Integer nGSP
#include "cholesky.fh"

      nGSP = nnShl

      End

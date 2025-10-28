      ************************************************************MLSKIP********
      * FXVTSRCDPR: Fix Vertex issues - Prototypes                             *
      **************************************************************************
      * Copyright (c) 2024 Bob Richardson                                      *
      * All Rights Reserved.                                                   *
      *                                                                        *
      **************************************************************************
      * Program Modification Log
      *-------------------------------------------------------------------------
      *   Date   Cus-Prj# Int T Description
      * -------- -------- --- - ------------------------------------------------
      * 09/13/24 WS-162322  BDR Created
      **************************************************************************
      * Prototypes

      // API Error Data Structure
       Dcl-ds ApiErrDS         qualified       inz;
              BytProv             int(10:0)    inz(%size(ApiErrDS));
              BytAvail            int(10:0);
              MsgId               char(7);
              Reserved            char(1);
              MsgData             char(100);
       End-ds;

      // Display a message to the screen
       Dcl-pr DspMsgToScn;
         Dcl-Parm Message Char(50) Const;
         Dcl-Parm reply Char(1) Const OPTIONS(*nopass);
       End-PR;

       Dcl-pr $ChangeLibraryList extpgm('QLICHGLL');
               ChgLibCur        char(11)    const;
               ChgLibPrd1       char(11)    const;
               ChgLibPrd2       char(11)    const;
               ChgLibLst        char(11)    dim(250)
                                     options(*varsize);
               ChgLibLstC       int(10)     const;
               ChgLibErrC       likeds(ApiErrDS)
                                     options(*varsize);
       End-pr;

       Dcl-pr RmvLibraryListEntry ind;
         Dcl-Parm Library Char(10) Const;
       End-pr;

       Dcl-pr AddLibraryListEntry ind;
         Dcl-Parm AddLibrary Char(10) Const;
         Dcl-Parm ExistingLibrary Char(10) Const;
         Dcl-Parm Action Char(8) Const;
       End-pr;

       Dcl-pr myrpg_memcmp int(10) extproc('myrpg_memcmp');
         First pointer;
         Second pointer;
         Size uns(10) const;
       End-pr;

       Dcl-pr myrpg_memcpy extproc('myrpg_memcpy');
         Destination pointer;
         Source pointer;
         Size uns(10) const;
       End-pr;





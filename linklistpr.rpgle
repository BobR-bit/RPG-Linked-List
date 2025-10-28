      *!@ MOD                                                                  MLSKIP
      ********************************************************MLSKIP************
      * LINKLISTPR These are procedures for providing Linklists                *
      **************************************************************************
      * Copyright (c) 2024, Bob Richardson                                     *
      * All Rights Reserved.                                                   *
      **************************************************************************
      * Program Modification Log
      *-------------------------------------------------------------------------
      *   Date   Cus-Prj#   Int T Description
      * -------- ---------- --- - ----------------------------------------------
      * 09/25/24            BDT Created
      **************************************************************************

       Dcl-pr CreateLinkedList pointer;
         Data pointer;
       END-PR;

       Dcl-pr AddLinkedListEntry pointer;
         Root pointer;
         Data Pointer;
       End-pr;

       Dcl-pr AddLinkedListEntrySorted pointer;
         RootPtr pointer;
         DataPtr pointer;
         Size uns(10);
         ResetBasePtr pointer;
       End-pr;

       Dcl-pr FindLinkedListEntry pointer;
         RootPtr pointer;
         Data pointer;
         Size uns(10);
       End-pr;

       Dcl-pr DeleteLinkedListEntry pointer;
         Node pointer;
         ResetBasePtr pointer;
       End-pr;

       Dcl-pr DeleteLinkedList ind;
          Root pointer;
       END-PR;

       //Dcl-pr myrpg_memcmp int(10) extproc('myrpg_memcmp');
       //  First pointer;
       //  Second pointer;
       //  Size uns(10) const;
       //End-pr;


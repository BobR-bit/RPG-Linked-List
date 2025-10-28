      *                                                                      MLSKIP
       ctl-opt copyright('Bob Richardson (C), 2024');
       ctl-opt BNDDIR('QC2LE');
       ctl-opt BNDDIR('WYNBOB/WYNBOB');
      ********************************************************MLSKIP************
      * LINKLISTTS - A test and example program for the linklist modules       *
      **************************************************************************
      * Copyright (c) 2025, Bob Richardson                                     *
      * All Rights Reserved.                                                   *
      **************************************************************************
      * Program Modification Log
      *-------------------------------------------------------------------------
      *   Date   Cus-Prj#   Int T Description
      * -------- ---------- --- - ----------------------------------------------
      * 06/16/25            BDT Created
      **************************************************************************
      // Mainline
      /Copy SRCFILE,LINKLISTPR
      /Copy SRCFILE,COMMONPR
       Dcl-f qsysprt printer(132);

      // *Entry
        Dcl-pi *n;
        End-pi;

      // Declare locals
        Dcl-s Counter Int(10) inz(1);
        Dcl-s DataSetCounter Int(10) inz(1);
        Dcl-s Size Uns(10) Inz(%size(DataDs));
        Dcl-s ResetRoot ind Inz(*off);
        Dcl-s ResetRootPtr pointer inz(%addr(ResetRoot));
       // Printer File Output
        Dcl-ds Output qualified len(132);
          PrtOut Char(132) pos(1);
        END-DS;

       // Data for the Lists
        Dcl-ds First qualified;
          List Char(5) inz('AABCD');
          ch Char(1) dim(5) overlay(List);
        End-ds;
       // Data Set for testinging AddLinkedListSorted
        Dcl-ds Second qualified;
          List Char(4) inz('ABDC');
          ch Char(1) dim(4) overlay(List);
        End-ds;
       // Data Set for testinging AddLinkedListSorted
        Dcl-ds Third qualified;
          List Char(4) inz('DBCA');
          ch Char(1) dim(4) overlay(List);
        End-ds;
       // Data Set for testinging AddLinkedListSorted
        Dcl-ds Forth qualified;
          List Char(4) inz('DCAA');
          ch Char(1) dim(4) overlay(List);
        End-ds;

       // The nodes
        Dcl-s PootPtr pointer;

        Dcl-ds Root qualified based(RootPtr);
          Data_p pointer;
          Prev_n pointer;
          Next_n pointer;
        End-ds;

        Dcl-s CurNodePtr pointer;

        Dcl-ds CurNode qualified based(CurNodePtr);
          Data_p pointer;
          Prev_n pointer;
          Next_n pointer;
        End-ds;

       // The Data for the Nodes
        Dcl-s DataPtr pointer;

        Dcl-ds DataDs qualified based(DataPtr);
          Data Char(1);
        End-ds;

       // Used to Find Linked List Entry
        Dcl-s Ptr pointer;


       // Build The first Linked List
        Dow Counter <= 5;
         // The find link list entry is only really used when the list could have duplicates
         // FindLinkedListEntry is doing a byte to byte compare
          ptr = %addr(First.ch(Counter));
          CurNodePtr = FindLinkedListEntry(RootPtr:ptr
                                               :Size);
          If CurNodePtr =  *NULL; // If not Found
            DataPtr = %alloc(%size(DataDs));
            If DataPtr = *NULL;  // You would want to make sure the memory was allocated
             // Clean up the allocated memory
              DeleteLinkedList(RootPtr);
              *INLR = *on;
              return;
            Endif;
           // Assign the data to the allocated memory
            DataDs.Data = First.ch(Counter);
           // Check to see if the list exists
            If RootPtr = *null;
             // If not then set the Root
              RootPtr = AddLinkedListEntry(RootPtr:DataPtr);
            Else;
             // Otherwise add the new node
              CurNodePtr = AddLinkedListEntry(RootPtr:DataPtr);
            Endif;
          Endif;
         // Next Data Element
          Counter += 1;
        Enddo;

       // Read through the First Linked list
        Counter = 1;
        CurNodePtr = RootPtr;
        Dow CurNodePtr <> *NULL;
          DataPtr = CurNode.Data_p;
          Output.PrtOut = 'Counter ' + %char(Counter) + ' Data ' + DataDs.Data;
          Write QSYSPRT Output;
          CurNodePtr = CurNode.Next_n;
          Counter += 1;
        Enddo;

       // Clean up the allocated memory reset the root
        DeleteLinkedList(RootPtr);
        RootPtr = *NULL;

       // Run the other three data sets with the AddLinkedListEntrySorted
        Dow DataSetCounter <= 3;
          Counter = 1;
         // Build Linked List basesd on the data sets above
          Dow Counter <= 4;
            If DataSetCounter = 1;
              ptr = %addr(Second.ch(Counter));
            Elseif DataSetCounter = 2;
              ptr = %addr(Third.ch(Counter));
            Elseif DataSetCounter = 3;
              ptr = %addr(Forth.ch(Counter));
            Endif;
           // The find link list entry is only really used when the list could have duplicates
            CurNodePtr = FindLinkedListEntry(RootPtr:Ptr:Size);
            If CurNodePtr =  *NULL; // If not Found
              DataPtr = %alloc(%size(DataDs));
              If DataPtr = *NULL;  // You would want to make sure the memory was allocated
               // Clean up the allocated memory
                DeleteLinkedList(RootPtr);
                *INLR = *on;
                return;
              Endif;
             // Get the Data for the Current DataSetCounter
              If DataSetCounter = 1;
                DataDs.Data = Second.ch(Counter);
              Elseif DataSetCounter = 2;
                DataDs.Data = Third.ch(Counter);
              Elseif DataSetCounter = 3;
                DataDs.Data = Forth.ch(Counter);
              Endif;

             // Check to see if the list exists
              If RootPtr = *null;
               // If not then set the Root
                RootPtr = AddLinkedListEntry(RootPtr:DataPtr);
              Else;
               // Otherwise add the new node
                CurNodePtr = AddLinkedListEntrySorted(RootPtr:DataPtr:
                                                     Size:ResetRootPtr);
               // If the Root of the Linked List Needs to be reset
                If ResetRoot;
                  RootPtr = CurNodePtr;
                  ResetRoot = *off;
                Endif;
              Endif;
            Endif;
           // Next Data Element
            Counter += 1;
          Enddo; // End do while Counter <= 4

         // Read through the Current Linked list
          Counter = 1;
          CurNodePtr = RootPtr;
          Dow CurNodePtr <> *NULL;
            DataPtr = CurNode.Data_p;
            Output.PrtOut = 'DataSet ' + %char(DataSetCounter) +
              ' Counter ' + %char(Counter) + ' Data ' + DataDS.Data;
            Write QSYSPRT Output;
            CurNodePtr = CurNode.Next_n;
            Counter += 1;
          Enddo;

         // Clean up the allocated memory reset the root
          DeleteLinkedList(RootPtr);
          RootPtr = *NULL;

         // Next Data Set
          DataSetCounter += 1;
        Enddo; // Outer Loop for difference data sets

       // Set LR and Leave
        *INLR = *on;
        Return;




      *!@ MOD                                                                  MLSKIP
       ctl-opt copyright('Bob Richardson (C), 2024');
       ctl-opt BNDDIR('WYNBOB/WYNBOB':'QC2LE');
      ********************************************************MLSKIP************
      * LINKLIST These are procedures for providing Linklists                  *
      **************************************************************************
      * Copyright (c) 2024, Bob Richardson                                     *
      * All Rights Reserved.                                                   *
      **************************************************************************
      * Program Modification Log
      *-------------------------------------------------------------------------
      *   Date   Cus-Prj#   Int T Description
      * -------- ---------- --- - ----------------------------------------------
      * 09/26/24            BDT   Program Created
      **************************************************************************
       ctl-opt nomain;

      /Copy SRCFILE,LINKLISTPR
      /Copy SRCFILE,COMMONPR

      // Create a new Linked List
       Dcl-proc CreateLinkedList Export;
         Dcl-pi *n pointer;
           Data pointer;
         End-pi;

         Dcl-s p pointer;

         Dcl-ds Node qualified based(p);
           Data_p pointer;
           Prev_n pointer;
           Next_n pointer;
         End-ds;

         p = %alloc(%size(Node));

         if p <> *NULL;
           Node.Data_p = Data;
           Node.Prev_n = *NULL;
           Node.Next_n = *NULL;
         Endif;

         return p;
       End-proc;

      // Add a linked list entry
       Dcl-proc AddLinkedListEntry Export;
         Dcl-pi *n pointer;
           RootPtr pointer;
           Data pointer;
         End-pi;

         Dcl-ds Root qualified based(RootPtr);
           Data_p pointer;
           Prev_n pointer;
           Next_n pointer;
         End-ds;

         Dcl-s ModePtr pointer;

         Dcl-ds Node qualified based(NodePtr);
           Data_p pointer;
           Prev_n pointer;
           Next_n pointer;
         End-ds;

         Dcl-s NewNodePtr pointer;

         Dcl-ds NewNode qualified based(NewNodePtr);
           Data_p pointer;
           Prev_n pointer;
           Next_n pointer;
         End-ds;

        // If the Linked List does not exist, Create it
         if RootPtr = *NULL ;
           NewNodePtr = CreateLinkedlist( Data );
           NodePtr = NewNodePtr;
           RootPtr = NewNodePtr;
         Else;
          // Find the last node in the list
           NodePtr = RootPtr;
           Dow Node.Next_n <> *NULL;
             NodePtr = Node.Next_n;
           Enddo;
          // Add the new node
           NewNodePtr = %alloc(%size(NewNode));
          // Make Sure we were able to allocate the memory
           If NewNodePtr <> *NULL;
             Node.Next_n = NewnodePtr;
             NewNode.Prev_n = NodePtr;
             NewNode.Next_n = *NULL;
             NewNode.Data_p = Data;
           Endif;
          // Set Return Value
           NodePtr = NewNodePtr;
         Endif;

         return NodePtr;
       End-proc;


      //  If you use these functions it is the responsiblility of the calling
      //  program to monitor if this is the new Root node
      //        CurNodePtr = DeleteLinkedListEntry(NodePtr:ResetRootPtr);
               // If the Root of the Linked List Needs to be reset
      //        If ResetRoot;
      //          RootPtr = CurNodePtr;
      //          ResetRoot = *off;
      //        Endif;

      // Delete Linked List Entry
       Dcl-proc DeleteLinkedListEntry Export;
         Dcl-pi *n pointer;
           CurNodePtr Pointer;
           ResetRootPtr pointer;
         End-pi;

         Dcl-ds CurNode qualified based(CurNodePtr);
           Data_p pointer;
           Prev_n pointer;
           Next_n pointer;
         End-ds;

         Dcl-ds NextNode qualified based(CurNode.Next_n);
           Data_p pointer;
           Prev_n pointer;
           Next_n pointer;
         End-ds;

         Dcl-ds PrevNode qualified based(CurNode.Prev_n);
           Data_p pointer;
           Prev_n pointer;
           Next_n pointer;
         End-ds;

         Dcl-s NodePtr pointer;

         Dcl-s ResetRoot ind based(ResetRootPtr);

         If CurNodePtr <> *NULL;
          // Determine the pointer to return (previous node if present,
          // otherwise next node if present, otherwise NULL)
           If CurNode.Prev_n <> *NULL;
             NodePtr = %Addr(PrevNode);
           Else;
             If CurNode.Next_n <> *NULL;
               NodePtr = %Addr(NextNode);
             Else;
               NodePtr = *NULL;
             Endif;
           Endif;

          // Adjust surrounding node links as appropriate
           If CurNode.Prev_n <> *NULL;
             If CurNode.Next_n <> *NULL;
               // Middle node: link prev -> next and next -> prev
               PrevNode.Next_n = CurNode.Next_n;
               NextNode.Prev_n = CurNode.Prev_n;
             Else;
               // Last node: prev becomes new tail
               PrevNode.Next_n = *NULL;
             Endif;
           Else;
             // Deleting the first node: make next node the new root (if any)
             If CurNode.Next_n <> *NULL;
               ResetRoot = *on;
               NextNode.Prev_n = *NULL;
             Endif;
           Endif;

          // Free the caller data buffer (if allocated) and the node itself
           If CurNode.Data_p <> *NULL;
             dealloc(n) CurNode.Data_p;
             CurNode.Data_p = *null;
           Endif;
           dealloc(n) CurNodePtr;
          // Null the caller pointer to be safe
           CurNodePtr = *NULL;
         Else;
          // CurNode was already null - return null
           NodePtr = CurNodePtr;
         Endif;

         return NodePtr;
       End-proc;


      // Find a Link List Entry
       Dcl-proc FindLinkedListEntry Export;
         Dcl-pi *n pointer;
           RootPtr pointer;
           Data pointer;
           Size uns(10);
         End-pi;

         Dcl-ds Root qualified based(RootPtr);
           Data_p pointer;
           Prev_n pointer;
           Next_n pointer;
         End-ds;

         Dcl-s NodePtr pointer;

         Dcl-ds Node qualified based(NodePtr);
           Data_p pointer;
           Prev_n pointer;
           Next_n pointer;
         End-ds;

         Dcl-s CompareResult int(10);

         If RootPtr <> *NULL;
           NodePtr = %Addr(Root);
           Dow NodePtr <> *NULL;
             CompareResult = myrpg_memcmp(Node.Data_p:Data:Size);
             If  CompareResult = 0;
               return NodePtr;
             Endif;
            // Get Next Node
             NodePtr = Node.Next_n;
           Enddo;
         Endif;

         return *NULL;
       End-proc;

      // Delete the entire Linked List - Assumes we are starting at the Root
       Dcl-proc DeleteLinkedList Export;
         Dcl-pi *n ind;
            RootPtr pointer;
         End-pi;

         Dcl-ds Root qualified based(RootPtr);
           Data_p pointer;
           Prev_n pointer;
           Next_n pointer;
         End-ds;

         dcl-s NodePtr pointer;

         Dcl-ds Node qualified based(NodePtr);
           Data_p pointer;
           Prev_n pointer;
           Next_n pointer;
         End-ds;

         Dcl-s ResetRoot ind Inz(*off);
         Dcl-s ResetRootPtr pointer Inz(%addr(ResetRoot));

         // Remove Each Linked List Entry
          NodePtr = %Addr(Root);
          Dow NodePtr <> *NULL;
           // Delete Linked List Entry set the pointer to Next Node
            NodePtr = DeleteLinkedListEntry(NodePtr:ResetRootPtr);
          Enddo;

          Return (*on);
       End-Proc;


      //  If you use these functions it is the responsiblility of the calling
      //  program to monitor if this is the new Root node
      //        CurNodePtr = AddLinkedListEntrySorted(RootPtr:DataPtr:
      //                                             Size:ResetRootPtr);
               // If the Root of the Linked List Needs to be reset
      //        If ResetRoot;
      //          RootPtr = CurNodePtr;
      //          ResetRoot = *off;
      //        Endif;

      // Add a linked list entry Sorted
       Dcl-proc AddLinkedListEntrySorted Export;
         Dcl-pi *n pointer;
           RootPtr pointer;
           Data pointer;
           Size uns(10);
           ResetRootPtr pointer;
         End-pi;

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

         Dcl-s NewNodePtr pointer;

         Dcl-ds NewNode qualified based(NewNodePtr);
           Data_p pointer;
           Prev_n pointer;
           Next_n pointer;
         End-ds;

         Dcl-s PrevNodePtr pointer;

         Dcl-ds PrevNode qualified based(PrevNodePtr);
           Data_p pointer;
           Prev_n pointer;
           Next_n pointer;
         End-ds;

         Dcl-s ResetRoot ind based(ResetRootPtr);
         Dcl-s DoWhile ind inz(*off);
         Dcl-s CompareResult int(10);

        // If the Linked List does not exist, Create it
         if RootPtr = *NULL ;
           NewNodePtr = CreateLinkedlist( Data );
           RootPtr = NewNodePtr;
           ResetRoot = *on;
         Else;
          // Loop Through the List
           CurNodePtr = RootPtr;
           if CurNodePtr <> *NULL;
             DoWhile = *on;
           Endif;

           Dow DoWhile;
             CompareResult = myrpg_memcmp(Data:CurNode.Data_p:Size);
             If CompareResult < 0;  // Parm 1 < parm 2
              // Set PreviousNode to CurNode Previous
               PrevNodePtr = CurNode.Prev_n;
               NewNodePtr = %alloc(%size(NewNode));
              // We were able to allocate new memory
               if NewNodePtr <> *NULL;
                 NewNode.Next_n = CurNodePtr;
                 NewNode.Prev_n = CurNode.Prev_n;
                 NewNode.Data_p = Data;
                // Adjust the pointers
                 CurNode.Prev_n = NewNodePtr;
                 If  PrevNodePtr <> *NULL;
                   PrevNode.Next_n = NewNodePtr;
                 else;
                   ResetRoot = *on;
                 Endif;
               Endif;
             Endif;

            // Bottom of Loop
             CurNodePtr = CurNode.Next_n;
             if CurNodePtr = *NULL OR ResetRoot;
               DoWhile = *off;
             Endif;
           Enddo;

          // If no record was found greater than the new data, then add to the end of the list
           If NewNodePtr = *NULL;
             NewNodePtr = AddlinkedListEntry(RootPtr:Data);
           Endif;

         Endif; //End if Root was Null

         return NewNodePtr;
       End-proc;


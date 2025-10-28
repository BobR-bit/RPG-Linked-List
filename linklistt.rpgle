      *                                                                      MLSKIP
       ctl-opt copyright('Bob Richardson (C), 2024');
       ctl-opt BNDDIR('QC2LE':'WYNBOB/WYNBOB');
      ********************************************************
      * LINKLISTT: Test program for LINKLIST procedures  Note   *
      ********************************************************
       Ctl-opt bnddir('QC2LE':'WYNBOB/WYNBOB');

       /Copy SRCFILE,LINKLISTPR
       /Copy SRCFILE,COMMONPR

      // Test data structure
       Dcl-ds TestData qualified;
         id Int(10);
         name Char(10);
       End-ds;

       // Pointers for linked list operations
       Dcl-s RootPtr pointer Inz(*null);
       Dcl-s NodePtr0 pointer;
       Dcl-s NodePtr1 pointer;
       Dcl-s NodePtr2 pointer;
       Dcl-s NodePtr3 pointer;
       Dcl-s DataPtr0 pointer;
       Dcl-s DataPtr1 pointer;
       Dcl-s DataPtr2 pointer;
       Dcl-s DataPtr3 pointer;
       Dcl-s TestPtr pointer;

      // Additional pointers for isolated tests

       // Test counters
       Dcl-s TestsPassed Int(5) Inz(0);
       Dcl-s TestsFailed Int(5) Inz(0);

       Dcl-s Size Uns(10);
       Dcl-s ResetRoot ind Inz(*off);
       Dcl-s ResetRootPtr pointer Inz(%addr(ResetRoot));


       // Initialize test environment

       // Test 1: Create new linked list
       DataPtr1 = %alloc(%size(TestData));
       TestData.id = 1;
       TestData.name = 'Test1';
       Size = %size(TestData);
       TestPtr = %addr(TestData);
       myrpg_memcpy(DataPtr1: TestPtr: Size);

       NodePtr1 = CreateLinkedList(DataPtr1);
       If NodePtr1 <> *NULL;
         TestsPassed += 1;
         RootPtr = NodePtr1;
         dsply ('Test 1 Passed: Create linked list');
       Else;
         TestsFailed += 1;
         dsply ('Test 1 Failed: Create linked list');
       Endif;

       // Test 2: Add entry to linked list
       TestData.id = 2;
       TestData.name = 'Test2';
       DataPtr2 = %alloc(%size(TestData));
       TestPtr = %addr(TestData);
       myrpg_memcpy(DataPtr2: TestPtr: Size);

       NodePtr2 = AddLinkedListEntry(RootPtr: DataPtr2);
       If NodePtr2 <> *NULL;
         TestsPassed += 1;
         dsply ('Test 2 Passed: Add entry');
       Else;
         TestsFailed += 1;
         dsply ('Test 2 Failed: Add entry');
       Endif;

       // Test 3: Find entry in linked list
       TestPtr = FindLinkedListEntry(RootPtr: DataPtr2: Size);
       If TestPtr = NodePtr2;
         TestsPassed += 1;
         dsply ('Test 3 Passed: Find entry');
       Else;
         TestsFailed += 1;
         dsply ('Test 3 Failed: Find entry');
       Endif;

       // Test 4: Add sorted entry
       TestData.id = 0;  // Should go to front of list
       TestData.name = 'Test0';
       DataPtr0 = %alloc(%size(TestData));
       TestPtr = %addr(TestData);
       myrpg_memcpy(DataPtr0: TestPtr: Size);

       NodePtr0 = AddLinkedListEntrySorted(RootPtr: DataPtr0:
                                               Size: ResetRootPtr);
       If (ResetRoot);
         RootPtr = NodePtr0; // Update root if it changed;
         ResetRoot = *off;
       Endif;
       If NodePtr0 <> *NULL;
         TestsPassed += 1;
         dsply ('Test 4 Passed: Add sorted');
       Else;
         TestsFailed += 1;
         dsply ('Test 4 Failed: Add sorted');
       Endif;

      // Add a fourth node to the list
       // Test 5: Add entry to linked list
       TestData.id = 3;
       TestData.name = 'Test3';
       DataPtr3 = %alloc(%size(TestData));
       TestPtr = %addr(TestData);
       myrpg_memcpy(DataPtr3: TestPtr: Size);

       NodePtr3 = AddLinkedListEntry(RootPtr: DataPtr3);
       If NodePtr3 <> *NULL;
         TestsPassed += 1;
         dsply ('Test 5 Passed: Add entry');
       Else;
         TestsFailed += 1;
         dsply ('Test 5 Failed: Add entry');
       Endif;

      // Delete middle node (Node2)
       TestPtr = DeleteLinkedListEntry(NodePtr2:ResetRootPtr);
       If TestPtr = NodePtr1;
        TestsPassed += 1;
        dsply ('Test 6 Passed: Deleted middle node');
       Else;
        TestsFailed += 1;
        dsply ('Test 6 Failed: Delete middle node');
       Endif;

      // Verify Node1 and Node3 still present
       TestPtr = FindLinkedListEntry(RootPtr: DataPtr1: Size);
       If TestPtr <> *NULL;
        TestsPassed += 1;
        dsply ('Test 7 Passed: Node1 still present');
       Else;
        TestsFailed += 1;
        dsply ('Test 7 Failed: Node1 missing');
       Endif;

       TestPtr = FindLinkedListEntry(RootPtr: DataPtr3: Size);
       If TestPtr <> *NULL;
        TestsPassed += 1;
        dsply ('Test 8 Passed: Node3 still present');
       Else;
        TestsFailed += 1;
        dsply ('Test 8 Failed: Node3 missing');
       Endif;

      // Test 6: Delete entire list
       If (DeleteLinkedList(RootPtr));
         TestsPassed += 1;
         dsply ('Test 9 Passed: Delete list');
       Else;
         TestsFailed += 1;
         dsply ('Test 9   Failed: Delete list');
       Endif;

       // Display test results
       dsply ('Tests Passed:' + %char(TestsPassed));
       dsply ('Tests Failed:' + %char(TestsFailed));

       *inlr = *on;
       return;

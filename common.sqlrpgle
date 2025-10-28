      *!@ MOD                                                                  MLSKIP
       ctl-opt copyright('Bob Richardson  (C), 2024');
      ********************************************************MLSKIP************
      * COMMON : These are procedures used in many programs                    *
      **************************************************************************
      * Copyright (c) 2024  Bob Richardson                                     *
      * All Rights Reserved.                                                   *
      *                                                                        *
      **************************************************************************
      * Program Modification Log
      *-------------------------------------------------------------------------
      *   Date   Cus-Prj#   Int T Description
      * -------- ---------- --- - ----------------------------------------------
      * 09/13/24 WS-162322  BDR Created
      **************************************************************************
       ctl-opt nomain;

      /Copy SRCFILE,COMMONPR

      // my own implmentation of memcmp in RPG
       Dcl-proc myrpg_memcmp Export;
         Dcl-pi *n int(10);
           s1 pointer;
           s2 pointer;
           len uns(10) const;
         End-pi;
        // Set up Char pointers
         Dcl-s Locals1 pointer;
         Dcl-s p1 Char(1) based(Locals1);
         Dcl-s Locals2 pointer;
         Dcl-s n1 Char(1) based(Locals2);

        // Locals
         Dcl-s Length uns(10);
         Dcl-s CharCompareStatus int(10) inz(0);
         Dcl-s DoWhile ind inz(*on);

         Locals1 = s1;
         Locals2 = s2;

         Length = len;

         If Locals1 = Locals2;
           return CharCompareStatus;
         Endif;

         Dow Length > 0 AND DoWhile;
           If p1 <> n1;
             If p1 > n1;
               CharCompareStatus = 1;
               DoWhile = *off;
             else;
               CharCompareStatus = -1;
               DoWhile = *off;
             Endif;
           Endif;
           Length -= 1;
           Locals1 += 1;
           Locals2 += 1;
         Enddo;

        // Return the value
         Return CharCompareStatus;
       End-proc;

      // my own implmentation of memcpy in RPG
       Dcl-proc myrpg_memcpy Export;
         Dcl-pi *n ;
           d1 pointer;
           s1 pointer;
           len uns(10) const;
         End-pi;
        // Set up Char pointers
         Dcl-s Locald1 pointer;
         Dcl-s ds1 Char(1) based(Locald1);
         Dcl-s Locals1 pointer;
         Dcl-s sc1 Char(1) based(Locals1);

        // Locals
         Dcl-s Length uns(10);

        // Set Local Length
         Length = Len;

        // Set Local Pointers
         Locald1 = d1;
         Locals1 = s1;

        // Copy Srouce to Destination
         Dow Length > 0;
           ds1 = sc1;
           Length -= 1;
           Locald1 += 1;
           Locals1 += 1;
         Enddo;

        // Return
         Return;
       End-proc;


    


# RPG-Linked-List
With the eventual advent of auto or dynamic arrays in RPG my past effort in creating doubly linked lists in RPG is probably going to be for wastes.  However, I have never seen a truly dynamic linked list in RPG before mine.  It might be out there, but I was not able to find one when I was looking. 

Having a background in C, and all of it variants led me to desire linked lists back when I started writing RPG programs. 

I wrote my first linked list module in C back in the 1980’s, probably.

I used them extensively over the years and recreated a module in C on the iSeries many years ago.  I have used it in many C program on the ISeries over the years as well.

In all fairness I could very well have just used this module for my linked list in RPG.  But I wanted a more in-depth understanding of RPG pointers and especially RPG base pointers.  So, I recreated my linked list module in RPG back in 2024.

Now a linked list module can contain many procedures to do many things.  I created mine with procedures that meet the way I have come to use them over the years.  I add data to the list sorted rather than have a procedure to sort the list after the fact.  I also choose to have the calling program maintain the Root and allocate memory for the data.  RPG and C are not object languages and it just seems to better fit for non-object languages.

Anyway, keep that in mind when you choose to critique it.  I also wrote my own version or memory copy and memory compare.  I will share that some day as well.  For now, here is a truly dynamic linked list module.   If anyone thinks it would be useful, your more then welcome to hack away.

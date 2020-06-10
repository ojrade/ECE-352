///////////////////////////////////////////////////////////////////////////////
//
// Copyright 2019 Jim Skrentny
// Posting or sharing this file is prohibited, including any changes/additions.
//
///////////////////////////////////////////////////////////////////////////////
// Main File:        heapAlloc.c
// This File:        heapAlloc.c
// Other Files:      N/A
// Semester:         CS 354 Fall 2019
//
// Author:           Ojas Rade
// Email:            rade@wisc.edu
// CS Login:         ojas
//
/////////////////////////// OTHER SOURCES OF HELP //////////////////////////////
//                   fully acknowledge and credit all sources of help,
//                   other than Instructors and TAs.
//
// Persons:          None
//                   
//
// Online sources:   None
//                                     
//////////////////////////// 80 columns wide ///////////////////////////////////


#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdio.h>
#include <string.h>
#include "heapAlloc.h"

/*
 * This structure serves as the header for each allocated and free block.
 * It also serves as the footer for each free block but only containing size.
 */
typedef struct blockHeader {
        int size_status;
    /*
    * Size of the block is always a multiple of 8.
    * Size is stored in all block headers and free block footers.
    *
    * Status is stored only in headers using the two least significant bits.
    *   Bit0 => least significant bit, last bit
    *   Bit0 == 0 => free block
    *   Bit0 == 1 => allocated block
    *
    *   Bit1 => second last bit 
    *   Bit1 == 0 => previous block is free
    *   Bit1 == 1 => previous block is allocated
    * 
    * End Mark: 
    *  The end of the available memory is indicated using a size_status of 1.
    * 
    * Examples:
    * 
    * 1. Allocated block of size 24 bytes:
    *    Header:
    *      If the previous block is allocated, size_status should be 27
    *      If the previous block is free, size_status should be 25
    * 
    * 2. Free block of size 24 bytes:
    *    Header:
    *      If the previous block is allocated, size_status should be 26
    *      If the previous block is free, size_status should be 24
    *    Footer:
    *      size_status should be 24
    */
} blockHeader;         

/* Global variable - DO NOT CHANGE. It should always point to the first block,
 * i.e., the block at the lowest address.
 */

blockHeader *heapStart = NULL;
blockHeader *next = NULL;

/* 
 * Function for allocating 'size' bytes of heap memory.
 * Argument size: requested size for the payload
 * Returns address of allocated block on success.
 * Returns NULL on failure.
 * This function should:
 * - Check size - Return NULL if not positive or if larger than heap space.
 * - Determine block size rounding up to a multiple of 8 and possibly adding padding as a result.
 * - Use NEXT-FIT PLACEMENT POLICY to chose a free block
 * - Use SPLITTING to divide the chosen free block into two if it is too large.
 * - Update header(s) and footer as needed.
 * Tips: Be careful with pointer arithmetic and scale factors.
 */
void* allocHeap(int size) {
    if(size < 1){
	fprintf(stderr, "Size specified to allocate must be greater than 0\n");
	return NULL;
    }
    //total block size with header
    int totBlk = size + sizeof(blockHeader);

    //aligns words
    int doubWord = 8;

    //checking multiple of 8
    if(totBlk < doubWord){
	totBlk = doubWord;
    } else if(totBlk % doubWord != 0){
        int rem = totBlk % 8;
	totBlk = totBlk + (doubWord-rem);
    }

    //start from start needs to be changed
    blockHeader *curr = next;

    //next fit block
    blockHeader *new = NULL;

    //size of least sig bit
    int LSB = 0;

    //size of block w/o marker bits
    int blkSize = 0;

    //new block's size
    int newBlkSize = 0;

    if (curr == NULL) {
	fprintf(stderr, "Allocate memory for heap first\n");
	return NULL;
    }

    //cycle through blocks starting from next
    while((curr->size_status)>1){
	LSB = (curr->size_status) % doubWord;
	blkSize = (curr->size_status)-LSB;

	//curr is full
	if ((LSB % 2)!=0){
	    //move next
	    curr = (blockHeader*)((char*)curr+blkSize);
	} else{
	    if(blkSize == totBlk){
	    	new = curr;
		if(LSB == 2){
		    (new->size_status) = totBlk+3;
		} else{
		    (new->size_status) = totBlk+1;
		}

		//update predeccessor
		blockHeader *predBlk = (blockHeader*) ((char*)new+totBlk);
		if(predBlk->size_status != 1){
		    predBlk->size_status = (predBlk->size_status)+2;
		}
		next = (blockHeader*) ((char*)new + sizeof(blockHeader));
		dumpMem();
		return next;
	    } else if(blkSize > totBlk){
		//set first block to first option so size to test against
		if(newBlkSize==0){
		    new = curr;
		    newBlkSize = (new->size_status)-((new->size_status)%doubWord);
		} else if(blkSize<newBlkSize){
		    new = curr;
		    newBlkSize = (new->size_status)-((new->size_status)&doubWord);
		}
		break;
	    } else{
		curr = (blockHeader*)((char*)curr+blkSize);
	    }
	}
    }
    //cycle through rest
    if(new==NULL){
	curr = heapStart;
        while((curr->size_status)>1){
            LSB = (curr->size_status) % doubWord;
	    blkSize = (curr->size_status)-LSB;

	    //curr is full
	    if ((LSB % 2)!=0){
	        //move next
	        curr = (blockHeader*)((char*)curr+blkSize);
	    } else{
	        if(blkSize == totBlk){
	    	    new = curr;
		    if(LSB == 2){
		        (new->size_status) = totBlk+3;
		    } else{
		        (new->size_status) = totBlk+1;
		    }

		    //update predeccessor
		    blockHeader *predBlk = (blockHeader*) ((char*)new+totBlk);
		    if(predBlk->size_status != 1){
		        predBlk->size_status = (predBlk->size_status)+2;
		    }
		    next = (blockHeader*)((char*)new+sizeof(blockHeader));
		    return next;
	        } else if(blkSize > totBlk){
		    //set first block to first option so size to test against
		    if(newBlkSize==0){
		        new = curr;
		        newBlkSize = (new->size_status)-((new->size_status)%doubWord);
		    } else if(blkSize<newBlkSize){
		        new = curr;
		        newBlkSize = (new->size_status)-((new->size_status)&doubWord);
		    }
		    //get to end
		    /*
		    while(curr->size_status>1){
		        curr = (blockHeader*)((char*)curr+blkSize);
		    }*/
		    break;
	        } else{
		    curr = (blockHeader*)((char*)curr+blkSize);
	        }
	    }		
        }
    }
    if(new == NULL){
	fprintf(stderr,"No memory available\n");
	return NULL;
    }
    //get size of block to split
    int splitSize = (newBlkSize-totBlk);

    //create split
    blockHeader *split = (blockHeader*)((char*)new+totBlk);
    split->size_status = splitSize+2;

    //footer to split
    blockHeader *splitFtr = (blockHeader*) ((char*)split+splitSize-4);
    splitFtr->size_status = splitSize;

    //check if pred can be coalated
    blockHeader *pred = (blockHeader*)((char*)split+splitSize);
    int predBlkSS = pred->size_status;
    //check pred free and isn't end
    if(predBlkSS != 1 && (predBlkSS % 2) != 0){
	int predBlkSize = predBlkSS-(predBlkSS % doubWord);

	//set size of new split block
	split->size_status = (split->size_status)+predBlkSize;

	//footer
	splitFtr = (blockHeader*)((char*)split+splitSize+predBlkSize-4);
	splitFtr->size_status = splitSize+predBlkSize;
    }
    next = split;
    //set size status
    if(LSB == 2){
	new->size_status = totBlk+3;
    } else{
	new->size_status = totBlk+1;
    }
    return (blockHeader*)((char*)new+sizeof(blockHeader));
}

/* 
 * Function for freeing up a previously allocated block.
 * Argument ptr: address of the block to be freed up.
 * Returns 0 on success.
 * Returns -1 on failure.
 * This function should:
 * - Return -1 if ptr is NULL.
 * - Return -1 if ptr is not a multiple of 8.
 * - Return -1 if ptr is outside of the heap space.
 * - Return -1 if ptr block is already freed.
 * - USE IMMEDIATE COALESCING if one or both of the adjacent neighbors are free.
 * - Update header(s) and footer as needed.
 */                    
int freeHeap(void *ptr) { 	
    if(ptr == NULL){
	fprintf(stderr,"Memory is empty\n");
    	return -1;
    }

    int isNext=0;
    int doubWord=8;
    //header for block to free
    blockHeader *blkToFree = (blockHeader*)((char*)ptr-4);

    int sizeStat = blkToFree->size_status;

    //Least significant bit size_status
    int LSB = sizeStat % doubWord;

    //check if next
    if(ptr == next){
	isNext=1;
    }
    //Check if free
    if(LSB == 0){
	fprintf(stderr,"Block is already free\n");
	return -1;
    }

    //get size of block to be freed
    int sizeOfBTF = sizeStat-LSB;
    //check multiple of 8
    if(sizeOfBTF % 8 != 0){
	fprintf(stderr,"Not a multiple of 8\n");
	return -1;
    } else{
	blkToFree->size_status = (blkToFree->size_status)-1;

	//footer
	blockHeader *blkToFreeFtr = (blockHeader*)((char*)blkToFree + sizeOfBTF - 4);
	blkToFreeFtr->size_status = sizeOfBTF;

	//successor check
	blockHeader *succ = (blockHeader*)((char*)blkToFree + sizeOfBTF);

	if(succ->size_status != 1){
	    succ->size_status = (succ->size_status)-2;
	}
	if(next == succ){
	   isNext=1;
	}

	//size of successor
	int succSS = succ->size_status;

	//successor lsb
	int succLSB = succSS % doubWord;

	//check not at the end & can coalate with
	if((succSS != 1) && (succLSB % 2 == 0)){
	    //successor block size
	    int succSize = succSS-succLSB;
	    blkToFree->size_status = (blkToFree->size_status)+succSize;
	    blkToFreeFtr = (blockHeader*)((char*)blkToFree+sizeOfBTF+succSize-4);
	    blkToFreeFtr->size_status = sizeOfBTF+succSize;    
	}
	if(isNext == 1){
	    next = blkToFree;
	}
	//predeccessor
	sizeStat = blkToFree->size_status;
	LSB = sizeStat % doubWord;
	sizeOfBTF = sizeStat-LSB;

	//if LSB = 0 then pred is free
	if(LSB == 0){
	    blockHeader *predFtr = (blockHeader*)((char*)blkToFree-4);
	    int sizeOfPred = predFtr->size_status;
	    //get pred
	    blockHeader *predHdr = (blockHeader*)((char*)blkToFree-sizeOfPred);
	    predHdr->size_status = (predHdr->size_status)+sizeOfBTF;

	    //footer
	    blkToFreeFtr->size_status = sizeOfBTF+sizeOfPred;

	    if(isNext == 1){
		next = predHdr;
	    }
	}
    }
    return 0;
}

/*
 * Function used to initialize the memory allocator.
 * Intended to be called ONLY once by a program.
 * Argument sizeOfRegion: the size of the heap space to be allocated.
 * Returns 0 on success.
 * Returns -1 on failure.
 */                    
int initHeap(int sizeOfRegion) {         

    static int allocated_once = 0; //prevent multiple initHeap calls

    int pagesize;  // page size
    int padsize;   // size of padding when heap size not a multiple of page size
    int allocsize; // size of requested allocation including padding
    void* mmap_ptr; // pointer to memory mapped area
    int fd;

    blockHeader* endMark;
  
    if (0 != allocated_once) {
        fprintf(stderr, 
        "Error:mem.c: InitHeap has allocated space during a previous call\n");
        return -1;
    }
    if (sizeOfRegion <= 0) {
        fprintf(stderr, "Error:mem.c: Requested block size is not positive\n");
        return -1;
    }

    // Get the pagesize
    pagesize = getpagesize();

    // Calculate padsize as the padding required to round up sizeOfRegion 
    // to a multiple of pagesize
    padsize = sizeOfRegion % pagesize;
    padsize = (pagesize - padsize) % pagesize;

    allocsize = sizeOfRegion + padsize;

    // Using mmap to allocate memory
    fd = open("/dev/zero", O_RDWR);
    if (-1 == fd) {
        fprintf(stderr, "Error:mem.c: Cannot open /dev/zero\n");
        return -1;
    }
    mmap_ptr = mmap(NULL, allocsize, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
    if (MAP_FAILED == mmap_ptr) {
        fprintf(stderr, "Error:mem.c: mmap cannot allocate space\n");
        allocated_once = 0;
        return -1;
    }
  
    allocated_once = 1;

    // for double word alignment and end mark
    allocsize -= 8;

    // Initially there is only one big free block in the heap.
    // Skip first 4 bytes for double word alignment requirement.
    heapStart = (blockHeader*) mmap_ptr + 1;

    // Set the end mark
    endMark = (blockHeader*)((void*)heapStart + allocsize);
    endMark->size_status = 1;

    // Set size in header
    heapStart->size_status = allocsize;

    // Set p-bit as allocated in header
    // note a-bit left at 0 for free
    heapStart->size_status += 2;

    // Set the footer
    blockHeader *footer = (blockHeader*) ((char*)heapStart + allocsize - 4);
    footer->size_status = allocsize;
  
    next = heapStart;
    return 0;
    dumpMem();
}         
                 
/* 
 * Function to be used for DEBUGGING to help you visualize your heap structure.
 * Prints out a list of all the blocks including this information:
 * No.      : serial number of the block 
 * Status   : free/used (allocated)
 * Prev     : status of previous block free/used (allocated)
 * t_Begin  : address of the first byte in the block (where the header starts) 
 * t_End    : address of the last byte in the block 
 * t_Size   : size of the block as stored in the block header
 */                     
void dumpMem() {  

    int counter;
    char status[5];
    char p_status[5];
    char *t_begin = NULL;
    char *t_end   = NULL;
    int t_size;

    blockHeader *current = heapStart;
    counter = 1;

    int used_size = 0;
    int free_size = 0;
    int is_used   = -1;

    fprintf(stdout, "************************************Block list***\
                    ********************************\n");
    fprintf(stdout, "No.\tStatus\tPrev\tt_Begin\t\tt_End\t\tt_Size\n");
    fprintf(stdout, "-------------------------------------------------\
                    --------------------------------\n");
  
    while (current->size_status != 1) {
        t_begin = (char*)current;
        t_size = current->size_status;
    
        if (t_size & 1) {
            // LSB = 1 => used block
            strcpy(status, "used");
            is_used = 1;
            t_size = t_size - 1;
        } else {
            strcpy(status, "Free");
            is_used = 0;
        }

        if (t_size & 2) {
            strcpy(p_status, "used");
            t_size = t_size - 2;
        } else {
            strcpy(p_status, "Free");
        }

        if (is_used) 
            used_size += t_size;
        else 
            free_size += t_size;

        t_end = t_begin + t_size - 1;
    
        fprintf(stdout, "%d\t%s\t%s\t0x%08lx\t0x%08lx\t%d\n", counter, status, 
        p_status, (unsigned long int)t_begin, (unsigned long int)t_end, t_size);
    
        current = (blockHeader*)((char*)current + t_size);
        counter = counter + 1;
    }

    fprintf(stdout, "---------------------------------------------------\
                    ------------------------------\n");
    fprintf(stdout, "***************************************************\
                    ******************************\n");
    fprintf(stdout, "Total used size = %d\n", used_size);
    fprintf(stdout, "Total free size = %d\n", free_size);
    fprintf(stdout, "Total size = %d\n", used_size + free_size);
    fprintf(stdout, "***************************************************\
                    ******************************\n");
    fflush(stdout);

    return;  
}  

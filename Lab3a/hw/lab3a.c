#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <fcntl.h>
#include "ext2_fs.h"

#define EXT2_S_IFREG	0x8000
#define EXT2_S_IFDIR	0x4000
#define EXT2_S_IFLNK	0xA000

int imageDescriptor=-1;
struct ext2_super_block blockInfo;
int blockSize=-1;
int numOfGroups=-1;
int blocks_per_group = -1;
struct ext2_group_desc * group_desc;
struct ext2_dir_entry directory;

void superblock_summary();
void group_summary();
void free_block_entries();
void free_inode_entries();
void print_time();
void indirect_entries_recursion();
void indirect_entries();
void inode_summary();

int main(int argc, char **argv){
    if(argc != 2) {
        fprintf(stderr,"Incorrect Arugments: ./lab3a name.image\n");
        exit(1);
    }
    const char *image = argv[1];
    imageDescriptor = open(image, O_RDONLY);
    if(imageDescriptor < 0){
        fprintf(stderr,"cannot open image \n");
        close(imageDescriptor);
        exit(2);
    }
    superblock_summary();
    group_summary();
    free_block_entries();
    free_inode_entries();
    inode_summary();
    free(group_desc);
    exit(0);
}

void superblock_summary(){
    if(pread(imageDescriptor,&blockInfo,sizeof(struct ext2_super_block),EXT2_MIN_BLOCK_SIZE) < 0){
        fprintf(stderr,"pread superblock fail\n");
        close(imageDescriptor);
        exit(2);
    }
    if(EXT2_SUPER_MAGIC != blockInfo.s_magic){
        fprintf(stderr,"magic number mismatch\n");
        close(imageDescriptor);
        exit(2);
    }
    blockSize = EXT2_MIN_BLOCK_SIZE << blockInfo.s_log_block_size;
    printf("SUPERBLOCK,%d,%d,%d,%d,%d,%d,%d\n",blockInfo.s_blocks_count,blockInfo.s_inodes_count,blockSize,blockInfo.s_inode_size,blockInfo.s_blocks_per_group,blockInfo.s_inodes_per_group,blockInfo.s_first_ino);

    numOfGroups = blockInfo.s_blocks_count/blockInfo.s_blocks_per_group+1;
    blocks_per_group = blockInfo.s_blocks_per_group;
    group_desc = (struct ext2_group_desc*)malloc(blockSize);
}

void group_summary(){
	if(pread(imageDescriptor,group_desc,blockSize,blockSize*2) < 0){
    	fprintf(stderr,"pread group_summary fail\n");
    	close(imageDescriptor);
    	exit(2);
	}
    int i;
	for(i = 0; i < numOfGroups; i++){
		if(i != numOfGroups - 1){
			printf("GROUP,%d,%d,%d,%d,%d,%d,%d,%d\n", i,blocks_per_group,blockInfo.s_inodes_per_group,group_desc[i].bg_free_blocks_count,
				group_desc[i].bg_free_inodes_count, 3, 4, 5);
		} else {
			int num_inodes = 0;
			int num_blocks_per_group = 0;
			if(blockInfo.s_blocks_count%blocks_per_group==0) num_blocks_per_group = blocks_per_group;
			else num_blocks_per_group = blockInfo.s_blocks_count%blocks_per_group;
			if(blockInfo.s_inodes_count%blockInfo.s_inodes_per_group==0) num_inodes = blockInfo.s_inodes_per_group;
			else num_inodes = blockInfo.s_inodes_count%blockInfo.s_inodes_per_group;

			printf("GROUP,%d,%d,%d,%d,%d,%d,%d,%d\n", i,num_blocks_per_group,
				num_inodes,group_desc[i].bg_free_blocks_count,
				group_desc[i].bg_free_inodes_count, 3, 4, 5);
		}
	}

}

void free_block_entries(){
	unsigned char *free_block_bitmap = (unsigned char*)group_desc;
	if( pread(imageDescriptor,free_block_bitmap,blockSize,blockSize*3) < 0){
    	fprintf(stderr,"pread free_block_entries fail\n");
    	close(imageDescriptor);
    	exit(2);
	}
	int i, j;
	for(i = 0; i < blockSize; i++){
		for(j = 0; j < 8; j++)
			if(free_block_bitmap[i]>>j&1){
				continue;
			} else {
				printf("BFREE,%d\n", i*8+j+1);
			}
	}

}

void free_inode_entries(){
	unsigned char *free_inode_bitmap = (unsigned char*)group_desc;
	if( pread(imageDescriptor,free_inode_bitmap,blockSize,blockSize*4) < 0){
    	fprintf(stderr,"pread free_inode_entries fail\n");
    	close(imageDescriptor);
    	exit(2);
	}
	int i, j;
	for(i = 0; i < blockSize; i++){
		for(j = 0; j < 8; j++)
			if(free_inode_bitmap[i]>>j&1){
			    continue;
			} else {
				printf("IFREE,%d\n", i*8+j+1);
			}
	}
}

void print_time(int timestamp){
	char buffer[26] = {0};
    time_t current = timestamp;
    struct tm* timeInfo;
    timeInfo = gmtime(&current);
    strftime(buffer, 26, "%m/%d/%y %H:%M:%S", timeInfo);
    printf("%s",buffer);
}

void indirect_entries_recursion(int inode_no, uint32_t block_no, int level, uint32_t oldoffset){
  	if(level==0){
  	    return;
  	}
  	uint32_t pointers[EXT2_MIN_BLOCK_SIZE];
  	memset(pointers,0,EXT2_MIN_BLOCK_SIZE*4);
   	if (pread(imageDescriptor, pointers, blockSize, block_no*blockSize) < 0) {
    	fprintf(stderr, "Incorrect pread\n");
    	exit(1);
   	}
   	int i;
   	for(i=0; i<blockSize/4; i++){
     	if(pointers[i]==0) {
     	    continue;
     	}
     	uint32_t offset = oldoffset+(uint32_t)(i*pow(256, level-1));
     	printf("INDIRECT,%u,%u,%u,%u,%u\n",inode_no,level,offset,block_no,pointers[i]);
     	if(level>1){
     		indirect_entries_recursion(inode_no,pointers[i],level-1,offset);
     	}
   }
}

void indirect_entries(unsigned int inode_no, unsigned int level, uint32_t block_no){
    if(level==0){
        return;
    }
    uint32_t pointers[EXT2_MIN_BLOCK_SIZE];
    memset(pointers,0,EXT2_MIN_BLOCK_SIZE*4);
    if (pread(imageDescriptor, pointers, blockSize, block_no*blockSize) < 0) {
        fprintf(stderr, "Incorrect pread\n");
        exit(1);
    }
    int i;
    for(i=0;i<blockSize/4;i++){
        if(pointers[i]==0){continue;}
        if(level==2 || level==3){indirect_entries(inode_no,level-1,pointers[i]);}

        int externaloffset=pointers[i]*blockSize;
        int internaloffset=0;
        while(internaloffset<blockSize){
            if(pread(imageDescriptor,&directory,sizeof(struct ext2_dir_entry),externaloffset+internaloffset)<0){
	            fprintf(stderr,"pread free_inode_entries fail\n");
	            close(imageDescriptor);
	            exit(2);
            }
            if(directory.inode==0){
                internaloffset+=directory.rec_len;
                continue;
            }
            printf("DIRENT,%d,%d,%d,%d,%d,'%s'\n",inode_no,internaloffset, directory.inode,directory.rec_len,directory.name_len,directory.name);
            internaloffset+=directory.rec_len;
        }
    }
}

void inode_summary(){
	int num_bytes =  blockInfo.s_inodes_per_group*blockInfo.s_inode_size;
	struct ext2_inode *inodes = (struct ext2_inode *)malloc( num_bytes);
	if(pread(imageDescriptor,inodes, num_bytes, blockSize*5) < 0){
    	fprintf(stderr,"pread free_inode_entries fail\n");
    	close(imageDescriptor);
    	exit(2);
	}
	unsigned int i;
	for(i = 0; i < blockInfo.s_inodes_per_group; i++){
		char file_type = '?';
		if(inodes[i].i_mode == 0 || inodes[i].i_links_count == 0){
		    continue;
		}
		if ((inodes[i].i_mode&EXT2_S_IFREG) == EXT2_S_IFREG){
		    file_type = 'f';
		}
		if ((inodes[i].i_mode&EXT2_S_IFDIR) == EXT2_S_IFDIR){
		    file_type = 'd';
		}
		if ((inodes[i].i_mode&EXT2_S_IFLNK) == EXT2_S_IFLNK){
		    file_type = 's';
		}

		printf("INODE,%d,%c,%o,%d,%d,%d,", i+1, file_type, (inodes[i].i_mode&4095), (inodes[i].i_uid), (inodes[i].i_gid), (inodes[i].i_links_count));
		print_time(inodes[i].i_ctime);
		printf(",");
		print_time(inodes[i].i_mtime);
		printf(",");
		print_time(inodes[i].i_atime);
		printf(",%d,%d",inodes[i].i_size,inodes[i].i_blocks);
		int k;
	    for(k = 0; k < EXT2_N_BLOCKS; k++){
	    	if(file_type!='s'){
	    		printf(",%d", inodes[i].i_block[k]);
	    	}
	    	else{
	    		printf(",%d", inodes[i].i_block[k]);
	    		break;
	    	}
	    }
	    printf("\n");
	    if(file_type=='d'){
	        int j;
	        for(j=0; j<12; j++){
				if(inodes[i].i_block[j]==0){
				    continue;
				}
				int externaloffset=inodes[i].i_block[j]*blockSize;
				int internaloffset=0;
				while(internaloffset<blockSize){
				    if( pread(imageDescriptor, &directory,sizeof(struct ext2_dir_entry), externaloffset+internaloffset)<0 ){
				        fprintf(stderr,"pread free_inode_entries fail\n");
				        close(imageDescriptor);
				        exit(2);
				    }
				    if(directory.inode==0){
				        internaloffset+=directory.rec_len;
				        continue;
				    }
				    printf("DIRENT,%d,%d,%d,%d,%d,'%s'\n",i+1,internaloffset, directory.inode,directory.rec_len,directory.name_len,directory.name);
				    internaloffset+=directory.rec_len;
				}
	       	}
	      	for(j=12; j<15; j++){
		 		if(inodes[i].i_block[j]!=0){
		   			indirect_entries(i+1,j-11,inodes[i].i_block[j]);
		   		}
	       	}
	      }

	        if (inodes[i].i_block[EXT2_IND_BLOCK] != 0) {
			    indirect_entries_recursion(i+1, inodes[i].i_block[EXT2_IND_BLOCK], 1, 12);
	        }
	        if (inodes[i].i_block[EXT2_DIND_BLOCK] != 0) {
			    indirect_entries_recursion(i+1, inodes[i].i_block[EXT2_DIND_BLOCK], 2, 12+EXT2_MIN_BLOCK_SIZE/4);
	        }
	        if (inodes[i].i_block[EXT2_TIND_BLOCK] != 0) {
			    indirect_entries_recursion(i+1, inodes[i].i_block[EXT2_TIND_BLOCK], 3, 12+256+256*256);
	        }
	}
	free(inodes);
}
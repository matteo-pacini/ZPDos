#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <process.h>

int main(int argc, char *argv[]) {

    clock_t start, end;
    int status;

    if (argc < 2) {
        printf("Usage: %s <program-to-launch> [arguments...]\n", argv[0]);
        return 1;
    }

    printf("ZPDos' MEASURE.EXE - Execution time measurement tool\n");
    printf("----------------------------------------------------\n");

    start = clock();

    status = spawnvp(P_WAIT, argv[1], &argv[1]);

    if (status == -1) {
        perror("Error launching external program");
        return 1;
    }
    
    end = clock();

    printf("----------------------------------------------------\n");
    printf("Execution time: %.2f seconds.\n", (double)(end - start) / CLOCKS_PER_SEC);

    return 0;
}

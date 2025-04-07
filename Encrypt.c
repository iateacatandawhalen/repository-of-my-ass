#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void encrypt(FILE *input, FILE *output, int shift) {
    char c;

    while ((c = fgetc(input)) != EOF) {
        if (c == '\n') {
            fputc(c, output);  // Preserve newline characters
        } else if (c >= 'a' && c <= 'z') {
            fputc((c - 'a' + shift) % 26 + 'a', output);  // Encrypt lowercase letters
        } else if (c >= 'A' && c <= 'Z') {
            fputc((c - 'A' + shift) % 26 + 'A', output);  // Encrypt uppercase letters
        } else {
            fputc(c, output);  // Copy other characters (such as spaces, punctuation, etc.)
        }
    }
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <input file> <shift value>\n", argv[0]);
        return 1;
    }

    FILE *inputFile = fopen(argv[1], "r");
    if (inputFile == NULL) {
        perror("Failed to open input file");
        return 1;
    }

    int shift = atoi(argv[2]);
    FILE *outputFile = fopen("o.txt", "w");
    if (outputFile == NULL) {
        perror("Failed to open output file");
        fclose(inputFile);
        return 1;
    }

    encrypt(inputFile, outputFile, shift);

    fclose(inputFile);
    fclose(outputFile);

    printf("File encrypted successfully. Output saved to 'o.txt'.\n");
    return 0;
}

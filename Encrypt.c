#include <stdio.h>
#include <stdlib.h>  // For atoi()
#include <string.h>  // For potential future string operations

void encrypt_decrypt(FILE *input_file, FILE *output_file, int shift) {
    char ch;

    // Check if shift is negative and adjust accordingly
    if (shift < 0) {
        shift = -shift; // Reverse the direction for negative shift (decryption)
    }

    while ((ch = fgetc(input_file)) != EOF) {
        if ('a' <= ch && ch <= 'z') {
            ch = ((ch - 'a' + shift) % 26 + 26) % 26 + 'a';  // Wrap within 'a' to 'z'
        } else if ('A' <= ch && ch <= 'Z') {
            ch = ((ch - 'A' + shift) % 26 + 26) % 26 + 'A';  // Wrap within 'A' to 'Z'
        }

        fputc(ch, output_file);  // Write encrypted or decrypted character to output
    }
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <input file> <shift>\n", argv[0]);
        return 1;
    }

    FILE *input_file = fopen(argv[1], "r");
    if (input_file == NULL) {
        perror("Error opening input file");
        return 1;
    }

    FILE *output_file = fopen("o.txt", "w");
    if (output_file == NULL) {
        perror("Error opening output file");
        fclose(input_file);
        return 1;
    }

    int shift = atoi(argv[2]);  // Convert shift value from string to integer

    // Encrypt or decrypt based on shift value
    encrypt_decrypt(input_file, output_file, shift);

    fclose(input_file);
    fclose(output_file);

    printf("Operation completed successfully. The result is saved in 'o.txt'.\n");

    return 0;
}
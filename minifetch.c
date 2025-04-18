#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/utsname.h>

void print_hostname() {
    char hostname[256];
    gethostname(hostname, sizeof(hostname));
    printf("Hostname: %s\n", hostname);
}

void print_uname() {
    struct utsname uts;
    if (uname(&uts) == 0) {
        printf("OS: %s %s\n", uts.sysname, uts.release);
        printf("Kernel: %s\n", uts.version);
        printf("Arch: %s\n", uts.machine);
    }
}

void print_uptime() {
    FILE *fp = fopen("/proc/uptime", "r");
    if (fp) {
        double uptime;
        fscanf(fp, "%lf", &uptime);
        int days = uptime / 86400;
        int hours = ((int)uptime % 86400) / 3600;
        int minutes = ((int)uptime % 3600) / 60;
        printf("Uptime: %dd %dh %dm\n", days, hours, minutes);
        fclose(fp);
    }
}

void detect_intel_gen(const char* model_name) {
    if (strstr(model_name, "i3-2") || strstr(model_name, "i5-2") || strstr(model_name, "i7-2"))
        printf("(Generation: Sandy Bridge)\n");
    else if (strstr(model_name, "i3-3") || strstr(model_name, "i5-3") || strstr(model_name, "i7-3"))
        printf("(Generation: Ivy Bridge)\n");
    else if (strstr(model_name, "i3-4") || strstr(model_name, "i5-4") || strstr(model_name, "i7-4"))
        printf("(Generation: Haswell)\n");
    else if (strstr(model_name, "i3-5") || strstr(model_name, "i5-5") || strstr(model_name, "i7-5"))
        printf("(Generation: Broadwell)\n");
    else if (strstr(model_name, "i3-6") || strstr(model_name, "i5-6") || strstr(model_name, "i7-6"))
        printf("(Generation: Skylake)\n");
    else if (strstr(model_name, "i3-7") || strstr(model_name, "i5-7") || strstr(model_name, "i7-7"))
        printf("(Generation: Kaby Lake)\n");
    else if (strstr(model_name, "i3-8") || strstr(model_name, "i5-8") || strstr(model_name, "i7-8"))
        printf("(Generation: Coffee Lake)\n");
    else if (strstr(model_name, "i3-9") || strstr(model_name, "i5-9") || strstr(model_name, "i7-9"))
        printf("(Generation: Coffee Lake Refresh)\n");
    else if (strstr(model_name, "i3-10") || strstr(model_name, "i5-10") || strstr(model_name, "i7-10"))
        printf("(Generation: Comet Lake / Ice Lake)\n");
    else if (strstr(model_name, "i3-11") || strstr(model_name, "i5-11") || strstr(model_name, "i7-11"))
        printf("(Generation: Tiger Lake / Rocket Lake)\n");
    else if (strstr(model_name, "i3-12") || strstr(model_name, "i5-12") || strstr(model_name, "i7-12"))
        printf("(Generation: Alder Lake)\n");
    else if (strstr(model_name, "i3-13") || strstr(model_name, "i5-13") || strstr(model_name, "i7-13"))
        printf("(Generation: Raptor Lake)\n");
    else
        printf("(Generation: Unknown / Non-Intel / Older than Sandy Bridge)\n");
}

void print_cpu_model_and_gen() {
    FILE *fp = fopen("/proc/cpuinfo", "r");
    if (fp) {
        char line[256], model_name[256] = "";
        while (fgets(line, sizeof(line), fp)) {
            if (strstr(line, "model name") || strstr(line, "Processor")) {
                char *colon = strchr(line, ':');
                if (colon) {
                    strcpy(model_name, colon + 2); // Save model name
                    printf("CPU: %s", model_name);
                    detect_intel_gen(model_name);
                    break;
                }
            }
        }
        fclose(fp);
    }
}

void print_memory() {
    FILE *fp = fopen("/proc/meminfo", "r");
    if (fp) {
        char label[64];
        unsigned long total;
        fscanf(fp, "%s %lu", label, &total);
        printf("RAM: %lu MB total\n", total / 1024);
        fclose(fp);
    }
}

void print_gpu_info() {
    FILE *fp = popen("lspci | grep -i 'vga\\|3d'", "r");
    if (!fp) {
        perror("Failed to run lspci");
        return;
    }

    char line[512];
    if (fgets(line, sizeof(line), fp)) {
        char *desc = strchr(line, ' ');
        if (desc) {
            while (*desc == ' ') desc++;
            printf("GPU: %s", desc);
        }
    } else {
        printf("GPU: Not detected or lspci not available\n");
    }

    pclose(fp);
}

int main() {
    printf("=== Minifetch ===\n");
    print_hostname();
    print_uname();
    print_uptime();
    print_cpu_model_and_gen();
    print_memory();
    print_gpu_info();
    return 0;
}
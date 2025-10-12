#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

pid_t child_pid;
int total_signals;
int sent = 0;
int acked = 0;
int received = 0;

void receiver_handler(int sig) {
    if (sig == SIGUSR1) {
        received++;
        printf("receiver: received signal #%d and sending ack\n", received);
        kill(getppid(), SIGUSR1);
    } else if (sig == SIGINT) {
        printf("receiver: received %d signals\n", received);
        _exit(0);
    }
}

void ack_handler(int sig) { 
    acked++;
}

void alarm_handler(int sig) { 
    if (acked >= total_signals) {
        printf("all signals have been sent!\n");
        kill(child_pid, SIGINT);
        exit(0);
    } else {
        printf("sender: total remaining signal(s): %d\n", total_signals - acked);
        kill(child_pid, SIGUSR1);
        alarm(1);
    }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <number_of_signals>\n", argv[0]);
        exit(1);
    }

    total_signals = atoi(argv[1]);
    if (total_signals <= 0) {
        fprintf(stderr, "Invalid number of signals\n");
        exit(1);
    }

    child_pid = fork();

    if (child_pid == 0) { 
        signal(SIGUSR1, receiver_handler);
        signal(SIGINT, receiver_handler);
        while (1)
            pause();
    } else { 
        signal(SIGUSR1, ack_handler);
        signal(SIGALRM, alarm_handler);

        for (int i = 0; i < total_signals; i++) {
            kill(child_pid, SIGUSR1);
            sent++;
        }

        alarm(1);

        while (1)
            pause();

        wait(NULL);
    }

    return 0;
}


CC = gcc
CFLAGS = -Wall
TARGET = signal_lab

all: $(TARGET)

$(TARGET): signal_lab.c
	$(CC) $(CFLAGS) -o $(TARGET) signal_lab.c

clean:
	rm -f $(TARGET)

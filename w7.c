#include <fcntl.h>
#include <editline/readline.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include "helper.h"

int parse(Token* tokens, Pipeline* pipeline) {
    pipeline->num_commands = 0;
    pipeline->is_in_background = false;

    size_t cmd_idx = 0;
    size_t arg_idx = 0;
    pipeline->commands[cmd_idx] = (Command){ .args = {NULL}, .stdin = NULL, .stdout = NULL, .num_args = 0, .append_stdout = false };

    for (int i = 0; tokens[i].type != TOKEN_END; i++) {
        Token token = tokens[i];
        switch (token.type) {
            case TOKEN_COMMAND:
            case TOKEN_ARGUMENT:
                pipeline->commands[cmd_idx].args[arg_idx++] = token.data;
                pipeline->commands[cmd_idx].num_args = arg_idx;
                break;

            case TOKEN_PIPE:
                pipeline->commands[cmd_idx].args[arg_idx] = NULL;
                cmd_idx++;
                arg_idx = 0;
                pipeline->commands[cmd_idx] = (Command){ .args = {NULL}, .stdin = NULL, .stdout = NULL, .num_args = 0, .append_stdout = false };
                break;

            case TOKEN_REDIRECT_IN:
                i++;
                pipeline->commands[cmd_idx].stdin = tokens[i].data;
                break;

            case TOKEN_REDIRECT_OUT:
                i++;
                pipeline->commands[cmd_idx].stdout = tokens[i].data;
                pipeline->commands[cmd_idx].append_stdout = false;
                break;

            case TOKEN_REDIRECT_APPEND:
                i++;
                pipeline->commands[cmd_idx].stdout = tokens[i].data;
                pipeline->commands[cmd_idx].append_stdout = true;
                break;

            default:
                break;
        }
    }

    pipeline->commands[cmd_idx].args[arg_idx] = NULL;
    pipeline->num_commands = cmd_idx + 1;

    return 0;
}

int interpret(Pipeline* pipeline, Job* job) {
    job->num_processes = 0;

    if (pipeline->num_commands == 0)
        return 0;

    if (pipeline->num_commands == 1) {
        Command* cmd = &pipeline->commands[0];
        int stdin_copy = -1, stdout_copy = -1;

        if (cmd->stdin) {
            stdin_copy = dup(STDIN_FILENO);
            int fd = open(cmd->stdin, O_RDONLY);
            if (fd < 0) {
                perror("open (stdin)");
                return -1;
            }
            dup2(fd, STDIN_FILENO);
            close(fd);
        }

        if (cmd->stdout) {
            stdout_copy = dup(STDOUT_FILENO);
            int flags = O_WRONLY | O_CREAT | (cmd->append_stdout ? O_APPEND : O_TRUNC);
            int fd = open(cmd->stdout, flags, 0644);
            if (fd < 0) {
                perror("open (stdout)");
                return -1;
            }
            dup2(fd, STDOUT_FILENO);
            close(fd);
        }

        do_exec(cmd, false);

        if (stdin_copy != -1) {
            dup2(stdin_copy, STDIN_FILENO);
            close(stdin_copy);
        }
        if (stdout_copy != -1) {
            dup2(stdout_copy, STDOUT_FILENO);
            close(stdout_copy);
        }

        return 0;
    }

    if (pipeline->num_commands == 2) {
        Command* cmd1 = &pipeline->commands[0];
        Command* cmd2 = &pipeline->commands[1];
        int pipefd[2];
        pid_t pid1, pid2;

        if (pipe(pipefd) == -1) {
            perror("pipe");
            return -1;
        }

        if ((pid1 = fork()) == 0) {
            close(pipefd[0]);
            dup2(pipefd[1], STDOUT_FILENO);
            close(pipefd[1]);
            execvp(cmd1->args[0], cmd1->args);
            perror("execvp (cmd1)");
            exit(1);
        }

        // second command
        if ((pid2 = fork()) == 0) {
            close(pipefd[1]);
            dup2(pipefd[0], STDIN_FILENO);
            close(pipefd[0]);
            execvp(cmd2->args[0], cmd2->args);
            perror("execvp (cmd2)");
            exit(1);
        }

        close(pipefd[0]);
        close(pipefd[1]);
        waitpid(pid1, NULL, 0);
        waitpid(pid2, NULL, 0);
    }

    return 0;
}

int main() {
    while (1) {
        char* cmd = readline("$ ");
        if (cmd == NULL)
            break;

        add_history(cmd);
        evaluate(cmd);
        free(cmd);
    }
    return 0;
}


// makefile
CC = gcc
CFLAGS = -Wall -Wextra -g
TARGET = w7
OBJS = week7.o helper.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

week7.o: week7.c helper.h
	$(CC) $(CFLAGS) -c week7.c

helper.o: helper.c helper.h
	$(CC) $(CFLAGS) -c helper.c

clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: all clean

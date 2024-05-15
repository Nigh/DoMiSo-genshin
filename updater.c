
#include <process.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tchar.h>
#include <windows.h>
#include <winuser.h>

#define ORIGIN_ME "___ORIGIN_ME___"
#define KILL_ME "___KILL_ME___"
#define DELETE_ME "___delete_me___.exe"

// USAGE:
// .\updater.exe ___ORIGIN_ME___ app.zip app.exe

// Compile:
// tcc .\updater.c -luser32

void unzip(const char *path) {
    TCHAR wpath[128];
    TCHAR cmd[128];

    sprintf(wpath, "%s", path);
    sprintf(cmd, "powershell -command \"Expand-Archive -Force %s .\"", path);
    printf("cmd=%s\n", cmd);
    printf("Sleep 200ms\n");
    Sleep(200);
    system(cmd);
    DeleteFile(wpath);
}

void runNewBinary(const char *path) {
    TCHAR cmd[128];
    STARTUPINFO si = {sizeof(si)};
    PROCESS_INFORMATION pi;
    sprintf(cmd, "%s", path);
    CreateProcess(NULL, cmd, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi);
}

void cloneSelf() {
    TCHAR selfPath[_MAX_PATH];
    GetModuleFileName(NULL, selfPath, _MAX_PATH);
    printf("%d = Copy %s to %s\n", CopyFile(selfPath, DELETE_ME, FALSE), selfPath, DELETE_ME);
    HANDLE hfile = CreateFile(DELETE_ME, 0, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_FLAG_DELETE_ON_CLOSE, NULL);
    printf("HANDLE(%d) = Create %s in FILE_FLAG_DELETE_ON_CLOSE\n", hfile, DELETE_ME);
    HANDLE hProcessOrig = OpenProcess(SYNCHRONIZE, TRUE, GetCurrentProcessId());
    printf("Origin HANDLE = %d\n", hProcessOrig);

    // Create clone process
    TCHAR cmd[256];
    wsprintf(cmd, __T("%s " KILL_ME " %d \"%s\""), DELETE_ME, hProcessOrig, selfPath);
    printf("%s\n", cmd);
    STARTUPINFO si;
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    PROCESS_INFORMATION pi;
    CreateProcess(NULL, cmd, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi);

    printf("Close(%d)\n", hProcessOrig);
    CloseHandle(hProcessOrig);
    printf("Close(%d)\n", hfile);
    CloseHandle(hfile);
}

void delete_original(const char *handle, const char *path) {
    HANDLE hProcessOrig = (HANDLE)_ttoi(handle);
    printf("[k]Wait(%d)\n", hProcessOrig);
    WaitForSingleObject(hProcessOrig, INFINITE);
    printf("[k]Close(%d)\n", hProcessOrig);
    CloseHandle(hProcessOrig);
    printf("[k]DeleteFile(%s)\n", path);
    DeleteFile(path);
}

int main(int argc, const char *argv[]) {

    // printf("argc=%d\n", argc);
    // for (size_t i = 0; i < argc; i++) {
    //     printf("argv[%d]=%s\n", i, argv[i]);
    // }

    if (argc != 4) {
        return -1;
    }

    if (strcmp(argv[1], ORIGIN_ME) == 0) {
        printf("--> unzip\n");
        unzip(argv[2]);
        printf("--> runNewBinary\n");
        runNewBinary(argv[3]);
        printf("--> cloneSelf\n");
        cloneSelf();
    } else if (strcmp(argv[1], KILL_ME) == 0) {
        printf("-->[k] killSelf\n");
        delete_original(argv[2], argv[3]);
    }
    return 0;
}

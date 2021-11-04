#include "framework.h"


#pragma comment(lib, "legacy_stdio_definitions.lib")
#pragma comment(lib, "ws2_32.lib")

// dllmain.cpp : Defines the entry point for the DLL application.

BOOL __declspec(dllexport) APIENTRY
    DllMain(HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}


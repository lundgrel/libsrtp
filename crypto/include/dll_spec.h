#ifndef __DLL_SPEC_H
#define __DLL_SPEC_H


#if defined(SRTP_DLL_EXPORTS)
#define API_METHOD __declspec(dllexport) 
#elif defined(SRTP_DLL_IMPORT)
#define API_METHOD __declspec(dllimport)
#else
#define API_METHOD /* no declspec(dll) specified */
#endif



#endif /*__DLL_SPEC_H */
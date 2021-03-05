#include <iostream>
#include <wtypes.h>


typedef unsigned char byte;
typedef void (*CONVERT_TO_RPN)(byte[], int, int,byte[]);
int main()
{
    //byte a[27] = { 255,255,255,255,255,255,255,255,255,255,255,255,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255 };
    byte a[60] = { 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
                   255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
                   255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
                   255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255};
    byte b[60];
    std::cout << "a address:" << &a;
    std::cout << "b address:" << &b;
    CONVERT_TO_RPN convertToRpnProc;
    HINSTANCE hDll = NULL;
    hDll = LoadLibrary(TEXT("Projekt_JA_ASM"));
    convertToRpnProc = (CONVERT_TO_RPN)GetProcAddress(hDll, "filter");
    (convertToRpnProc)(a, 5, 5, b);
    for (int i = 0; i < 60; i++) {
        std::cout << "a[" << i << "] = " << a[i] * 1 << " ";
        std::cout << "b[" << i << "] = " << b[i] * 1 << std::endl;
    }
}
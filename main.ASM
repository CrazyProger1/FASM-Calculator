format PE console

entry start


include 'win32a.inc'

section '.data' data readable writable
        titleMsg db 'Calculator V0.1 by @crazyproger1', 0
        exitMsg db 'To exit press any key...', 0

        enterFnMsg db 'Enter first operand: ', 0
        enterSnMsg db 'Enter second operand: ', 0

        enterActionMsg db 'Enter operator (supported: + - * /): ', 0
        wrongActionMsg db 'This action does not supported yet =(', 0
        continueMsg db 'Do you want to continue (Y/N)?', 0

        emptyStr db '%d', 0
        pointStr db ',', 0

        resStr db 'Result: %d', 0

        endlStr db 0Dh, 0Ah ,0

        formatStr db ' %s', 0
        formatNum db ' %d', 0
        formatFloat db ' %f', 0


        fnum dd ?
        snum dd ?
        rest dd ?
        result dd ?

        NULL equ 0
        DECIMAL_PLACES equ 3







section '.code' code readable executable

        proc print txt, endl
                push [txt]
                call [printf]
                pop eax
                mov edx, [endl]
                cmp edx, TRUE
                jne notEndl
                     push endlStr
                     call [printf]
                notEndl:
                ret
        endp

        proc input msg, var, format
              stdcall print, [msg], 0
              push [var]
              push [format]
              call [scanf]
              ret
        endp

        macro endl{
             stdcall print, endlStr, 0
        }

        mainlp:
                endl
                stdcall input, enterFnMsg, fnum, formatNum
                stdcall input, enterSnMsg, snum, formatNum

                stdcall print, enterActionMsg, 0
                call [getch]

                cmp eax, 43 ; check if input char is +
                je plus
                cmp eax, 45 ; check if input char is -
                je minus
                cmp eax, 42 ; check if input char is *
                je multiply
                cmp eax, 47
                je divide

                jmp wrongAction

                plus:
                        mov ecx, [fnum]
                        add ecx, [snum]
                        mov [result], ecx
                        jmp res

                minus:
                        mov ecx, [fnum]
                        sub ecx, [snum]
                        mov [result], ecx
                        jmp res

                multiply:
                        mov ecx, [fnum]
                        imul ecx, [snum]
                        mov [result], ecx
                        jmp res

                divide:
                        mov edx, 0 ; reset the rest
                        mov eax, [fnum]
                        div [snum]
                        mov [result], eax
                        mov [rest], edx

                        endl
                        push [result]
                        push resStr
                        call [printf]

                        mov edx, [rest]
                        cmp edx, 0
                        je askcontinue

                        stdcall print, pointStr, 0

                        mov ebx, 0
                        divlp:
                                mov edx, 0 ; reset the rest
                                mov eax, [rest]
                                imul eax, 10
                                div [snum]

                                push eax
                                push emptyStr
                                call [printf]

                                mov [rest], edx


                                inc ebx
                                cmp ebx, DECIMAL_PLACES
                        jne divlp

                        jmp askcontinue


                wrongAction:
                        stdcall print, wrongActionMsg, 1

                askcontinue:
                        endl
                        stdcall print, continueMsg, 0
                        call [getch]
                        cmp eax, 89
                        je mainlp
                        jmp exit



        start:
                stdcall print, titleMsg, 1



                jmp mainlp

        res:
                endl
                push [result]
                push resStr
                call [printf]
                jmp askcontinue

        exit:
                endl
                stdcall print, exitMsg, 0
                call [getch]
                push NULL
                call [ExitProcess]










section '.idata' import data readable
        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'

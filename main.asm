.486
.model flat,stdcall
option casemap:none

;///////////////////////////////////////////////////////////////////////////////
; Include�ļ�����
;///////////////////////////////////////////////////////////////////////////////
include windows.inc
include user32.inc
include kernel32.inc
include masm32.inc

includelib user32.lib
includelib kernel32.lib
includelib masm32.lib
include \masm32\macros\macros.asm
;///////////////////////////////////////////////////////////////////////////////
; EQU ����
;///////////////////////////////////////////////////////////////////////////////
ICO_MAIN 	equ 103;ͼ��
DLG_MAIN 	equ 101
IDM_ABOUT 	equ 40001
IDM_EXIT	equ 40002
IDC_COMBO1  equ 1001 ;����
IDC_COMBO2  equ 1003 ;������
IDC_COMBO3  equ 1004 ;У��λ
IDC_COMBO4  equ 1005 ;����λ
IDC_COMBO5  equ 1006 ;ֹͣλ
IDC_LIST1   equ 1008 ;��������
IDC_EDIT   equ 1009 ;���������
IDC_BTN_OPEN equ 1011 ;�򿪴��ڰ�ť


BUTTON_RED equ 2001;��ɫ��ť
BUTTON_GREEN equ 2002;��ɫ��ť
BUTTON_BLUE equ 2003;��ɫ��ť
BUTTON_WHITE equ 2004;��ɫ��ť
BUTTON_YELLOW equ 2005;��ɫ��ť
BUTTON_PURPLE equ 2006;��ɫ��ť
BUTTON_CYAN equ 2007;��ɫ��ť
BUTTON_DARK equ 2008;��ɫ��ť

BUTTON_SYNC_TIME equ 2009;��ɫ��ť
;///////////////////////////////////////////////////////////////////////////////
; ���ݶ�
;///////////////////////////////////////////////////////////////////////////////
.data
Parity	BYTE EVENPARITY,ODDPARITY,NOPARITY,MARKPARITY,SPACEPARITY
szFromatTime db  'P6%02d%02d%02d', 0


.data?
hInstance 	dd ?
hIcon 		dd ?
hWinMain 	dd ?
hCom		dd ? ;���ھ��
g_bOpened		dd ? ;�Ƿ�򿪴���
hCloseEvent dd ? ;���ڹر��¼�
g_olRead	OVERLAPPED <>
g_olWait	OVERLAPPED <>
g_olWrite	OVERLAPPED <>
g_hListBox	dd ? ;
sysTime SYSTEMTIME <>



;///////////////////////////////////////////////////////////////////////////////
; �����
;///////////////////////////////////////////////////////////////////////////////
.code
_GetLastErrorMsg proc
	local @szError[256]:CHAR
	local @dwError
	invoke GetLastError
	mov @dwError,eax
	invoke FormatMessage,FORMAT_MESSAGE_FROM_SYSTEM,NULL,@dwError,0,addr @szError,sizeof @szError,NULL
	invoke MessageBox,hWinMain,addr @szError,CTXT("����"),MB_ICONERROR
	Ret
_GetLastErrorMsg EndP
;��ʼ��
_Init proc
	local @hCombo
	invoke	LoadIcon,hInstance,ICO_MAIN
	;����ͼ��
	mov hIcon,eax
	invoke	SendMessage,hWinMain,WM_SETICON,ICON_BIG,hIcon
	;��ʼ����������
	;����
	invoke GetDlgItem,hWinMain,IDC_COMBO1
	mov @hCombo,eax
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("COM1")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("COM2")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("COM3")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("COM4")
	invoke SendMessage,@hCombo,CB_SETCURSEL,0,0	;Ĭ��ѡ��COM1
	;������
	invoke GetDlgItem,hWinMain,IDC_COMBO2
	mov @hCombo,eax
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("75")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("110")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("134")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("150")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("300")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("600")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("1200")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("1800")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("2400")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("4800")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("7200")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("9600")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("14400")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("19200")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("38400")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("56000")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("57600")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("115200")
	invoke SendMessage,@hCombo,CB_SETCURSEL,17,0	;Ĭ��ѡ��115200
	;У��λ
	invoke GetDlgItem,hWinMain,IDC_COMBO3
	mov @hCombo,eax
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("ż")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("��")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("��")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("��־")	
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("�ո�")
	invoke SendMessage,@hCombo,CB_SETCURSEL,2,0	;Ĭ��ѡ��NO
	;����λ
	invoke GetDlgItem,hWinMain,IDC_COMBO4
	mov @hCombo,eax
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("4")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("5")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("6")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("7")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("8")
	invoke SendMessage,@hCombo,CB_SETCURSEL,4,0	;Ĭ��ѡ��NO
	;ֹͣλ
	invoke GetDlgItem,hWinMain,IDC_COMBO5
	mov @hCombo,eax
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("1")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("1.5")
	invoke SendMessage,@hCombo,CB_ADDSTRING,0,CTXT("2")
	invoke SendMessage,@hCombo,CB_SETCURSEL,0,0	;Ĭ��ѡ��NO
	
	;�ر��¼�
	invoke CreateEvent,\
		NULL,\ 	;default security attributes
		FALSE,\ ;auto reset event
		FALSE,\	;not signaled
		NULL	;no name
	mov hCloseEvent,eax
	
	;��ʼ��Overlapped����
	;��
	invoke RtlZeroMemory,addr g_olRead,sizeof g_olRead
	invoke CreateEvent,\
		NULL,\ 	;default security attributes
		TRUE,\ ;auto reset event
		FALSE,\	;not signaled
		NULL	;no name
	mov g_olRead.hEvent,eax
	
	;�ȴ�
	invoke RtlZeroMemory,addr g_olWait,sizeof g_olWait
	invoke CreateEvent,\
		NULL,\ 	;default security attributes
		TRUE,\ ;auto reset event
		FALSE,\	;not signaled
		NULL	;no name
	mov g_olWait.hEvent,eax
	
	;д
	invoke RtlZeroMemory,addr g_olWrite,sizeof g_olWrite
	invoke CreateEvent,\
		NULL,\ 	;default security attributes
		TRUE,\ ;auto reset event
		TRUE,\	;not signaled
		NULL	;no name
	mov g_olWrite.hEvent,eax
	
	mov g_bOpened,FALSE
	
	invoke GetDlgItem,hWinMain,IDC_LIST1
	mov g_hListBox,eax
	
	Ret
_Init EndP

;///////////////////////////////////////////////////////////////////////////////
;��������
;///////////////////////////////////////////////////////////////////////////////
_HandleData proc _lpBuffer
	invoke SendMessage,g_hListBox,LB_ADDSTRING,0,_lpBuffer
	Ret
_HandleData EndP

;///////////////////////////////////////////////////////////////////////////////
;������
;///////////////////////////////////////////////////////////////////////////////
_ReadData proc
	local @inbuffer[100]:BYTE
	local @dwErrFlag,@nBytesRead
	local @cs:COMSTAT
	
	invoke ClearCommError,hCom,addr @dwErrFlag,addr @cs
	.if @dwErrFlag
		invoke PurgeComm,hCom,PURGE_RXABORT or PURGE_RXCLEAR
		call _GetLastErrorMsg
		ret
	.endif	
	.if @cs.cbInQue
		invoke RtlZeroMemory,addr @inbuffer,sizeof @inbuffer
		invoke ReadFile,hCom,addr @inbuffer,@cs.cbInQue,addr @nBytesRead,addr g_olRead
		.if eax
			invoke _HandleData,addr @inbuffer
		.else
			invoke GetLastError
			.if eax==ERROR_IO_PENDING
				invoke GetOverlappedResult,hCom,addr g_olRead,addr @nBytesRead,TRUE
			.else
				call _GetLastErrorMsg
			.endif
		.endif
	.endif
	Ret
_ReadData EndP

;///////////////////////////////////////////////////////////////////////////////
;д����
;///////////////////////////////////////////////////////////////////////////////
_WriteData proc _lpBuffer,_nSize
	local @nBytesWritten
	invoke WaitForSingleObject,g_olWrite.hEvent,2000
	.if eax==WAIT_TIMEOUT ;���ͳ�ʱ?
		ret
	.endif
	invoke WriteFile,hCom,_lpBuffer,_nSize,addr @nBytesWritten,addr g_olWrite
	.if !eax
		invoke GetLastError
		.if eax==ERROR_IO_PENDING
			invoke GetOverlappedResult,hCom,addr g_olWrite,addr @nBytesWritten,TRUE
		.else
			call _GetLastErrorMsg
		.endif
	.else
		mov eax,@nBytesWritten
	.endif
	Ret
_WriteData EndP

;///////////////////////////////////////////////////////////////////////////////
;��д�����߳�
;///////////////////////////////////////////////////////////////////////////////
_ReadThread proc _lParam	
	local @nBytesRead,@dwEvent,@dwError
	local @cs:COMSTAT
	
	.while g_bOpened		
		invoke WaitCommEvent,hCom,addr @dwEvent,addr g_olWait
		.if !eax
			invoke GetLastError
			.if eax==ERROR_IO_PENDING
				invoke GetOverlappedResult,hCom,addr g_olWait,addr @nBytesRead,TRUE
			.else
				call _GetLastErrorMsg
				.break
			.endif
		.endif
		.if (@dwEvent&EV_RXCHAR)
			call _ReadData
		.else
			invoke ClearCommError,hCom,addr @dwError,addr @cs
			.if @dwError
				invoke PurgeComm,hCom,PURGE_RXABORT or PURGE_RXCLEAR ;�������������
			.endif
		.endif
	.endw
	invoke SetEvent,hCloseEvent	
	Ret
_ReadThread EndP

;///////////////////////////////////////////////////////////////////////////////
;�򿪴���
_OpenCom proc uses esi
	local @hCombo,@index,@hButton
	local @szCom[20]:CHAR
	local @dwThreadID
	local @to:COMMTIMEOUTS
	local @dcb:DCB
	local @szTmp[30]:CHAR
	local @Parity:BYTE
	
	invoke GetDlgItem,hWinMain,IDC_BTN_OPEN
	mov @hButton,eax
	invoke GetDlgItem,hWinMain,IDC_COMBO1
	mov @hCombo,eax
		
	.if g_bOpened	;�Ѵ�?
		invoke EnableWindow,@hCombo,TRUE
		invoke SetWindowText,@hButton,CTXT("��")
		call _CloseCom
	.else
		invoke SendMessage,@hCombo,CB_GETCURSEL,0,0
		mov @index,eax
		invoke RtlZeroMemory,addr @szCom,sizeof @szCom
		invoke SendMessage,@hCombo,CB_GETLBTEXT,@index,addr @szCom
		
		invoke CreateFile,addr @szCom,\
			GENERIC_READ OR GENERIC_WRITE,\
			0,\
			NULL,\
			OPEN_EXISTING,\
			FILE_FLAG_OVERLAPPED,\
			NULL
		mov hCom,eax
		.if eax == INVALID_HANDLE_VALUE
			call _GetLastErrorMsg
		.else
			;���İ�ť״̬
			invoke EnableWindow,@hCombo,FALSE
			invoke SetWindowText,@hButton,CTXT("�ر�")
			mov g_bOpened,TRUE
			invoke SetCommMask,hCom,EV_RXCHAR ;�����¼���������
			invoke SetupComm,hCom,1024,512 ;�������롢����������Ĵ�С
			invoke PurgeComm,hCom,PURGE_TXABORT+PURGE_RXABORT+PURGE_TXCLEAR+PURGE_RXCLEAR ;��ɾ����롢���������
			;��ʱ����
			invoke RtlZeroMemory,addr @to,sizeof @to
			mov @to.ReadTotalTimeoutMultiplier,5
			mov @to.ReadTotalTimeoutConstant,1000
			invoke SetCommTimeouts,hCom,addr @to
			;��������
			invoke RtlZeroMemory,addr @dcb,sizeof @dcb
			invoke GetCommState,hCom,addr @dcb
			;������
			invoke GetDlgItem,hWinMain,IDC_COMBO2
			mov @hCombo,eax
			invoke SendMessage,@hCombo,CB_GETCURSEL,0,0
			mov @index,eax
			invoke RtlZeroMemory,addr @szTmp,sizeof @szTmp
			invoke SendMessage,@hCombo,CB_GETLBTEXT,@index,addr @szTmp			
			invoke atol,addr @szTmp
			mov @dcb.BaudRate,eax
			;У��λ
			invoke GetDlgItem,hWinMain,IDC_COMBO2
			mov @hCombo,eax
			invoke SendMessage,@hCombo,CB_GETCURSEL,0,0
			mov @index,eax
			.if eax==0
				mov @dcb.Parity,EVENPARITY
			.elseif eax==1
				mov @dcb.Parity,ODDPARITY
			.elseif eax==2
				mov @dcb.Parity,NOPARITY
			.elseif eax==3
				mov @dcb.Parity,MARKPARITY
			.elseif eax==4
				mov @dcb.Parity,SPACEPARITY
			.endif
			;����λ
			invoke GetDlgItem,hWinMain,IDC_COMBO4
			mov @hCombo,eax
			invoke SendMessage,@hCombo,CB_GETCURSEL,0,0
			mov @index,eax
			
			.if eax==0
				mov @dcb.ByteSize,4
			.elseif eax==1
				mov @dcb.ByteSize,5
			.elseif eax==2
				mov @dcb.ByteSize,6
			.elseif eax==3
				mov @dcb.ByteSize,7
			.elseif eax==4
				mov @dcb.ByteSize,8
			.endif
			
			;ֹͣλ
			invoke GetDlgItem,hWinMain,IDC_COMBO5
			mov @hCombo,eax
			invoke SendMessage,@hCombo,CB_GETCURSEL,0,0
			mov @index,eax
			.if eax==0
				mov @dcb.StopBits,ONESTOPBIT
			.elseif eax==1
				mov @dcb.StopBits,ONE5STOPBITS
			.elseif eax==2
				mov @dcb.StopBits,TWOSTOPBITS			
			.endif			
			invoke SetCommState,hCom,addr @dcb
			
			;���������߳�
			invoke ResetEvent,hCloseEvent
			invoke CreateThread,NULL,0,offset _ReadThread,NULL,NULL,addr @dwThreadID
		.endif
	.endif
	
	Ret
_OpenCom EndP
;///////////////////////////////////////////////////////////////////////////////
;�ر�
_CloseCom proc
	.if g_bOpened
		mov g_bOpened,FALSE
		invoke SetCommMask,hCom,0
		invoke WaitForSingleObject,hCloseEvent,INFINITE
		invoke PurgeComm,hCom,PURGE_RXCLEAR		
		invoke CloseHandle,hCom
	.endif
	Ret
_CloseCom EndP

;///////////////////////////////////////////////////////////////////////////////
_ProcDlgMain proc uses ebx edi esi hWnd,wMsg,wParam,lParam	
	local @hEdit
	local @sendbuff[255]:CHAR
	local @timebuff[255]:CHAR
	mov	eax,wMsg
	.if	eax == WM_CLOSE
		invoke 	EndDialog,hWnd,NULL
	.elseif eax == WM_INITDIALOG
		push hWnd
		pop hWinMain
		call _Init
	.elseif	eax == WM_COMMAND
		mov	eax,wParam
		.if	ax == IDCANCEL || ax == IDM_EXIT
			call _CloseCom
			invoke	EndDialog,hWnd,NULL
		.elseif ax == IDM_ABOUT	;����
			invoke AboutBox,hWnd,hInstance,hIcon,CTXT("Ƕ��ʽʵ��"),CTXT("����ͨ��"),\
				CTXT("by crypt0n")
		.elseif ax == IDC_BTN_OPEN ;�򿪴���
			call _OpenCom
		.elseif ax == IDOK ;����
			invoke GetDlgItem,hWnd,IDC_EDIT
			mov @hEdit,eax
			invoke GetWindowText,@hEdit,addr @sendbuff,sizeof @sendbuff			
			invoke SendMessage,g_hListBox,LB_ADDSTRING,0,addr @sendbuff
			invoke GetWindowTextLength,@hEdit
			invoke _WriteData,addr @sendbuff,eax
		.elseif ax == BUTTON_RED; �찴ť
			mov [@sendbuff+1], "P"; �ƶ���������
			mov [@sendbuff+2], "3"
			mov [@sendbuff+3], "r"
			mov [@sendbuff+4], "e"
			mov [@sendbuff+5], "d"
			mov eax, sizeof @sendbuff
			invoke _WriteData,addr @sendbuff,eax
		.elseif ax == BUTTON_GREEN; �̰�ť
			mov [@sendbuff+1], "P"; �ƶ���������
			mov [@sendbuff+2], "5"
			mov [@sendbuff+3], "g"
			mov [@sendbuff+4], "r"
			mov [@sendbuff+5], "e"
			mov [@sendbuff+6], "e"
			mov [@sendbuff+7], "n"
			mov eax, sizeof @sendbuff
			invoke _WriteData,addr @sendbuff,eax
		.elseif ax == BUTTON_BLUE; ����ť
			mov [@sendbuff+1], "P"; �ƶ���������
			mov [@sendbuff+2], "4"
			mov [@sendbuff+3], "b"
			mov [@sendbuff+4], "l"
			mov [@sendbuff+5], "u"
			mov [@sendbuff+6], "e"
			mov eax, sizeof @sendbuff
			invoke _WriteData,addr @sendbuff,eax
		.elseif ax == BUTTON_WHITE; �װ�ť
			mov [@sendbuff+1], "P"; �ƶ���������
			mov [@sendbuff+2], "5"
			mov [@sendbuff+3], "w"
			mov [@sendbuff+4], "h"
			mov [@sendbuff+5], "i"
			mov [@sendbuff+6], "t"
			mov [@sendbuff+7], "e"
			mov eax, sizeof @sendbuff
			invoke _WriteData,addr @sendbuff,eax
		.elseif ax == BUTTON_YELLOW; �ư�ť
			mov [@sendbuff+1], "P"; �ƶ���������
			mov [@sendbuff+2], "6"
			mov [@sendbuff+3], "y"
			mov [@sendbuff+4], "e"
			mov [@sendbuff+5], "l"
			mov [@sendbuff+6], "l"
			mov [@sendbuff+7], "o"
			mov [@sendbuff+8], "w"
			mov eax, sizeof @sendbuff
			invoke _WriteData,addr @sendbuff,eax
		.elseif ax == BUTTON_PURPLE; �ϰ�ť
			mov [@sendbuff+1], "P"; �ƶ���������
			mov [@sendbuff+2], "6"
			mov [@sendbuff+3], "p"
			mov [@sendbuff+4], "u"
			mov [@sendbuff+5], "r"
			mov [@sendbuff+6], "p"
			mov [@sendbuff+7], "l"
			mov [@sendbuff+8], "e"
			mov eax, sizeof @sendbuff
			invoke _WriteData,addr @sendbuff,eax
		.elseif ax == BUTTON_CYAN; �ఴť
			mov [@sendbuff+1], "P"; �ƶ���������
			mov [@sendbuff+2], "4"
			mov [@sendbuff+3], "c"
			mov [@sendbuff+4], "y"
			mov [@sendbuff+5], "a"
			mov [@sendbuff+6], "n"
			mov eax, sizeof @sendbuff
			invoke _WriteData,addr @sendbuff,eax
		.elseif ax == BUTTON_DARK; ����ť
			mov [@sendbuff+1], "P"; �ƶ���������
			mov [@sendbuff+2], "4"
			mov [@sendbuff+3], "d"
			mov [@sendbuff+4], "a"
			mov [@sendbuff+5], "r"
			mov [@sendbuff+6], "k"
			mov eax, sizeof @sendbuff
			invoke _WriteData,addr @sendbuff,eax
		.elseif ax == BUTTON_SYNC_TIME; ͬ��ʱ��
			invoke	GetLocalTime,addr sysTime
			xor eax,eax
			xor ebx,ebx
			xor ecx,ecx
			mov ax,sysTime.wHour
			mov bx,sysTime.wMinute
			mov cx,sysTime.wSecond
			invoke	wsprintf,addr @timebuff,addr szFromatTime,eax,ebx,ecx
			invoke _WriteData,addr @timebuff,eax
			invoke MessageBox, NULL, addr @timebuff, addr @timebuff, MB_OK
		.endif

	.endif
	xor	eax,eax
	ret
	Ret
_ProcDlgMain EndP

;///////////////////////////////////////////////////////////////////////////////
start:
	invoke GetModuleHandle,NULL
	mov hInstance,eax
	invoke DialogBoxParam,hInstance,DLG_MAIN,NULL,offset _ProcDlgMain,NULL
	invoke ExitProcess,NULL
;///////////////////////////////////////////////////////////////////////////////
	end start

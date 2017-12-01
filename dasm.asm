.stack 100h  

.data
duom    db  255,0,255 dup (0)
tmp     dw ?
rez     db  255,0,255 dup (0)
rasymoBuferis db 255,0,255 dup ("$")
rasyk   dw ?
registrai db "ALAXCLCXDLDXBLBXAHSPCHBPDHSIBHDI$"
efektyvusAdresas1 db "BX+SIBX+DIBP+SIBP+DI$"
efektyvusAdresas2 db "SIDIBPBX$"
baitas  db ?
opk     db ?
opksk   dw ?
adr     db ? 
mod     db ?
reg     db ?
rm      db ?
s       db ?
w       db ?
pjb     db ?
pvb     db ?
ajb     db ?
avb     db ?
bojb    db ?
bovb    db ?
srjb    db ?
srvb    db ?
sr      db ?
j       db ?
v       db ?
nr      db ? 
dHandle dw ?
rHandle dw ? 
nuskSim db ?
spausdB db ?
prefix  db ?
yraPrefix    db ?
yraSr   db ?
4lastBitai db ?
skliaustai1 db "[$"
skliaustai2 db "]$"
kablelis    db ",$"
pliusas     db "+$"
dvitaskis   db ":$"
pES     db "ES$"
pCS     db "CS$"
pSS     db "SS$"
pDS     db "DS$"
bpt     db "BYTE PTR $"
wpt     db "WORD PTR $"
far     db "FAR $"
operacijos1 db "ADD  OR   ADC  SBB  AND  SUB  XOR  CMP  $"
operacijos2 db "INC  DEC  PUSH POP  $"
operacijos3 db "MOV  INT  $"
operacijos4 db "LOOP JCXZ $"
operacijos5 db "CALL JMP  $"
operacijos6 db "INC  DEC  CALL CALL JMP  JMP  PUSH $"
operacijos7 db "          NOT  NEG  MUL  IMUL DIV  IDIV $"
operacijos8 db "RET  IRET RETF $"
operacijos9 db "CALL $" 
jumpai      db "JO   JNO  JNAE JAE  JE   JNE  JBE  JA   JS   JNS  JP   JNP  JL   JGE  JLE  JG   $"
neatpazinta db "NEATPAZINTA$"
tarpai      db "               $"
tarpu       dw ?
dPoz    dw 0100h
x       db ? 
x2       db ?
nEil db 0Dh,0Ah
pranesimas1 db "Deividas Brazenas, PS I kursas, 4 grupe. Disasembleris$"
pranesimas3 db "Klaida atidarant duomenu faila$"
pranesimas4 db "Klaida atidarant rezultatu faila$"
pranesimas5 db "Klaida uzdarant duomenu faila$"
pranesimas6 db "Klaida uzdarant rezultatu faila$"
pranesimas7 db "Klaida skaitant$"
pranesimas8 db "Klaida rasant$" 

.code
pradzia:
    MOV ax,@data
    MOV ds,ax
    MOV	ch, 0			
	MOV	cl, es:[0080h]
	CMP	cx, 2
	JBE Yra
	CMP cx,3
	JA Failai
	MOV	bx, 0081h
  Ieskok:
	CMP	es:[bx], '?/'	
	JE	Yra			
	INC	bx			
	LOOP Ieskok			
	JMP	END			

    Yra:
	MOV	ah, 9			
	MOV	dx, offset pranesimas1
	INT	21h
	JMP END
	
	Failai:
	    CALL RaskFailus     			
;---------------------------------------
	MOV	ah, 3Dh			
	MOV	al, 00				
	MOV	dx, offset duom
	INT	21h
	JC klaidaAtidarantSkaityma				
	MOV	dHandle, ax
;---------------------------------------
    MOV ah,3Ch
    MOV cx,0
    MOV dx,offset rez
    INT 21h
    JC klaidaAtidarantRasyma
    MOV rHandle,ax
;---------------------------------------
    
    IsNaujo:
    MOV spausdB,0
    MOV w,0b
    MOV s,0b
    MOV yraPrefix,0b
    MOV tarpu,0Fh 
    MOV di,offset rasymoBuferis
    MOV ax,dPoz
    MOV x,al
    IdekBaitaIsvedimui ah
    IdekBaitaIsvedimui x
    PerkelkSimboli dvitaskis
    Skaityk opk
    CMP nuskSim,0
    JE Pabaiga: 
    CALL ArPrefixas
    CMP yraPrefix,1b
    JE SkaitykDar
        Nustatyk:
        CALL NustatykOPK
        CALL IsveskBuf
        CALL SpausdinkNaujaEil 
        JMP IsNaujo
    SkaitykDar:
        Skaityk opk
        JMP Nustatyk:
    Pabaiga:
        
;--------------------------------------    
    UzdarykFaila dHandle klaidaUzdarantSkaityma 		
    UzdarykFaila rHandle klaidaUzdarantRasyma 
;--------------------------------------
    END:
    MOV ah,4Ch
    INT 21h
;****************************************
klaidaAtidarantSkaityma:
    isveskEkranan pranesimas3
klaidaAtidarantRasyma:
    isveskEkranan pranesimas4
klaidaUzdarantSkaityma:
    isveskEkranan pranesimas5
klaidaUzdarantRasyma:
    isveskEkranan pranesimas6
klaidaSkaitant:
    isveskEkranan pranesimas7
klaidaRasant:                
    isveskEkranan pranesimas8   
;---------------------------------------
UzdarykFaila MACRO handle klaida 
    MOV	ah, 3Eh			
	MOV	bx, handle
	INT	21h				
    JC klaida   
ENDM
;---------------------------------------    
Shifting MACRO baitas skaicius shiftas idek
    MOV al,baitas
    AND al,skaicius
    SHR al,shiftas
    MOV idek,al    
ENDM
;---------------------------------------
Perkelk MACRO isKur nuoKur Kiek
    MOV si,offset isKur
    MOV cx,kiek
    ADD si,nuoKur
    LOCAL dek
    dek:
        MOV bl,[si]
        MOV [di],bl
        INC si
        INC di
        INC spausdB
        loop dek    
ENDM
;--------------------------------------
PerkelkSimboli MACRO sim
    MOV al,sim
    MOV [di],al
    INC di
    INC spausdB
ENDM
;--------------------------------------
Skaityk MACRO iKur
    CALL SkaitykBaita
    MOV iKur,al
    IdekBaitaIsvedimui al    
ENDM
;--------------------------------------
IdekBaitaIsvedimui MACRO ka
    MOV al,ka
    CALL BaitaiIASCII
ENDM
;--------------------------------------
segreg MACRO seg
    LOCAL sr01
    LOCAL sr10
    LOCAL sr11
    LOCAL BaikSRRM
    MOV al,sr
    cmpje 01b sr01
    cmpje 10b sr10
    cmpje 11b sr11
        Perkelk pES 0 2
        JMP BaikSRRM
    sr01:
        Perkelk pCS 0 2
        JMP BaikSRRM
    sr10:
        Perkelk pSS 0 2
        JMP BaikSRRM
    sr11:
        Perkelk pDS 0 2  
    BaikSRRM:
ENDM   
;-----------------------------------------------
cmpje MACRO suKuo kur  ;TAI KAS AL
    CMP al,suKuo
    JE kur
ENDM
;-----------------------------------------------
cmpjbe MACRO suKuo kur  ;TAI KAS AL
    CMP al,suKuo
    JBE kur
ENDM
;-----------------------------------------------
opkIs8 MACRO    ;zaidziam su AL
   MOV ah,0
   MOV bl,8h
   DIV bl
   MOV bl,5d
   MUL bl
ENDM 
;-----------------------------------------------
isveskEkranan MACRO eilute
    MOV ah,9h
    MOV dx,offset eilute
    INT 21h
    JMP END 
ENDM
;-----------------------------------------------
Registras MACRO kas
    ;4 * reg + 2 * w
    MOV bl,kas
    ADD bl,bl
    ADD bl,bl
    MOV bh,2
    MOV ah,0
    MOV al,w
    MUL bh
    ADD al,bl 
    Perkelk registrai ax 2    
ENDM
;-----------------------------------------------
DoStuff1 MACRO baik
    LOCAL xxakw1
    CMP w,1b
    JE xxakw1
    Perkelk registrai 0 2
    JMP baik
    xxakw1:
    Perkelk registrai 2 2
ENDM
;-----------------------------------------------
Kart5 MACRO kas
    MOV ah,0
    MOV al,kas
    MOV bl,5
    MUL bl
    MOV opksk,ax
ENDM
;***********************************************
PROC RaskFailus
    MOV ch, 0
    MOV cl, es:[0080h]
    SUB cl, 1
   	MOV bx, offset duom
	MOV si, 0
	MOV di, 0 
	storeFilename:
	MOV al, es:[0082h + si]
	CMP al, 20h
	JNE tasPats
	MOV bx, offset tmp
	MOV di, 0
	INC bx
	tasPats:
	MOV [bx + di], al
	INC si
	INC di
	LOOP storeFilename
    RET
RaskFailus ENDP
;**********************************************
PROC SkaitykBaita   ;OUT - al (nuskaityas baitas)
    MOV bx,dHandle
	MOV	ah, 3Fh		
	MOV	cx, 1
	MOV	dx,offset baitas
	INT	21h
	JC klaidaSkaitant
	
	MOV nuskSim,al
	MOV al,baitas
	INC dPoz
	SUB tarpu,2h
    RET
SkaitykBaita ENDP
;*********************************************
PROC SpausdinkNaujaEil
    MOV ah,40h
    MOV bx,rHandle
    MOV ch,0
    MOV cl,2
    MOV dx,offset nEil
    INT 21h
    JC klaidaRasant
    RET
SpausdinkNaujaEil ENDP      
;*********************************************
PROC IsveskBuf
    MOV ah,40h
    MOV bx,rHandle
    MOV ch,0
    MOV cl,spausdB
    MOV dx,offset rasymoBuferis
    INT 21h
    JC klaidaRasant 
    RET
IsveskBuf ENDP 
;*********************************************
PROC ArPrefixas
    MOV al,baitas
    cmpje 26h yraPref
    cmpje 2Eh yraPref
    cmpje 36h yraPref
    cmpje 3Eh yraPref
    JMP nerPrefixo 
     
    yraPref: 
        MOV yraPrefix,1b
        MOV al,baitas
        MOV prefix,al
            
    nerPrefixo:    
    RET
ArPrefixas ENDP
;*********************************************
PROC RaskPrefixa
    MOV al,prefix
    cmpje 2Eh prefixCS
    cmpje 36h prefixSS
    cmpje 3Eh prefixDS
        Perkelk pES 0 2 
        JMP baikPrefix
    prefixCS:
        Perkelk pCS 0 2
        JMP baikPrefix
    prefixSS:
        Perkelk pSS 0 2
        JMP baikPrefix
    prefixDS:
        Perkelk pDS 0 2
    baikPrefix:
    RET    
RaskPrefixa ENDP    
;*********************************************
PROC NuskaitykAdresavima
    Shifting opk 00000001b 0 w
    Skaityk adr 
    CALL RaskModRegRM
    CALL NuskaitykPoslinki
    RET
NuskaitykAdresavima ENDP        
;*********************************************
PROC RaskModRegRM
    Shifting adr 11000000b 6 mod
    Shifting adr 00111000b 3 reg
    Shifting adr 00000111b 0 rm    
    RET
RaskModRegRM ENDP
    
PROC RaskRegistra
    Registras reg     
    RET
RaskRegistra ENDP
;*********************************************
PROC NuskaitykPoslinki
    MOV al,mod
    cmpje 01b SkaitykMod01
    cmpje 10b SkaitykMod10
    CMP mod,11b
    JE BaikSkaityt
    CMP rm,110b
    JNE BaikSkaityt  
        Skaityk ajb
        Skaityk avb
        JMP BaikSkaityt     
    SkaitykMod01:
        Skaityk pjb
        JMP BaikSkaityt    
    SkaitykMod10:
        Skaityk pjb
        Skaityk pvb
    BaikSkaityt:
    RET
NuskaitykPoslinki ENDP
;*********************************************
PROC NuskaitykAdresa
    Skaityk ajb          ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Skaityk avb
    RET
NuskaitykAdresa ENDP   
;********************************************
PROC NuskaitykBO
    Skaityk bojb
    CMP s,1b
    JE bos1
    CMP w,1b
    JNE BaikSkaitytBO
    
    Skaityk bovb
    JMP BaikSkaitytBO 
    
    bos1:
        CMP w,1b
        JE s1w1
            Skaityk bovb
            JMP BaikSkaitytBO     
        s1w1: 
            CMP bojb,80h
            JAE pleciamFF
                MOV bovb,000h
                JMP BaikSkaitytBO
            pleciamFF:
                MOV bovb,0FFh       
    BaikSkaitytBO:
    RET
NuskaitykBO ENDP 
;********************************************
PROC RaskEfektyvuAdresa
    CMP yraPrefix,1b
    JNE neraPrefixo
        CALL RaskPrefixa
        PerkelkSimboli dvitaskis
    neraPrefixo:
        PerkelkSimboli skliaustai1
    CMP rm,100b
    JAE rmVirs100   ;rm maziau nei 100
        ;5 * rm
        MOV ah,0
        MOV al,rm
        MOV bl,5
        MUL bl
        Perkelk efektyvusAdresas1 ax 5
        JMP PabaigaEA 
    rmVirs100:
        CMP rm,110b
        JE rm110
        GrizkModNe00:
        ;(rm-4)*2
        MOV ah,0
        MOV al,rm
        SUB al,4
        MOV bl,2
        MUL bl
        Perkelk efektyvusAdresas2 ax 2
        JMP PabaigaEA   
    rm110:
        CMP mod,00b
        JNE GrizkModNe00    
    PabaigaEA:
    RET
RaskEfektyvuAdresa ENDP
;********************************************
PROC RegMem
    MOV al,mod
    cmpje 11b mod11
    cmpje 00b mod00
    cmpje 01b mod01
    cmpje 10b mod10
    
    mod11:
        Registras rm
        JMP BaikAdresavima
    mod00:
        CALL RaskEfektyvuAdresa
        CMP rm,110b
        JNE nespausdinkAdreso
        IdekBaitaIsvedimui avb
        IdekBaitaIsvedimui ajb
        nespausdinkAdreso:
        PerkelkSimboli skliaustai2
        JMP BaikAdresavima    
    mod01: 
        CALL RaskEfektyvuAdresa
        MOV al,pliusas
        PerkelkSimboli al
        IdekBaitaIsvedimui pjb
        PerkelkSimboli skliaustai2
        JMP BaikAdresavima  
    mod10:
        CALL RaskEfektyvuAdresa
        MOV al,pliusas
        PerkelkSimboli al
        IdekBaitaIsvedimui pvb
        IdekBaitaIsvedimui pjb 
        PerkelkSimboli skliaustai2
    BaikAdresavima:
    RET
RegMem ENDP
;********************************************
PROC IsRegIRM 
    CALL RegMem
    PerkelkSimboli kablelis
    CALL RaskRegistra    
    RET
IsRegIRM ENDP
;********************************************
PROC IsRMiReg 
    CALL RaskRegistra
    PerkelkSimboli kablelis 
    CALL RegMem    
    RET
IsRMiReg ENDP
;********************************************
PROC IsBOiAK
    DoStuff1 persokak
    persokak:
    PerkelkSimboli kablelis
    
    CMP w,1b
    JNE akw0
    IdekBaitaIsvedimui bovb
    akw0:
    IdekBaitaIsvedimui bojb   
    RET
IsBOiAK ENDP 
;********************************************
PROC IsSRiRM
    Perkelk wpt 0 9
    CALL RegMem
    PerkelkSimboli kablelis
    segreg sr       
    RET
ENDP IsSRiRM  
;********************************************
PROC IsRMiSR
    segreg sr
    PerkelkSimboli kablelis       
    Perkelk wpt 0 9
    CALL RegMem           
    RET
ENDP IsRMiSR
;********************************************    
PROC IsRMiAK
    DoStuff1 xpersokak
    xpersokak:
    PerkelkSimboli kablelis    
    CALL RegMem
    RET
IsRMiAK ENDP 
;********************************************
PROC IsAKiRM 
    CALL RegMem
    PerkelkSimboli kablelis
    DoStuff1 BaikAKRM
    BaikAKRM: 
    RET
IsAKiRM ENDP 
;********************************************
PROC IsBOiRM
    CMP mod,11b
    JE PersokBORM
    CMP s,1b
    JE BORMw1
    CMP w,1b
    JE BORMw1
        Perkelk bpt 0 9
        JMP PersokBORM    
    BORMw1:
        Perkelk wpt 0 9
    PersokBORM:
    CALL RegMem
    PerkelkSimboli kablelis
    
    CMP s,1b
    JE BORMs1
        CMP w,1b
        JE BORMs0w1
            IdekBaitaIsvedimui bojb
            JMP BaikBORM
        BORMs0w1:
            IdekBaitaIsvedimui bovb
            IdekBaitaIsvedimui bojb
            JMP BaikBORM       
    BORMs1:
            IdekBaitaIsvedimui bovb
            IdekBaitaIsvedimui bojb
    BaikBORM:    
    RET
IsBOiRM ENDP
;-------------------------------------------
PROC IsAiAK
    DoStuff1 apersokak
    apersokak:
    PerkelkSimboli kablelis
    PerkelkSimboli skliaustai1
    IdekBaitaIsvedimui avb
    IdekBaitaIsvedimui ajb
    PerkelkSimboli skliaustai2
    RET
IsAiAK ENDP 
;-------------------------------------------
PROC IsAKiA
    PerkelkSimboli skliaustai1
    IdekBaitaIsvedimui avb
    IdekBaitaIsvedimui ajb
    PerkelkSimboli skliaustai2
    PerkelkSimboli kablelis
    DoStuff1 BaikAK  
    BaikAK:    
    RET
IsAKiA ENDP 
;-------------------------------------------
PROC IsBOiReg
    CALL RaskRegistra
    PerkelkSimboli kablelis
    CMP w,0b
    JE BOREGw0   
        IdekBaitaIsvedimui bovb
    BOREGw0:
    IdekBaitaIsvedimui bojb
    RET
IsBOiReg ENDP  
;-------------------------------------------
PROC IsorinisTiesioginis
    IdekBaitaIsvedimui srvb
    IdekBaitaIsvedimui srjb
    PerkelkSimboli dvitaskis
    IdekBaitaIsvedimui avb
    IdekBaitaIsvedimui ajb
    RET
IsorinisTiesioginis ENDP 
;-------------------------------------------
PROC VidinisTiesioginis
    MOV ah,pvb
    MOV al,pjb
    ADD ax,dPoz
    MOV x,al
    IdekBaitaIsvedimui ah
    IdekBaitaIsvedimui x
    RET
VidinisTiesioginis ENDP       
;-------------------------------------------
PROC BaitaiIASCII   ;ENTRY - al (baitas)
    MOV ah,0
    MOV bl,10h
    DIV bl
    CMP al,0Ah
    JAE alVirs10
    
    ADD al,30h
    JMP Prasok1     
    alVirs10:
        ADD al,37h
    Prasok1:
    CMP ah,0Ah
    JAE ahVirs10
    
    ADD ah,30h
    JMP Prasok2
    ahVirs10:
        ADD ah,37h
    Prasok2:
        MOV j,al
        MOV v,ah
        PerkelkSimboli j
        PerkelkSimboli v            
    RET
BaitaiIASCII ENDP
;---------------------------------------------
PROC SutvarkykZenkla
    CBW
    CMP ax,7Fh
    JBE BaikZenklas
    XOR ax,0FFFFh
    INC ax
    MOV bx,ax
    MOV ax,dPoz
    SUB ax,bx
    JMP persokZenkla
    BaikZenklas:
    ADD ax,dPoz
    persokZenkla:    
    RET
SutvarkykZenkla ENDP
;---------------------------------------------
PROC NustatykOPK
    MOV al,opk
    cmpjbe 3Dh grupe1
    cmpjbe 5Fh grupe2
    cmpjbe 6Fh NeatpazintaK
    cmpjbe 7Fh grupe3
    cmpjbe 83h grupe4
    cmpjbe 87h NeatpazintaK
    cmpjbe 8Bh grupe5
    cmpjbe 8Eh grupe6
    cmpjbe 8Fh grupe7
    cmpjbe 99h NeatpazintaK
    cmpjbe 9Ah grupe21
    cmpjbe 9Fh NeatpazintaK
    cmpjbe 0A3h grupe8
    cmpjbe 0AFh NeatpazintaK   
    cmpjbe 0BFh grupe9 
    cmpjbe 0C1h NeatpazintaK
    cmpjbe 0C2h grupe18
    cmpjbe 0C3h grupe19
    cmpjbe 0C5h NeatpazintaK
    cmpjbe 0C7h grupe10
    cmpjbe 0C9h NeatpazintaK
    cmpjbe 0CAh grupe22 
    cmpjbe 0CBh grupe23
    cmpjbe 0CCh NeatpazintaK
    cmpjbe 0CDh grupe11
    cmpjbe 0CEh NeatpazintaK
    cmpjbe 0CFh grupe20
    cmpjbe 0E1h NeatpazintaK
    cmpjbe 0E3h grupe12
    cmpjbe 0E7h NeatpazintaK
    cmpjbe 0E9h grupe13
    cmpjbe 0EAh grupe14
    cmpjbe 0EBh grupe15
    cmpjbe 0F5h NeatpazintaK
    cmpjbe 0F7h grupe16
    cmpjbe 0FDh NeatpazintaK
    cmpjbe 0FFh grupe17 

    grupe1: ;Nuo 00 iki 3D
        cmpje 06h pushk
        cmpje 0Eh pushk
        cmpje 16h pushk
        cmpje 1Eh pushk
        
        cmpje 07h popk
        cmpje 17h popk
        cmpje 1Fh popk
        
        cmpje 0Fh NeatpazintaK
        cmpje 26h NeatpazintaK
        cmpje 27h NeatpazintaK
        cmpje 2Eh NeatpazintaK
        cmpje 2Fh NeatpazintaK
        cmpje 36h NeatpazintaK
        cmpje 37h NeatpazintaK
        ;Jei ne tie, tai OPK / 8
        
        opkIs8
        MOV opksk,ax
        Shifting opk 00001111b 0 4lastBitai
        
        CMP 4lastBitai,5h
        JBE lastBitaiMaziauNei5
            SUB 4lastBitai,8h  
        lastBitaiMaziauNei5:
            MOV al,4lastBitai
            cmpje 0 var0
            cmpje 1 var0
            cmpje 2 var1
            cmpje 3 var1
            cmpje 4 var2
            cmpje 5 var2
            
            var0:
                CALL NuskaitykAdresavima
                Perkelk tarpai 0 tarpu
                Perkelk operacijos1 opksk 5
                CALL IsRegIRM
                JMP BaikOPK    
            var1:
                CALL NuskaitykAdresavima
                Perkelk tarpai 0 tarpu
                Perkelk operacijos1 opksk 5
                CALL IsRMiReg
                JMP BaikOPK
            var2:
                Shifting opk 00000001b 0 w
                CALL NuskaitykBO
                Perkelk tarpai 0 tarpu
                Perkelk operacijos1 opksk 5
                CALL IsBOiAK
                JMP BaikOPK    
        pushk:
            Perkelk tarpai 0 tarpu
            Perkelk operacijos2 10 5
            Shifting opk 00011000b 3 sr
            segreg sr
            JMP BaikOPK
        popk: 
            Perkelk tarpai 0 tarpu
            Perkelk operacijos2 15 5
            Shifting opk 00011000b 3 sr
            segreg sr
            JMP BaikOPK
    
    grupe2: ;NUO 40 iki 5F
        SUB al,40h
        opkIs8
        MOV opksk,ax
        Perkelk tarpai 0 tarpu
        Perkelk operacijos2 opksk 5
        Shifting opk 00000111b 0 reg
        MOV w,1b
        CALL RaskRegistra
        JMP BaikOPK
    
    grupe3: ;NUO 70 iki 7F
        SUB al,70h  ;(opk - 70h) * 5
        MOV bl,5h
        MUL bl
        MOV opksk,ax
        Skaityk baitas
        MOV al,baitas
        CALL SutvarkykZenkla
        MOV x,al
        MOV x2,ah
        Perkelk tarpai 0 tarpu
        Perkelk jumpai opksk 5
        IdekBaitaIsvedimui x2
        IdekBaitaIsvedimui x
        JMP BaikOPK
    
    grupe4: ;80h-83h
        CALL NuskaitykAdresavima
        Kart5 reg  
        Shifting opk 00000010b 1 s
        Shifting opk 00000001b 0 w 
        CALL NuskaitykBO
        Perkelk tarpai 0 tarpu
        Perkelk operacijos1 opksk 5
        CALL IsBOiRM
        JMP BaikOPK
     
     grupe5:
        Shifting opk 00000001b 0 w 
        CALL NuskaitykAdresavima
        Perkelk tarpai 0 tarpu
        Perkelk operacijos3 0 5
        Shifting opk 00001111b 0 4lastBitai 
        CMP 4lastBitai,1010b
        JAE movVar2
            CALL IsRegIRM
            JMP BaikOPK    
        movVar2:
            CALL IsRMiReg
            JMP BaikOPK 
    
    grupe6:
        CMP al,8Dh
        JE NeatpazintaK
        CALL NuskaitykAdresavima
        Perkelk tarpai 0 tarpu
        Perkelk operacijos3 0 5
        Shifting adr 00011000b 3 sr
        Shifting opk 00001111b 0 4lastBitai
        CMP 4lastBitai,1110b
        JE movIsr
            CALL IsSRiRM
            JMP BaikOPK
        movIsr:
            CALL IsRMiSR
            JMP BaikOPK
    
    grupe7:
        CALL NuskaitykAdresavima
        CMP reg,000b
        JNE NeatpazintaK
        Perkelk tarpai 0 tarpu
        Perkelk operacijos2 15 5
        Perkelk wpt 0 9
        CALL RegMem
        JMP BaikOPK
    
    grupe8:
        Skaityk ajb
        Skaityk avb
        Shifting opk 00000001b 0 w
        Shifting opk 00001111b 0 4lastBitai
        Perkelk tarpai 0 tarpu
        Perkelk operacijos3 0 5
        CMP 4lastBitai,0010b
        JAE movIadr
            CALL IsAiAK
            JMP BaikOPK
        movIadr:
            CALL IsAKiA
            JMP BaikOPK
    
    grupe9:
        Shifting opk 00001000b 3 w
        Shifting opk 00000111b 0 reg
        CALL NuskaitykBO
        Perkelk tarpai 0 tarpu
        Perkelk operacijos3 0 5
        CALL IsBOiReg
        JMP BaikOPK
    
    grupe10:
        CALL NuskaitykAdresavima
        CMP reg,000h
        JNE NeatpazintaK
        Shifting opk 00000001b 0 w
        CALL NuskaitykBO
        Perkelk tarpai 0 tarpu
        Perkelk operacijos3 0 5
        CALL IsBOiRM      
        JMP BaikOPK
    
    grupe11:
        Skaityk nr
        Perkelk tarpai 0 tarpu
        Perkelk operacijos3 5 5
        IdekBaitaIsvedimui nr
        JMP BaikOPK
    
    grupe12:
        Skaityk baitas
        Shifting opk 00001111b 0 4lastBitai
        SUB 4lastBitai,10b
        Kart5 4lastBitai
        Perkelk tarpai 0 tarpu
        Perkelk operacijos4 opksk 5
        MOV al,baitas
        CALL SutvarkykZenkla
        MOV x,al    ;pasidedam laikinai kad nedingtu
        IdekBaitaIsvedimui ah
        IdekBaitaIsvedimui x
        JMP BaikOPK
    
    grupe13: 
        Skaityk pjb
        Skaityk pvb
        Shifting opk 00001111b 0 4lastBitai
        SUB 4lastbitai,1000b
        Kart5 4lastBitai           
        Perkelk tarpai 0 tarpu
        Perkelk operacijos5 opksk 5
        CALL VidinisTiesioginis
        JMP BaikOPK
    
    grupe14:
        Skaityk ajb
        Skaityk avb
        Skaityk srjb
        Skaityk srvb
        Perkelk tarpai 0 tarpu
        Perkelk operacijos5 5 5 
        CALL IsorinisTiesioginis
        JMP BaikOPK
    
    grupe15:
        Skaityk baitas
        Perkelk tarpai 0 tarpu
        Perkelk operacijos5 5 5
        MOV al,baitas
        CALL SutvarkykZenkla
        MOV x,al    ;pasidedam laikinai kad nedingtu
        IdekBaitaIsvedimui ah
        IdekBaitaIsvedimui x
        JMP BaikOPK
    
    grupe16:
        CALL NuskaitykAdresavima
        Kart5 reg
        Perkelk tarpai 0 tarpu     
        Perkelk operacijos7 opksk 5
        Shifting opk 00000001b 0 w               
        CMP w,1b
        JE gr16w1
            Perkelk bpt 0 9
            JMP Persokgr16
        gr16w1:
            Perkelk wpt 0 9
        Persokgr16:
        CALL RegMem
        JMP BaikOPK   
        
    grupe17:
        CALL NuskaitykAdresavima
        Kart5 reg
        Perkelk tarpai 0 tarpu     
        Perkelk operacijos6 opksk 5
            MOV al,reg
            cmpje 000b xvar1
            cmpje 001b xvar1
            cmpje 010b xvar2
            cmpje 011b xvar3
            cmpje 100b xvar2
            cmpje 101b xvar3
            cmpje 110b xvar1
            JMP NeatpazintaK
            
            xvar1:
                Shifting opk 00000001b 0 w
                CMP w,1b
                JE xw1
                    Perkelk bpt 0 9
                    JMP xpersok
                xw1:
                    Perkelk wpt 0 9
                    xpersok:
                    CALL RegMem
                    JMP BaikOPK
            xvar2:
                CMP mod,11b
                JE NeatpazintaK
                Perkelk wpt 0 9
                MOV w,1b
                CALL RegMem 
                JMP BaikOPK   
            xvar3:
                CMP mod,11b
                JE NeatpazintaK
                Perkelk far 0 4
                MOV w,1b
                CALL RegMem
                JMP BaikOPK
    grupe18:
        Skaityk bojb
        Skaityk bovb
        Perkelk tarpai 0 tarpu     
        Perkelk operacijos8 0 5
        IdekBaitaIsvedimui bovb
        IdekBaitaIsvedimui bojb
        JMP BaikOPK
    grupe19:
        Perkelk tarpai 0 tarpu     
        Perkelk operacijos8 0 5
        JMP BaikOPK
    grupe20:
        Perkelk tarpai 0 tarpu     
        Perkelk operacijos8 5 5
        JMP BaikOPK
    grupe21:
        Skaityk ajb
        Skaityk avb
        Skaityk srjb
        Skaityk srvb
        Perkelk tarpai 0 tarpu
        Perkelk operacijos9 0 5
        CALL IsorinisTiesioginis
        JMP BaikOPK
    grupe22:
        Skaityk bojb
        Skaityk bovb
        Perkelk tarpai 0 tarpu
        Perkelk operacijos8 10 5
        IdekBaitaIsvedimui bovb
        IdekBaitaIsvedimui bojb
        JMP BaikOPK
    grupe23:
        Perkelk tarpai 0 tarpu
        Perkelk operacijos8 10 5
        JMP BaikOPK
                                                     
    NeatpazintaK:
        Perkelk tarpai 0 tarpu    
        Perkelk neatpazinta 0 11      
    BaikOPK:
    RET
NustatykOPK ENDP

END pradzia
; -----------------------------------------------------------------------------
;  Fibonacci Generator (Windows x64)
; -----------------------------------------------------------------------------

default rel                     ; Hey computer, assume everything is "nearby" in memory.

extern GetStdHandle             ; Borrow the "Get the Screen Handle" tool from Windows.
extern WriteFile                ; Borrow the "Write to Screen" tool from Windows.
extern ExitProcess              ; Borrow the "Close Program" button from Windows.

section .data                   ; This is the "Storage Room" for things that don't change.
    STD_OUTPUT_HANDLE equ -11   ; A nickname for the number -11 (which means "The Screen").
    space             db " "    ; Save a single space character so we can use it later.
    count             dq 20     ; Save the number 20 (how many times we want to loop).

section .bss                    ; This is the "Empty Box Room" for stuff we'll create later.
    buffer            resb 32   ; Make a 32-character empty box to hold our numbers-as-text.
    written           resd 1    ; Make a tiny 4-byte box to store "how many letters we wrote".

section .text                   ; This is the "Instruction Manual" where the code lives.
    global main                 ; Tell Windows: "Start reading right here!"

main:                           ; The front door of our program.
    sub rsp, 40                 ; Clear off some desk space (40 bytes) for Windows to work.

    xor r12, r12                ; Set R12 to 0 (our first Fibonacci number).
    mov r13, 1                  ; Set R13 to 1 (our second Fibonacci number).
    mov r14, [rel count]        ; Look in the storage room and put 20 into R14 (our counter).

.loop:                          ; A label so we can "jump" back here.
    ; --- STEP 1: Turn the number into text ---
    mov rax, r12                ; Put our current number into the RAX register.
    lea rdi, [rel buffer]       ; Point to our empty box (buffer) so we know where to write.
    call itoa                   ; Go run the "number-to-text" instructions below.

    ; --- STEP 2: Ask Windows for the screen ---
    mov rcx, STD_OUTPUT_HANDLE  ; Tell Windows "I want to talk to the Screen (-11)".
    call GetStdHandle           ; Actually get the handle.
    mov rbx, rax                ; Save that handle in RBX so we don't lose it.

    ; --- STEP 3: Print the number ---
    mov rcx, rbx                ; Give Windows the Screen Handle.
    lea rdx, [rel buffer]       ; Give Windows the address of our text box.
    mov r8, rsi                 ; Tell Windows how many letters are in the box.
    lea r9, [rel written]       ; Tell Windows where to save the "receipt" of the work.
    mov qword [rsp + 32], 0     ; Put a 0 in the 5th spot (Windows is picky).
    call WriteFile              ; Actually show it on the screen!

    ; --- STEP 4: Print a space ---
    mov rcx, rbx                ; Give Windows the Screen Handle again.
    lea rdx, [rel space]        ; Give Windows the address of our space character.
    mov r8, 1                   ; Tell Windows "It's just one character".
    lea r9, [rel written]       ; Give it the receipt box again.
    mov qword [rsp + 32], 0     ; Put a 0 in the 5th spot again.
    call WriteFile              ; Actually show the space!

    ; --- STEP 5: Do the Math ---
    mov r15, r13                ; Remember the current second number.
    add r13, r12                ; Add the first number to the second to get the NEW number.
    mov r12, r15                ; The old second number becomes the new first number.

    dec r14                     ; Subtract 1 from our counter (20, 19, 18...).
    jnz .loop                   ; If the counter isn't 0 yet, jump back to ".loop".

    ; --- STEP 6: Goodbye ---
    xor rcx, rcx                ; Set our exit code to 0 (Everything is OK!).
    call ExitProcess            ; Tell Windows we are done. Bye!

; --- IT REGISTERED TO TEXT CONVERTER ---
itoa:                           ; The sub-manual for turning bits into letters.
    mov r10, 10                 ; We use 10 because we count in base-10.
    xor rcx, rcx                ; Set our letter-counter to 0.

.split_digits:                  ; Break the number apart.
    xor rdx, rdx                ; Clear out the remainder register.
    div r10                     ; Divide the number by 10.
    add dl, '0'                 ; Turn the remainder into an ASCII character (like '5').
    push rdx                    ; Throw that character onto the "Stack" (a pile of dishes).
    inc rcx                     ; Count another letter.
    test rax, rax               ; Is there anything left of the number?
    jnz .split_digits           ; If yes, keep splitting.

    mov rsi, rcx                ; Save the total length in RSI for the print step.
    mov rdx, rcx                ; Also save it in RDX just in case.

.reorder:                       ; Take the characters off the pile.
    pop rax                     ; Take a character off the top of the stack pile.
    stosb                       ; Put it into our text box and move to the next spot.
    loop .reorder               ; Do this for every letter we counted.
    ret                         ; Go back to where we were called from.

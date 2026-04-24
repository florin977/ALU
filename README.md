# ALU cu Add, Subtract, Booth Radix 4 si Non-Restoring Division
![Full ALU implemented in logisim-evolution](Media/ALU_Logisim_Final.png)

## Descrierea Proiectului
Acest proiect reprezinta o Unitate Aritmetica si Logica (ALU) hardware implementata in Logisim-Evolution. Proiectul a fost realizat pentru materia de Calculatoare Numerice din cadrul Universitatii Politehnica Timisoara (UPT).

Arhitectura proceseaza date de intrare pe 8 biti (numere cu semn, reprezentate in complement fata de 2) si genereaza un rezultat pe 16 biti. Designul foloseste o arhitectura Multi-Ciclu, separand clar Unitatea de Control (FSM) de Datapath pentru a optimiza executia algoritmilor complecsi.

## Operatii Suportate (OPCODE)
Operatia curenta este selectata prin intermediul unui OPCODE pe 2 biti:

* 00 - Adunare (ADD): A + B. Rezultatul pe 8 biti este extins cu semn (Sign Extend) pentru a oferi un rezultat curat pe 16 biti.
* 01 - Scadere (SUB): A - B. Rezultatul este extins cu semn pe 16 biti.
* 10 - Inmultire (Booth Radix-4): Inmulteste doua numere cu semn de 8 biti. Rezultatul ocupa intreaga magistrala de 16 biti.
* 11 - Impartire (Signed Non-Restoring): Imparte Deimpartitul la Impartitor. Rezultatul de 16 biti este format din Rest (8 biti High) si Cat (8 biti Low).

## Arhitectura Hardware

### 1. Unitatea de Control (FSM)
Inima procesorului este o Masina cu Stari Finite (Finite State Machine) organizata in 4 stari principale:
1. IDLE (00): Starea de asteptare. Sistemul este inactiv pana la primirea semnalului START.
2. INIT (01): Faza de preluare (Fetch). Se incarca valorile in registrele interne (M, Q), iar registrul A (Acumulatorul) este resetat la zero.
3. EXEC (11): Faza de calcul. Bucla principala ruleaza timp de 8 cicluri de ceas, efectuand operatiile de shiftare si calcul alu specifice operatiei.
4. DONE (10): Faza de scriere (Write-Back). Se activeaza semnalul END_FLAG, iar rezultatul devine stabil pe pinii de iesire.

### 2. Modulul de Impartire (Signed Non-Restoring Division)
Implementarea divizorului foloseste tehnica "Wrapper-ului Combinatoric" pentru a trata numerele cu semn fara a adauga cicluri de ceas suplimentare:
* Pre-procesare (Intrare): Numerele negative sunt transformate instantaneu in valori absolute inainte de a intra in nucleu. Nucleul algoritmic proceseaza exclusiv numere fara semn (Unsigned).
* Executie: Se foloseste algoritmul Non-Restoring clasic.
* Post-procesare si Corectie (Iesire): Deoarece algoritmul poate finaliza cu un rest negativ, un circuit combinatoric aplica instantaneu corectia de magnitudine (A + M). Semnul Catului este generat de o poarta XOR intre semnele intrarilor, iar Restul preia intotdeauna semnul Deimpartitului original.

### 3. Gestionarea Iesirilor (Output Formatting)
Magistrala finala de iesire (OUT_PUT) garanteaza livrarea unor date fara biti reziduali:
* Pentru ADD/SUB se foloseste un bloc de Sign Extension la 16 biti.
* Pentru DIV/MUL se foloseste un Splitter de 16 biti care concateneaza cele doua registre interne de 8 biti.
* Un MUX controlat de OPCODE decide ce tip de formatare ajunge la pinul de iesire.

## Mod de Utilizare
1. Deschideti proiectul in Logisim-Evolution.
2. Setati intrarile A_IN si B_IN pe pinii corespunzatori.
3. Alegeti operatia dorita din pinul OPCODE.
4. Apasati butonul START (nivel logic 1 urmat de 0).
5. Porniti ceasul sistemului (Tick manual sau Auto-Tick).
6. Cand operatia s-a incheiat, indicatorul de final se va aprinde, iar rezultatul va fi vizibil pe pinul de 16 biti OUT_PUT.
# Trivia
Nome: Samuele

Cognome: Tavani


Descrizione: 
Un progetto di un gioco trivia che va ad acquisire le domande e le eventuali risposte da un sito web: OpenTriviaDB.

## Struttura

Modello dei dati:

  Riceve i dati grezzi dal sito e li trasfomra in un formatto che l'app può usare, ho aggiunto anche un meccanismo per far sì che traduca anche gli apici e le virgolette,
  ha delle proprietà che definiscono chiaramente cosa contiene una domanda, si sono utilizzate infatti: 
   - testoDomanda
   - rispostaCorretta
   - tutteLeRisposte.

  La classe Question contiene anche il metodo per il parsing (elaborazione dei dati), infatti prende una mappa JSON ed estrae i valori.

  Utilizzo anche Htmlunescape per pulire e unescape.convert() per risovlere il problema dei simboli (gli apici, le virgolette, ecc...)

  Ho ideato anche un posizionamento random della risposta giusta così che se dovesse ricapitare, la selezione delle risposte avrà degli ordini smepre differenti (opzioni.shuffle)

Struttura dell'App routing:  

  Gestusce la struttura base della UI
    - QuizApp è il contenitore principale che tiene anche il tema dell'app
    - MainTabScreen è un StatefulWidget perché ricorda quale tab sia aperto
    - BottomNavigationBargestisce la barra in basso dello schermo e usa anche _cmabiaScheda che serve per agiornare l'indice che servirà in seguito per cambiare widget
    - Il meccanismo di routing invece si ha con body: _pagine[_indiceSelezionato] e mostra il widget corrispondente all'indice selezionato

Selezione Domande:

  Si usa HomePage che è un StatefulWidget per l'interazione con l'input di testo
    - Per leggere e modificare il contenuto nel TextField usiamo TextEditingController ed è fondamentale usare il dispose() per evitare perdita di memoria
    - _avviaPartita() invece deve validare l'input che è un numero che deve andare da 1 a 50 (limite consigliato per l'API
     Utilizza Navigator.push per il routing dinamico e sposta l'utente alla schermata di gioco.
    - Usa ActionChip per selezionare la quantità di domande predisposte

About Page:
  Un aggiunta in più per dire con cosa è fatta l'app e da dove si prendono le domande

Logica di Gioco:
  gestice le comunicazioni API e lo stato della partita
  - si fa un set con il numero delle domande che si vogliono fare
  - all'avvio della schermata con initState() viene chiamata caricaDomanda()
      - _caricaDomanda() è async che aspetta la risposta API
      - crea l'URL con il numero di odmande: amount = ${widget.numeroDomande}
      - Dopo il collegamento usa setState() per aggiornare _domande e imposta la variabile booleana di ocntrollo su false
  - rispondiA(String rispostaSelezionata)
    - verifica che la risposta selezionata sia uguale a quella giusta
    - incrementa il punteggio
    - fa avanzare con la prossima domanda se l'utente non ha finito le domande a disposizione
  - build()
    - ha una struttura a stato e mostra varie interfaccie in base allo stato del programma
    - usa l'operatore spread per generare dinamicamente un ElevatedButton per ogni risposta nell'elenco
    - Si utilizza Navigator.pop(context) per tornare alla Home Page

    
    




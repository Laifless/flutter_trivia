import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart'; 
import 'dart:math';

void main() {
  runApp(const QuizApp());
}

// --- 1. MODELLO DATI (CON DECODIFICA HTML) ---
class Question {
  final String questionText;
  final String correctAnswer;
  final List<String> allAnswers;

  Question({
    required this.questionText,
    required this.correctAnswer,
    required this.allAnswers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Inizializza il decodificatore HTML
    final unescape = HtmlUnescape(); 

    // Decodifica la domanda
    final String decodedQuestion = unescape.convert(json['question']);

    // Decodifica la risposta corretta
    final String decodedCorrectAnswer = unescape.convert(json['correct_answer']);

    // Decodifica e unisci le risposte
    List<String> answers = List<String>.from(json['incorrect_answers'])
        .map((answer) => unescape.convert(answer)) 
        .toList();
        
    answers.add(decodedCorrectAnswer); // Aggiungiamo la risposta corretta decodificata
    answers.shuffle(); // Mischia le risposte

    return Question(
      questionText: decodedQuestion, 
      correctAnswer: decodedCorrectAnswer,
      allAnswers: answers,
    );
  }
}

// --- 2. MAIN APP & ROUTING ---
class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Quiz',
      theme: ThemeData(primaryColor: const Color.fromARGB(255, 230, 194, 174)),
      home: const MainTabScreen(),
    );
  }
}

// --- 3. NAVIGAZIONE A SCHEDE (TABS) ---
class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),      
    AboutPage(),     
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: 'Gioca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 160, 98, 27),
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- 4. SCHERMATA HOME (AVVIO E SELEZIONE DOMANDE) ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController(text: '10'); 
  String? _errorText;
  
  // Opzioni predefinite per l'utente
  final List<int> presetAmounts = [5, 10, 15, 20];

  void _startGame() {
    final amountText = _controller.text;
    final amount = int.tryParse(amountText);
    
    // Validazione: controlla se è un numero e se è compreso tra 1 e 50 (limite API consigliato)
    if (amount == null || amount < 1 || amount > 50) {
      setState(() {
        _errorText = "Inserisci un numero valido (1-50)";
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    // Navigazione, passando il numero di domande selezionato al GameScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(numberOfQuestions: amount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Trivia")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.quiz, size: 100, color: Color.fromARGB(255, 183, 77, 58)),
              const SizedBox(height: 30),
              
              const Text(
                "Quante domande vuoi?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),

              // Campo di input
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Numero domande',
                  errorText: _errorText,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  // Pulisci l'errore mentre l'utente digita
                  if (_errorText != null) {
                    setState(() {
                      _errorText = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Bottoni di selezione rapida
              Wrap(
                spacing: 10.0,
                children: presetAmounts.map((amount) {
                  return ActionChip(
                    label: Text("$amount Domande"),
                    onPressed: () {
                      _controller.text = amount.toString();
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // Bottone di avvio
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: _startGame,
                child: const Text('INIZIA PARTITA', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// --- 5. SCHERMATA INFO (SCHEDA 2) ---
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Informazioni")),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Questo gioco utilizza le API di OpenTriviaDB.\n"
            "Realizzato con Flutter.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

// --- 6. LOGICA DI GIOCO (GAME SCREEN CON PARAMETRO) ---
class GameScreen extends StatefulWidget {
  final int numberOfQuestions; // Ricevuto da HomePage

  const GameScreen({super.key, required this.numberOfQuestions});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  // Chiamata API Aggiornata: usa il numero di domande selezionato
  Future<void> _fetchQuestions() async {
    final url = 'https://opentdb.com/api.php?amount=${widget.numberOfQuestions}&type=multiple'; 
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        setState(() {
          _questions = results.map((json) => Question.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Errore caricamento API. Codice: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("Errore di rete/parsing: $e");
    }
  }

  void _answerQuestion(String selectedAnswer) {
    bool isCorrect = selectedAnswer == _questions[_currentQuestionIndex].correctAnswer;
    
    if (isCorrect) {
      _score++;
    }

    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _isGameOver = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Stato: Caricamento
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Caricamento domande...")
          ],
        )),
      );
    }

    // Stato: Nessuna domanda caricata (Errore o API vuota)
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Errore Caricamento")),
        body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Impossibile caricare le domande dall'API. Riprova.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Torna al menu
                    },
                    child: const Text("Torna al Menu"),
                  ),
                ],
              ),
            ),
        ),
      );
    }

    // Stato: Fine Gioco
    if (_isGameOver) {
      return Scaffold(
        appBar: AppBar(title: const Text("Risultato")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Punteggio Finale: $_score / ${_questions.length}", 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Torna alla Home
                },
                child: const Text("Torna al Menu"),
              )
            ],
          ),
        ),
      );
    }

    // Stato: Gioco in corso
    final currentQuestion = _questions[_currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Domanda ${_currentQuestionIndex + 1}/${_questions.length}"),
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Visualizzazione del Punteggio
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Punteggio: $_score",
                style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 168, 70, 45), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // Testo Domanda
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 191, 166),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                currentQuestion.questionText, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            
            // Lista Opzioni
            ...currentQuestion.allAnswers.map((answer) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color.fromARGB(255, 121, 81, 35),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _answerQuestion(answer),
                  child: Text(
                    answer,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
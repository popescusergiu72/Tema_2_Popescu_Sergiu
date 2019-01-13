%{ //define and include directives of cpp

    #include<stdio.h>
    #include<string.h>

    extern void yyerror(const char *msg);
    extern int yyval;

    int yylex();
    char msg[500];
    
    int decc = 0;
    int readd = 0;
    int writee = 0;
    int divv = 0;
   
    int EsteCorecta = 1;

    class TVAR
    {
        char *nume;
        int valoare;
        TVAR *next;

    public:
        static TVAR *head;
        static TVAR *tail;

        TVAR();
        TVAR(char *n, int v = -1);

        int exists(char *n);
        void add(char *n, int v = -1);
        int getValue(char *n);
        void setValue(char *n, int v);
    };

    TVAR* TVAR::head;
    TVAR* TVAR::tail;

    TVAR::TVAR()
    {
        TVAR::head = NULL;
        TVAR::tail = NULL;
    }

    TVAR::TVAR(char *n, int v)
    {
        this->nume = new char[strlen(n)+1];
        strcpy(this->nume, n);
        this->valoare = v;
        this->next = NULL;
    }

    int TVAR::exists(char *n)
    {
        TVAR *tmp = TVAR::head;

        while(tmp != NULL)
        {
            if(strcmp(tmp->nume, n) == 0)
                return 1;
            tmp = tmp->next;
        }

        return 0;
    }

    void TVAR::add(char *n, int v)
    {
        TVAR *nou = new TVAR(n, v);

        if(head == NULL)
            TVAR::head = TVAR::tail = nou;
        else
        {
            TVAR::tail->next = nou;
            TVAR::tail = nou;
        }
    }

    int TVAR::getValue(char *n)
    {
        TVAR *tmp = TVAR::head;

        while(tmp != NULL)
        {
            if(strcmp(tmp->nume, n) == 0)
                return tmp->valoare;
            tmp = tmp->next;
        }

        return -1;
    }

    void TVAR::setValue(char *n, int v)
    {
        TVAR *tmp = TVAR::head;

        while(tmp != NULL)
        {
            if(strcmp(tmp->nume, n) == 0)
                tmp->valoare = v;
            tmp = tmp->next;
        }
    }

    TVAR *ts = NULL;

%}//definitions

%locations

%union { char* sir; int val; }

%token TOK_PROGRAM TOK_VAR TOK_BEGIN TOK_END TOK_INTEGER TOK_DIV TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO
%token TOK_PUNCT_VIRGULA TOK_DOUA_PUNCTE TOK_VIRGULA TOK_ASSIGN TOK_PLUS TOK_MINUS TOK_INMULTIT TOK_LEFT TOK_RIGHT TOK_ERROR

%token <val> TOK_INT
%token <sir> TOK_ID

%start prog

%left TOK_PLUS TOK_MINUS
%left TOK_INMULTIT TOK_DIV

%% //rules

prog: TOK_PROGRAM prog_name TOK_VAR dec_list TOK_BEGIN stmt_list TOK_END
    | error prog_name TOK_VAR dec_list TOK_BEGIN stmt_list TOK_END { EsteCorecta = 0; }
    | error TOK_VAR dec_list TOK_BEGIN stmt_list TOK_END { EsteCorecta = 0; }
    | error dec_list TOK_BEGIN stmt_list TOK_END { EsteCorecta = 0; }
    | error TOK_BEGIN stmt_list TOK_END { EsteCorecta = 0; }
    | error stmt_list TOK_END { EsteCorecta = 0; }
    | error TOK_END { EsteCorecta = 0; }
    | error { EsteCorecta = 0; }
    ;
prog_name: TOK_ID // eroare sintaxa la linia/coloana ?????
    ;
dec_list: dec
        | dec_list TOK_PUNCT_VIRGULA dec
        ;
dec: {decc = 1;} id_list TOK_DOUA_PUNCTE type{decc = 0;}
    ;
type: TOK_INTEGER
    ;
id_list: TOK_ID
        {
            if( decc == 1)
            {
                if(ts != NULL )
                {
                    if(ts->exists($1) == 0)
                        ts->add($1);
                    else
                    {  
                        sprintf(msg, "%d:%d Eroare semantica: Declaratii multiple pentru variabila '%s'", @1.first_line, @1.first_column, $1);
                        yyerror(msg);
                        //YYERROR;
                        EsteCorecta = 0;
                    }
                }
                else
                {
                    ts = new TVAR();
                    ts->add($1);
                }
            }

            if( readd == 1 && ts != NULL )
            {        
                if( ts->exists($1) == 0  )
                {
                    sprintf(msg, "%d:%d Eroare semantica: Variabila '%s' nu a fost declarata!", @1.first_line, @1.first_column, $1);
                    yyerror(msg);
                    //YYERROR;
                    EsteCorecta = 0;
                }
                else
                {
                    ts->setValue($1, yyval.val );
                }
            }

            if ( writee == 1 && ts != NULL )
            {
                // getValue($1); + afisaj
            }
        }
       | id_list TOK_VIRGULA TOK_ID
       {
            if( decc == 1)
            {
                if(ts != NULL )
                {
                    if(ts->exists($3) == 0)
                        ts->add($3);
                    else
                    {  
                        sprintf(msg, "%d:%d Eroare semantica: Declaratii multiple pentru variabila '%s'", @1.first_line, @1.first_column, $3);
                        yyerror(msg);
                        //YYERROR;
                        EsteCorecta = 0;
                    }
                }
                else
                {
                    printf("orice");
                    ts = new TVAR();
                    ts->add($3);
                }
            }

            if( readd == 1 && ts != NULL )
            {        
                if( ts->exists($3) == 0  )
                {
                    sprintf(msg, "%d:%d Eroare semantica: Variabila '%s' nu a fost declarata!", @1.first_line, @1.first_column, $3);
                    yyerror(msg);
                    //YYERROR;
                    EsteCorecta = 0;
                }
                else
                {
                    ts->setValue($3, yyval.val );
                }
            }

            if ( writee == 1 && ts != NULL )
            {
                // getValue($1); + afisaj
            }
        }
       ;
stmt_list: stmt
         | stmt_list TOK_PUNCT_VIRGULA stmt
         ;
stmt: assign 
    | read
    | write
    | for
    ;
assign: TOK_ID TOK_ASSIGN exp
      {
        if( ts != NULL )
        {
            if( ts->exists($1) == 1)
                ts->setValue($1, 1);
            else
            {
                sprintf(msg, "%d:%d Eroare semantica: Variabila '%s' nu a fost declarata!", @1.first_line, @1.first_column, $1);
                yyerror(msg);
                //YYERROR;
                EsteCorecta = 0;
            }
        }
        else
        {
            sprintf(msg, "%d:%d Eroare semantica: Variabila '%s' nu a fost declarata!", @1.first_line, @1.first_column, $1);
            yyerror(msg);
            //YYERROR;
            EsteCorecta = 0;
        }
      }
      ;
exp: term
   | exp TOK_PLUS term
   | exp TOK_MINUS term
   ;
term: factor
    | term TOK_INMULTIT factor
    | term {divv = 1;} TOK_DIV factor {divv = 0;}
    ;
factor: TOK_ID // verificare tok id
        {
            if( ts != NULL )
            {
                if( ts->exists($1) == 1)
                {
                    if( divv == 1 )
                    {
                        if( ts->getValue($1) == 0 )
                        {
                            sprintf(msg, "%d:%d Eroare semantica: Nu se poate efectua impartirea la 0!", @1.first_line, @1.first_column);
                            yyerror(msg);
                            //YYERROR;
                            EsteCorecta = 0;
                        }
                    }

                    if( ts->getValue($1) == -1 )
                    {
                        sprintf(msg, "%d:%d Eroare semantica: Variabila '%s' nu este initializata!", @1.first_line, @1.first_column, $1);
                        yyerror(msg);
                        //YYERROR;
                        EsteCorecta = 0;
                    }
                }
                else
                {
                    sprintf(msg, "%d:%d Eroare semantica: Variabila '%s' nu a fost declarata!", @1.first_line, @1.first_column, $1);
                    yyerror(msg);
                    //YYERROR;
                    EsteCorecta = 0;
                }
            }
            else
            {
                sprintf(msg, "%d:%d Eroare semantica: Variabila '%s' nu a fost declarata!", @1.first_line, @1.first_column, $1);
                yyerror(msg);
                //YYERROR;
                EsteCorecta = 0;
            }
        }
      | TOK_INT
        {
            if( divv == 1 )
            {
                if( $1 == 0 )
                {
                    sprintf(msg, "%d:%d Eroare semantica: Nu se poate efectua impartirea la 0!", @1.first_line, @1.first_column);
                    yyerror(msg);
                    //YYERROR;
                    EsteCorecta = 0;
                }
            }
        }
      | TOK_LEFT exp TOK_RIGHT
      ;
read: { readd = 1; } TOK_READ TOK_LEFT id_list TOK_RIGHT { readd = 0; } 
    ;
write: { writee = 1; } TOK_WRITE TOK_LEFT id_list TOK_RIGHT { writee = 0; }
     ;
for: TOK_FOR index_exp TOK_DO body
   ;
index_exp: TOK_ID TOK_ASSIGN exp TOK_TO exp
         ;
body: stmt
    | TOK_BEGIN stmt_list TOK_END
    ;

%% //user defines directives

int main()
{
    yyparse();

    if( EsteCorecta == 1 )
        printf("CORECTA\n");
    
    return 0;
}

void yyerror(const char *msg)
{
    printf("Error: %s\n", msg);

    return;
}

%{
	#include <stdio.h>
  #include <string.h>
  extern int colNo;
	extern  int lineNo;
	int yylex();
	int yyerror(const char *msg);
	int syyerror(const char *msg);
	int Is_div=0;
	int Is_read=0;
	int Is_write=0;
  int EsteCorecta = 1;
	char msg[500];

	class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;

	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
      void add(char* n, int v = -1);
			int getValue(char* n);
			void setValue(char* n, int v);
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}


	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }
	 int TVAR::getValue(char* n)
	{
		TVAR* tmp = TVAR::head;
		while(tmp != NULL)
		{
			 if(strcmp(tmp->nume,n) == 0)
				return tmp->valoare;
			 tmp = tmp->next;
		}
		return -1;
	}

	void TVAR::setValue(char* n, int v)
	{
		TVAR* tmp = TVAR::head;
		while(tmp != NULL)
		{
			if(strcmp(tmp->nume,n) == 0)
			{
					tmp->valoare = v;
			}
			tmp = tmp->next;
		}
	}

	TVAR* ts = NULL;
%}



%locations

%union { char* sir; int val;}

%token TOK_PROG TOK_VAR TOK_BEGIN TOK_END TOK_INTEGER TOK_ASSIGN TOK_PLUS TOK_MINUS TOK_MULTIPLY TOK_DIVIDE TOK_INT TOK_LEFT TOK_RIGHT TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO TOK_ERROR

%token <val> TOK_NUMBER
%token <sir> TOK_VARIABLE


%start prog

%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIVIDE

%%
prog :	TOK_PROG prog_name TOK_VAR  dec_list TOK_BEGIN stmt_list TOK_END
    		|
    		error prog_name TOK_VAR  dec_list TOK_BEGIN stmt_list TOK_END
       			{ EsteCorecta = 0;}
				|
				error TOK_VAR  dec_list TOK_BEGIN stmt_list TOK_END
       			{ EsteCorecta = 0;	}
				|
			  error dec_list TOK_BEGIN stmt_list TOK_END
       			{ EsteCorecta = 0;		}
				|
				error TOK_BEGIN stmt_list TOK_END
       			{ EsteCorecta = 0;	}
				|
				error stmt_list TOK_END
       			{ EsteCorecta = 0;		}
				|
				error TOK_END
       			{ EsteCorecta = 0;}
				|
				error
						{ EsteCorecta = 0;
							}

    ;
prog_name : TOK_VARIABLE
			;
dec_list : dec
					|
					dec_list ';' dec
					;

dec 		: id_list ':' type
 					;

type		: TOK_INTEGER
					;
id_list : TOK_VARIABLE
						{
							if(Is_read!=1 && Is_write!=1)
							{
								if(ts != NULL)
								{
									if(ts->exists($1) == 1)
									{
										sprintf(msg,"%d:%d Eroare semantica: Variabila %s este declarata deja", @1.first_line, @1.first_column, $1);
										syyerror(msg);
										YYERROR;
									}
									else
									{
										ts->add($1);
									}
								}
								else
									{
									  ts = new TVAR();
										ts->add($1);
									}
							}
							else
							{
								if(ts != NULL)
								{
									if(ts->exists($1) != 1)
									{
										sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata ", @1.first_line, @1.first_column, $1);
										syyerror(msg);
										YYERROR;
									}
									else
									{
										if(Is_write==1&&Is_read==0)
										{
											if(ts->getValue($1)!=1)
											{
												sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este initializata ", @1.first_line, @1.first_column, $1);
												syyerror(msg);
												YYERROR;
											}
										}
										else
												if(Is_write==0&&Is_read==1)
												{
													ts->setValue($1,1);
												}
									}
								}
								else
									{
										sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata ", @1.first_line, @1.first_column, $1);
										syyerror(msg);
										YYERROR;
									}
							}
						}

					|
					id_list ',' TOK_VARIABLE
					{
						if(Is_read!=1 && Is_write!=1)
						{
							if(ts != NULL)
							{
								if(ts->exists($3) == 1)
								{
									sprintf(msg,"%d:%d Eroare semantica: Variabila %s este declarata deja", @1.first_line, @1.first_column, $3);
									syyerror(msg);
									YYERROR;
								}
								else
								{
									ts->add($3);
								}
							}
							else
								{
									ts = new TVAR();
									ts->add($3);
								}
							}
							else
							{
								if(ts != NULL)
								{
									if(ts->exists($3) != 1)
									{
										sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata ", @1.first_line, @1.first_column, $3);
										syyerror(msg);
										YYERROR;
									}
									else
									{
										if(Is_write==1&&Is_read==0)
										{
											if(ts->getValue($3)!=1)
											{
												sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este initializata ", @1.first_line, @1.first_column, $3);
												syyerror(msg);
												YYERROR;
											}
										}
										else
												if(Is_write==0&&Is_read==1)
												{
													ts->setValue($3,1);
												}

									}
								}
								else
									{
										sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata ", @1.first_line, @1.first_column, $3);
										syyerror(msg);
										YYERROR;
									}
							}

					}
					;
stmt_list: stmt
					|
					stmt_list ';' stmt
					;
stmt 		: assign
 					|
					read
					|
					write
					|
					for
					;
assign	: TOK_VARIABLE TOK_ASSIGN exp
					{
					if(ts != NULL)
					{
							if(ts->exists($1) != 1)
							{
								sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu e declarata!", @1.first_line, @1.first_column, $1);
								syyerror(msg);
								YYERROR;
							}
							else
							{
								ts->setValue($1,1);
							}
						}
					else
					{
						sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu e declarata!", @1.first_line, @1.first_column, $1);
						syyerror(msg);
						YYERROR;
					}
				}
 					;
exp			: term
					|
					exp TOK_PLUS term
					|
					exp TOK_MINUS term
					;
term    : factor
				  |
					term TOK_MULTIPLY factor
					|
					term {Is_div=1;} TOK_DIVIDE factor
					{ Is_div=0; }
					;
factor 	: TOK_VARIABLE
					{
					if(ts != NULL)
					{
							if(ts->exists($1) != 1)
							{
								sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu e declarata!", @1.first_line, @1.first_column, $1);
								syyerror(msg);
								YYERROR;
							}
							else
							{
								if(ts->getValue($1)!=1)
								{
									sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu e initializata", @1.first_line, @1.first_column, $1);
									syyerror(msg);
									YYERROR;
								}
								else
								{
									if(Is_div==1)
									{
										if(ts->getValue($1)==0)
										{
											sprintf(msg,"%d:%d Eroare semantica: NU se poate imparti la 0", @1.first_line, @1.first_column);
											syyerror(msg);
											YYERROR;
										}
									}
								}
							}
						}
					else
					{
						sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu e declarata!", @1.first_line, @1.first_column, $1);
						syyerror(msg);
						YYERROR;
					}
					}
 					|
					TOK_NUMBER
					{
						if(Is_div==1)
						{
							if($1==0)
							{
								sprintf(msg,"%d:%d Eroare semantica: NU se poate imparti la 0", @1.first_line, @1.first_column);
								syyerror(msg);
								YYERROR;
							}
						}
					}
					|
					TOK_LEFT exp TOK_RIGHT
					;
read 		: TOK_READ {Is_read=1;} TOK_LEFT id_list TOK_RIGHT
					{ Is_read=0; }
					;
write   : TOK_WRITE {Is_write=1;} TOK_LEFT id_list TOK_RIGHT
					{Is_write=0;}
					;
for			: TOK_FOR index_exp TOK_DO body
					;
index_exp   :  TOK_VARIABLE TOK_ASSIGN exp TOK_TO exp
						{
						if(ts != NULL)
						{
								if(ts->exists($1) != 1)
								{
									sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu e declarata!", @1.first_line, @1.first_column, $1);
									syyerror(msg);
									YYERROR;
								}
								else
								{
									ts->setValue($1,1);
								}
							}
						else
						{
							sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu e declarata!", @1.first_line, @1.first_column, $1);
							syyerror(msg);
							YYERROR;
						}
						}
						;
body			:	stmt
						|
						TOK_BEGIN stmt_list TOK_END
						;



%%

int main()
{
	yyparse();

	if(EsteCorecta == 1)
	{
		printf("CORECTA\n");
	}

       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s at %d->%d  \n", msg,lineNo,colNo-1);
	return 1;
}


int syyerror(const char *msg)
{
	printf("Error: %s   \n", msg);
	return 1;
}

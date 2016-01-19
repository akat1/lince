Lince - ~prolog interpreter wannabe

1. Grammar:

program: clause program | target program | EOF                                   
target: ARROW structures DOT
clause: structure DOT | structure ARROW structures DOT
structure: SYMBOL | SYMBOL LPAREN structures RPAREN | VARIABLE
structures: structure | structure COMMA structures
commandline: structures DOT EOL

2. Install:

$ cd src/
$ make

3. Usage:

./lince [database files]

4. Example usage:

$ ./lince ../test/test.pro 
Lince (~prolog interpreter) version 0.1
Building database...
Parsing ../test/test.pro
Done!

Database:
eq(X,X,) :- 

?- eq(X, test).
yes
X -> test
Accept? (yes/no) yes
X -> test
?- eq(X, test), eq(X, Y), eq(Y, Z), eq(Z, test).
yes
X -> test
Y -> test
Z -> test
Accept? (yes/no) no
no
?- 

5. Contact

E-mail: shm [at] digitalsun [dot] pl

6. Licence

This software is released under the beerware licence.
( Borrowed from FreeBSD code )

<shm@digitalsun.pl> wrote this file. As long as you retain this notice you
can do whatever you want with this stuff. If we meet some day, and you think
this stuff is worth it, you can buy me a beer in return. :)

							Mateusz Kocielski


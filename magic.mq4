#define EMPTYSTRING     ""
#define EAIDMIN         1
#define EAIDMAX         21473


  //+------------------------------------------------------------------+
//
int iMakeHash (string s1, string s2=EMPTYSTRING, string s3=EMPTYSTRING, string s4=EMPTYSTRING, string s5=EMPTYSTRING
              ,string s6=EMPTYSTRING, string s7=EMPTYSTRING, string s8=EMPTYSTRING, string s9=EMPTYSTRING, string s10=EMPTYSTRING)
{
  /*
  Produce 32bit string hash code from  a string composed of up to TEN concatenated input strings.
  WebRef: http://www.cse.yorku.ca/~oz/hash.html
  KeyWrd: "djb2"
  FirstParaOnPage:
  "  Hash Functions
    A comprehensive collection of hash functions, a hash visualiser and some test results [see Mckenzie
    et al. Selecting a Hashing Algorithm, SP&E 20(2):209-224, Feb 1990] will be available someday. If
    you just want to have a good hash function, and cannot wait, djb2 is one of the best string hash
    functions i know. it has excellent distribution and speed on many different sets of keys and table
    sizes. you are not likely to do better with one of the "well known" functions such as PJW, K&R[1],
    etc. Also see tpop pp. 126 for graphing hash functions.
  "

  NOTES:
  0. WARNING - mql4 strings maxlen=255 so... unless code changed to deal with up to 10 string parameters
     the total length of contactenated string must be <=255
  1. C source uses "unsigned [char|long]", not in MQL4 syntax
  //
  Downside?
    original code uses UNSIGNED - MQL4 not support this, presume could use type double and then cast back to type int.
  */
  string s = StringConcatenate(s1,s2,s3,s4,s5,s6,s7,s8,s9,s10);
  int iHash = 5381;
  int iLast = StringLen(s)-1;
  int iPos=0;

  while( iPos <= iLast )    //while (c = *str++)  [ consume str bytes until EOS hit {isn't C concise!} ]
  {
    //original C code: hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
    iHash = ((iHash << 5) + iHash) + StringGetChar(s,iPos);    //StringGetChar() returns int
    iPos++;
  }
  return(MathAbs(iHash));
  
}//iMakeHash()




  //+------------------------------------------------------------------+
//
int iMakeExpertId ()
{
  int i1a,i2a,i1b,i2b;
  int iExpertId = EAIDMAX+1;
  while(iExpertId<EAIDMIN || iExpertId>EAIDMAX)
  {
    i1a=TimeLocal(); i2a=GetTickCount();
    Sleep(500);
    i1b=TimeLocal(); i2b=GetTickCount();
    MathSrand(iMakeHash(Symbol()
                        ,DoubleToStr(Period(),Digits)
                        ,DoubleToStr(i2a*WindowBarsPerChart()/Period(),Digits-1)
                        ,DoubleToStr(WindowTimeOnDropped()/i2b,Digits+1)
                        ,StringConcatenate(i2a/Period()
                                          ,Symbol()
                                          ,Period()
                                          ,i1a
                                          ,i2b*WindowBarsPerChart()/Period()
                                          ,i1b/WindowBarsPerChart()
                                          ,WindowTimeOnDropped()
                                          )
                        )
              );

    iExpertId = MathRand();  //here, on 2nd rand call, is even btr (tests seem to say this...)
  }

  return(iExpertId);

}
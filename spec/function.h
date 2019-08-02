/* Declaration with static storage class specifier */
extern int max(int a, int b);

/* Return type is pointer to array of 3 int */
int (*foo(const void *p))[3]; 

/* Declares function of type double(void) */
static double const check(void) { return 0.; } 

/* Inline function */
inline int sum(int a, int b) 
{
        return a + b;
}

/* Declaration with definition */
int increment(int a){  
        a++;
        return a;
}

/* Function declaration that contains an anonymous struct definition */
struct { int a; } foo(void);
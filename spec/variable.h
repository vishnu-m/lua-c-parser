/* Declaration with storage class specifier */
static int list[20]; 

int *aptr[10]; // Declares an array of 10 pointers

/* Struct declaration */
struct st1 {
        int a;
};

/* Struct variable declaration and initialisation */
struct st1 st1_instance = {10};

/* Union declaration along with simultaneous union variable declaration */
union un1 {
        char *s;
}un1_instance;
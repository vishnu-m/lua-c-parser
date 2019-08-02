typedef void DRAWF( int, int );

typedef struct club
{
        char name[30];
        int size, year;
} GROUP;

typedef GROUP *PG;

typedef char char_t, *char_p, (*fp)(void);
/* Ordinary union */
union check {
        const int x, y;
};

/* Unnamed union */
union {
        const int a;
}u1;

/* Union containing Struct */

union un2 {
        struct st1 {
                double b;
        };
        char *s;
};

/* Unnamed union enclosing unnamed struct containing bit fields */
union {                   
        struct {
                unsigned int icon : 8;
                unsigned color : 4;
        } window1;
        int screenval;
}screen[25][80];

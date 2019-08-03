/* Ordinary struct */
struct coordinates {
        int x,y;
};

/* Struct with enum declaration inside */
struct rainbow {
        enum Fruit{Violet, Indigo, Blue, Green, Yellow, Red};
        enum Fruit field1;
};

/* Anonymous struct */
struct {
        char alpha;
        int num;
} var;

/* Nested Struct */
struct Student {
        struct marks{
                int physics;        
        }m1, m2;
        struct Student *pointer;
        struct Student **double_pointer;
}; 

/*Function pointer */
struct mycallback {
        int (*f)(int);
};

/* Bit fields */
struct bits {
        int x: 5;
        int y: 1;
        int z: 2;
};

/* Forward declaration */
struct context;

struct funcptrs{
        struct context *ctx;
};

struct context{
        struct funcptrs fps;
}; 

/* Struct containing named union */
struct st1 {
        float b;
        union u1 {
                struct {
                        int a;
                }svar1;
        }uvar1;
};

/* Struct containing unnamed union */
struct st2 {
	union {
		int a;
	}u;
	int b;
};
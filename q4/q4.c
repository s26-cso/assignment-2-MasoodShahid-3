#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
int main() {
    char op[6];
    int a,b;
    char cur[6] = "";
    void *lib = NULL;
    char path[32];
    int(*func)(int,int)=NULL;
    while (scanf("%5s %d %d", op, &a, &b)==3){
        if (strcmp(op,cur)!=0){
            if(lib!=NULL) dlclose(lib);
            lib=NULL;
            func=NULL;
            snprintf(path,sizeof(path),"./lib%s.so",op);
            lib=dlopen(path,RTLD_LAZY);
            if(lib!=NULL){
                func=(int(*)(int,int))dlsym(lib, op);
                if(func!=NULL){
                    strcpy(cur,op);
                }else{
                    dlclose(lib);
                    lib=NULL;
                    cur[0] = '\0';
                }
            } else{
                cur[0]='\0';
            }
        }
        if(func!=NULL){
            printf("%d\n", func(a, b));
            fflush(stdout);
        }
    }
    if(lib!=NULL){
        dlclose(lib);
    }
    return 0;
}
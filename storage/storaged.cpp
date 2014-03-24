/*
this shit on ubuntu needs: libmysqlcppconn-dev
compile by(on ubuntu ofc): g++ -Wall -I/usr/include/cppconn <my name> -L/usr/lib -lmysqlcppconn
on Gentoo, emerge dev-db/mysql-connector-c++ before compiling
*/

/* Standard C++ headers */
#include <cstdio>
#include <iostream>
#include <sstream>
#include <memory>
#include <string>
#include <stdexcept>
#include <map>
#include <stdlib.h>
#include <time.h>

/* MySQL Connector/C++ specific headers */
#include <driver.h>
#include <connection.h>
#include <statement.h>
#include <prepared_statement.h>
#include <resultset.h>
#include <metadata.h>
#include <resultset_metadata.h>
#include <exception.h>
#include <warning.h>

/* 7z */
#include<unistd.h>
#include <sys/wait.h>

#define COLNAME 200
#define LL long long
#define _kurwa

using namespace std;
using namespace sql;

//config variables
std::map < std::string, std::map < std::string, std::string > > CONFIG;

//configurations
int load_config_file();

//metadata loading functions
string load_line();
string load_word();

//helping functions
static void retrieve_data_and_print (ResultSet *, int);
bool are_strings_equal(string, string);
string get_random_string(int);
void scan_to_file(int /*size*/, string /*path*/);
void print_from_file(string /*path*/);

//mysql main function
void execute_mysql_request();

//file handling
void download_file_init();
void send_file_init();
void remove_file();

//7zip handling
void download_7z_init();
void send_7z_init();
void add_file_to_7z();
void remove_7z();

int main(int argc, const char *argv[]) {

    if(load_config_file()==1) {
        cout << "Error parsing file!";
        return 1;
    }
    //retrieving queries
    string Request;
    Request=load_word();
    if(are_strings_equal(Request,"DATABASE")) {
        execute_mysql_request();
    } else if(are_strings_equal(Request,"FILE")) {
        Request=load_word();
        if(are_strings_equal(Request,"SEND")) {
            download_file_init();
        } else if(are_strings_equal(Request,"TAKE")) {
            send_file_init();
        } else if(are_strings_equal(Request,"REMOVE")) {
            remove_file();
        } else {
            cout<<"ERROR - Wrong request";
        }
    } else if(are_strings_equal(Request,"7Z")) {
        Request=load_word();
        if(are_strings_equal(Request,"SEND")) {
            download_7z_init();
        } else if(are_strings_equal(Request,"TAKE")) {
            send_7z_init();
        } else if(are_strings_equal(Request,"REMOVE")) {
            remove_7z();
        } else if(are_strings_equal(Request,"UPDATE")) {
            add_file_to_7z();
        } else {
            cout<<"ERROR - Wrong request";
        }
    } else {
        cout<<"ERROR - Wrong request";
    }
    Request=load_word();

}

int load_config_file() {

    FILE * pFile;
    int c;
    string actsection;
    string actname;
    string loading;
    pFile=fopen ("config.ini","r");
    if (pFile==NULL)
        return 1;
    else {
        do {
            c = getc (pFile);
            if(c=='[') {
                loading="";
                c=getc(pFile);
                while(c!=']') {
                    loading+=c;
                    c=getc(pFile);
                }
                actsection=loading;
            } else if((c>='a' and c<='z') or (c>='A' and c<='Z')) {
                loading="";
                while(c!=' ' and c!='=') {
                    loading+=c;
                    c=getc(pFile);
                }
                actname=loading;
                while(c==' ')c=getc(pFile);
                loading="";
                c=getc(pFile);
                while(c!='\n' and c!=' ') {
                    loading+=c;
                    c=getc(pFile);
                }
                CONFIG[actsection][actname]=loading;
            }
        } while (c != EOF);
        fclose (pFile);
    }

    return 0;

}

string load_line() {

    string s;
    char c=getchar_unlocked();
    while( c>=32 && c<=126 ) {
        s+=c;
        c=getchar_unlocked();
    }
    return s;

}

string load_word() {

    string s;
    char c=getchar_unlocked();
    while( c>=32 && c<=126 && c!=' ' ) {
        if(c==EOF)return "EOF";
        s+=c;
        c=getchar_unlocked();
    }
    return s;
}

static void retrieve_data_and_print (ResultSet *rs, int colidx) {

    printf("NumberOfRows %d\n",(int)rs -> rowsCount());
    while (rs->next()) {
        cout << rs -> getString(colidx) << endl;
    }

    cout << endl;

}

bool are_strings_equal(string s1, string s2) {

    if(s1.compare(s2)==0) {
        return true;
    }
    else {
        return false;
    }
}

void execute_mysql_request() {

    try {
        Driver *driver = get_driver_instance();
        Connection *con = driver -> connect(CONFIG["mysql"]["dbhost"], CONFIG["mysql"]["user"], CONFIG["mysql"]["password"]);
        con -> setAutoCommit(1);
        con -> setSchema(CONFIG["mysql"]["database"]);
        Statement *stmt = con -> createStatement();
        string Query;
        Query = load_line();
        ResultSet *res;
        res = stmt -> executeQuery (Query.c_str());
        retrieve_data_and_print (res, 1);
        printf("EndOfResponse\n");//make sure, that there is nothing like that
    } catch (SQLException &e) {
        cout << "ERROR: SQLException in " << __FILE__;
        cout << " (" << __func__<< ") on line " << __LINE__ << endl;
        cout << "ERROR: " << e.what();
        cout << " (MySQL error code: " << e .getErrorCode();
        cout << ", SQLState: " << e.getSQLState() << ")" << endl;

        if (e.getErrorCode() == 1047) {
            /*
            Error: 1047 SQLSTATE: 08S01 (ER_UNKNOWN_COM_ERROR)
            Message: Unknown command
            */
            cout << "\nYour server does not seem to support Prepared Statements at all. ";
            cout << "Perhaps MYSQL < 4.1?" << endl;
        }

    } catch (std::runtime_error &e) {

        cout << "ERROR: runtime_error in " << __FILE__;
        cout << " (" << __func__ << ") on line " << __LINE__ << endl;
        cout << "ERROR: " << e.what() << endl;

    }

}

void print_from_file(string path) {

    char buffer[256];
    FILE *file;
    if( (file=fopen(path.c_str(),"r")) == NULL )
        fprintf( stderr, "Could not open file \"%s\"\n", path.c_str() );
    else {
        while( fgets(buffer,sizeof buffer,file) ) {
            printf( "%s", buffer );
        }
        fclose( file );
    }
    
}

void dumphex(unsigned char * bytes, int size){
    for(int i=0;i<size;i+=2)
    {
        printf("%02x", bytes[i+1]);
        printf("%02x ", bytes[i]);
    }
    printf("\n");
}

void scan_to_file(int size, string path) {

    FILE *file;
    file = fopen(path.c_str(), "ab");
    unsigned char * c=new unsigned char[size];
    //for(int i=0;i<size;i++)
    //    c[i]=getchar_unlocked();
    for(int i=0;i<size;i++){
        int wyn = fread(c+i, 1, 1, stdin);
    }
    //printf("%d ",wyn);
    dumphex(c,size);
    fclose(file);
    delete [] c;
}

//file handling
void download_file_init() {

    int size;
    string name;
    name=load_word();
    size=atoi(load_word().c_str());
    string path=CONFIG["paths"]["files"]+name;
    scan_to_file(size, path);

}

void send_file_init() {

    string name;
    name=load_word();
    print_from_file(CONFIG["paths"]["files"]+name);

}

void remove_file() {

    remove((CONFIG["paths"]["files"]+load_word()).c_str());

}

//7zip handling
void download_7z_init() {

    int size;
    string name;
    name=load_word();
    size=atoi(load_word().c_str());
    string path=CONFIG["paths"]["archives"]+name;
    scan_to_file(size, path);

}

void send_7z_init() {

    string name;
    name=load_word();
    print_from_file(CONFIG["paths"]["archives"]+name);

}

void add_file_to_7z() {

    int size;
    string filename,archivename;
    archivename=load_word();
    filename=load_word();
    size=atoi(load_word().c_str());
    string filepath=CONFIG["paths"]["tmp"]+filename+".gz";    
    string archivepath=CONFIG["paths"]["archives"]+archivename;
    scan_to_file(size, filepath);
    
    int pid = 0;
    pid = fork();
    if (pid==0) {
        execl("/bin/gzip", "gzip", "-d", filepath.c_str(), (char *)NULL); 
    }else{
        int pochujmitazmienna;
        waitpid(pid, &pochujmitazmienna, 0);
        filepath=CONFIG["paths"]["tmp"]+filename;
        pid=0;
        pid = fork();
        if (pid==0) {
            //execl("/usr/bin/7z", "7z", "a", archivepath.c_str(), filepath.c_str(), (char *)NULL); 
        }else{
            waitpid(pid, &pochujmitazmienna, 0);
            remove(filepath.c_str());
        }
    }
    
}

void remove_7z() {

    remove((CONFIG["paths"]["archives"]+load_word()).c_str());

}

string get_random_string(int len) {

    string s;
    srand(time(NULL));
    char alphanum[] =
        "0123456789"
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz";

    for (int i = 0; i < len; ++i) {
        s += alphanum[rand() % (sizeof(alphanum) - 1)];
    }

    return s;

}


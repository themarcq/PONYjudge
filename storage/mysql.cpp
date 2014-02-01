/*
this shit on ubuntu needs: libmysqlcppconn-dev
compile by(on ubuntu ofc): g++ -Wall -I/usr/include/cppconn <my name> -L/usr/lib -lmysqlcppconn
*/

/* Standard C++ headers */
#include <cstdio>
#include <iostream>
#include <sstream>
#include <memory>
#include <string>
#include <stdexcept>
#include <map>

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

#define COLNAME 200

using namespace std;
using namespace sql;

//config variables
string DBHOST;
string USER;
string PASSWORD;
string DATABASE;

//configurations
int load_config_file();

//metadata loading functions
string load_line();
string load_word();

//mysql help functions
static void retrieve_data_and_print (ResultSet *, int);
bool are_strings_equal(string, string);

//mysql main function
void execute_mysql_request(Statement *);

//file handling
void load_file();
void send_file();

//7zip handling
void load_7z();
void send_7z();
void load_file_to_7z();

int main(int argc, const char *argv[]) {

    if(load_config_file()==1) {
        cout << "Error parsing file!";
        return 1;
    }
    Driver *driver;
    Connection *con;
    Statement *stmt;

    try {
        driver = get_driver_instance();
        con = driver -> connect(DBHOST, USER, PASSWORD);
        con -> setAutoCommit(1);
        con -> setSchema(DATABASE);
        stmt = con -> createStatement();

        //retrieving queries
        string Request;
        Request=load_word();
        while(!are_strings_equal(Request,"END")) {
            if(are_strings_equal(Request,"DATABASE")) {
                execute_mysql_request(stmt);
            } else if(are_strings_equal(Request,"FILE")) {
                Request=load_word();
                if(are_strings_equal(Request,"SEND")) {
                    load_file();
                } else if(are_strings_equal(Request,"TAKE")) {
                    send_file();
                } else {
                    cout<<"ERROR - Wrong request";
                }
            } else if(are_strings_equal(Request,"7Z")) {
                Request=load_word();
                if(are_strings_equal(Request,"SEND")) {
                    load_7z();
                } else if(are_strings_equal(Request,"TAKE")) {
                    send_7z();
                } else if(are_strings_equal(Request,"UPDATE")) {
                    load_file_to_7z();
                } else {
                    cout<<"ERROR - Wrong request";
                }
            } else {
                cout<<"ERROR - Wrong request";
            }
            Request=load_word();
        }

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

        return EXIT_FAILURE;
    } catch (std::runtime_error &e) {

        cout << "ERROR: runtime_error in " << __FILE__;
        cout << " (" << __func__ << ") on line " << __LINE__ << endl;
        cout << "ERROR: " << e.what() << endl;

        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}

int load_config_file() {

    std::map < std::string, std::map < std::string, std::string > > vars;
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
                vars[actsection][actname]=loading;
                //printf("[%s]|%s|=|%s|\n",actsection.c_str(),actname.c_str(),loading.c_str());
            }
        } while (c != EOF);
        fclose (pFile);
    }

    DBHOST=vars["mysql"]["dbhost"];
    USER=vars["mysql"]["user"];
    PASSWORD=vars["mysql"]["password"];
    DATABASE=vars["mysql"]["database"];

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

void execute_mysql_request(Statement *stmt) {

    string Query;
    Query = load_line();
    ResultSet *res;
    res = stmt -> executeQuery (Query.c_str());
    retrieve_data_and_print (res, 1);
    printf("EndOfResponse\n");

}

//file handling
void load_file() {}
void send_file() {}

//7zip handling
void load_7z() {}
void send_7z() {}
void load_file_to_7z() {}

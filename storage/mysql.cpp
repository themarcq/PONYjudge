/* Standard C++ headers */
#include <cstdio>
#include <iostream>
#include <sstream>
#include <memory>
#include <string>
#include <stdexcept>

/* MySQL Connector/C++ specific headers */
/*
this shit on ubuntu needs: libmysqlcppconn-dev
compile by(on ubuntu ofc): g++ -Wall -I/usr/include/cppconn <my name> -L/usr/lib -lmysqlcppconn
*/
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

string load_line(){

    string s;
    int i=0;
    char c=getchar_unlocked();
    while( c>=32 && c<=126 ){
        s[i++]=c;
        c=getchar_unlocked();
    }
    s[i++]=0;
    return s;

}

string load_word(){

    string s;
    int i=0;
    char c=getchar_unlocked();
    while( (c<='Z' && c>='A') || (c<='z' && c>='a') || (c<='9' && c>='0') ){
        s[i++]=c;
        c=getchar_unlocked();
    }
    s[i++]=0;
    return s;
}

static void retrieve_data_and_print (ResultSet *rs, int colidx) {

    /* retrieve the row count in the result set */
    printf("NumberOfRows %d\n",(int)rs -> rowsCount());
    while (rs->next()) {
            cout << rs -> getString(colidx) << endl;
    } // while

    cout << endl;

} // retrieve_data_and_print()

int main(int argc, const char *argv[]) {


    //to trza wczytać z pliku
    char DBHOST[255]="tcp://127.0.0.1:3306";
    char USER[255]="root";
    char PASSWORD[255]="alleluja1";
    char DATABASE[255]="lol";

    Driver *driver;
    Connection *con;
    Statement *stmt;
    ResultSet *res;
    PreparedStatement *prep_stmt;

    /* initiate url, user, password and database variables */
    string url(argc >= 2 ? argv[1] : DBHOST);
    const string user(argc >= 3 ? argv[2] : USER);
    const string password(argc >= 4 ? argv[3] : PASSWORD);
    const string database(argc >= 5 ? argv[4] : DATABASE);

    try {
        driver = get_driver_instance();
        con = driver -> connect(url, user, password);
        con -> setAutoCommit(1);
        con -> setSchema(database);
        stmt = con -> createStatement();

        //retrieving queries
        string Request;
        Request=load_word();
        cout<<Request;
        while(Request!="EOF") {
            if(Request.compare("DATABASE")) {
                string Query;
                Query = load_line();
                res = stmt -> executeQuery (Query.c_str());
                retrieve_data_and_print (res, 1);
            } else if(Request.compare("FILE")) {
                //check what is it ( take or send file )
            } else if(Request.compare("7Z")) {
                //7z requests
            } else {
                cout<<"ERROR - Wrong request";
            }
            Request=load_word();
        }
        /* Clean up */
        delete res;
        delete stmt;
        delete prep_stmt;
        con -> close();
        delete con;

    } catch (SQLException &e) {
        cout << "ERROR: SQLException in " << __FILE__;
        cout << " (" << __func__<< ") on line " << __LINE__ << endl;
        cout << "ERROR: " << e.what();
        cout << " (MySQL error code: " << e.getErrorCode();
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
} // main()

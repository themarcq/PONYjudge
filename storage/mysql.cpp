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
#define NUMOFFSET 100
#define COLNAME 200

using namespace std;
using namespace sql;

string load_line(){

    string s;
    int i=0;
    char c=getchar();
    cout<<c;
    do{
        s[i++]=c;
        c=getchar();
        cout<<c;
    }while(c!='\n')
    return s;

}

static void retrieve_data_and_print (ResultSet *rs, int type, int colidx, string colname) {

    /* retrieve the row count in the result set */
    printf("NumberOfRows %d\n",(int)rs -> rowsCount());
    while (rs->next()) {
        if (type == NUMOFFSET) {
            cout << rs -> getString(colidx) << endl;
        } else if (type == COLNAME) {
            cout << rs -> getString(colname) << endl;
        } // if-else
    } // while

    cout << endl;

} // retrieve_data_and_print()

int main(int argc, const char *argv[]) {


    //to trza wczytać z pliku
    char * DBHOST="tcp://127.0.0.1:3306";
    char * USER="root";
    char * PASSWORD="haslo";
    char * DATABASE="lol";

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
        while(cin>>Request) {
            if(Request.compare("DATABASE")) {
                string Query;
                Query = load_line();
                cout << Query;
                res = stmt -> executeQuery (Query);
                retrieve_data_and_print (res, NUMOFFSET, 1, string("*"));
            } else if(Request.compare("FILE")) {
                //check what is it ( take or send file )
            } else if(Request.compare("7Z")) {
                //7z requests
            } else {
                cout<<"ERROR - Wrong request";
            }
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

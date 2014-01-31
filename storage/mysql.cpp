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
    char c=getchar_unlocked();
    while( c>=32 && c<=126 ){
        s+=c;
        c=getchar_unlocked();
    }
    return s;

}

string load_word(){

    string s;
    char c=getchar_unlocked();
    while( c>=32 && c<=126 && c!=' ' ){
        if(c==EOF)return "EOF";
        s+=c;
        c=getchar_unlocked();
    }
//    printf("|%s|",s.c_str());
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

bool are_strings_equal(string s1, string s2){
//printf("comparing |%s| and |%s| ",s1.c_str(),s2.c_str());
    if(s1.compare(s2)==0){
//        printf("equal\n");
        return true;
    }
    else{
//        printf("not equal\n");
        return false;
    }
    /*for(int i=0;s1[i]!=0 and s2[i]!=0;i++)
        if(s1[i]!=s2[i])
            return false;
    return true;*/
}

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
        while(!are_strings_equal(Request,"END")) {
            if(are_strings_equal(Request,"DATABASE")) {
                string Query;
                Query = load_line();
                res = stmt -> executeQuery (Query.c_str());
                retrieve_data_and_print (res, 1);
                printf("EndOfResponse\n");
            } else if(are_strings_equal(Request,"FILE")) {
                //check what is it ( take or send file )
                //then take its name, size, md5sum, chmods(optionally) and whatever we want
                //wait for characteristic beggining and load till reaching destinated size and characteristic end(we can chat if everything is ok)
                //check hash, save if good and throw prompt
            } else if(are_strings_equal(Request,"7Z")) {
                //everything same as is in file
                //but with adding subfiles to existing directories
                //and we can skip compressing
            } else {
                cout<<"ERROR - Wrong request";
            }
            Request=load_word();
        }
        
        /* Clean up */

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
} // main()

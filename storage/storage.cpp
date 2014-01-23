#include<iostream>
using namespace std;

main() {

    string Request;
    while(cin>>Request) {
        if(Request.equals('DATABASE')) {
//send rest of the request to mysql
        } else if(Request.equals('FILE')) {
//check what is it ( take or send file )
        } else if(Request.equals('7Z')) {
//7z requests
        } else {
            cout<<"ERROR - Wrong request";
        }
    }

}

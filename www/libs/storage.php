<?

class storage {

    public function connect() {
        global $GLOBALS;
        return mysql_connect($GLOBALS->StorageHost,'root',$GLOBALS->StoragePassword);
    }
    
    public function mysql_query($s){
        return mysq_query($s);//vurnerability!
    }

    public function disconnect() {
        mysql_close();
    }

}

?>

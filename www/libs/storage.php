<?

class storage {

    public function connect() {
        global $GLOBALS;
        return mysql_connect($GLOBALS->StorageHost,'root',$GLOBALS->StoragePassword);
    }

    public function disconnect() {
        mysql_close();
    }

}

?>

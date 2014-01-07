<?

class storage {

    public function connect() {
        global $GLOBALS;
        //return mysql_connect($GLOBALS->StorageHost,'root',$GLOBALS->StoragePassword);
    }
    
    public function mysql_query($query){
        return mysq_query($query);//vurnerability!
    }
    
    public function file_query($query){
        
    }
    
    public function file_transfer($file){
    
    }

    public function disconnect() {
        //mysql_close();
    }

}

?>

<?

class storage {

    public function connect($G) {
       return mysql_connect($G->storagehost,'root',$G->storagepassword);
    }

    public function disconnect(){
        mysql_close();
    }

}

?>

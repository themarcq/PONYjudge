<?

class user {

    public function auth() {
        global $STORAGE;
        if(!isSet($_COOKIE['id'])) {
            $this->logged = false;
            $this->nick = 'anon';
        } else {
            $result=$storage->querySql('SELECT');
        }
    }

}

?>

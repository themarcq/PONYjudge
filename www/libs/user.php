<?

class user{

    public function auth($S){
        if(!isSet($_COOKIE['id'])){
            $this->logged = false;
            $this->nick = 'anon';
        }else{
            $result=$S->query_sql('SELECT');
        }
    }

}

?>

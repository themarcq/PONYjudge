<?

class globals {

    public function load_config($file) {
        $arr=parse_ini_file($file);
        foreach($arr as $key => $value)
        {
            $this->$key = $value;
            echo $key.$value;
        }
    }

}

?>

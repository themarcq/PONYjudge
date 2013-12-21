<?

class globals {

    public function loadConfig($file) {
        $arr=parse_ini_file($file);
        foreach($arr as $key => $value)
        {
            $this->$key = $value;
        }
    }

    public function loadUrl() {
        if(isSet($_GET['page']))
            $this->RequestedPage=$_GET['page'];
        else
            $this->RequestedPage='news';
    }

}

?>

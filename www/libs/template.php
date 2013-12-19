<?

class template{
    public $errors;
    public $errors_number=0;
    public $menus;
    public function show(){
        global $globals;
        echo'
        <html>
            <head>
                <title>'.$globals->websitetitle.'</title>
                <link href="styles/style.css" rel="stylesheet" type="text/css" />
            </head>
            <body>
                <div id="header">head</div>
                <div id="menu">
        ';
        foreach($this->menus as $title => $url){
            echo '<div id="menuitem"><a href="'.$url.'">'.$title.'</a></div>';
        } 
        echo '  </div>
                <div id="container">
       ';
        foreach($this->errors as $error){
            echo '<div id="error">'.$error.'</div>';
        }    
        echo'
                </div>
            </body>
        </html
        ';
    }
    
    public function show_error($s){
        $this->errors[$this->errors_number++]=$s;
    }
    
    public function show_menu_item($title,$url){
        $this->menus[$title]=$url;
    }
    
}

?>

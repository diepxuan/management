<?php

/*
 * Server ping host
 */
if( !function_exists('ping') ) :
function ping($host, $port = 3306, $timeout = 2) {
  $fsock = fsockopen($host, $port, $errno, $errstr, $timeout);
  if ( ! $fsock ) {
    return FALSE;
  } else {
    return TRUE;
  }
}
endif;

/*
 * Servers configuration
 */
$i = 0;

$cfg['blowfish_secret'] = '51Lhp+H8YGJ2MgLaQZXpB$U$aIB+^f%20fVy';
$cfg['Lang'] = '';

/*
 * Localhost
 */
if( ping('localhost') ) {
  $i++;
  $cfg['Servers'][$i]['host']             = 'localhost';
  $cfg['Servers'][$i]['auth_type']        = 'config';
  $cfg['Servers'][$i]['user']             = 'sa';
  $cfg['Servers'][$i]['password']         = '877611';
  $cfg['Servers'][$i]['AllowNoPassword']  = true;
  $cfg['Servers'][$i]['extension']        = 'mysqli';
}

/*
 * Gss localhost (Magento)
 */
if( ping('192.168.1.190') ) {
  $i++;
  $cfg['Servers'][$i]['host']             = '192.168.1.190';
  $cfg['Servers'][$i]['auth_type']        = 'config';
  $cfg['Servers'][$i]['user']             = 'dev';
  $cfg['Servers'][$i]['password']         = 'dev@gss';
  $cfg['Servers'][$i]['AllowNoPassword']  = true;
  $cfg['Servers'][$i]['extension']        = 'mysqli';
}

/*
 * Remote master server
 */
if ($_SERVER["REMOTE_ADDR"] == "127.0.0.1") {

  if( ping('mysql.diepxuan.vn') ) {
    $i++;
    $cfg['Servers'][$i]['host']             = 'mysql.diepxuan.vn';
    $cfg['Servers'][$i]['auth_type']        = 'config';
    $cfg['Servers'][$i]['user']             = 'sa';
    $cfg['Servers'][$i]['password']         = '877611';
    $cfg['Servers'][$i]['AllowNoPassword']  = true;
    $cfg['Servers'][$i]['extension']        = 'mysqli';
  }

}

/**
 * Register phpmyadmin database for server
 */
for ($svr = 1; $svr <= $i; $svr++) {
  /* Advanced phpMyAdmin features */
  $cfg['Servers'][$svr]['controlhost']      = 'mysql.diepxuan.vn';
  $cfg['Servers'][$svr]['controlport']      = '3306';
  $cfg['Servers'][$svr]['controluser']      = 'sa';
  $cfg['Servers'][$svr]['controlpass']      = '877611';

  /* Storage database and tables */
  $cfg['Servers'][$svr]['pmadb']            = 'phpmyadmin'; //the name of my db table
  $cfg['Servers'][$svr]['bookmarktable']    = 'pma__bookmark'; //does the pma__ need to change to dave1_?
  $cfg['Servers'][$svr]['relation']         = 'pma__relation';
  $cfg['Servers'][$svr]['table_info']       = 'pma__table_info';
  $cfg['Servers'][$svr]['table_coords']     = 'pma__table_coords';
  $cfg['Servers'][$svr]['pdf_pages']        = 'pma__pdf_pages';
  $cfg['Servers'][$svr]['column_info']      = 'pma__column_info';
  $cfg['Servers'][$svr]['history']          = 'pma__history';
  $cfg['Servers'][$svr]['tracking']         = 'pma__tracking';
  $cfg['Servers'][$svr]['designer_coords']  = 'pma__designer_coords';
  $cfg['Servers'][$svr]['userconfig']       = 'pma__userconfig';
  $cfg['Servers'][$svr]['users']            = 'pma__users';
  $cfg['Servers'][$svr]['usergroups']       = 'pma__usergroups';
  $cfg['Servers'][$svr]['navigationhiding'] = 'pma__navigationhiding';
  $cfg['Servers'][$svr]['savedsearches']    = 'pma__savedsearches';
  $cfg['Servers'][$svr]['central_columns']  = 'pma__central_columns';
  $cfg['Servers'][$svr]['designer_settings']= 'pma__designer_settings';
  $cfg['Servers'][$svr]['export_templates'] = 'pma__export_templates';
  $cfg['Servers'][$svr]['recent']           = 'pma__recent';
  $cfg['Servers'][$svr]['favorite']         = 'pma__favorite';
  $cfg['Servers'][$svr]['table_uiprefs']    = 'pma__table_uiprefs';
}

/*
 * End of servers configuration
 */

?>
